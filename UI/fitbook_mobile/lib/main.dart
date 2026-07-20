import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/auth_provider.dart';
import 'providers/difficulty_level_provider.dart';
import 'providers/equipment_provider.dart';
import 'providers/file_provider.dart';
import 'providers/hall_provider.dart';
import 'providers/membership_package_provider.dart';
import 'providers/membership_payment_provider.dart';
import 'providers/news_item_provider.dart';
import 'providers/recommendation_provider.dart';
import 'providers/reservation_provider.dart';
import 'providers/specialization_provider.dart';
import 'providers/system_notification_provider.dart';
import 'providers/trainer_provider.dart';
import 'providers/training_category_provider.dart';
import 'providers/training_equipment_provider.dart';
import 'providers/training_provider.dart';
import 'providers/training_term_provider.dart';
import 'providers/user_account_provider.dart';
import 'providers/user_membership_provider.dart';
import 'screens/placeholder_home_screen.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const FitBookMobileApp());
}

class FitBookMobileApp extends StatelessWidget {
  const FitBookMobileApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => DifficultyLevelProvider()),
        ChangeNotifierProvider(create: (_) => EquipmentProvider()),
        ChangeNotifierProvider(create: (_) => FileProvider()),
        ChangeNotifierProvider(create: (_) => HallProvider()),
        ChangeNotifierProvider(create: (_) => MembershipPackageProvider()),
        ChangeNotifierProvider(create: (_) => MembershipPaymentProvider()),
        ChangeNotifierProvider(create: (_) => NewsItemProvider()),
        ChangeNotifierProvider(create: (_) => RecommendationProvider()),
        ChangeNotifierProvider(create: (_) => ReservationProvider()),
        ChangeNotifierProvider(create: (_) => SpecializationProvider()),
        ChangeNotifierProvider(create: (_) => SystemNotificationProvider()),
        ChangeNotifierProvider(create: (_) => TrainerProvider()),
        ChangeNotifierProvider(create: (_) => TrainingProvider()),
        ChangeNotifierProvider(create: (_) => TrainingCategoryProvider()),
        ChangeNotifierProvider(create: (_) => TrainingEquipmentProvider()),
        ChangeNotifierProvider(create: (_) => TrainingTermProvider()),
        ChangeNotifierProvider(create: (_) => UserAccountProvider()),
        ChangeNotifierProvider(create: (_) => UserMembershipProvider()),
      ],
      child: MaterialApp(
        title: 'FitBook',
        theme: buildAppTheme(),
        home: const PlaceholderHomeScreen(),
      ),
    );
  }
}
