import 'package:flutter/material.dart';

import '../models/enums/membership_status.dart';
import '../models/enums/payment_status.dart';
import '../models/responses/user_membership_response.dart';
import '../theme/app_theme.dart';
import '../widgets/status_chip.dart';

(String, ChipTone) membershipStatusDisplay(MembershipStatus status) => switch (status) {
  MembershipStatus.pending => ('Na čekanju', ChipTone.warning),
  MembershipStatus.active => ('Aktivna', ChipTone.success),
  MembershipStatus.expired => ('Istekla', ChipTone.neutral),
  MembershipStatus.cancelled => ('Otkazana', ChipTone.danger),
};

(Color, Color) membershipStatusColors(MembershipStatus status) => switch (status) {
  MembershipStatus.pending => (AppColors.warningSoft, AppColors.onWarningSoft),
  MembershipStatus.active => (AppColors.primarySoft, AppColors.onPrimarySoft),
  MembershipStatus.expired => (AppColors.neutralSoft, AppColors.onNeutralSoft),
  MembershipStatus.cancelled => (AppColors.dangerSoft, AppColors.onDangerSoft),
};

IconData membershipStatusIcon(MembershipStatus status) => switch (status) {
  MembershipStatus.pending => Icons.hourglass_empty,
  MembershipStatus.active => Icons.workspace_premium,
  MembershipStatus.expired => Icons.history,
  MembershipStatus.cancelled => Icons.cancel_outlined,
};

(String, ChipTone) paymentStatusDisplay(PaymentStatus status) => switch (status) {
  PaymentStatus.pending => ('Na čekanju', ChipTone.warning),
  PaymentStatus.completed => ('Plaćeno', ChipTone.success),
  PaymentStatus.failed => ('Neuspješno', ChipTone.danger),
  PaymentStatus.refunded => ('Refundirano', ChipTone.info),
};

IconData paymentStatusIcon(PaymentStatus status) => switch (status) {
  PaymentStatus.pending => Icons.schedule,
  PaymentStatus.completed => Icons.check_circle_outline,
  PaymentStatus.failed => Icons.error_outline,
  PaymentStatus.refunded => Icons.replay_circle_filled_outlined,
};

bool isCurrentMembership(UserMembershipResponse membership) =>
    membership.status == MembershipStatus.pending ||
    membership.status == MembershipStatus.active;

int membershipDaysRemaining(UserMembershipResponse membership) {
  final end = membership.endDateUtc.toLocal();
  final now = DateTime.now();
  return end.difference(now).inDays;
}
