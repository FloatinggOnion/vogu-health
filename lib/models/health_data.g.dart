// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'health_data.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class HealthDataAdapter extends TypeAdapter<HealthData> {
  @override
  final int typeId = 0;

  @override
  HealthData read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HealthData(
      date: fields[0] as String,
      hrv: fields[1] as double?,
      stressLevel: fields[2] as int?,
      heartRate: fields[3] as int?,
      sleepHours: fields[4] as double?,
      steps: fields[5] as int?,
      caloriesBurned: fields[6] as int?,
      createdAt: fields[7] as String,
    );
  }

  @override
  void write(BinaryWriter writer, HealthData obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.date)
      ..writeByte(1)
      ..write(obj.hrv)
      ..writeByte(2)
      ..write(obj.stressLevel)
      ..writeByte(3)
      ..write(obj.heartRate)
      ..writeByte(4)
      ..write(obj.sleepHours)
      ..writeByte(5)
      ..write(obj.steps)
      ..writeByte(6)
      ..write(obj.caloriesBurned)
      ..writeByte(7)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HealthDataAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HeartRateData _$HeartRateDataFromJson(Map<String, dynamic> json) =>
    HeartRateData(
      timestamp: DateTime.parse(json['timestamp'] as String),
      heartRate: (json['heartRate'] as num).toInt(),
      restingHeartRate: (json['restingHeartRate'] as num).toInt(),
      maxHeartRate: (json['maxHeartRate'] as num).toInt(),
      minHeartRate: (json['minHeartRate'] as num).toInt(),
    );

Map<String, dynamic> _$HeartRateDataToJson(HeartRateData instance) =>
    <String, dynamic>{
      'timestamp': instance.timestamp.toIso8601String(),
      'heartRate': instance.heartRate,
      'restingHeartRate': instance.restingHeartRate,
      'maxHeartRate': instance.maxHeartRate,
      'minHeartRate': instance.minHeartRate,
    };

SleepData _$SleepDataFromJson(Map<String, dynamic> json) => SleepData(
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: DateTime.parse(json['endTime'] as String),
      totalSleepTime: (json['totalSleepTime'] as num).toInt(),
      deepSleepTime: (json['deepSleepTime'] as num).toInt(),
      lightSleepTime: (json['lightSleepTime'] as num).toInt(),
      remSleepTime: (json['remSleepTime'] as num).toInt(),
      awakeTime: (json['awakeTime'] as num).toInt(),
      sleepQuality: (json['sleepQuality'] as num).toInt(),
      sleepScore: (json['sleepScore'] as num).toInt(),
    );

Map<String, dynamic> _$SleepDataToJson(SleepData instance) => <String, dynamic>{
      'startTime': instance.startTime.toIso8601String(),
      'endTime': instance.endTime.toIso8601String(),
      'totalSleepTime': instance.totalSleepTime,
      'deepSleepTime': instance.deepSleepTime,
      'lightSleepTime': instance.lightSleepTime,
      'remSleepTime': instance.remSleepTime,
      'awakeTime': instance.awakeTime,
      'sleepQuality': instance.sleepQuality,
      'sleepScore': instance.sleepScore,
    };

WeightData _$WeightDataFromJson(Map<String, dynamic> json) => WeightData(
      timestamp: DateTime.parse(json['timestamp'] as String),
      weight: (json['weight'] as num).toDouble(),
      bmi: (json['bmi'] as num).toDouble(),
      bodyFat: (json['bodyFat'] as num).toDouble(),
      bodyWater: (json['bodyWater'] as num).toDouble(),
      muscleMass: (json['muscleMass'] as num).toDouble(),
      boneMass: (json['boneMass'] as num).toDouble(),
    );

Map<String, dynamic> _$WeightDataToJson(WeightData instance) =>
    <String, dynamic>{
      'timestamp': instance.timestamp.toIso8601String(),
      'weight': instance.weight,
      'bmi': instance.bmi,
      'bodyFat': instance.bodyFat,
      'bodyWater': instance.bodyWater,
      'muscleMass': instance.muscleMass,
      'boneMass': instance.boneMass,
    };

HealthMetrics _$HealthMetricsFromJson(Map<String, dynamic> json) =>
    HealthMetrics(
      heartRate: (json['heartRate'] as List<dynamic>)
          .map((e) => HeartRateData.fromJson(e as Map<String, dynamic>))
          .toList(),
      sleep: (json['sleep'] as List<dynamic>)
          .map((e) => SleepData.fromJson(e as Map<String, dynamic>))
          .toList(),
      weight: (json['weight'] as List<dynamic>)
          .map((e) => WeightData.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$HealthMetricsToJson(HealthMetrics instance) =>
    <String, dynamic>{
      'heartRate': instance.heartRate,
      'sleep': instance.sleep,
      'weight': instance.weight,
    };

HealthInsight _$HealthInsightFromJson(Map<String, dynamic> json) =>
    HealthInsight(
      message: json['message'] as String,
      category: json['category'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      recommendation: json['recommendation'] as String?,
      confidence: (json['confidence'] as num?)?.toDouble(),
      metrics: json['metrics'] as Map<String, dynamic>?,
      actionType: json['actionType'] as String?,
      priority: json['priority'] as String?,
    );

Map<String, dynamic> _$HealthInsightToJson(HealthInsight instance) =>
    <String, dynamic>{
      'message': instance.message,
      'category': instance.category,
      'timestamp': instance.timestamp.toIso8601String(),
      'recommendation': instance.recommendation,
      'confidence': instance.confidence,
      'metrics': instance.metrics,
      'actionType': instance.actionType,
      'priority': instance.priority,
    };
