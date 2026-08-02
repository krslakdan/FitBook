import 'package:flutter/material.dart';

import '../models/enums/reservation_status.dart';
import '../models/responses/reservation_response.dart';
import '../theme/app_theme.dart';
import '../widgets/status_chip.dart';
import 'formatters.dart';

(String, ChipTone) reservationStatusDisplay(ReservationStatus status) => switch (status) {
  ReservationStatus.pending => ('Na čekanju', ChipTone.warning),
  ReservationStatus.confirmed => ('Potvrđeno', ChipTone.success),
  ReservationStatus.cancelled => ('Otkazano', ChipTone.danger),
  ReservationStatus.completed => ('Završeno', ChipTone.neutral),
};

(Color, Color) reservationStatusColors(ReservationStatus status) => switch (status) {
  ReservationStatus.pending => (AppColors.warningSoft, AppColors.onWarningSoft),
  ReservationStatus.confirmed => (AppColors.primarySoft, AppColors.onPrimarySoft),
  ReservationStatus.cancelled => (AppColors.dangerSoft, AppColors.onDangerSoft),
  ReservationStatus.completed => (AppColors.neutralSoft, AppColors.onNeutralSoft),
};

IconData reservationStatusIcon(ReservationStatus status) => switch (status) {
  ReservationStatus.pending => Icons.hourglass_empty,
  ReservationStatus.confirmed => Icons.check_circle_outline,
  ReservationStatus.completed => Icons.verified_outlined,
  ReservationStatus.cancelled => Icons.cancel_outlined,
};

String reservationSecondaryText(ReservationResponse reservation) => switch (reservation.status) {
  ReservationStatus.pending => 'Rezervisano ${formatRelativeTime(reservation.reservedAtUtc)}',
  ReservationStatus.confirmed =>
    'Potvrđeno ${formatRelativeTime(reservation.confirmedAtUtc ?? reservation.reservedAtUtc)}',
  ReservationStatus.completed =>
    'Završeno ${formatRelativeTime(reservation.completedAtUtc ?? reservation.trainingTermEndTimeUtc)}',
  ReservationStatus.cancelled =>
    'Otkazano ${formatRelativeTime(reservation.cancelledAtUtc ?? reservation.reservedAtUtc)}',
};

bool isActiveReservation(ReservationResponse reservation) {
  final live = reservation.status == ReservationStatus.pending ||
      reservation.status == ReservationStatus.confirmed;
  return live && reservation.trainingTermEndTimeUtc.isAfter(DateTime.now().toUtc());
}
