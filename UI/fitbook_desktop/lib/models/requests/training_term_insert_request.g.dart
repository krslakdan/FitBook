// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'training_term_insert_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TrainingTermInsertRequest _$TrainingTermInsertRequestFromJson(
  Map<String, dynamic> json,
) => TrainingTermInsertRequest(
  startTimeUtc: DateTime.parse(json['startTimeUtc'] as String),
  endTimeUtc: DateTime.parse(json['endTimeUtc'] as String),
  maxParticipants: (json['maxParticipants'] as num).toInt(),
  isActive: json['isActive'] as bool,
  trainingId: (json['trainingId'] as num).toInt(),
  trainerId: (json['trainerId'] as num).toInt(),
  hallId: (json['hallId'] as num).toInt(),
);

Map<String, dynamic> _$TrainingTermInsertRequestToJson(
  TrainingTermInsertRequest instance,
) => <String, dynamic>{
  'startTimeUtc': instance.startTimeUtc.toIso8601String(),
  'endTimeUtc': instance.endTimeUtc.toIso8601String(),
  'maxParticipants': instance.maxParticipants,
  'isActive': instance.isActive,
  'trainingId': instance.trainingId,
  'trainerId': instance.trainerId,
  'hallId': instance.hallId,
};
