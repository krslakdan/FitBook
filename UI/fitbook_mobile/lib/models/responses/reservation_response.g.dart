// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reservation_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReservationResponse _$ReservationResponseFromJson(Map<String, dynamic> json) =>
    ReservationResponse(
      id: (json['id'] as num).toInt(),
      status: $enumDecode(_$ReservationStatusEnumMap, json['status']),
      reservedAtUtc: DateTime.parse(json['reservedAtUtc'] as String),
      confirmedAtUtc: json['confirmedAtUtc'] == null
          ? null
          : DateTime.parse(json['confirmedAtUtc'] as String),
      cancelledAtUtc: json['cancelledAtUtc'] == null
          ? null
          : DateTime.parse(json['cancelledAtUtc'] as String),
      completedAtUtc: json['completedAtUtc'] == null
          ? null
          : DateTime.parse(json['completedAtUtc'] as String),
      cancellationReason: json['cancellationReason'] as String?,
      userAccountId: (json['userAccountId'] as num).toInt(),
      userFirstName: json['userFirstName'] as String,
      userLastName: json['userLastName'] as String,
      userEmail: json['userEmail'] as String,
      trainingTermId: (json['trainingTermId'] as num).toInt(),
      trainingName: json['trainingName'] as String,
      trainerFirstName: json['trainerFirstName'] as String,
      trainerLastName: json['trainerLastName'] as String,
      hallName: json['hallName'] as String,
      trainingTermStartTimeUtc: DateTime.parse(
        json['trainingTermStartTimeUtc'] as String,
      ),
      trainingTermEndTimeUtc: DateTime.parse(
        json['trainingTermEndTimeUtc'] as String,
      ),
      lastStatusChangedByUserAccountId:
          (json['lastStatusChangedByUserAccountId'] as num?)?.toInt(),
      createdAtUtc: DateTime.parse(json['createdAtUtc'] as String),
      updatedAtUtc: json['updatedAtUtc'] == null
          ? null
          : DateTime.parse(json['updatedAtUtc'] as String),
    );

Map<String, dynamic> _$ReservationResponseToJson(
  ReservationResponse instance,
) => <String, dynamic>{
  'id': instance.id,
  'status': _$ReservationStatusEnumMap[instance.status]!,
  'reservedAtUtc': instance.reservedAtUtc.toIso8601String(),
  'confirmedAtUtc': instance.confirmedAtUtc?.toIso8601String(),
  'cancelledAtUtc': instance.cancelledAtUtc?.toIso8601String(),
  'completedAtUtc': instance.completedAtUtc?.toIso8601String(),
  'cancellationReason': instance.cancellationReason,
  'userAccountId': instance.userAccountId,
  'userFirstName': instance.userFirstName,
  'userLastName': instance.userLastName,
  'userEmail': instance.userEmail,
  'trainingTermId': instance.trainingTermId,
  'trainingName': instance.trainingName,
  'trainerFirstName': instance.trainerFirstName,
  'trainerLastName': instance.trainerLastName,
  'hallName': instance.hallName,
  'trainingTermStartTimeUtc': instance.trainingTermStartTimeUtc
      .toIso8601String(),
  'trainingTermEndTimeUtc': instance.trainingTermEndTimeUtc.toIso8601String(),
  'lastStatusChangedByUserAccountId': instance.lastStatusChangedByUserAccountId,
  'createdAtUtc': instance.createdAtUtc.toIso8601String(),
  'updatedAtUtc': instance.updatedAtUtc?.toIso8601String(),
};

const _$ReservationStatusEnumMap = {
  ReservationStatus.pending: 1,
  ReservationStatus.confirmed: 2,
  ReservationStatus.cancelled: 3,
  ReservationStatus.completed: 4,
};
