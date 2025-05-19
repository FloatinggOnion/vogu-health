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
class HeartRateData {
  final DateTime timestamp;
  final int heartRate;
  final int restingHeartRate;
  final int maxHeartRate;
  final int minHeartRate;

  HeartRateData({
    required this.timestamp,
    required this.heartRate,
    required this.restingHeartRate,
    required this.maxHeartRate,
    required this.minHeartRate,
  });

  factory HeartRateData.fromJson(Map<String, dynamic> json) => _$HeartRateDataFromJson(json);
  Map<String, dynamic> toJson() => _$HeartRateDataToJson(this);
}

@JsonSerializable()
class SleepData {
  final DateTime startTime;
  final DateTime endTime;
  final int totalSleepTime;
  final int deepSleepTime;
  final int lightSleepTime;
  final int remSleepTime;
  final int awakeTime;
  final int sleepQuality;
  final int sleepScore;

  SleepData({
    required this.startTime,
    required this.endTime,
    required this.totalSleepTime,
    required this.deepSleepTime,
    required this.lightSleepTime,
    required this.remSleepTime,
    required this.awakeTime,
    required this.sleepQuality,
    required this.sleepScore,
  });

  factory SleepData.fromJson(Map<String, dynamic> json) => _$SleepDataFromJson(json);
  Map<String, dynamic> toJson() => _$SleepDataToJson(this);
}

@JsonSerializable()
class WeightData {
  final DateTime timestamp;
  final double weight;
  final double bmi;
  final double bodyFat;
  final double bodyWater;
  final double muscleMass;
  final double boneMass;

  WeightData({
    required this.timestamp,
    required this.weight,
    required this.bmi,
    required this.bodyFat,
    required this.bodyWater,
    required this.muscleMass,
    required this.boneMass,
  });

  factory WeightData.fromJson(Map<String, dynamic> json) => _$WeightDataFromJson(json);
  Map<String, dynamic> toJson() => _$WeightDataToJson(this);
}

@JsonSerializable()
class HealthMetrics {
  final List<HeartRateData> heartRate;
  final List<SleepData> sleep;
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
class HealthInsight {
  final String message;
  final String category;
  final DateTime timestamp;
  final String? recommendation;
  final double? confidence;
  final Map<String, dynamic>? metrics;
  final String? actionType;
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