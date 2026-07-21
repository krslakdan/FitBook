import 'package:flutter/material.dart';

import '../layouts/master_screen.dart';
import '../widgets/coming_soon_view.dart';

class MembershipScreen extends StatelessWidget {
  const MembershipScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const MasterScreen(
      title: 'Članarina',
      subtitle: 'Paketi i plaćanja',
      child: ComingSoonView(
        icon: Icons.workspace_premium_outlined,
        message:
            'Pregled aktivne članarine, historije plaćanja i odabir paketa uz plaćanje je u pripremi.',
      ),
    );
  }
}
