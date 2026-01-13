// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'knowledge_item_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class KnowledgeItemModelAdapter extends TypeAdapter<KnowledgeItemModel> {
  @override
  final int typeId = 12;

  @override
  KnowledgeItemModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return KnowledgeItemModel(
      id: fields[0] as String,
      userId: fields[1] as String,
      type: fields[2] as KnowledgeType,
      title: fields[3] as String,
      content: fields[4] as String,
      createdAt: fields[5] as DateTime,
      subjectId: fields[6] as String?,
      isPinned: fields[7] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, KnowledgeItemModel obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.userId)
      ..writeByte(2)
      ..write(obj.type)
      ..writeByte(3)
      ..write(obj.title)
      ..writeByte(4)
      ..write(obj.content)
      ..writeByte(5)
      ..write(obj.createdAt)
      ..writeByte(6)
      ..write(obj.subjectId)
      ..writeByte(7)
      ..write(obj.isPinned);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is KnowledgeItemModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
