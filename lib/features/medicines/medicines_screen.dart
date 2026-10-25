import 'package:flutter/material.dart';

import 'dose_card.dart';
import 'medicine_form_screen.dart';
import 'medicine_list_screen.dart';
import 'medicine_store.dart';

/// Le medicine da prendere oggi, in ordine di orario.
class MedicinesScreen extends StatelessWidget {
  const MedicinesScreen({super.key, required this.store});

  final MedicineStore store;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Medicine')),
      // ListenableBuilder ridisegna la lista ogni volta che lo store cambia.
      body: ListenableBuilder(
        listenable: store,
        builder: (context, _) {
          final doses = store.todayDoses();
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                'Da prendere oggi',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 16),
              if (doses.isEmpty)
                Text(
                  'Non hai ancora inserito medicine.\n'
                  'Tocca il pulsante qui sotto per aggiungerne una.',
                  style: Theme.of(context).textTheme.bodyLarge,
                )
              else
                for (final dose in doses)
                  DoseCard(
                    dose: dose,
                    taken: store.isTaken(dose),
                    late: store.isLate(dose),
                    onToggle: () => store.toggleTaken(dose),
                  ),
              const SizedBox(height: 16),
              // Se non c'è ancora nulla, si va dritti al modulo.
              if (doses.isEmpty)
                ElevatedButton.icon(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => MedicineFormScreen(store: store),
                    ),
                  ),
                  icon: const Icon(Icons.add, size: 32),
                  label: const Text('Aggiungi medicina'),
                )
              else
                OutlinedButton.icon(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => MedicineListScreen(store: store),
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 64),
                    textStyle: const TextStyle(fontSize: 22),
                  ),
                  icon: const Icon(Icons.edit_note, size: 32),
                  label: const Text('Le mie medicine'),
                ),
            ],
          );
        },
      ),
    );
  }
}
