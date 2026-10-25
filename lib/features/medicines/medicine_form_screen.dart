import 'package:flutter/material.dart';

import 'medicine.dart';
import 'medicine_store.dart';

/// Modulo per aggiungere una medicina nuova o modificarne una esistente.
/// È uno StatefulWidget perché tiene dati che cambiano mentre si scrive
/// (come i campi di un Form in VB.NET).
class MedicineFormScreen extends StatefulWidget {
  const MedicineFormScreen({super.key, required this.store, this.medicine});

  final MedicineStore store;

  /// null = medicina nuova.
  final Medicine? medicine;

  @override
  State<MedicineFormScreen> createState() => _MedicineFormScreenState();
}

class _MedicineFormScreenState extends State<MedicineFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _dose;
  late final TextEditingController _notes;
  late List<TimeOfDay> _times;
  bool _showTimesError = false;

  bool get _isNew => widget.medicine == null;

  @override
  void initState() {
    super.initState();
    final m = widget.medicine;
    _name = TextEditingController(text: m?.name ?? '');
    _dose = TextEditingController(text: m?.dose ?? '');
    _notes = TextEditingController(text: m?.notes ?? '');
    _times = [...?m?.times];
  }

  @override
  void dispose() {
    _name.dispose();
    _dose.dispose();
    _notes.dispose();
    super.dispose();
  }

  Future<void> _addTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 8, minute: 0),
      helpText: 'A che ora va presa?',
      // Due caselle grandi (ore e minuti) invece del quadrante:
      // più facile da usare con le dita.
      initialEntryMode: TimePickerEntryMode.input,
    );
    if (picked == null) return;
    setState(() {
      if (!_times.contains(picked)) _times.add(picked);
      _times.sort((a, b) => minutesOf(a).compareTo(minutesOf(b)));
      _showTimesError = false;
    });
  }

  Future<void> _save() async {
    final fieldsOk = _formKey.currentState!.validate();
    setState(() => _showTimesError = _times.isEmpty);
    if (!fieldsOk || _times.isEmpty) return;

    await widget.store.save(
      Medicine(
        id: widget.medicine?.id ?? MedicineStore.newId(),
        name: _name.text.trim(),
        dose: _dose.text.trim(),
        times: _times,
        notes: _notes.text.trim(),
      ),
    );
    await _askAboutReminders();
    if (mounted) Navigator.of(context).pop();
  }

  /// La prima volta spiega a cosa servono gli avvisi prima che il telefono
  /// chieda il permesso, così la persona sa cosa rispondere.
  Future<void> _askAboutReminders() async {
    if (!widget.store.shouldAskForReminders || !mounted) return;
    final wants = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.notifications_active, size: 48),
        title: const Text('Vuoi un avviso?'),
        content: const Text(
          "Calendula può avvisarti quando è l'ora di prendere "
          'ogni medicina.\n\n'
          'Se dici di sì, il telefono ti chiederà il permesso: '
          'tocca "Consenti".',
          style: TextStyle(fontSize: 20),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('No, grazie'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(minimumSize: const Size(120, 56)),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Sì'),
          ),
        ],
      ),
    );
    await widget.store.answerRemindersQuestion(wantsReminders: wants ?? false);
  }

  Future<void> _delete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Togliere questa medicina?'),
        content: Text(widget.medicine!.name),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Sì, togli'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await widget.store.delete(widget.medicine!.id);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isNew ? 'Nuova medicina' : 'Modifica medicina'),
        actions: [
          if (!_isNew)
            IconButton(
              tooltip: 'Togli medicina',
              iconSize: 32,
              icon: const Icon(Icons.delete),
              onPressed: _delete,
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _name,
              style: const TextStyle(fontSize: 22),
              decoration: const InputDecoration(
                labelText: 'Nome della medicina',
                border: OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.sentences,
              validator: (value) => (value == null || value.trim().isEmpty)
                  ? 'Scrivi il nome della medicina'
                  : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _dose,
              style: const TextStyle(fontSize: 22),
              decoration: const InputDecoration(
                labelText: 'Quanto prenderne',
                hintText: 'Es. 1 compressa',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            Text('Orari', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final t in _times)
                  InputChip(
                    label: Text(
                      formatTime(t),
                      style: const TextStyle(fontSize: 22),
                    ),
                    deleteIcon: const Icon(Icons.close, size: 28),
                    onDeleted: () => setState(() => _times.remove(t)),
                  ),
              ],
            ),
            if (_showTimesError)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'Aggiungi almeno un orario',
                  style: TextStyle(
                    fontSize: 18,
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
              ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: _addTime,
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 56),
                textStyle: const TextStyle(fontSize: 20),
              ),
              icon: const Icon(Icons.alarm_add, size: 28),
              label: const Text('Aggiungi orario'),
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _notes,
              style: const TextStyle(fontSize: 22),
              decoration: const InputDecoration(
                labelText: 'Note (facoltativo)',
                hintText: 'Es. dopo mangiato',
                border: OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.sentences,
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton.icon(
            onPressed: _save,
            icon: const Icon(Icons.save, size: 32),
            label: const Text('Salva'),
          ),
        ),
      ),
    );
  }
}
