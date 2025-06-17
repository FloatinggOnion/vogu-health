// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SleepDataRequest _$SleepDataRequestFromJson(Map<String, dynamic> json) =>
    SleepDataRequest(
      startTime: json['start_time'] as String,
      endTime: json['end_time'] as String,
      quality: (json['quality'] as num).toInt(),
      phases: SleepPhases.fromJson(json['phases'] as Map<String, dynamic>),
      source: json['source'] as String,
    );

Map<String, dynamic> _$SleepDataRequestToJson(SleepDataRequest instance) =>
    <String, dynamic>{
      'start_time': instance.startTime,
      'end_time': instance.endTime,
      'quality': instance.quality,
      'phases': instance.phases,
      'source': instance.source,
    };

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

HeartRateDataRequest _$HeartRateDataRequestFromJson(
        Map<String, dynamic> json) =>
    HeartRateDataRequest(
      timestamp: json['timestamp'] as String,
      value: (json['value'] as num).toInt(),
      restingRate: (json['resting_rate'] as num).toInt(),
      activityType: json['activity_type'] as String?,
      source: json['source'] as String,
    );

Map<String, dynamic> _$HeartRateDataRequestToJson(
        HeartRateDataRequest instance) =>
    <String, dynamic>{
      'timestamp': instance.timestamp,
      'value': instance.value,
      'resting_rate': instance.restingRate,
      'activity_type': instance.activityType,
      'source': instance.source,
    };

WeightDataRequest _$WeightDataRequestFromJson(Map<String, dynamic> json) =>
    WeightDataRequest(
      timestamp: json['timestamp'] as String,
      value: (json['value'] as num).toDouble(),
      bmi: (json['bmi'] as num).toDouble(),
      bodyComposition: json['body_composition'] == null
          ? null
          : BodyComposition.fromJson(
              json['body_composition'] as Map<String, dynamic>),
      source: json['source'] as String,
    );

Map<String, dynamic> _$WeightDataRequestToJson(WeightDataRequest instance) =>
    <String, dynamic>{
      'timestamp': instance.timestamp,
      'value': instance.value,
      'bmi': instance.bmi,
      'body_composition': instance.bodyComposition,
      'source': instance.source,
    };

BodyComposition _$BodyCompositionFromJson(Map<String, dynamic> json) =>
    BodyComposition(
      bodyFat: (json['body_fat'] as num?)?.toDouble(),
      muscleMass: (json['muscle_mass'] as num?)?.toDouble(),
      waterPercentage: (json['water_percentage'] as num?)?.toDouble(),
      boneMass: (json['bone_mass'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$BodyCompositionToJson(BodyComposition instance) =>
    <String, dynamic>{
      'body_fat': instance.bodyFat,
      'muscle_mass': instance.muscleMass,
      'water_percentage': instance.waterPercentage,
      'bone_mass': instance.boneMass,
    };

ApiResponse _$ApiResponseFromJson(Map<String, dynamic> json) => ApiResponse(
      status: json['status'] as String,
      message: json['message'] as String,
    );

Map<String, dynamic> _$ApiResponseToJson(ApiResponse instance) =>
    <String, dynamic>{
      'status': instance.status,
      'message': instance.message,
    };

SleepDataResponse _$SleepDataResponseFromJson(Map<String, dynamic> json) =>
    SleepDataResponse(
      id: (json['id'] as num).toInt(),
      startTime: json['start_time'] as String,
      endTime: json['end_time'] as String,
      quality: (json['quality'] as num?)?.toInt(),
      deepSleep: (json['deep_sleep'] as num?)?.toInt(),
      lightSleep: (json['light_sleep'] as num?)?.toInt(),
      remSleep: (json['rem_sleep'] as num?)?.toInt(),
      awakeTime: (json['awake_time'] as num?)?.toInt(),
      source: json['source'] as String,
      createdAt: json['created_at'] as String,
    );

Map<String, dynamic> _$SleepDataResponseToJson(SleepDataResponse instance) =>
    <String, dynamic>{
      'id': instance.id,
      'start_time': instance.startTime,
      'end_time': instance.endTime,
      'quality': instance.quality,
      'deep_sleep': instance.deepSleep,
      'light_sleep': instance.lightSleep,
      'rem_sleep': instance.remSleep,
      'awake_time': instance.awakeTime,
      'source': instance.source,
      'created_at': instance.createdAt,
    };

HeartRateDataResponse _$HeartRateDataResponseFromJson(
        Map<String, dynamic> json) =>
    HeartRateDataResponse(
      id: (json['id'] as num).toInt(),
      timestamp: json['timestamp'] as String,
      value: (json['value'] as num?)?.toInt(),
      restingRate: (json['resting_rate'] as num?)?.toInt(),
      activityType: json['activity_type'] as String?,
      source: json['source'] as String,
      createdAt: json['created_at'] as String,
    );

Map<String, dynamic> _$HeartRateDataResponseToJson(
        HeartRateDataResponse instance) =>
    <String, dynamic>{
      'id': instance.id,
      'timestamp': instance.timestamp,
      'value': instance.value,
      'resting_rate': instance.restingRate,
      'activity_type': instance.activityType,
      'source': instance.source,
      'created_at': instance.createdAt,
    };

WeightDataResponse _$WeightDataResponseFromJson(Map<String, dynamic> json) =>
    WeightDataResponse(
      id: (json['id'] as num).toInt(),
      timestamp: json['timestamp'] as String,
      value: (json['value'] as num?)?.toDouble(),
      bmi: (json['bmi'] as num?)?.toDouble(),
      bodyFat: (json['body_fat'] as num?)?.toDouble(),
      muscleMass: (json['muscle_mass'] as num?)?.toDouble(),
      waterPercentage: (json['water_percentage'] as num?)?.toDouble(),
      boneMass: (json['bone_mass'] as num?)?.toDouble(),
      source: json['source'] as String,
      createdAt: json['created_at'] as String,
    );

Map<String, dynamic> _$WeightDataResponseToJson(WeightDataResponse instance) =>
    <String, dynamic>{
      'id': instance.id,
      'timestamp': instance.timestamp,
      'value': instance.value,
      'bmi': instance.bmi,
      'body_fat': instance.bodyFat,
      'muscle_mass': instance.muscleMass,
      'water_percentage': instance.waterPercentage,
      'bone_mass': instance.boneMass,
      'source': instance.source,
      'created_at': instance.createdAt,
    };

DailyHealthSummaryResponse _$DailyHealthSummaryResponseFromJson(
        Map<String, dynamic> json) =>
    DailyHealthSummaryResponse(
      status: json['status'] as String,
      data: DailyHealthData.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$DailyHealthSummaryResponseToJson(
        DailyHealthSummaryResponse instance) =>
    <String, dynamic>{
      'status': instance.status,
      'data': instance.data,
    };

DailyHealthData _$DailyHealthDataFromJson(Map<String, dynamic> json) =>
    DailyHealthData(
      date: json['date'] as String,
      sleep: (json['sleep'] as List<dynamic>)
          .map((e) => SleepDataResponse.fromJson(e as Map<String, dynamic>))
          .toList(),
      heartRate: (json['heart_rate'] as List<dynamic>)
          .map((e) => HeartRateDataResponse.fromJson(e as Map<String, dynamic>))
          .toList(),
      weight: (json['weight'] as List<dynamic>)
          .map((e) => WeightDataResponse.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$DailyHealthDataToJson(DailyHealthData instance) =>
    <String, dynamic>{
      'date': instance.date,
      'sleep': instance.sleep,
      'heart_rate': instance.heartRate,
      'weight': instance.weight,
    };

HealthInsightsResponse _$HealthInsightsResponseFromJson(
        Map<String, dynamic> json) =>
    HealthInsightsResponse(
      status: json['status'] as String,
      insights:
          HealthInsights.fromJson(json['insights'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$HealthInsightsResponseToJson(
        HealthInsightsResponse instance) =>
    <String, dynamic>{
      'status': instance.status,
      'insights': instance.insights,
    };

HealthInsights _$HealthInsightsFromJson(Map<String, dynamic> json) =>
    HealthInsights(
      summary: json['summary'] as String,
      status: json['status'] as String,
      highlights: (json['highlights'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      recommendations: (json['recommendations'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      nextSteps: json['next_steps'] as String,
    );

Map<String, dynamic> _$HealthInsightsToJson(HealthInsights instance) =>
    <String, dynamic>{
      'summary': instance.summary,
      'status': instance.status,
      'highlights': instance.highlights,
      'recommendations': instance.recommendations,
      'next_steps': instance.nextSteps,
    };
