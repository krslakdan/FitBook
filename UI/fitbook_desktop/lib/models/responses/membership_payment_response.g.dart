// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'membership_payment_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MembershipPaymentResponse _$MembershipPaymentResponseFromJson(
  Map<String, dynamic> json,
) => MembershipPaymentResponse(
  id: (json['id'] as num).toInt(),
  amount: (json['amount'] as num).toDouble(),
  currency: json['currency'] as String,
  paymentProvider: json['paymentProvider'] as String,
  status: $enumDecode(_$PaymentStatusEnumMap, json['status']),
  paidAtUtc: json['paidAtUtc'] == null
      ? null
      : DateTime.parse(json['paidAtUtc'] as String),
  refundedAtUtc: json['refundedAtUtc'] == null
      ? null
      : DateTime.parse(json['refundedAtUtc'] as String),
  refundAmount: (json['refundAmount'] as num?)?.toDouble(),
  userMembershipId: (json['userMembershipId'] as num).toInt(),
  userAccountId: (json['userAccountId'] as num).toInt(),
  createdAtUtc: DateTime.parse(json['createdAtUtc'] as String),
  updatedAtUtc: json['updatedAtUtc'] == null
      ? null
      : DateTime.parse(json['updatedAtUtc'] as String),
);

Map<String, dynamic> _$MembershipPaymentResponseToJson(
  MembershipPaymentResponse instance,
) => <String, dynamic>{
  'id': instance.id,
  'amount': instance.amount,
  'currency': instance.currency,
  'paymentProvider': instance.paymentProvider,
  'status': _$PaymentStatusEnumMap[instance.status]!,
  'paidAtUtc': instance.paidAtUtc?.toIso8601String(),
  'refundedAtUtc': instance.refundedAtUtc?.toIso8601String(),
  'refundAmount': instance.refundAmount,
  'userMembershipId': instance.userMembershipId,
  'userAccountId': instance.userAccountId,
  'createdAtUtc': instance.createdAtUtc.toIso8601String(),
  'updatedAtUtc': instance.updatedAtUtc?.toIso8601String(),
};

const _$PaymentStatusEnumMap = {
  PaymentStatus.pending: 1,
  PaymentStatus.completed: 2,
  PaymentStatus.failed: 3,
  PaymentStatus.refunded: 4,
};
