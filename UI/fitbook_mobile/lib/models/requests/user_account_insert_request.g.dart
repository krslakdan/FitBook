// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_account_insert_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserAccountInsertRequest _$UserAccountInsertRequestFromJson(
  Map<String, dynamic> json,
) => UserAccountInsertRequest(
  firstName: json['firstName'] as String,
  lastName: json['lastName'] as String,
  email: json['email'] as String,
  phoneNumber: json['phoneNumber'] as String,
  username: json['username'] as String,
  password: json['password'] as String,
  role: json['role'] as String,
  profileImageUrl: json['profileImageUrl'] as String?,
  isActive: json['isActive'] as bool? ?? true,
);

Map<String, dynamic> _$UserAccountInsertRequestToJson(
  UserAccountInsertRequest instance,
) => <String, dynamic>{
  'firstName': instance.firstName,
  'lastName': instance.lastName,
  'email': instance.email,
  'phoneNumber': instance.phoneNumber,
  'username': instance.username,
  'password': instance.password,
  'role': instance.role,
  'profileImageUrl': instance.profileImageUrl,
  'isActive': instance.isActive,
};
