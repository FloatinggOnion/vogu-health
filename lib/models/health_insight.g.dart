// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'health_insight.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HealthInsight _$HealthInsightFromJson(Map<String, dynamic> json) =>
    HealthInsight(
      id: json['id'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      category: json['category'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      metrics: json['metrics'] as Map<String, dynamic>?,
      recommendations: (json['recommendations'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      severity: (json['severity'] as num?)?.toInt(),
    );

Map<String, dynamic> _$HealthInsightToJson(HealthInsight instance) =>
    <String, dynamic>{
      'id': instance.id,
      'timestamp': instance.timestamp.toIso8601String(),
      'category': instance.category,
      'title': instance.title,
      'description': instance.description,
      'metrics': instance.metrics,
      'recommendations': instance.recommendations,
      'severity': instance.severity,
    };
