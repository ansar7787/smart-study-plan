// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'progress_snapshot_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ProgressSnapshotModelAdapter extends TypeAdapter<ProgressSnapshotModel> {
  @override
  final int typeId = 8;

  @override
  ProgressSnapshotModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ProgressSnapshotModel(
      periodStart: fields[0] as DateTime,
      periodEnd: fields[1] as DateTime,
      totalTasks: fields[2] as int,
      completedTasks: fields[3] as int,
      overdueTasks: fields[4] as int,
      totalStudyHours: fields[5] as double,
      sessionCount: fields[6] as int,
    );
  }

  @override
  void write(BinaryWriter writer, ProgressSnapshotModel obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.periodStart)
      ..writeByte(1)
      ..write(obj.periodEnd)
      ..writeByte(2)
      ..write(obj.totalTasks)
      ..writeByte(3)
      ..write(obj.completedTasks)
      ..writeByte(4)
      ..write(obj.overdueTasks)
      ..writeByte(5)
      ..write(obj.totalStudyHours)
      ..writeByte(6)
      ..write(obj.sessionCount);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProgressSnapshotModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
