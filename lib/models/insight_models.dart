import 'package:json_annotation/json_annotation.dart';

part 'insight_models.g.dart';

@JsonSerializable()
class InsightResponse {
  final String summary;
  final String status;
  final List<String> highlights;
  final List<String> recommendations;
  @JsonKey(name: 'next_steps')
  final String nextSteps;

  InsightResponse({
    required this.summary,
    required this.status,
    required this.highlights,
    required this.recommendations,
    required this.nextSteps,
  });

  factory InsightResponse.fromJson(Map<String, dynamic> json) =>
      _$InsightResponseFromJson(json);

  Map<String, dynamic> toJson() => _$InsightResponseToJson(this);
}

@JsonSerializable()
class InsightApiResponse {
  final String status;
  final InsightResponse insights;

  InsightApiResponse({
    required this.status,
    required this.insights,
  });

  factory InsightApiResponse.fromJson(Map<String, dynamic> json) =>
      _$InsightApiResponseFromJson(json);

  Map<String, dynamic> toJson() => _$InsightApiResponseToJson(this);
}

@JsonSerializable()
class SleepInsightResponse {
  final String type;
  final String message;
  final String severity;
  final DateTime timestamp;
  final Map<String, dynamic>? additionalData;

  SleepInsightResponse({
    required this.type,
    required this.message,
    required this.severity,
    required this.timestamp,
    this.additionalData,
  });

  factory SleepInsightResponse.fromJson(Map<String, dynamic> json) =>
      _$SleepInsightResponseFromJson(json);

  Map<String, dynamic> toJson() => _$SleepInsightResponseToJson(this);
}

@JsonSerializable()
class HeartRateInsightResponse {
  final String type;
  final String message;
  final String severity;
  final DateTime timestamp;
  final Map<String, dynamic>? additionalData;

  HeartRateInsightResponse({
    required this.type,
    required this.message,
    required this.severity,
    required this.timestamp,
    this.additionalData,
  });

  factory HeartRateInsightResponse.fromJson(Map<String, dynamic> json) =>
      _$HeartRateInsightResponseFromJson(json);

  Map<String, dynamic> toJson() => _$HeartRateInsightResponseToJson(this);
}

@JsonSerializable()
class WeightInsightResponse {
  final String type;
  final String message;
  final String severity;
  final DateTime timestamp;
  final Map<String, dynamic>? additionalData;

  WeightInsightResponse({
    required this.type,
    required this.message,
    required this.severity,
    required this.timestamp,
    this.additionalData,
  });

  factory WeightInsightResponse.fromJson(Map<String, dynamic> json) =>
      _$WeightInsightResponseFromJson(json);

  Map<String, dynamic> toJson() => _$WeightInsightResponseToJson(this);
}

@JsonSerializable()
class CorrelationInsightResponse {
  final String type;
  final String message;
  final String severity;
  final DateTime timestamp;
  final Map<String, dynamic>? additionalData;

  CorrelationInsightResponse({
    required this.type,
    required this.message,
    required this.severity,
    required this.timestamp,
    this.additionalData,
  });

  factory CorrelationInsightResponse.fromJson(Map<String, dynamic> json) =>
      _$CorrelationInsightResponseFromJson(json);

  Map<String, dynamic> toJson() => _$CorrelationInsightResponseToJson(this);
} 