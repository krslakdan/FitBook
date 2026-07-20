// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_account_change_own_password_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserAccountChangeOwnPasswordRequest
_$UserAccountChangeOwnPasswordRequestFromJson(Map<String, dynamic> json) =>
    UserAccountChangeOwnPasswordRequest(
      currentPassword: json['currentPassword'] as String,
      newPassword: json['newPassword'] as String,
    );

Map<String, dynamic> _$UserAccountChangeOwnPasswordRequestToJson(
  UserAccountChangeOwnPasswordRequest instance,
) => <String, dynamic>{
  'currentPassword': instance.currentPassword,
  'newPassword': instance.newPassword,
};
