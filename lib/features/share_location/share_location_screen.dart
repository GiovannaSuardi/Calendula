import 'package:flutter/material.dart';

import '../../widgets/coming_soon.dart';

/// Invio della propria posizione ai familiari.
class ShareLocationScreen extends StatelessWidget {
  const ShareLocationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dove sono')),
      body: const ComingSoon(
        icon: Icons.location_on,
        description:
            'Potrai mandare la tua posizione ai tuoi familiari '
            'con un messaggio.',
      ),
    );
  }
}
