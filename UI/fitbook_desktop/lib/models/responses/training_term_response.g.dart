// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'training_term_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TrainingTermResponse _$TrainingTermResponseFromJson(
  Map<String, dynamic> json,
) => TrainingTermResponse(
  id: (json['id'] as num).toInt(),
  startTimeUtc: DateTime.parse(json['startTimeUtc'] as String),
  endTimeUtc: DateTime.parse(json['endTimeUtc'] as String),
  maxParticipants: (json['maxParticipants'] as num).toInt(),
  status: $enumDecode(_$TrainingTermStatusEnumMap, json['status']),
  isActive: json['isActive'] as bool,
  trainingId: (json['trainingId'] as num).toInt(),
  trainingName: json['trainingName'] as String,
  trainerId: (json['trainerId'] as num).toInt(),
  trainerFirstName: json['trainerFirstName'] as String,
  trainerLastName: json['trainerLastName'] as String,
  hallId: (json['hallId'] as num).toInt(),
  hallName: json['hallName'] as String,
  createdAtUtc: DateTime.parse(json['createdAtUtc'] as String),
  updatedAtUtc: json['updatedAtUtc'] == null
      ? null
      : DateTime.parse(json['updatedAtUtc'] as String),
);

Map<String, dynamic> _$TrainingTermResponseToJson(
  TrainingTermResponse instance,
) => <String, dynamic>{
  'id': instance.id,
  'startTimeUtc': instance.startTimeUtc.toIso8601String(),
  'endTimeUtc': instance.endTimeUtc.toIso8601String(),
  'maxParticipants': instance.maxParticipants,
  'status': _$TrainingTermStatusEnumMap[instance.status]!,
  'isActive': instance.isActive,
  'trainingId': instance.trainingId,
  'trainingName': instance.trainingName,
  'trainerId': instance.trainerId,
  'trainerFirstName': instance.trainerFirstName,
  'trainerLastName': instance.trainerLastName,
  'hallId': instance.hallId,
  'hallName': instance.hallName,
  'createdAtUtc': instance.createdAtUtc.toIso8601String(),
  'updatedAtUtc': instance.updatedAtUtc?.toIso8601String(),
};

const _$TrainingTermStatusEnumMap = {
  TrainingTermStatus.scheduled: 1,
  TrainingTermStatus.cancelled: 2,
  TrainingTermStatus.completed: 3,
};
