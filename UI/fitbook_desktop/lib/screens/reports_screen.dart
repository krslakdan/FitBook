import 'dart:io';
import 'dart:typed_data';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';

import '../layouts/master_screen.dart';
import '../models/requests/reservations_report_request.dart';
import '../providers/report_provider.dart';
import '../theme/app_theme.dart';
import '../utils/api_client_exception.dart';
import '../utils/formatters.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  static const _maxRangeDays = 730;

  DateTime? _from;
  DateTime? _to;
  String? _rangeError;

  bool _downloadingReservations = false;
  bool _downloadingPopularity = false;
  bool _printingReservations = false;
  bool _printingPopularity = false;

  static const _pdfTypeGroup = XTypeGroup(label: 'PDF dokument', extensions: ['pdf']);

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(backgroundColor: AppColors.primaryDark, content: Text(message)),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(backgroundColor: AppColors.danger, content: Text(message)),
    );
  }

  Future<void> _pickDate({
    required DateTime? current,
    required ValueChanged<DateTime> onPicked,
  }) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: current ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );
    if (picked == null) return;
    onPicked(picked);
  }

  String? _validateRange() {
    if (_from == null || _to == null) {
      return 'Odaberite početni i krajnji datum termina.';
    }
    if (_to!.isBefore(_from!)) {
      return 'Krajnji datum termina ne može biti prije početnog datuma.';
    }
    if (calendarDaysBetween(_from!, _to!) > _maxRangeDays) {
      return 'Period izvještaja ne može biti duži od $_maxRangeDays dana.';
    }
    return null;
  }

  Future<void> _saveReport({
    required String suggestedName,
    required Future<Uint8List> Function() fetch,
    required String successLabel,
  }) async {
    final bytes = await fetch();

    final location = await getSaveLocation(
      suggestedName: suggestedName,
      acceptedTypeGroups: const [_pdfTypeGroup],
    );
    if (location == null) return;

    final path = location.path.toLowerCase().endsWith('.pdf')
        ? location.path
        : '${location.path}.pdf';
    await File(path).writeAsBytes(bytes);

    if (!mounted) return;
    _showSuccess('$successLabel je uspješno preuzet: $path');
  }

  Future<void> _printReport({
    required String documentName,
    required Future<Uint8List> Function() fetch,
  }) async {
    final bytes = await fetch();
    await Printing.layoutPdf(name: documentName, onLayout: (_) async => bytes);
  }

  Future<void> _downloadReservationsReport() async {
    final error = _validateRange();
    setState(() => _rangeError = error);
    if (error != null) return;

    final dateStamp = '${formatDateStamp(_from!)}-${formatDateStamp(_to!)}';

    setState(() => _downloadingReservations = true);
    try {
      await _saveReport(
        suggestedName: 'izvjestaj-rezervacije-$dateStamp.pdf',
        fetch: _fetchReservationsReport,
        successLabel: 'Izvještaj o rezervacijama',
      );
    } on ApiClientException catch (e) {
      if (mounted) _showError(e.message);
    } on FileSystemException {
      if (mounted) _showError('Datoteku nije moguće sačuvati na odabranu lokaciju.');
    } finally {
      if (mounted) setState(() => _downloadingReservations = false);
    }
  }

  Future<void> _printReservationsReport() async {
    final error = _validateRange();
    setState(() => _rangeError = error);
    if (error != null) return;

    final dateStamp = '${formatDateStamp(_from!)}-${formatDateStamp(_to!)}';

    setState(() => _printingReservations = true);
    try {
      await _printReport(
        documentName: 'izvjestaj-rezervacije-$dateStamp',
        fetch: _fetchReservationsReport,
      );
    } on ApiClientException catch (e) {
      if (mounted) _showError(e.message);
    } finally {
      if (mounted) setState(() => _printingReservations = false);
    }
  }

  Future<void> _downloadPopularityReport() async {
    final dateStamp = formatDateStamp(DateTime.now());

    setState(() => _downloadingPopularity = true);
    try {
      await _saveReport(
        suggestedName: 'izvjestaj-popularnost-treninga-$dateStamp.pdf',
        fetch: _fetchPopularityReport,
        successLabel: 'Izvještaj o popularnosti treninga',
      );
    } on ApiClientException catch (e) {
      if (mounted) _showError(e.message);
    } on FileSystemException {
      if (mounted) _showError('Datoteku nije moguće sačuvati na odabranu lokaciju.');
    } finally {
      if (mounted) setState(() => _downloadingPopularity = false);
    }
  }

  Future<void> _printPopularityReport() async {
    final dateStamp = formatDateStamp(DateTime.now());

    setState(() => _printingPopularity = true);
    try {
      await _printReport(
        documentName: 'izvjestaj-popularnost-treninga-$dateStamp',
        fetch: _fetchPopularityReport,
      );
    } on ApiClientException catch (e) {
      if (mounted) _showError(e.message);
    } finally {
      if (mounted) setState(() => _printingPopularity = false);
    }
  }

  Future<Uint8List> _fetchReservationsReport() {
    return context.read<ReportProvider>().getReservationsReport(
      ReservationsReportRequest(fromDate: _from!, toDate: _to!),
    );
  }

  Future<Uint8List> _fetchPopularityReport() {
    return context.read<ReportProvider>().getTrainingPopularityReport();
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      title: 'Izvještaji',
      subtitle: 'Generisanje PDF izvještaja',
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: _buildReservationsCard()),
              const SizedBox(width: 16),
              Expanded(child: _buildPopularityCard()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReservationsCard() {
    return _ReportCard(
      icon: Icons.event_available_outlined,
      title: 'Izvještaj o rezervacijama',
      description:
          'Pregled svih rezervacija za termine u odabranom periodu, sa korisnikom, '
          'treningom, terminom i statusom rezervacije.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: _DateField(
                  label: 'Termini od',
                  value: _from,
                  onTap: () => _pickDate(
                    current: _from,
                    onPicked: (picked) => setState(() {
                      _from = picked;
                      _rangeError = null;
                    }),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _DateField(
                  label: 'Termini do',
                  value: _to,
                  onTap: () => _pickDate(
                    current: _to ?? _from,
                    onPicked: (picked) => setState(() {
                      _to = picked;
                      _rangeError = null;
                    }),
                  ),
                ),
              ),
            ],
          ),
          if (_rangeError != null)
            Padding(
              padding: const EdgeInsets.only(top: 6, left: 4),
              child: Text(
                _rangeError!,
                style: const TextStyle(fontSize: 12, color: AppColors.danger),
              ),
            ),
          const SizedBox(height: 14),
          _ReportActions(
            downloading: _downloadingReservations,
            printing: _printingReservations,
            onDownload: _downloadReservationsReport,
            onPrint: _printReservationsReport,
          ),
        ],
      ),
    );
  }

  Widget _buildPopularityCard() {
    return _ReportCard(
      icon: Icons.leaderboard_outlined,
      title: 'Popularnost treninga',
      description:
          'Rang lista svih treninga po ukupnom broju rezervacija, sa kategorijom '
          'treninga. Obuhvata sve podatke u sistemu.',
      child: _ReportActions(
        downloading: _downloadingPopularity,
        printing: _printingPopularity,
        onDownload: _downloadPopularityReport,
        onPrint: _printPopularityReport,
      ),
    );
  }
}

class _ReportCard extends StatelessWidget {
  const _ReportCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.child,
  });

  final IconData icon;
  final String title;
  final String description;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.primarySoft,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 22, color: AppColors.onPrimarySoft),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            description,
            style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.5),
          ),
          const Spacer(),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _DateField extends StatelessWidget {
  const _DateField({required this.label, required this.value, required this.onTap});

  final String label;
  final DateTime? value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: onTap,
          child: InputDecorator(
            decoration: const InputDecoration(
              suffixIcon: Icon(Icons.calendar_today_outlined, size: 18),
            ),
            child: Text(
              value == null ? 'Odaberite datum' : formatDate(value),
              style: TextStyle(
                fontSize: 13.5,
                color: value == null ? AppColors.textSecondary : AppColors.textPrimary,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ReportActions extends StatelessWidget {
  const _ReportActions({
    required this.downloading,
    required this.printing,
    required this.onDownload,
    required this.onPrint,
  });

  final bool downloading;
  final bool printing;
  final VoidCallback onDownload;
  final VoidCallback onPrint;

  @override
  Widget build(BuildContext context) {
    final busy = downloading || printing;

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        OutlinedButton.icon(
          onPressed: busy ? null : onPrint,
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          ),
          icon: printing
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.print_outlined, size: 18),
          label: Text(printing ? 'Priprema…' : 'Štampaj PDF'),
        ),
        const SizedBox(width: 12),
        FilledButton.icon(
          onPressed: busy ? null : onDownload,
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          ),
          icon: downloading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : const Icon(Icons.download_outlined, size: 18),
          label: Text(downloading ? 'Preuzimanje…' : 'Preuzmi PDF'),
        ),
      ],
    );
  }
}
