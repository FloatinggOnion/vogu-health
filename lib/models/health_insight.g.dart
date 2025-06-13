// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'health_insight.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

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
      id: fields[0] as String,
      timestamp: fields[1] as DateTime,
      category: fields[2] as String,
      title: fields[3] as String,
      description: fields[4] as String,
      metrics: (fields[5] as Map?)?.cast<String, dynamic>(),
      recommendations: (fields[6] as List?)?.cast<String>(),
      severity: fields[7] as int?,
    );
  }

  @override
  void write(BinaryWriter writer, HealthInsight obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.timestamp)
      ..writeByte(2)
      ..write(obj.category)
      ..writeByte(3)
      ..write(obj.title)
      ..writeByte(4)
      ..write(obj.description)
      ..writeByte(5)
      ..write(obj.metrics)
      ..writeByte(6)
      ..write(obj.recommendations)
      ..writeByte(7)
      ..write(obj.severity);
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
