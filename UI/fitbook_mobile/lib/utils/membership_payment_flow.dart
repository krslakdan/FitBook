import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

import '../models/enums/membership_status.dart';
import '../models/responses/user_membership_response.dart';
import '../providers/user_membership_provider.dart';
import 'api_client_exception.dart';

enum MembershipPaymentOutcome { paid, processing, cancelled, failed, notConfigured }

class MembershipPaymentResult {
  const MembershipPaymentResult(this.outcome, {this.membership, this.message});

  final MembershipPaymentOutcome outcome;
  final UserMembershipResponse? membership;
  final String? message;
}

class MembershipPaymentFlow {
  const MembershipPaymentFlow._();

  static Future<MembershipPaymentResult> pay({
    required UserMembershipProvider provider,
    required int membershipId,
  }) async {
    try {
      final intent = await provider.createPaymentIntent(membershipId);

      if (intent.publishableKey.isEmpty) {
        return const MembershipPaymentResult(
          MembershipPaymentOutcome.notConfigured,
          message: 'Plaćanje karticom trenutno nije konfigurisano.',
        );
      }

      Stripe.publishableKey = intent.publishableKey;

      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: intent.clientSecret,
          merchantDisplayName: 'FitBook',
          style: ThemeMode.light,
        ),
      );

      await Stripe.instance.presentPaymentSheet();
    } on StripeException catch (e) {
      if (e.error.code == FailureCode.Canceled) {
        return const MembershipPaymentResult(MembershipPaymentOutcome.cancelled);
      }
      final detail = e.error.localizedMessage;
      return MembershipPaymentResult(
        MembershipPaymentOutcome.failed,
        message: (detail != null && detail.isNotEmpty)
            ? detail
            : 'Plaćanje nije uspjelo. Pokušajte ponovo.',
      );
    } on ApiClientException catch (e) {
      return MembershipPaymentResult(MembershipPaymentOutcome.failed, message: e.message);
    }

    return _finalize(provider, membershipId);
  }

  static Future<MembershipPaymentResult> _finalize(
    UserMembershipProvider provider,
    int membershipId,
  ) async {
    try {
      var membership = await provider.confirmPayment(membershipId);

      var attempts = 0;
      while (membership.status == MembershipStatus.pending && attempts < 3) {
        await Future.delayed(const Duration(milliseconds: 1200));
        membership = await provider.confirmPayment(membershipId);
        attempts++;
      }

      if (membership.status == MembershipStatus.active || membership.isPaid) {
        return MembershipPaymentResult(MembershipPaymentOutcome.paid, membership: membership);
      }
      return MembershipPaymentResult(MembershipPaymentOutcome.processing, membership: membership);
    } on ApiClientException catch (e) {
      return MembershipPaymentResult(MembershipPaymentOutcome.processing, message: e.message);
    }
  }
}

(String message, bool success) membershipPaymentResultMessage(MembershipPaymentResult result) {
  return switch (result.outcome) {
    MembershipPaymentOutcome.paid => ('Plaćanje uspješno! Vaša članarina je aktivna.', true),
    MembershipPaymentOutcome.processing => ('Plaćanje se obrađuje. Status će uskoro biti ažuriran.', false),
    MembershipPaymentOutcome.cancelled => ('Plaćanje je otkazano. Možete ga dovršiti kasnije.', false),
    MembershipPaymentOutcome.failed => (result.message ?? 'Plaćanje nije uspjelo. Pokušajte ponovo.', false),
    MembershipPaymentOutcome.notConfigured => (result.message ?? 'Plaćanje trenutno nije dostupno.', false),
  };
}
