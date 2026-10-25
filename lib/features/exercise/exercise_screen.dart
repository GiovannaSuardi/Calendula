import 'package:flutter/material.dart';

import '../../widgets/coming_soon.dart';

/// Esercizi di ginnastica dolce guidati.
class ExerciseScreen extends StatelessWidget {
  const ExerciseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ginnastica')),
      body: const ComingSoon(
        icon: Icons.self_improvement,
        description: 'Semplici esercizi da fare a casa, uno alla volta.',
      ),
    );
  }
}
