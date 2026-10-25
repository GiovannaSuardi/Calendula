import 'package:flutter/material.dart';

import 'medicine.dart';

/// Riquadro di una medicina da prendere oggi, con il pulsante "L'ho presa".
class DoseCard extends StatelessWidget {
  const DoseCard({
    super.key,
    required this.dose,
    required this.taken,
    required this.late,
    required this.onToggle,
  });

  final ScheduledDose dose;
  final bool taken;
  final bool late;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final medicine = dose.medicine;
    final Color background;
    if (taken) {
      background = const Color(0xFFD3F9D8); // verde: fatto
    } else if (late) {
      background = const Color(0xFFFFE3E3); // rosso chiaro: in ritardo
    } else {
      background = Colors.white;
    }

    return Card(
      color: background,
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  formatTime(dose.time),
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        medicine.name,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (medicine.dose.isNotEmpty)
                        Text(
                          medicine.dose,
                          style: const TextStyle(fontSize: 20),
                        ),
                      if (medicine.notes.isNotEmpty)
                        Text(
                          medicine.notes,
                          style: const TextStyle(
                            fontSize: 18,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      if (late)
                        const Text(
                          'In ritardo',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFC92A2A),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (taken)
              OutlinedButton.icon(
                onPressed: onToggle,
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 64),
                  textStyle: const TextStyle(fontSize: 22),
                ),
                icon: const Icon(
                  Icons.check_circle,
                  size: 32,
                  color: Color(0xFF2B8A3E),
                ),
                label: const Text('Presa (annulla)'),
              )
            else
              ElevatedButton.icon(
                onPressed: onToggle,
                icon: const Icon(Icons.check, size: 32),
                label: const Text("L'ho presa"),
              ),
          ],
        ),
      ),
    );
  }
}
