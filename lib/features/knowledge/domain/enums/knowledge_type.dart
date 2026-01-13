import 'package:hive/hive.dart';

part 'knowledge_type.g.dart';

@HiveType(typeId: 13)
enum KnowledgeType {
  @HiveField(0)
  note,

  @HiveField(1)
  summary,

  @HiveField(2)
  idea,
}
