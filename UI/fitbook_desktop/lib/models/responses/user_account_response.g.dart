// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_account_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserAccountResponse _$UserAccountResponseFromJson(Map<String, dynamic> json) =>
    UserAccountResponse(
      id: (json['id'] as num).toInt(),
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      email: json['email'] as String,
      phoneNumber: json['phoneNumber'] as String,
      username: json['username'] as String,
      role: json['role'] as String,
      profileImageUrl: json['profileImageUrl'] as String?,
      isActive: json['isActive'] as bool,
      createdAtUtc: DateTime.parse(json['createdAtUtc'] as String),
      updatedAtUtc: json['updatedAtUtc'] == null
          ? null
          : DateTime.parse(json['updatedAtUtc'] as String),
    );

Map<String, dynamic> _$UserAccountResponseToJson(
  UserAccountResponse instance,
) => <String, dynamic>{
  'id': instance.id,
  'firstName': instance.firstName,
  'lastName': instance.lastName,
  'email': instance.email,
  'phoneNumber': instance.phoneNumber,
  'username': instance.username,
  'role': instance.role,
  'profileImageUrl': instance.profileImageUrl,
  'isActive': instance.isActive,
  'createdAtUtc': instance.createdAtUtc.toIso8601String(),
  'updatedAtUtc': instance.updatedAtUtc?.toIso8601String(),
};
