import 'package:flutter/material.dart';

import '../../widgets/coming_soon.dart';

/// Idee per pasti facili e leggeri.
class MealsScreen extends StatelessWidget {
  const MealsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pasti')),
      body: const ComingSoon(
        icon: Icons.restaurant,
        description: 'Ricette facili e leggere per colazione, pranzo e cena.',
      ),
    );
  }
}
