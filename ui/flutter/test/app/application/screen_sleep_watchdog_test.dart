import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ponydownloader/api/model/downloader_config.dart';
import 'package:ponydownloader/api/model/meta.dart';
import 'package:ponydownloader/api/model/options.dart';
import 'package:ponydownloader/api/model/request.dart';
import 'package:ponydownloader/api/model/task.dart' as api_task;
import 'package:ponydownloader/app/application/app_runtime_controller.dart';
import 'package:ponydownloader/app/application/screen_sleep_watchdog.dart';
import 'package:ponydownloader/core/common/api_server_state.dart';
import 'package:ponydownloader/core/common/start_config.dart';

void main() {
  late _FakeBackend backend;
  late DateTime now;

  setUp(() {
    backend = _FakeBackend();
    now = DateTime(2026, 9, 22, 8);
  });

  Future<ProviderContainer> start({
    bool desktopNotification = true,
    List<api_task.Task> tasks = const [],
  }) async {
    backend.tasks = List.of(tasks);
    final container = ProviderContainer(
      overrides: [
        appRuntimeControllerProvider.overrideWith(() => _TestRuntimeController(desktopNotification)),
        screenSleepWatchdogProvider.overrideWith(
          () => _TestWatchdog(
            backend: backend,
            now: () => now,
          ),
        ),
      ],
    );
    addTearDown(container.dispose);
    await container.read(screenSleepWatchdogProvider.future);
    return container;
  }

  test('heartbeat snapshots running and waiting tasks without recovering', () async {
    await start(
      tasks: [
        _task('a', api_task.Status.running),
        _task('b', api_task.Status.wait),
        _task('c', api_task.Status.pause),
      ],
    );

    final watchdog = backend.watchdog!;
    expect(backend.continued, isEmpty);
    expect(watchdog.snapshot().active, isTrue);
    expect(watchdog.snapshot().activeTaskIds, ['a', 'b']);
  });

  test('a long heartbeat gap resumes only tasks interrupted while asleep', () async {
    await start(tasks: [_task('a', api_task.Status.running), _task('b', api_task.Status.running)]);

    backend.tasks = [_task('a', api_task.Status.pause), _task('b', api_task.Status.error)];
    now = now.add(const Duration(hours: 4));
    await backend.watchdog!.recoverAfterGap();

    expect(backend.continued, [
      containsAll(['a', 'b']),
    ]);
    expect(backend.watchdog!.snapshot().lastRecoveryAt, isNotNull);
    expect(backend.notifyCount, 1);
  });

  test('tasks already running after wake are not resumed again', () async {
    await start(tasks: [_task('a', api_task.Status.running), _task('b', api_task.Status.wait)]);

    // Both made progress and are still healthy after the host wakes.
    backend.tasks = [_task('a', api_task.Status.running), _task('b', api_task.Status.done)];
    now = now.add(const Duration(minutes: 5));
    await backend.watchdog!.recoverAfterGap();

    expect(backend.continued, isEmpty);
    expect(backend.notifyCount, 0);
  });

  test('tasks paused before sleep stay paused', () async {
    await start(tasks: [_task('a', api_task.Status.pause), _task('b', api_task.Status.done)]);

    now = now.add(const Duration(minutes: 10));
    await backend.watchdog!.recoverAfterGap();

    expect(backend.continued, isEmpty);
    expect(backend.notifyCount, 0);
  });

  test('desktop notifications disabled suppress the recovery notice', () async {
    await start(desktopNotification: false, tasks: [_task('a', api_task.Status.running)]);

    backend.tasks = [_task('a', api_task.Status.error)];
    now = now.add(const Duration(hours: 1));
    await backend.watchdog!.recoverAfterGap();

    expect(backend.continued, hasLength(1));
    expect(backend.notifyCount, 0);
  });
}

api_task.Task _task(String id, api_task.Status status) {
  final task = api_task.Task(
    id: id,
    name: '$id.bin',
    meta: Meta(
      req: Request(url: 'https://example.com/$id.bin'),
      opts: Options(path: '/downloads'),
    ),
    status: status,
    uploading: false,
    progress: api_task.Progress(used: 0, speed: 0, downloaded: 1, uploadSpeed: 0, uploaded: 0),
    createdAt: DateTime(2026),
    updatedAt: DateTime(2026),
  );
  return task;
}

class _FakeBackend {
  List<api_task.Task> tasks = [];
  final continued = <List<String>>[];
  _TestWatchdog? watchdog;
  int notifyCount = 0;
}

class _TestWatchdog extends ScreenSleepWatchdog {
  _TestWatchdog({required _FakeBackend backend, required DateTime Function() now})
    : _backend = backend,
      super(
        enabledOverride: () => true,
        nowOverride: now,
      );

  final _FakeBackend _backend;

  @override
  Future<List<api_task.Task>> listTasks() async => List.of(_backend.tasks);

  @override
  Future<void> continueTasks(List<String> ids) async {
    _backend.continued.add(List.of(ids));
  }

  @override
  Future<bool> notifyDownloadsRecovered() async {
    _backend.notifyCount++;
    return true;
  }
}

class _TestRuntimeController extends AppRuntimeController {
  _TestRuntimeController(this.desktopNotification);

  final bool desktopNotification;

  @override
  Future<AppRuntimeState> build() async => AppRuntimeState(
    startConfig: StartConfig(),
    apiServerState: ApiServerState.fromJson({}),
    downloaderConfig: DownloaderConfig()..extra.desktopNotification = desktopNotification,
  );
}
