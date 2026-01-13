// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'analytics_insight_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AnalyticsInsightModelAdapter extends TypeAdapter<AnalyticsInsightModel> {
  @override
  final int typeId = 10;

  @override
  AnalyticsInsightModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AnalyticsInsightModel(
      message: fields[0] as String,
      type: fields[1] as InsightType,
    );
  }

  @override
  void write(BinaryWriter writer, AnalyticsInsightModel obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.message)
      ..writeByte(1)
      ..write(obj.type);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AnalyticsInsightModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
