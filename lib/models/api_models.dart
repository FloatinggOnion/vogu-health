import 'package:json_annotation/json_annotation.dart';

part 'api_models.g.dart';

// ============================================================================
// REQUEST MODELS
// ============================================================================

@JsonSerializable()
class SleepDataRequest {
  @JsonKey(name: 'start_time')
  final String startTime;
  @JsonKey(name: 'end_time')
  final String endTime;
  final int quality;
  final SleepPhases phases;
  final String source;

  SleepDataRequest({
    required this.startTime,
    required this.endTime,
    required this.quality,
    required this.phases,
    required this.source,
  });

  factory SleepDataRequest.fromJson(Map<String, dynamic> json) =>
      _$SleepDataRequestFromJson(json);
  Map<String, dynamic> toJson() => _$SleepDataRequestToJson(this);
}

@JsonSerializable()
class SleepPhases {
  final int deep;
  final int light;
  final int rem;
  final int awake;

  SleepPhases({
    required this.deep,
    required this.light,
    required this.rem,
    required this.awake,
  });

  factory SleepPhases.fromJson(Map<String, dynamic> json) =>
      _$SleepPhasesFromJson(json);
  Map<String, dynamic> toJson() => _$SleepPhasesToJson(this);
}

@JsonSerializable()
class HeartRateDataRequest {
  final String timestamp;
  final int value;
  @JsonKey(name: 'resting_rate')
  final int restingRate;
  @JsonKey(name: 'activity_type')
  final String? activityType;
  final String source;

  HeartRateDataRequest({
    required this.timestamp,
    required this.value,
    required this.restingRate,
    this.activityType,
    required this.source,
  });

  factory HeartRateDataRequest.fromJson(Map<String, dynamic> json) =>
      _$HeartRateDataRequestFromJson(json);
  Map<String, dynamic> toJson() => _$HeartRateDataRequestToJson(this);
}

@JsonSerializable()
class WeightDataRequest {
  final String timestamp;
  final double value;
  final double bmi;
  @JsonKey(name: 'body_composition')
  final BodyComposition? bodyComposition;
  final String source;

  WeightDataRequest({
    required this.timestamp,
    required this.value,
    required this.bmi,
    this.bodyComposition,
    required this.source,
  });

  factory WeightDataRequest.fromJson(Map<String, dynamic> json) =>
      _$WeightDataRequestFromJson(json);
  Map<String, dynamic> toJson() => _$WeightDataRequestToJson(this);
}

@JsonSerializable()
class BodyComposition {
  @JsonKey(name: 'body_fat')
  final double? bodyFat;
  @JsonKey(name: 'muscle_mass')
  final double? muscleMass;
  @JsonKey(name: 'water_percentage')
  final double? waterPercentage;
  @JsonKey(name: 'bone_mass')
  final double? boneMass;

  BodyComposition({
    this.bodyFat,
    this.muscleMass,
    this.waterPercentage,
    this.boneMass,
  });

  factory BodyComposition.fromJson(Map<String, dynamic> json) =>
      _$BodyCompositionFromJson(json);
  Map<String, dynamic> toJson() => _$BodyCompositionToJson(this);
}

// ============================================================================
// RESPONSE MODELS
// ============================================================================

@JsonSerializable()
class ApiResponse {
  final String status;
  final String message;

  ApiResponse({
    required this.status,
    required this.message,
  });

  factory ApiResponse.fromJson(Map<String, dynamic> json) =>
      _$ApiResponseFromJson(json);
  Map<String, dynamic> toJson() => _$ApiResponseToJson(this);
}

@JsonSerializable()
class SleepDataResponse {
  final int id;
  @JsonKey(name: 'start_time')
  final String startTime;
  @JsonKey(name: 'end_time')
  final String endTime;
  final int? quality;
  @JsonKey(name: 'deep_sleep')
  final int? deepSleep;
  @JsonKey(name: 'light_sleep')
  final int? lightSleep;
  @JsonKey(name: 'rem_sleep')
  final int? remSleep;
  @JsonKey(name: 'awake_time')
  final int? awakeTime;
  final String source;
  @JsonKey(name: 'created_at')
  final String createdAt;

  SleepDataResponse({
    required this.id,
    required this.startTime,
    required this.endTime,
    this.quality,
    this.deepSleep,
    this.lightSleep,
    this.remSleep,
    this.awakeTime,
    required this.source,
    required this.createdAt,
  });

  factory SleepDataResponse.fromJson(Map<String, dynamic> json) =>
      _$SleepDataResponseFromJson(json);
  Map<String, dynamic> toJson() => _$SleepDataResponseToJson(this);
}

@JsonSerializable()
class HeartRateDataResponse {
  final int id;
  final String timestamp;
  final int? value;
  @JsonKey(name: 'resting_rate')
  final int? restingRate;
  @JsonKey(name: 'activity_type')
  final String? activityType;
  final String source;
  @JsonKey(name: 'created_at')
  final String createdAt;

  HeartRateDataResponse({
    required this.id,
    required this.timestamp,
    this.value,
    this.restingRate,
    this.activityType,
    required this.source,
    required this.createdAt,
  });

  factory HeartRateDataResponse.fromJson(Map<String, dynamic> json) =>
      _$HeartRateDataResponseFromJson(json);
  Map<String, dynamic> toJson() => _$HeartRateDataResponseToJson(this);
}

@JsonSerializable()
class WeightDataResponse {
  final int id;
  final String timestamp;
  final double? value;
  final double? bmi;
  @JsonKey(name: 'body_fat')
  final double? bodyFat;
  @JsonKey(name: 'muscle_mass')
  final double? muscleMass;
  @JsonKey(name: 'water_percentage')
  final double? waterPercentage;
  @JsonKey(name: 'bone_mass')
  final double? boneMass;
  final String source;
  @JsonKey(name: 'created_at')
  final String createdAt;

  WeightDataResponse({
    required this.id,
    required this.timestamp,
    this.value,
    this.bmi,
    this.bodyFat,
    this.muscleMass,
    this.waterPercentage,
    this.boneMass,
    required this.source,
    required this.createdAt,
  });

  factory WeightDataResponse.fromJson(Map<String, dynamic> json) =>
      _$WeightDataResponseFromJson(json);
  Map<String, dynamic> toJson() => _$WeightDataResponseToJson(this);
}

@JsonSerializable()
class DailyHealthSummaryResponse {
  final String status;
  final DailyHealthData data;

  DailyHealthSummaryResponse({
    required this.status,
    required this.data,
  });

  factory DailyHealthSummaryResponse.fromJson(Map<String, dynamic> json) =>
      _$DailyHealthSummaryResponseFromJson(json);
  Map<String, dynamic> toJson() => _$DailyHealthSummaryResponseToJson(this);
}

@JsonSerializable()
class DailyHealthData {
  final String date;
  final List<SleepDataResponse> sleep;
  @JsonKey(name: 'heart_rate')
  final List<HeartRateDataResponse> heartRate;
  final List<WeightDataResponse> weight;

  DailyHealthData({
    required this.date,
    required this.sleep,
    required this.heartRate,
    required this.weight,
  });

  factory DailyHealthData.fromJson(Map<String, dynamic> json) =>
      _$DailyHealthDataFromJson(json);
  Map<String, dynamic> toJson() => _$DailyHealthDataToJson(this);
}

@JsonSerializable()
class HealthInsightsResponse {
  final String status;
  final HealthInsights insights;

  HealthInsightsResponse({
    required this.status,
    required this.insights,
  });

  factory HealthInsightsResponse.fromJson(Map<String, dynamic> json) =>
      _$HealthInsightsResponseFromJson(json);
  Map<String, dynamic> toJson() => _$HealthInsightsResponseToJson(this);
}

@JsonSerializable()
class HealthInsights {
  final String summary;
  final String status;
  final List<String> highlights;
  final List<String> recommendations;
  @JsonKey(name: 'next_steps')
  final String nextSteps;

  HealthInsights({
    required this.summary,
    required this.status,
    required this.highlights,
    required this.recommendations,
    required this.nextSteps,
  });

  factory HealthInsights.fromJson(Map<String, dynamic> json) =>
      _$HealthInsightsFromJson(json);
  Map<String, dynamic> toJson() => _$HealthInsightsToJson(this);
}

// ============================================================================
// ENUMS
// ============================================================================

enum MetricType {
  @JsonValue('sleep')
  sleep,
  @JsonValue('heart_rate')
  heartRate,
  @JsonValue('weight')
  weight,
}

enum InsightStatus {
  @JsonValue('good')
  good,
  @JsonValue('fair')
  fair,
  @JsonValue('poor')
  poor,
}

// ============================================================================
// EXTENSIONS
// ============================================================================

extension MetricTypeExtension on MetricType {
  String get value {
    switch (this) {
      case MetricType.sleep:
        return 'sleep';
      case MetricType.heartRate:
        return 'heart_rate';
      case MetricType.weight:
        return 'weight';
    }
  }
} 