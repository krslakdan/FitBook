// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_account_update_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserAccountUpdateRequest _$UserAccountUpdateRequestFromJson(
  Map<String, dynamic> json,
) => UserAccountUpdateRequest(
  firstName: json['firstName'] as String?,
  lastName: json['lastName'] as String?,
  email: json['email'] as String?,
  phoneNumber: json['phoneNumber'] as String?,
  username: json['username'] as String?,
  role: json['role'] as String?,
  profileImageUrl: json['profileImageUrl'] as String?,
  isActive: json['isActive'] as bool?,
);

Map<String, dynamic> _$UserAccountUpdateRequestToJson(
  UserAccountUpdateRequest instance,
) => <String, dynamic>{
  'firstName': instance.firstName,
  'lastName': instance.lastName,
  'email': instance.email,
  'phoneNumber': instance.phoneNumber,
  'username': instance.username,
  'role': instance.role,
  'profileImageUrl': instance.profileImageUrl,
  'isActive': instance.isActive,
};
