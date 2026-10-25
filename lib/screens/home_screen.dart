import 'package:flutter/material.dart';

import '../features/exercise/exercise_screen.dart';
import '../features/meals/meals_screen.dart';
import '../features/medicines/medicine_store.dart';
import '../features/medicines/medicines_screen.dart';
import '../features/routine/routine_screen.dart';
import '../features/share_location/share_location_screen.dart';
import '../features/walk_home/home_place.dart';
import '../features/walk_home/walk_home_screen.dart';
import '../widgets/big_tile.dart';

/// Schermata principale: sei pulsanti grandi, uno per ogni funzione.
class HomeScreen extends StatelessWidget {
  const HomeScreen({
    super.key,
    required this.medicineStore,
    required this.homeStore,
  });

  final MedicineStore medicineStore;
  final HomeStore homeStore;

  // Apre una schermata (come Form.Show() in VB.NET, ma con il tasto "indietro").
  void _open(BuildContext context, Widget screen) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Calendula')),
      body: SafeArea(
        child: GridView.count(
          crossAxisCount: 2,
          padding: const EdgeInsets.all(16),
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 0.9,
          children: [
            BigTile(
              icon: Icons.medication,
              label: 'Medicine',
              color: const Color(0xFFFFD8A8),
              onTap: () =>
                  _open(context, MedicinesScreen(store: medicineStore)),
            ),
            BigTile(
              icon: Icons.home,
              label: 'Torna a casa',
              color: const Color(0xFFB2F2BB),
              onTap: () => _open(context, WalkHomeScreen(homeStore: homeStore)),
            ),
            BigTile(
              icon: Icons.location_on,
              label: 'Dove sono',
              color: const Color(0xFFA5D8FF),
              onTap: () => _open(context, const ShareLocationScreen()),
            ),
            BigTile(
              icon: Icons.self_improvement,
              label: 'Ginnastica',
              color: const Color(0xFFD0BFFF),
              onTap: () => _open(context, const ExerciseScreen()),
            ),
            BigTile(
              icon: Icons.restaurant,
              label: 'Pasti',
              color: const Color(0xFFFFEC99),
              onTap: () => _open(context, const MealsScreen()),
            ),
            BigTile(
              icon: Icons.checklist,
              label: 'La mia giornata',
              color: const Color(0xFFFFC9C9),
              onTap: () => _open(context, const RoutineScreen()),
            ),
          ],
        ),
      ),
    );
  }
}
