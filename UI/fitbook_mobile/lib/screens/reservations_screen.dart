import 'package:flutter/material.dart';

import '../layouts/master_screen.dart';
import '../widgets/coming_soon_view.dart';

class ReservationsScreen extends StatelessWidget {
  const ReservationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const MasterScreen(
      title: 'Rezervacije',
      subtitle: 'Historija i aktivne rezervacije',
      child: ComingSoonView(
        icon: Icons.event_available_outlined,
        message:
            'Pregled aktivnih i prošlih rezervacija sa detaljima i otkazivanjem je u pripremi.',
      ),
    );
  }
}
