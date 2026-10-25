import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'features/medicines/medicine_store.dart';
import 'features/walk_home/home_place.dart';
import 'screens/home_screen.dart';
import 'theme/app_theme.dart';

/// Widget radice: imposta tema, lingua, titolo e prima schermata.
class CalendulaApp extends StatelessWidget {
  const CalendulaApp({
    super.key,
    required this.medicineStore,
    required this.homeStore,
  });

  final MedicineStore medicineStore;
  final HomeStore homeStore;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calendula',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      // Tutta l'app in italiano (pulsanti di sistema, orologio a 24 ore...).
      locale: const Locale('it'),
      supportedLocales: const [Locale('it')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      home: HomeScreen(medicineStore: medicineStore, homeStore: homeStore),
    );
  }
}
