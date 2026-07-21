import 'package:flutter/material.dart';

import '../layouts/master_screen.dart';
import '../widgets/coming_soon_view.dart';

class TrainingsScreen extends StatelessWidget {
  const TrainingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const MasterScreen(
      title: 'Treninzi',
      subtitle: 'Pregled i rezervacija',
      child: ComingSoonView(
        icon: Icons.fitness_center,
        message:
            'Pregled treninga sa pretragom, filtriranjem po kategorijama i rezervacijom termina je u pripremi.',
      ),
    );
  }
}
