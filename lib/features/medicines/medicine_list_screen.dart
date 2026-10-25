import 'package:flutter/material.dart';

import 'medicine.dart';
import 'medicine_form_screen.dart';
import 'medicine_store.dart';

/// Elenco di tutte le medicine, per aggiungerle, modificarle o toglierle.
class MedicineListScreen extends StatelessWidget {
  const MedicineListScreen({super.key, required this.store});

  final MedicineStore store;

  void _openForm(BuildContext context, [Medicine? medicine]) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => MedicineFormScreen(store: store, medicine: medicine),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Le mie medicine')),
      body: ListenableBuilder(
        listenable: store,
        builder: (context, _) {
          final medicines = store.medicines;
          if (medicines.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Text(
                  'Nessuna medicina inserita.',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
            );
          }
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              for (final m in medicines)
                Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    title: Text(
                      m.name,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      [
                        if (m.dose.isNotEmpty) m.dose,
                        m.times.map(formatTime).join(' - '),
                      ].join('\n'),
                      style: const TextStyle(fontSize: 20),
                    ),
                    trailing: const Icon(Icons.edit, size: 32),
                    onTap: () => _openForm(context, m),
                  ),
                ),
            ],
          );
        },
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton.icon(
            onPressed: () => _openForm(context),
            icon: const Icon(Icons.add, size: 32),
            label: const Text('Aggiungi medicina'),
          ),
        ),
      ),
    );
  }
}
