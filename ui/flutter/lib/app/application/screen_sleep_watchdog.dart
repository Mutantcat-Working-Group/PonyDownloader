import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as path;

import '../../api/model/task.dart' as api_task;
import '../../core/capabilities/app_capabilities.dart';
import '../../l10n/l10n.dart';
import '../../util/log_util.dart';
import '../../util/util.dart';
import 'app_runtime_controller.dart';

/// Desktop watchdog for host screen-off and sleep events.
///
/// A periodic heartbeat snapshots tasks that are running or waiting. When a
/// heartbeat arrives after a long gap (the host slept or the app was suspended
/// while the timer was stopped), the backend is asked to continue the tasks
/// that were active before the gap. The backend's continue-all semantics skip
/// tasks that are already running or done, so the recovery is idempotent.
final screenSleepWatchdogProvider = AsyncNotifierProvider<ScreenSleepWatchdog, ScreenSleepWatchdogState>(
  ScreenSleepWatchdog.new,
);

class ScreenSleepWatchdogState {
  const ScreenSleepWatchdogState({
    this.active = false,
    this.lastHeartbeatAt,
    this.lastRecoveryAt,
    this.activeTaskIds = const [],
  });

  final bool active;
  final DateTime? lastHeartbeatAt;
  final DateTime? lastRecoveryAt;
  final List<String> activeTaskIds;
}

class ScreenSleepWatchdog extends AsyncNotifier<ScreenSleepWatchdogState> {
  static const heartbeatInterval = Duration(seconds: 30);
  static const sleepGapThreshold = Duration(minutes: 2);
  static const _recoveryNotificationId = 0x504f4e59;

  ScreenSleepWatchdog({
    Future<List<api_task.Task>> Function()? listTasksOverride,
    Future<void> Function(List<String> ids)? continueTasksOverride,
    bool Function()? enabledOverride,
    DateTime Function()? nowOverride,
  }) : _listTasksOverride = listTasksOverride,
       _continueTasksOverride = continueTasksOverride,
       _enabledOverride = enabledOverride,
       _nowOverride = nowOverride;

  final Future<List<api_task.Task>> Function()? _listTasksOverride;
  final Future<void> Function(List<String> ids)? _continueTasksOverride;
  final bool Function()? _enabledOverride;
  final DateTime Function()? _nowOverride;

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  Timer? _heartbeatTimer;
  DateTime? _lastHeartbeatAt;
  List<String> _activeTaskIds = const [];
  DateTime? _lastRecoveryAt;
  bool _recovering = false;
  bool _heartbeatInFlight = false;
  bool _notificationsInitialized = false;

  @override
  Future<ScreenSleepWatchdogState> build() async {
    if (!isEnabled()) {
      return const ScreenSleepWatchdogState();
    }
    _heartbeatTimer?.cancel();
    _heartbeatTimer = Timer.periodic(heartbeatInterval, (_) => unawaited(heartbeat()));
    ref.onDispose(() => _heartbeatTimer?.cancel());
    await heartbeat();
    return snapshot();
  }

  @visibleForTesting
  bool isEnabled() {
    final override = _enabledOverride;
    if (override != null) return override();
    return !kIsWeb && Util.isDesktop();
  }

  @visibleForTesting
  DateTime nowAt() {
    final override = _nowOverride;
    return override != null ? override() : DateTime.now();
  }

  ScreenSleepWatchdogState snapshot() {
    return ScreenSleepWatchdogState(
      active: _lastHeartbeatAt != null,
      lastHeartbeatAt: _lastHeartbeatAt,
      lastRecoveryAt: _lastRecoveryAt,
      activeTaskIds: List.unmodifiable(_activeTaskIds),
    );
  }

  /// Invoked by the app lifecycle observer. Desktop runtimes do not always
  /// pause while the display sleeps, so the timer gap remains the primary
  /// trigger; this call covers explicit OS suspend/resume cycles.
  void handleLifecycleChange(AppLifecycleState state) {
    if (!isEnabled()) return;
    if (state == AppLifecycleState.resumed) {
      final last = _lastHeartbeatAt;
      if (last != null && nowAt().difference(last) >= sleepGapThreshold) {
        unawaited(recoverAfterGap());
      }
    }
  }

  Future<void> heartbeat() async {
    if (_heartbeatInFlight) return;
    _heartbeatInFlight = true;
    final now = nowAt();
    final previous = _lastHeartbeatAt;
    _lastHeartbeatAt = now;
    try {
      final tasks = await listTasks();
      _activeTaskIds = tasks
          .where((task) => task.status == api_task.Status.running || task.status == api_task.Status.wait)
          .map((task) => task.id)
          .toList(growable: false);
    } catch (error, stackTrace) {
      logger.w('screen sleep watchdog heartbeat failed', error, stackTrace);
    } finally {
      _heartbeatInFlight = false;
    }
    if (previous != null && now.difference(previous) >= sleepGapThreshold) {
      await recoverAfterGap();
    }
    state = AsyncValue.data(snapshot());
  }

  Future<void> recoverAfterGap() async {
    if (_recovering || _activeTaskIds.isEmpty || _lastHeartbeatAt == null) {
      return;
    }
    _recovering = true;
    try {
      final ids = List<String>.of(_activeTaskIds);
      final tasks = await listTasks();
      final stale = <String>[];
      final byId = {for (final task in tasks) task.id: task};
      for (final id in ids) {
        final status = byId[id]?.status;
        if (status == null ||
            (status != api_task.Status.running && status != api_task.Status.done)) {
          stale.add(id);
        }
      }
      if (stale.isEmpty) {
        logger.i('screen sleep watchdog found no interrupted tasks');
        return;
      }
      await continueTasks(stale);
      _lastRecoveryAt = nowAt();
      logger.i('screen sleep watchdog resumed ${stale.length} interrupted task(s)');
      await notifyDownloadsRecovered();
    } catch (error, stackTrace) {
      logger.w('screen sleep watchdog recovery failed', error, stackTrace);
    } finally {
      _recovering = false;
      state = AsyncValue.data(snapshot());
    }
  }

  @visibleForTesting
  Future<List<api_task.Task>> listTasks() {
    final override = _listTasksOverride;
    if (override != null) return override();
    return ref.read(ponydownloaderServiceProvider).getTasks(api_task.Status.values);
  }

  @visibleForTesting
  Future<void> continueTasks(List<String> ids) {
    final override = _continueTasksOverride;
    if (override != null) return override(ids);
    return ref.read(ponydownloaderServiceProvider).continueAllTasks(ids);
  }

  @visibleForTesting
  Future<bool> notifyDownloadsRecovered() async {
    final runtime = ref.read(appRuntimeControllerProvider).value;
    if (runtime?.downloaderConfig.extra.desktopNotification == false) return false;
    try {
      await _ensureNotificationsInitialized();
      final locale = appLocalizationsFor(runtime?.downloaderConfig.extra.locale ?? '');
      await _plugin.show(
        id: _recoveryNotificationId,
        title: locale.notificationDownloadsRecoveredTitle,
        body: locale.notificationDownloadsRecoveredBody,
        notificationDetails: NotificationDetails(
          macOS: const DarwinNotificationDetails(presentAlert: true, presentSound: false),
          linux: const LinuxNotificationDetails(),
          windows: const WindowsNotificationDetails(),
        ),
      );
      return true;
    } catch (error, stackTrace) {
      logger.w('screen sleep watchdog notification failed', error, stackTrace);
      return false;
    }
  }

  Future<void> _ensureNotificationsInitialized() async {
    if (_notificationsInitialized) return;
    String? windowsIconPath;
    try {
      if (Util.isWindows()) {
        final file = File(
          path.join(
            path.dirname(Platform.resolvedExecutable),
            'data',
            'flutter_assets',
            'assets',
            'icon',
            'icon_512.png',
          ),
        );
        if (await file.exists()) windowsIconPath = file.absolute.path;
      }
    } catch (error, stackTrace) {
      logger.w('prepare watchdog notification icon failed', error, stackTrace);
    }
    await _plugin.initialize(
      settings: InitializationSettings(
        macOS: const DarwinInitializationSettings(requestAlertPermission: false, requestSoundPermission: false),
        linux: LinuxInitializationSettings(
          defaultActionName: appLocalizationsFor('').open,
          defaultIcon: AssetsLinuxIcon('assets/icon/icon.png'),
        ),
        windows: WindowsInitializationSettings(
          appName: 'PonyDownloader',
          appUserModelId: 'org.mutantcat.ponydownloader',
          guid: '3c1bf3f4-3d91-4eaa-a33f-8705e71cf1ce',
          iconPath: windowsIconPath,
        ),
      ),
    );
    _notificationsInitialized = true;
  }
}
