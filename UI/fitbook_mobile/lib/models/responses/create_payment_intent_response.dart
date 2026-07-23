import 'package:json_annotation/json_annotation.dart';

part 'create_payment_intent_response.g.dart';

@JsonSerializable()
class CreatePaymentIntentResponse {
  CreatePaymentIntentResponse({
    required this.clientSecret,
    required this.paymentId,
    required this.publishableKey,
  });

  final String clientSecret;
  final int paymentId;
  final String publishableKey;

  factory CreatePaymentIntentResponse.fromJson(Map<String, dynamic> json) =>
      _$CreatePaymentIntentResponseFromJson(json);

  Map<String, dynamic> toJson() => _$CreatePaymentIntentResponseToJson(this);
}
