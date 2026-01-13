import 'package:hive/hive.dart';
import '../models/file_resource_model.dart';

abstract class ResourceLocalDataSource {
  Future<void> cacheResource(FileResourceModel model);
  Future<List<FileResourceModel>> getResourcesByUser(String userId);
  Future<List<FileResourceModel>> getResourcesBySubject(String subjectId);
  Future<void> deleteResource(String id);
  Future<void> clearAll();
}

class ResourceLocalDataSourceImpl implements ResourceLocalDataSource {
  static const String _boxName = 'file_resources';

  Future<Box<FileResourceModel>> _openBox() async {
    if (Hive.isBoxOpen(_boxName)) {
      return Hive.box<FileResourceModel>(_boxName);
    }
    return Hive.openBox<FileResourceModel>(_boxName);
  }

  @override
  Future<void> cacheResource(FileResourceModel model) async {
    final box = await _openBox();
    await box.put(model.id, model);
  }

  @override
  Future<List<FileResourceModel>> getResourcesByUser(String userId) async {
    final box = await _openBox();
    return box.values.where((r) => r.userId == userId && !r.isDeleted).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  @override
  Future<List<FileResourceModel>> getResourcesBySubject(
    String subjectId,
  ) async {
    final box = await _openBox();
    return box.values
        .where((r) => r.subjectId == subjectId && !r.isDeleted)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  @override
  Future<void> deleteResource(String id) async {
    final box = await _openBox();
    await box.delete(id);
  }

  @override
  Future<void> clearAll() async {
    final box = await _openBox();
    await box.clear();
  }
}
