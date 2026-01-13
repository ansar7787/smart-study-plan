// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'study_goal_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class StudyGoalModelAdapter extends TypeAdapter<StudyGoalModel> {
  @override
  final int typeId = 11;

  @override
  StudyGoalModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return StudyGoalModel(
      id: fields[0] as String,
      userId: fields[1] as String,
      title: fields[2] as String,
      description: fields[3] as String,
      metricType: fields[4] as GoalMetricType,
      targetValue: fields[5] as double,
      progress: fields[6] as double,
      startDate: fields[7] as DateTime,
      endDate: fields[8] as DateTime,
      status: fields[9] as GoalStatus,
    );
  }

  @override
  void write(BinaryWriter writer, StudyGoalModel obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.userId)
      ..writeByte(2)
      ..write(obj.title)
      ..writeByte(3)
      ..write(obj.description)
      ..writeByte(4)
      ..write(obj.metricType)
      ..writeByte(5)
      ..write(obj.targetValue)
      ..writeByte(6)
      ..write(obj.progress)
      ..writeByte(7)
      ..write(obj.startDate)
      ..writeByte(8)
      ..write(obj.endDate)
      ..writeByte(9)
      ..write(obj.status);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StudyGoalModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
