import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../api/api.dart' as api;
import '../../api/model/create_task.dart';
import '../../api/model/create_task_batch.dart';
import '../../api/model/downloader_config.dart';
import '../../api/model/extension.dart';
import '../../api/model/install_extension.dart';
import '../../api/model/resolve_result.dart';
import '../../api/model/resolve_task.dart';
import '../../api/model/switch_extension.dart';
import '../../api/model/task.dart';
import '../../api/model/update_check_extension_resp.dart';
import '../../api/model/update_extension_settings.dart';
import '../window/app_window_appearance.dart';
import 'capability_rpc.dart';
import 'ponydownloader_capability.dart';
import 'storage_capability.dart';
import 'app_navigation_capability.dart';
import '../../app/router/app_router.dart';

class AppCapabilities {
  AppCapabilities(CapabilityInvoker invoker)
    : ponydownloader = PonyDownloaderService(invoker),
      storage = AppStorageService(invoker),
      navigation = AppNavigationService(invoker);

  final PonyDownloaderService ponydownloader;
  final AppStorageService storage;
  final AppNavigationService navigation;
}

class LocalAppCapabilities {
  LocalAppCapabilities._() : codecs = createAppCapabilityCodecs() {
    registry = CapabilityRegistry(codecs);
    _bindPonyDownloader(registry);
    _bindStorage(registry);
    registry.bind(NavigationMethods.showDownloadingTasks, (_) {
      AppRouter.showDownloadingTasks();
      return const RpcUnit();
    });
    capabilities = AppCapabilities(LocalCapabilityInvoker(registry));
  }

  static final instance = LocalAppCapabilities._();

  final RpcCodecRegistry codecs;
  late CapabilityRegistry registry;
  late AppCapabilities capabilities;
}

final appCapabilitiesProvider = Provider<AppCapabilities>((ref) => LocalAppCapabilities.instance.capabilities);
final ponydownloaderServiceProvider = Provider<PonyDownloaderService>(
  (ref) => ref.watch(appCapabilitiesProvider).ponydownloader,
);
final appStorageServiceProvider = Provider<AppStorageService>((ref) => ref.watch(appCapabilitiesProvider).storage);

RpcCodecRegistry createAppCapabilityCodecs() {
  final codecs = RpcCodecRegistry();
  codecs
    ..register<AppWindowAppearance>((json) => AppWindowAppearance.fromJson(json! as Map<String, dynamic>))
    ..register<ResolveTask>((json) => ResolveTask.fromJson(json! as Map<String, dynamic>))
    ..register<ResolveResult>((json) => ResolveResult.fromJson(json! as Map<String, dynamic>))
    ..register<CreateTask>((json) => CreateTask.fromJson(json! as Map<String, dynamic>))
    ..register<CreateTaskBatch>((json) => CreateTaskBatch.fromJson(json! as Map<String, dynamic>))
    ..register<DownloaderConfig>((json) => DownloaderConfig.fromJson(json! as Map<String, dynamic>))
    ..register<TaskRuntimeStatus>((json) => TaskRuntimeStatus.fromJson(json! as Map<String, dynamic>))
    ..register<List<Task>>(
      (json) =>
          (json! as List<dynamic>).map((item) => Task.fromJson(item as Map<String, dynamic>)).toList(growable: false),
    )
    ..register<InstallExtension>((json) => InstallExtension.fromJson(json! as Map<String, dynamic>))
    ..register<UpdateExtensionSettings>((json) => UpdateExtensionSettings.fromJson(json! as Map<String, dynamic>))
    ..register<SwitchExtension>((json) => SwitchExtension.fromJson(json! as Map<String, dynamic>))
    ..register<List<Extension>>(
      (json) => (json! as List<dynamic>)
          .map((item) => Extension.fromJson(item as Map<String, dynamic>))
          .toList(growable: false),
    )
    ..register<UpdateCheckExtensionResp>((json) => UpdateCheckExtensionResp.fromJson(json! as Map<String, dynamic>));
  return codecs;
}

void _bindPonyDownloader(CapabilityRegistry registry) {
  registry
    ..bind(PonyDownloaderMethods.resolve, api.resolve)
    ..bind(PonyDownloaderMethods.createTask, api.createTask)
    ..bind(PonyDownloaderMethods.createTaskBatch, api.createTaskBatch)
    ..bind(PonyDownloaderMethods.patchTask, (params) async {
      await api.patchTask(params['id'] as String, ResolveTask.fromJson(params['request'] as Map<String, dynamic>));
      return const RpcUnit();
    })
    ..bind(
      PonyDownloaderMethods.getTasks,
      (statuses) => api.getTasks(statuses.map((name) => Status.values.byName(name)).toList(growable: false)),
    )
    ..bind(PonyDownloaderMethods.getTaskStatus, api.getTaskStatus)
    ..bind(PonyDownloaderMethods.getTaskStats, api.getTaskStats)
    ..bind(PonyDownloaderMethods.pauseTask, (id) async {
      await api.pauseTask(id);
      return const RpcUnit();
    })
    ..bind(PonyDownloaderMethods.continueTask, (id) async {
      await api.continueTask(id);
      return const RpcUnit();
    })
    ..bind(PonyDownloaderMethods.pauseTasks, (params) async {
      await api.pauseAllTasks(_optionalStringList(params['ids']));
      return const RpcUnit();
    })
    ..bind(PonyDownloaderMethods.continueTasks, (params) async {
      await api.continueAllTasks(_optionalStringList(params['ids']));
      return const RpcUnit();
    })
    ..bind(PonyDownloaderMethods.deleteTask, (params) async {
      await api.deleteTask(params['id'] as String, params['force'] as bool? ?? false);
      return const RpcUnit();
    })
    ..bind(PonyDownloaderMethods.deleteTasks, (params) async {
      await api.deleteTasks(_optionalStringList(params['ids']), params['force'] as bool? ?? false);
      return const RpcUnit();
    })
    ..bind(PonyDownloaderMethods.getConfig, (_) => api.getConfig())
    ..bind(PonyDownloaderMethods.putConfig, (config) async {
      await api.putConfig(config);
      return const RpcUnit();
    })
    ..bind(PonyDownloaderMethods.installExtension, api.installExtension)
    ..bind(PonyDownloaderMethods.getExtensions, (_) => api.getExtensions())
    ..bind(PonyDownloaderMethods.updateExtensionSettings, (params) async {
      await api.updateExtensionSettings(
        params['identity'] as String,
        UpdateExtensionSettings.fromJson(params['request'] as Map<String, dynamic>),
      );
      return const RpcUnit();
    })
    ..bind(PonyDownloaderMethods.switchExtension, (params) async {
      await api.switchExtension(
        params['identity'] as String,
        SwitchExtension.fromJson(params['request'] as Map<String, dynamic>),
      );
      return const RpcUnit();
    })
    ..bind(PonyDownloaderMethods.deleteExtension, (identity) async {
      await api.deleteExtension(identity);
      return const RpcUnit();
    })
    ..bind(PonyDownloaderMethods.checkExtensionUpdate, api.upgradeCheckExtension)
    ..bind(PonyDownloaderMethods.updateExtension, (identity) async {
      await api.updateExtension(identity);
      return const RpcUnit();
    })
    ..bind(PonyDownloaderMethods.testWebhook, (url) async {
      await api.testWebhook(url);
      return const RpcUnit();
    });
}

void _bindStorage(CapabilityRegistry registry) {
  registry
    ..bind(StorageMethods.getCreateHistory, (_) async {
      final config = await api.getConfig();
      return config.extra.createHistory;
    })
    ..bind(StorageMethods.saveCreateHistory, (urls) async {
      final config = await api.getConfig();
      final history = List<String>.of(config.extra.createHistory);
      for (final url in urls) {
        history.remove(url);
        history.insert(0, url);
        if (history.length > 64) history.removeLast();
      }
      config.extra.createHistory = history;
      await api.putConfig(config);
      return const RpcUnit();
    })
    ..bind(StorageMethods.removeCreateHistory, (url) async {
      final config = await api.getConfig();
      final history = List<String>.of(config.extra.createHistory)..remove(url);
      config.extra.createHistory = history;
      await api.putConfig(config);
      return const RpcUnit();
    })
    ..bind(StorageMethods.clearCreateHistory, (_) async {
      final config = await api.getConfig();
      config.extra.createHistory = const [];
      await api.putConfig(config);
      return const RpcUnit();
    });
}

List<String>? _optionalStringList(Object? value) {
  if (value == null) return null;
  return (value as List<dynamic>).map((item) => item.toString()).toList(growable: false);
}
