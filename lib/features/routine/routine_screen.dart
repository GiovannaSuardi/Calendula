import 'package:flutter/material.dart';

import '../../widgets/coming_soon.dart';

/// Le attività della giornata da spuntare.
class RoutineScreen extends StatelessWidget {
  const RoutineScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('La mia giornata')),
      body: const ComingSoon(
        icon: Icons.checklist,
        description: 'Le cose da fare oggi, da spuntare una alla volta.',
      ),
    );
  }
}
