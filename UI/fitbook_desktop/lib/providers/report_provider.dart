import 'dart:typed_data';

import '../models/requests/reservations_report_request.dart';
import 'base_provider.dart';

/// Talks to `ReportsController` (`api/reports`, Admin-only). Both endpoints
/// return a raw PDF file rather than JSON, so this extends [BaseProvider]
/// directly and hands back the response bytes for the caller to save/print.
class ReportProvider extends BaseProvider {
  Future<Uint8List> getReservationsReport(ReservationsReportRequest request) async {
    final response = await apiPost('Reports/reservations', body: request);
    return response.bodyBytes;
  }

  Future<Uint8List> getTrainingPopularityReport() async {
    final response = await apiGet('Reports/training-popularity');
    return response.bodyBytes;
  }
}
