import 'dart:typed_data';

import '../models/requests/reservations_report_request.dart';
import 'base_provider.dart';

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
