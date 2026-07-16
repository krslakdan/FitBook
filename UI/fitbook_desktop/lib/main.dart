import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/auth_provider.dart';
import 'providers/difficulty_level_provider.dart';
import 'providers/hall_provider.dart';
import 'providers/membership_package_provider.dart';
import 'providers/news_item_provider.dart';
import 'providers/report_provider.dart';
import 'providers/reservation_provider.dart';
import 'providers/trainer_provider.dart';
import 'providers/training_category_provider.dart';
import 'providers/training_equipment_provider.dart';
import 'providers/training_provider.dart';
import 'providers/training_term_provider.dart';
import 'providers/user_account_provider.dart';

void main() {
  runApp(const FitBookDesktopApp());
}

class FitBookDesktopApp extends StatelessWidget {
  const FitBookDesktopApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => DifficultyLevelProvider()),
        ChangeNotifierProvider(create: (_) => HallProvider()),
        ChangeNotifierProvider(create: (_) => MembershipPackageProvider()),
        ChangeNotifierProvider(create: (_) => NewsItemProvider()),
        ChangeNotifierProvider(create: (_) => ReservationProvider()),
        ChangeNotifierProvider(create: (_) => TrainerProvider()),
        ChangeNotifierProvider(create: (_) => TrainingProvider()),
        ChangeNotifierProvider(create: (_) => TrainingCategoryProvider()),
        ChangeNotifierProvider(create: (_) => TrainingEquipmentProvider()),
        ChangeNotifierProvider(create: (_) => TrainingTermProvider()),
        ChangeNotifierProvider(create: (_) => UserAccountProvider()),
        ChangeNotifierProvider(create: (_) => ReportProvider()),
      ],
      child: MaterialApp(
        title: 'FitBook Desktop',
        theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple)),
        home: const _StartupGate(),
      ),
    );
  }
}

class _StartupGate extends StatefulWidget {
  const _StartupGate();

  @override
  State<_StartupGate> createState() => _StartupGateState();
}

class _StartupGateState extends State<_StartupGate> {
  late final Future<bool> _sessionRestored;

  @override
  void initState() {
    super.initState();
    _sessionRestored = context.read<AuthProvider>().tryRestoreSession();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _sessionRestored,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        final isAuthenticated = snapshot.data ?? false;
        return Scaffold(
          appBar: AppBar(title: const Text('FitBook Desktop')),
          body: Center(
            child: Text(
              isAuthenticated
                  ? 'Prijavljeni ste. Ekrani stižu u sljedećoj fazi.'
                  : 'Niste prijavljeni. Ekran za prijavu stiže u sljedećoj fazi.',
            ),
          ),
        );
      },
    );
  }
}
