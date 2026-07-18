import 'dart:convert';

import '../models/responses/dashboard_summary_response.dart';
import 'base_provider.dart';

class DashboardProvider extends BaseProvider {
  Future<DashboardSummaryResponse> getSummary({int reservationsDays = 7}) async {
    final response = await apiGet(
      'Dashboard/summary',
      queryParameters: {'reservationsDays': reservationsDays},
    );
    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    return DashboardSummaryResponse.fromJson(decoded);
  }
}
