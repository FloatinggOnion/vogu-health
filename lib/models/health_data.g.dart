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

class SleepPhasesAdapter extends TypeAdapter<SleepPhases> {
  @override
  final int typeId = 1;

  @override
  SleepPhases read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SleepPhases(
      deep: fields[0] as int,
      light: fields[1] as int,
      rem: fields[2] as int,
      awake: fields[3] as int,
    );
  }

  @override
  void write(BinaryWriter writer, SleepPhases obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.deep)
      ..writeByte(1)
      ..write(obj.light)
      ..writeByte(2)
      ..write(obj.rem)
      ..writeByte(3)
      ..write(obj.awake);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SleepPhasesAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class SleepDataAdapter extends TypeAdapter<SleepData> {
  @override
  final int typeId = 2;

  @override
  SleepData read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SleepData(
      startTime: fields[0] as DateTime,
      endTime: fields[1] as DateTime,
      quality: fields[2] as int,
      phases: fields[3] as SleepPhases,
    );
  }

  @override
  void write(BinaryWriter writer, SleepData obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.startTime)
      ..writeByte(1)
      ..write(obj.endTime)
      ..writeByte(2)
      ..write(obj.quality)
      ..writeByte(3)
      ..write(obj.phases);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SleepDataAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class HeartRateDataAdapter extends TypeAdapter<HeartRateData> {
  @override
  final int typeId = 3;

  @override
  HeartRateData read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HeartRateData(
      timestamp: fields[0] as DateTime,
      value: fields[1] as int,
      restingRate: fields[2] as int?,
      activityType: fields[3] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, HeartRateData obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.timestamp)
      ..writeByte(1)
      ..write(obj.value)
      ..writeByte(2)
      ..write(obj.restingRate)
      ..writeByte(3)
      ..write(obj.activityType);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HeartRateDataAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class BodyCompositionAdapter extends TypeAdapter<BodyComposition> {
  @override
  final int typeId = 4;

  @override
  BodyComposition read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return BodyComposition(
      bodyFat: fields[0] as double,
      muscleMass: fields[1] as double,
      waterPercentage: fields[2] as double,
      boneMass: fields[3] as double?,
    );
  }

  @override
  void write(BinaryWriter writer, BodyComposition obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.bodyFat)
      ..writeByte(1)
      ..write(obj.muscleMass)
      ..writeByte(2)
      ..write(obj.waterPercentage)
      ..writeByte(3)
      ..write(obj.boneMass);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BodyCompositionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class WeightDataAdapter extends TypeAdapter<WeightData> {
  @override
  final int typeId = 5;

  @override
  WeightData read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return WeightData(
      timestamp: fields[0] as DateTime,
      value: fields[1] as double,
      bmi: fields[2] as double?,
      bodyComposition: fields[3] as BodyComposition?,
    );
  }

  @override
  void write(BinaryWriter writer, WeightData obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.timestamp)
      ..writeByte(1)
      ..write(obj.value)
      ..writeByte(2)
      ..write(obj.bmi)
      ..writeByte(3)
      ..write(obj.bodyComposition);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WeightDataAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class HealthMetricsAdapter extends TypeAdapter<HealthMetrics> {
  @override
  final int typeId = 6;

  @override
  HealthMetrics read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HealthMetrics(
      heartRate: (fields[0] as List).cast<HeartRateData>(),
      sleep: (fields[1] as List).cast<SleepData>(),
      weight: (fields[2] as List).cast<WeightData>(),
    );
  }

  @override
  void write(BinaryWriter writer, HealthMetrics obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.heartRate)
      ..writeByte(1)
      ..write(obj.sleep)
      ..writeByte(2)
      ..write(obj.weight);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HealthMetricsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class HealthInsightAdapter extends TypeAdapter<HealthInsight> {
  @override
  final int typeId = 7;

  @override
  HealthInsight read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HealthInsight(
      message: fields[0] as String,
      category: fields[1] as String,
      timestamp: fields[2] as DateTime,
      recommendation: fields[3] as String?,
      confidence: fields[4] as double?,
      metrics: (fields[5] as Map?)?.cast<String, dynamic>(),
      actionType: fields[6] as String?,
      priority: fields[7] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, HealthInsight obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.message)
      ..writeByte(1)
      ..write(obj.category)
      ..writeByte(2)
      ..write(obj.timestamp)
      ..writeByte(3)
      ..write(obj.recommendation)
      ..writeByte(4)
      ..write(obj.confidence)
      ..writeByte(5)
      ..write(obj.metrics)
      ..writeByte(6)
      ..write(obj.actionType)
      ..writeByte(7)
      ..write(obj.priority);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HealthInsightAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SleepPhases _$SleepPhasesFromJson(Map<String, dynamic> json) => SleepPhases(
      deep: (json['deep'] as num).toInt(),
      light: (json['light'] as num).toInt(),
      rem: (json['rem'] as num).toInt(),
      awake: (json['awake'] as num).toInt(),
    );

Map<String, dynamic> _$SleepPhasesToJson(SleepPhases instance) =>
    <String, dynamic>{
      'deep': instance.deep,
      'light': instance.light,
      'rem': instance.rem,
      'awake': instance.awake,
    };

SleepData _$SleepDataFromJson(Map<String, dynamic> json) => SleepData(
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: DateTime.parse(json['endTime'] as String),
      quality: (json['quality'] as num).toInt(),
      phases: SleepPhases.fromJson(json['phases'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$SleepDataToJson(SleepData instance) => <String, dynamic>{
      'startTime': instance.startTime.toIso8601String(),
      'endTime': instance.endTime.toIso8601String(),
      'quality': instance.quality,
      'phases': instance.phases,
    };

HeartRateData _$HeartRateDataFromJson(Map<String, dynamic> json) =>
    HeartRateData(
      timestamp: DateTime.parse(json['timestamp'] as String),
      value: (json['value'] as num).toInt(),
      restingRate: (json['restingRate'] as num?)?.toInt(),
      activityType: json['activityType'] as String?,
    );

Map<String, dynamic> _$HeartRateDataToJson(HeartRateData instance) =>
    <String, dynamic>{
      'timestamp': instance.timestamp.toIso8601String(),
      'value': instance.value,
      'restingRate': instance.restingRate,
      'activityType': instance.activityType,
    };

BodyComposition _$BodyCompositionFromJson(Map<String, dynamic> json) =>
    BodyComposition(
      bodyFat: (json['bodyFat'] as num).toDouble(),
      muscleMass: (json['muscleMass'] as num).toDouble(),
      waterPercentage: (json['waterPercentage'] as num).toDouble(),
      boneMass: (json['boneMass'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$BodyCompositionToJson(BodyComposition instance) =>
    <String, dynamic>{
      'bodyFat': instance.bodyFat,
      'muscleMass': instance.muscleMass,
      'waterPercentage': instance.waterPercentage,
      'boneMass': instance.boneMass,
    };

WeightData _$WeightDataFromJson(Map<String, dynamic> json) => WeightData(
      timestamp: DateTime.parse(json['timestamp'] as String),
      value: (json['value'] as num).toDouble(),
      bmi: (json['bmi'] as num?)?.toDouble(),
      bodyComposition: json['bodyComposition'] == null
          ? null
          : BodyComposition.fromJson(
              json['bodyComposition'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$WeightDataToJson(WeightData instance) =>
    <String, dynamic>{
      'timestamp': instance.timestamp.toIso8601String(),
      'value': instance.value,
      'bmi': instance.bmi,
      'bodyComposition': instance.bodyComposition,
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
