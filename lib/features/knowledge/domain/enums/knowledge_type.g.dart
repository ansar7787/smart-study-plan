// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'knowledge_type.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class KnowledgeTypeAdapter extends TypeAdapter<KnowledgeType> {
  @override
  final int typeId = 13;

  @override
  KnowledgeType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return KnowledgeType.note;
      case 1:
        return KnowledgeType.summary;
      case 2:
        return KnowledgeType.idea;
      case 3:
        return KnowledgeType.session;
      default:
        return KnowledgeType.note;
    }
  }

  @override
  void write(BinaryWriter writer, KnowledgeType obj) {
    switch (obj) {
      case KnowledgeType.note:
        writer.writeByte(0);
        break;
      case KnowledgeType.summary:
        writer.writeByte(1);
        break;
      case KnowledgeType.idea:
        writer.writeByte(2);
        break;
      case KnowledgeType.session:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is KnowledgeTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
