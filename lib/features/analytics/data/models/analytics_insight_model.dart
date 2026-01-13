import 'package:hive/hive.dart';
import '../../domain/entities/analytics_insight.dart';
import '../../domain/enums/insight_type.dart';

part 'analytics_insight_model.g.dart';

@HiveType(typeId: 10)
class AnalyticsInsightModel extends HiveObject {
  @HiveField(0)
  final String message;

  @HiveField(1)
  final InsightType type;

  AnalyticsInsightModel({required this.message, required this.type});

  AnalyticsInsight toEntity() => AnalyticsInsight(message: message, type: type);

  factory AnalyticsInsightModel.fromEntity(AnalyticsInsight e) =>
      AnalyticsInsightModel(message: e.message, type: e.type);
}
