import '../enums/insight_type.dart';

class AnalyticsInsight {
  final String message;
  final InsightType type;

  const AnalyticsInsight({required this.message, required this.type});
}
