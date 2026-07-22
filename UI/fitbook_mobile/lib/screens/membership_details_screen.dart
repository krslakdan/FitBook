import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../layouts/master_screen.dart';
import '../models/enums/membership_status.dart';
import '../models/responses/membership_payment_response.dart';
import '../models/requests/user_membership_cancel_request.dart';
import '../models/responses/user_membership_response.dart';
import '../models/search_objects/membership_payment_search_object.dart';
import '../providers/membership_payment_provider.dart';
import '../providers/user_membership_provider.dart';
import '../theme/app_theme.dart';
import '../utils/api_client_exception.dart';
import '../utils/formatters.dart';
import '../utils/membership_display.dart';
import '../utils/membership_payment_flow.dart';
import '../widgets/cancel_membership_dialog.dart';
import '../widgets/status_chip.dart';

class MembershipDetailsScreen extends StatefulWidget {
  const MembershipDetailsScreen({super.key, required this.membership});

  final UserMembershipResponse membership;

  @override
  State<MembershipDetailsScreen> createState() => _MembershipDetailsScreenState();
}

class _MembershipDetailsScreenState extends State<MembershipDetailsScreen> {
  late UserMembershipResponse _membership;
  List<MembershipPaymentResponse> _payments = const [];

  bool _loadingPayments = true;
  String? _paymentsError;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _membership = widget.membership;
    _refresh();
  }

  Future<void> _refresh() async {
    await Future.wait([_refreshMembership(), _loadPayments()]);
  }

  Future<void> _refreshMembership() async {
    final provider = context.read<UserMembershipProvider>();
    try {
      final updated = await provider.getById(widget.membership.id);
      if (!mounted) return;
      setState(() => _membership = updated);
    } on ApiClientException {
      return;
    }
  }

  Future<void> _loadPayments() async {
    setState(() {
      _loadingPayments = true;
      _paymentsError = null;
    });

    final provider = context.read<MembershipPaymentProvider>();
    try {
      final result = await provider.get(
        filter: MembershipPaymentSearchObject(
          userMembershipId: widget.membership.id,
          page: 1,
          pageSize: 100,
          includeTotalCount: true,
        ),
      );
      if (!mounted) return;
      final payments = [...result.items]
        ..sort((a, b) => b.createdAtUtc.compareTo(a.createdAtUtc));
      setState(() {
        _payments = payments;
        _loadingPayments = false;
      });
    } on ApiClientException catch (e) {
      if (!mounted) return;
      setState(() {
        _paymentsError = e.message;
        _loadingPayments = false;
      });
    }
  }

  Future<void> _pay() async {
    setState(() => _busy = true);
    final provider = context.read<UserMembershipProvider>();
    try {
      final result = await MembershipPaymentFlow.pay(
        provider: provider,
        membershipId: _membership.id,
      );
      if (!mounted) return;
      final (message, success) = membershipPaymentResultMessage(result);
      _showMessage(message, success: success);
      await _refresh();
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _cancel() async {
    final isPaid = _membership.isPaid;
    final reason = await showCancelMembershipDialog(context, refundExpected: isPaid);
    if (reason == null || !mounted) return;

    setState(() => _busy = true);
    final provider = context.read<UserMembershipProvider>();
    try {
      final updated = await provider.cancel(
        _membership.id,
        UserMembershipCancelRequest(reason: reason),
      );
      if (!mounted) return;
      setState(() => _membership = updated);
      _showMessage(
        isPaid ? 'Članarina je otkazana. Povrat sredstava je pokrenut.' : 'Članarina je otkazana.',
      );
      await _loadPayments();
    } on ApiClientException catch (e) {
      if (!mounted) return;
      _showMessage(e.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _showMessage(String message, {bool success = false}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: success ? AppColors.primaryDark : null,
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      title: _membership.packageName,
      subtitle: 'Detalji članarine',
      showBackButton: true,
      child: RefreshIndicator(
        onRefresh: _refresh,
        color: AppColors.primary,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          children: [
            _StatusHero(membership: _membership),
            const SizedBox(height: 20),
            _InfoCard(membership: _membership),
            const SizedBox(height: 24),
            const Text(
              'Historija plaćanja',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 12),
            ..._buildPayments(),
            const SizedBox(height: 24),
            _buildAction(),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildPayments() {
    if (_loadingPayments && _payments.isEmpty) {
      return const [
        Padding(
          padding: EdgeInsets.symmetric(vertical: 28),
          child: Center(child: CircularProgressIndicator()),
        ),
      ];
    }

    if (_paymentsError != null && _payments.isEmpty) {
      return [
        _MessageBox(
          icon: Icons.cloud_off_outlined,
          message: _paymentsError!,
          action: OutlinedButton.icon(
            onPressed: _loadPayments,
            icon: const Icon(Icons.refresh, size: 18),
            label: const Text('Pokušaj ponovo'),
          ),
        ),
      ];
    }

    if (_payments.isEmpty) {
      return const [
        _MessageBox(
          icon: Icons.receipt_long_outlined,
          message: 'Za ovu članarinu još nema zabilježenih plaćanja.',
        ),
      ];
    }

    return [
      for (final payment in _payments) ...[
        _PaymentRow(payment: payment),
        const SizedBox(height: 10),
      ],
    ];
  }

  Widget _buildAction() {
    switch (_membership.status) {
      case MembershipStatus.pending:
        return FilledButton.icon(
          onPressed: _busy ? null : _pay,
          style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(52)),
          icon: _busy
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2.4, color: Colors.white),
                )
              : const Icon(Icons.lock_outline, size: 20),
          label: Text(_busy ? 'Obrada...' : 'Dovršite plaćanje'),
        );
      case MembershipStatus.active:
        return FilledButton.icon(
          onPressed: _busy ? null : _cancel,
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.danger,
            minimumSize: const Size.fromHeight(52),
          ),
          icon: _busy
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2.4, color: Colors.white),
                )
              : const Icon(Icons.cancel_outlined, size: 20),
          label: Text(_busy ? 'Obrada...' : 'Otkaži članarinu'),
        );
      case MembershipStatus.expired:
      case MembershipStatus.cancelled:
        return const SizedBox.shrink();
    }
  }
}

class _StatusHero extends StatelessWidget {
  const _StatusHero({required this.membership});

  final UserMembershipResponse membership;

  @override
  Widget build(BuildContext context) {
    final (statusLabel, _) = membershipStatusDisplay(membership.status);
    final (background, foreground) = membershipStatusColors(membership.status);

    final subtitle = switch (membership.status) {
      MembershipStatus.active => 'Vrijedi do ${formatDate(membership.endDateUtc.toLocal())}',
      MembershipStatus.pending => 'Čeka na plaćanje',
      MembershipStatus.expired => 'Isteklo ${formatDate(membership.endDateUtc.toLocal())}',
      MembershipStatus.cancelled => 'Članarina je otkazana',
    };

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(membershipStatusIcon(membership.status), size: 26, color: foreground),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  statusLabel,
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: foreground),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.3,
                    fontWeight: FontWeight.w500,
                    color: foreground.withValues(alpha: 0.85),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.membership});

  final UserMembershipResponse membership;

  @override
  Widget build(BuildContext context) {
    final rows = <(IconData, String, String)>[
      (Icons.workspace_premium_outlined, 'Paket', membership.packageName),
      (Icons.timelapse_outlined, 'Trajanje', formatMembershipDuration(membership.packageDurationDays)),
      (Icons.payments_outlined, 'Cijena', formatMoney(membership.packagePrice)),
    ];

    if (membership.status != MembershipStatus.pending) {
      rows.add((
        Icons.date_range_outlined,
        'Period',
        '${formatDate(membership.startDateUtc.toLocal())} – ${formatDate(membership.endDateUtc.toLocal())}',
      ));
    }

    if (membership.status == MembershipStatus.active) {
      rows.add((
        Icons.hourglass_bottom_outlined,
        'Preostalo',
        formatDaysRemaining(membershipDaysRemaining(membership)),
      ));
    }

    rows.add((Icons.schedule_outlined, 'Kreirano', formatDateTime(membership.createdAtUtc)));

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var i = 0; i < rows.length; i++)
            _Line(
              icon: rows[i].$1,
              label: rows[i].$2,
              value: rows[i].$3,
              last: i == rows.length - 1,
            ),
        ],
      ),
    );
  }
}

class _Line extends StatelessWidget {
  const _Line({required this.icon, required this.label, required this.value, this.last = false});

  final IconData icon;
  final String label;
  final String value;
  final bool last;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: last ? 0 : 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.primarySoft,
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(icon, size: 19, color: AppColors.onPrimarySoft),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary)),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PaymentRow extends StatelessWidget {
  const _PaymentRow({required this.payment});

  final MembershipPaymentResponse payment;

  @override
  Widget build(BuildContext context) {
    final (statusLabel, statusTone) = paymentStatusDisplay(payment.status);
    final whenDate = payment.paidAtUtc ?? payment.createdAtUtc;
    final isRefunded = payment.refundedAtUtc != null && payment.refundAmount != null;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.neutralSoft,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(paymentStatusIcon(payment.status), size: 21, color: AppColors.onNeutralSoft),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        formatMoney(payment.amount, payment.currency),
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    StatusChip(label: statusLabel, tone: statusTone),
                  ],
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    const Icon(Icons.credit_card, size: 14, color: AppColors.textSecondary),
                    const SizedBox(width: 5),
                    Text(
                      '${payment.paymentProvider} · ${formatDateTime(whenDate)}',
                      style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
                    ),
                  ],
                ),
                if (isRefunded) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.replay, size: 14, color: AppColors.onInfoSoft),
                      const SizedBox(width: 5),
                      Text(
                        'Povrat ${formatMoney(payment.refundAmount!, payment.currency)} · ${formatDateTime(payment.refundedAtUtc)}',
                        style: const TextStyle(fontSize: 12.5, color: AppColors.onInfoSoft),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageBox extends StatelessWidget {
  const _MessageBox({required this.icon, required this.message, this.action});

  final IconData icon;
  final String message;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Icon(icon, size: 38, color: AppColors.textSecondary),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 13.5, height: 1.4, color: AppColors.textSecondary),
          ),
          if (action != null) ...[
            const SizedBox(height: 16),
            action!,
          ],
        ],
      ),
    );
  }
}
