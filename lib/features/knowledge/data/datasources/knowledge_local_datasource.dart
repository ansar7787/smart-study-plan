import 'package:hive_flutter/hive_flutter.dart';
import 'package:smart_study_plan/features/knowledge/data/models/knowledge_item_model.dart';

abstract class KnowledgeLocalDataSource {
  Future<List<KnowledgeItemModel>> getAll(String userId);
  Future<void> save(KnowledgeItemModel item);
  Future<void> update(KnowledgeItemModel item);
  Future<void> delete(String id);
}

class KnowledgeLocalDataSourceImpl implements KnowledgeLocalDataSource {
  static const boxName = 'knowledge_items';

  @override
  Future<List<KnowledgeItemModel>> getAll(String userId) async {
    final box = await Hive.openBox<KnowledgeItemModel>(boxName);
    return box.values.where((e) => e.userId == userId).toList();
  }

  @override
  Future<void> save(KnowledgeItemModel item) async {
    final box = await Hive.openBox<KnowledgeItemModel>(boxName);
    await box.put(item.id, item);
  }

  @override
  Future<void> update(KnowledgeItemModel item) async {
    await save(item);
  }

  @override
  Future<void> delete(String id) async {
    final box = await Hive.openBox<KnowledgeItemModel>(boxName);
    await box.delete(id);
  }
}
