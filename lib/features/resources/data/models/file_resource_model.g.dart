// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'file_resource_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class FileResourceModelAdapter extends TypeAdapter<FileResourceModel> {
  @override
  final int typeId = 3;

  @override
  FileResourceModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FileResourceModel(
      id: fields[0] as String,
      userId: fields[1] as String,
      subjectId: fields[2] as String?,
      taskId: fields[3] as String?,
      name: fields[4] as String,
      type: fields[5] as String,
      url: fields[6] as String,
      size: fields[7] as int,
      isFavorite: fields[8] as bool,
      isDeleted: fields[9] as bool,
      createdAt: fields[10] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, FileResourceModel obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.userId)
      ..writeByte(2)
      ..write(obj.subjectId)
      ..writeByte(3)
      ..write(obj.taskId)
      ..writeByte(4)
      ..write(obj.name)
      ..writeByte(5)
      ..write(obj.type)
      ..writeByte(6)
      ..write(obj.url)
      ..writeByte(7)
      ..write(obj.size)
      ..writeByte(8)
      ..write(obj.isFavorite)
      ..writeByte(9)
      ..write(obj.isDeleted)
      ..writeByte(10)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FileResourceModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
