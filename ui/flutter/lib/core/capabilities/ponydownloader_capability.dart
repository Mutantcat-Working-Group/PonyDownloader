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
import 'capability_rpc.dart';

abstract final class PonyDownloaderMethods {
  static const resolve = RpcMethod<ResolveTask, ResolveResult>('ponydownloader.resolve');
  static const createTask = RpcMethod<CreateTask, String>('ponydownloader.task.create');
  static const createTaskBatch = RpcMethod<CreateTaskBatch, List<String>>('ponydownloader.task.createBatch');
  static const patchTask = RpcMethod<Map<String, dynamic>, RpcUnit>('ponydownloader.task.patch');
  static const getTasks = RpcMethod<List<String>, List<Task>>('ponydownloader.task.list');
  static const getTaskStatus = RpcMethod<String, TaskRuntimeStatus>('ponydownloader.task.status');
  static const getTaskStats = RpcMethod<String, Map<String, dynamic>>('ponydownloader.task.stats');
  static const pauseTask = RpcMethod<String, RpcUnit>('ponydownloader.task.pause');
  static const continueTask = RpcMethod<String, RpcUnit>('ponydownloader.task.continue');
  static const pauseTasks = RpcMethod<Map<String, dynamic>, RpcUnit>('ponydownloader.task.pauseBatch');
  static const continueTasks = RpcMethod<Map<String, dynamic>, RpcUnit>('ponydownloader.task.continueBatch');
  static const deleteTask = RpcMethod<Map<String, dynamic>, RpcUnit>('ponydownloader.task.delete');
  static const deleteTasks = RpcMethod<Map<String, dynamic>, RpcUnit>('ponydownloader.task.deleteBatch');
  static const getConfig = RpcMethod<RpcUnit, DownloaderConfig>('ponydownloader.config.get');
  static const putConfig = RpcMethod<DownloaderConfig, RpcUnit>('ponydownloader.config.put');
  static const installExtension = RpcMethod<InstallExtension, String>('ponydownloader.extension.install');
  static const getExtensions = RpcMethod<RpcUnit, List<Extension>>('ponydownloader.extension.list');
  static const updateExtensionSettings =
      RpcMethod<Map<String, dynamic>, RpcUnit>('ponydownloader.extension.updateSettings');
  static const switchExtension = RpcMethod<Map<String, dynamic>, RpcUnit>('ponydownloader.extension.switch');
  static const deleteExtension = RpcMethod<String, RpcUnit>('ponydownloader.extension.delete');
  static const checkExtensionUpdate = RpcMethod<String, UpdateCheckExtensionResp>('ponydownloader.extension.checkUpdate');
  static const updateExtension = RpcMethod<String, RpcUnit>('ponydownloader.extension.update');
  static const testWebhook = RpcMethod<String, RpcUnit>('ponydownloader.webhook.test');
}

class PonyDownloaderService {
  const PonyDownloaderService(this._invoker);

  final CapabilityInvoker _invoker;

  Future<ResolveResult> resolve(ResolveTask request) => _invoker.invoke(PonyDownloaderMethods.resolve, request);

  Future<String> createTask(CreateTask request) => _invoker.invoke(PonyDownloaderMethods.createTask, request);

  Future<List<String>> createTaskBatch(CreateTaskBatch request) =>
      _invoker.invoke(PonyDownloaderMethods.createTaskBatch, request);

  Future<void> patchTask(String id, ResolveTask request) async {
    await _invoker.invoke(PonyDownloaderMethods.patchTask, {'id': id, 'request': request.toJson()});
  }

  Future<List<Task>> getTasks(List<Status> statuses) =>
      _invoker.invoke(PonyDownloaderMethods.getTasks, statuses.map((status) => status.name).toList(growable: false));

  Future<TaskRuntimeStatus> getTaskStatus(String id) => _invoker.invoke(PonyDownloaderMethods.getTaskStatus, id);

  Future<Map<String, dynamic>> getTaskStats(String id) => _invoker.invoke(PonyDownloaderMethods.getTaskStats, id);

  Future<void> pauseTask(String id) async => _invoker.invoke(PonyDownloaderMethods.pauseTask, id);

  Future<void> continueTask(String id) async => _invoker.invoke(PonyDownloaderMethods.continueTask, id);

  Future<void> pauseAllTasks(List<String>? ids) async {
    await _invoker.invoke(PonyDownloaderMethods.pauseTasks, {'ids': ids});
  }

  Future<void> continueAllTasks(List<String>? ids) async {
    await _invoker.invoke(PonyDownloaderMethods.continueTasks, {'ids': ids});
  }

  Future<void> deleteTask(String id, bool force) async {
    await _invoker.invoke(PonyDownloaderMethods.deleteTask, {'id': id, 'force': force});
  }

  Future<void> deleteTasks(List<String>? ids, bool force) async {
    await _invoker.invoke(PonyDownloaderMethods.deleteTasks, {'ids': ids, 'force': force});
  }

  Future<DownloaderConfig> getConfig() => _invoker.invoke(PonyDownloaderMethods.getConfig, const RpcUnit());

  Future<void> putConfig(DownloaderConfig config) async => _invoker.invoke(PonyDownloaderMethods.putConfig, config);

  Future<String> installExtension(InstallExtension request) => _invoker.invoke(PonyDownloaderMethods.installExtension, request);

  Future<List<Extension>> getExtensions() => _invoker.invoke(PonyDownloaderMethods.getExtensions, const RpcUnit());

  Future<void> updateExtensionSettings(String identity, UpdateExtensionSettings request) async {
    await _invoker.invoke(PonyDownloaderMethods.updateExtensionSettings, {'identity': identity, 'request': request.toJson()});
  }

  Future<void> switchExtension(String identity, SwitchExtension request) async {
    await _invoker.invoke(PonyDownloaderMethods.switchExtension, {'identity': identity, 'request': request.toJson()});
  }

  Future<void> deleteExtension(String identity) async => _invoker.invoke(PonyDownloaderMethods.deleteExtension, identity);

  Future<UpdateCheckExtensionResp> upgradeCheckExtension(String identity) =>
      _invoker.invoke(PonyDownloaderMethods.checkExtensionUpdate, identity);

  Future<void> updateExtension(String identity) async => _invoker.invoke(PonyDownloaderMethods.updateExtension, identity);

  Future<void> testWebhook(String url) async => _invoker.invoke(PonyDownloaderMethods.testWebhook, url);
}
