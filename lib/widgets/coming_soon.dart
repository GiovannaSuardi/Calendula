import 'package:flutter/material.dart';

/// Segnaposto per le funzioni non ancora realizzate.
class ComingSoon extends StatelessWidget {
  const ComingSoon({super.key, required this.icon, required this.description});

  final IconData icon;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 96, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 24),
            Text(
              description,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 16),
            Text('In arrivo', style: Theme.of(context).textTheme.titleLarge),
          ],
        ),
      ),
    );
  }
}
