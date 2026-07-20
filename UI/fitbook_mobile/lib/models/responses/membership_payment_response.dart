import 'package:json_annotation/json_annotation.dart';

import '../enums/payment_status.dart';

part 'membership_payment_response.g.dart';

@JsonSerializable()
class MembershipPaymentResponse {
  MembershipPaymentResponse({
    required this.id,
    required this.amount,
    required this.currency,
    required this.paymentProvider,
    required this.status,
    this.paidAtUtc,
    this.refundedAtUtc,
    this.refundAmount,
    required this.userMembershipId,
    required this.userAccountId,
    required this.createdAtUtc,
    this.updatedAtUtc,
  });

  final int id;
  final double amount;
  final String currency;
  final String paymentProvider;
  final PaymentStatus status;
  final DateTime? paidAtUtc;
  final DateTime? refundedAtUtc;
  final double? refundAmount;
  final int userMembershipId;
  final int userAccountId;
  final DateTime createdAtUtc;
  final DateTime? updatedAtUtc;

  factory MembershipPaymentResponse.fromJson(Map<String, dynamic> json) =>
      _$MembershipPaymentResponseFromJson(json);

  Map<String, dynamic> toJson() => _$MembershipPaymentResponseToJson(this);
}
