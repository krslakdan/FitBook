// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_payment_intent_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreatePaymentIntentResponse _$CreatePaymentIntentResponseFromJson(
  Map<String, dynamic> json,
) => CreatePaymentIntentResponse(
  clientSecret: json['clientSecret'] as String,
  paymentId: (json['paymentId'] as num).toInt(),
);

Map<String, dynamic> _$CreatePaymentIntentResponseToJson(
  CreatePaymentIntentResponse instance,
) => <String, dynamic>{
  'clientSecret': instance.clientSecret,
  'paymentId': instance.paymentId,
};
