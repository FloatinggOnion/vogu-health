// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'insight_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

InsightResponse _$InsightResponseFromJson(Map<String, dynamic> json) =>
    InsightResponse(
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

Map<String, dynamic> _$InsightResponseToJson(InsightResponse instance) =>
    <String, dynamic>{
      'summary': instance.summary,
      'status': instance.status,
      'highlights': instance.highlights,
      'recommendations': instance.recommendations,
      'next_steps': instance.nextSteps,
    };

InsightApiResponse _$InsightApiResponseFromJson(Map<String, dynamic> json) =>
    InsightApiResponse(
      status: json['status'] as String,
      insights:
          InsightResponse.fromJson(json['insights'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$InsightApiResponseToJson(InsightApiResponse instance) =>
    <String, dynamic>{
      'status': instance.status,
      'insights': instance.insights,
    };

SleepInsightResponse _$SleepInsightResponseFromJson(
        Map<String, dynamic> json) =>
    SleepInsightResponse(
      type: json['type'] as String,
      message: json['message'] as String,
      severity: json['severity'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      additionalData: json['additionalData'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$SleepInsightResponseToJson(
        SleepInsightResponse instance) =>
    <String, dynamic>{
      'type': instance.type,
      'message': instance.message,
      'severity': instance.severity,
      'timestamp': instance.timestamp.toIso8601String(),
      'additionalData': instance.additionalData,
    };

HeartRateInsightResponse _$HeartRateInsightResponseFromJson(
        Map<String, dynamic> json) =>
    HeartRateInsightResponse(
      type: json['type'] as String,
      message: json['message'] as String,
      severity: json['severity'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      additionalData: json['additionalData'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$HeartRateInsightResponseToJson(
        HeartRateInsightResponse instance) =>
    <String, dynamic>{
      'type': instance.type,
      'message': instance.message,
      'severity': instance.severity,
      'timestamp': instance.timestamp.toIso8601String(),
      'additionalData': instance.additionalData,
    };

WeightInsightResponse _$WeightInsightResponseFromJson(
        Map<String, dynamic> json) =>
    WeightInsightResponse(
      type: json['type'] as String,
      message: json['message'] as String,
      severity: json['severity'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      additionalData: json['additionalData'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$WeightInsightResponseToJson(
        WeightInsightResponse instance) =>
    <String, dynamic>{
      'type': instance.type,
      'message': instance.message,
      'severity': instance.severity,
      'timestamp': instance.timestamp.toIso8601String(),
      'additionalData': instance.additionalData,
    };

CorrelationInsightResponse _$CorrelationInsightResponseFromJson(
        Map<String, dynamic> json) =>
    CorrelationInsightResponse(
      type: json['type'] as String,
      message: json['message'] as String,
      severity: json['severity'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      additionalData: json['additionalData'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$CorrelationInsightResponseToJson(
        CorrelationInsightResponse instance) =>
    <String, dynamic>{
      'type': instance.type,
      'message': instance.message,
      'severity': instance.severity,
      'timestamp': instance.timestamp.toIso8601String(),
      'additionalData': instance.additionalData,
    };
