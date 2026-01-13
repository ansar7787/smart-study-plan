// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'progress_trends_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ProgressTrendsModelAdapter extends TypeAdapter<ProgressTrendsModel> {
  @override
  final int typeId = 9;

  @override
  ProgressTrendsModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ProgressTrendsModel(
      dailyStudyHours: (fields[0] as List).cast<double>(),
      dailyTaskCompletion: (fields[1] as List).cast<double>(),
      studyStreak: fields[2] as int,
    );
  }

  @override
  void write(BinaryWriter writer, ProgressTrendsModel obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.dailyStudyHours)
      ..writeByte(1)
      ..write(obj.dailyTaskCompletion)
      ..writeByte(2)
      ..write(obj.studyStreak);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProgressTrendsModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
