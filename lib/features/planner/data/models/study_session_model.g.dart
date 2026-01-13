// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'study_session_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class StudySessionModelAdapter extends TypeAdapter<StudySessionModel> {
  @override
  final int typeId = 2;

  @override
  StudySessionModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return StudySessionModel(
      id: fields[0] as String,
      userId: fields[1] as String,
      taskId: fields[2] as String?,
      title: fields[3] as String,
      description: fields[4] as String,
      startTime: fields[5] as DateTime,
      endTime: fields[6] as DateTime,
      subjectId: fields[7] as String?,
      location: fields[8] as String?,
      isRecurring: fields[9] as bool,
      recurrencePattern: fields[10] as String?,
      createdAt: fields[11] as DateTime,
      updatedAt: fields[12] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, StudySessionModel obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.userId)
      ..writeByte(2)
      ..write(obj.taskId)
      ..writeByte(3)
      ..write(obj.title)
      ..writeByte(4)
      ..write(obj.description)
      ..writeByte(5)
      ..write(obj.startTime)
      ..writeByte(6)
      ..write(obj.endTime)
      ..writeByte(7)
      ..write(obj.subjectId)
      ..writeByte(8)
      ..write(obj.location)
      ..writeByte(9)
      ..write(obj.isRecurring)
      ..writeByte(10)
      ..write(obj.recurrencePattern)
      ..writeByte(11)
      ..write(obj.createdAt)
      ..writeByte(12)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StudySessionModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
