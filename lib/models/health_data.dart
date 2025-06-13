import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';

part 'health_data.g.dart';

@HiveType(typeId: 0)
class HealthData extends HiveObject {
  @HiveField(0)
  final String date;

  @HiveField(1)
  final double? hrv;

  @HiveField(2)
  final int? stressLevel;

  @HiveField(3)
  final int? heartRate;

  @HiveField(4)
  final double? sleepHours;

  @HiveField(5)
  final int? steps;

  @HiveField(6)
  final int? caloriesBurned;

  @HiveField(7)
  final String createdAt;

  HealthData({
    required this.date,
    this.hrv,
    this.stressLevel,
    this.heartRate,
    this.sleepHours,
    this.steps,
    this.caloriesBurned,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'date': date,
      'hrv': hrv,
      'stress_level': stressLevel,
      'heart_rate': heartRate,
      'sleep_hours': sleepHours,
      'steps': steps,
      'calories_burned': caloriesBurned,
      'created_at': createdAt,
    };
  }

  factory HealthData.fromMap(Map<String, dynamic> map) {
    return HealthData(
      date: map['date'] as String,
      hrv: map['hrv'] as double?,
      stressLevel: map['stress_level'] as int?,
      heartRate: map['heart_rate'] as int?,
      sleepHours: map['sleep_hours'] as double?,
      steps: map['steps'] as int?,
      caloriesBurned: map['calories_burned'] as int?,
      createdAt: map['created_at'] as String,
    );
  }
}

@JsonSerializable()
@HiveType(typeId: 1)
class SleepPhases {
  @HiveField(0)
  final int deep;
  @HiveField(1)
  final int light;
  @HiveField(2)
  final int rem;
  @HiveField(3)
  final int awake;

  SleepPhases({
    required this.deep,
    required this.light,
    required this.rem,
    required this.awake,
  });

  factory SleepPhases.fromJson(Map<String, dynamic> json) => _$SleepPhasesFromJson(json);
  Map<String, dynamic> toJson() => _$SleepPhasesToJson(this);
}

@JsonSerializable()
@HiveType(typeId: 2)
class SleepData {
  @HiveField(0)
  final DateTime startTime;
  @HiveField(1)
  final DateTime endTime;
  @HiveField(2)
  final int quality;
  @HiveField(3)
  final SleepPhases phases;

  SleepData({
    required this.startTime,
    required this.endTime,
    required this.quality,
    required this.phases,
  });

  factory SleepData.fromJson(Map<String, dynamic> json) => _$SleepDataFromJson(json);
  Map<String, dynamic> toJson() => _$SleepDataToJson(this);
}

@JsonSerializable()
@HiveType(typeId: 3)
class HeartRateData {
  @HiveField(0)
  final DateTime timestamp;
  @HiveField(1)
  final int value;
  @HiveField(2)
  final int? restingRate;
  @HiveField(3)
  final String? activityType;

  HeartRateData({
    required this.timestamp,
    required this.value,
    this.restingRate,
    this.activityType,
  });

  factory HeartRateData.fromJson(Map<String, dynamic> json) => _$HeartRateDataFromJson(json);
  Map<String, dynamic> toJson() => _$HeartRateDataToJson(this);
}

@JsonSerializable()
@HiveType(typeId: 4)
class BodyComposition {
  @HiveField(0)
  final double bodyFat;
  @HiveField(1)
  final double muscleMass;
  @HiveField(2)
  final double waterPercentage;
  @HiveField(3)
  final double? boneMass;

  BodyComposition({
    required this.bodyFat,
    required this.muscleMass,
    required this.waterPercentage,
    this.boneMass,
  });

  factory BodyComposition.fromJson(Map<String, dynamic> json) => _$BodyCompositionFromJson(json);
  Map<String, dynamic> toJson() => _$BodyCompositionToJson(this);
}

@JsonSerializable()
@HiveType(typeId: 5)
class WeightData {
  @HiveField(0)
  final DateTime timestamp;
  @HiveField(1)
  final double value;
  @HiveField(2)
  final double? bmi;
  @HiveField(3)
  final BodyComposition? bodyComposition;

  WeightData({
    required this.timestamp,
    required this.value,
    this.bmi,
    this.bodyComposition,
  });

  factory WeightData.fromJson(Map<String, dynamic> json) => _$WeightDataFromJson(json);
  Map<String, dynamic> toJson() => _$WeightDataToJson(this);
}

@JsonSerializable()
@HiveType(typeId: 6)
class HealthMetrics {
  @HiveField(0)
  final List<HeartRateData> heartRate;
  @HiveField(1)
  final List<SleepData> sleep;
  @HiveField(2)
  final List<WeightData> weight;

  HealthMetrics({
    required this.heartRate,
    required this.sleep,
    required this.weight,
  });

  factory HealthMetrics.fromJson(Map<String, dynamic> json) => _$HealthMetricsFromJson(json);
  Map<String, dynamic> toJson() => _$HealthMetricsToJson(this);
}

@JsonSerializable()
@HiveType(typeId: 7)
class HealthInsight {
  @HiveField(0)
  final String message;
  @HiveField(1)
  final String category;
  @HiveField(2)
  final DateTime timestamp;
  @HiveField(3)
  final String? recommendation;
  @HiveField(4)
  final double? confidence;
  @HiveField(5)
  final Map<String, dynamic>? metrics;
  @HiveField(6)
  final String? actionType;
  @HiveField(7)
  final String? priority;

  HealthInsight({
    required this.message,
    required this.category,
    required this.timestamp,
    this.recommendation,
    this.confidence,
    this.metrics,
    this.actionType,
    this.priority,
  });

  factory HealthInsight.fromJson(Map<String, dynamic> json) => _$HealthInsightFromJson(json);
  Map<String, dynamic> toJson() => _$HealthInsightToJson(this);
} 