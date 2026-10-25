import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'medicine.dart';
import 'medicine_reminders.dart';

/// Tiene l'elenco delle medicine e quelle già prese oggi, e le salva
/// sul telefono. Quando qualcosa cambia chiama notifyListeners(), così
/// le schermate si aggiornano da sole (simile a un evento in VB.NET).
class MedicineStore extends ChangeNotifier {
  MedicineStore._(this._prefs, this._now, this._reminders) {
    _load();
  }

  /// Crea l'archivio leggendo i dati salvati.
  /// [now] si può sostituire nei test per simulare l'ora.
  static Future<MedicineStore> load({
    DateTime Function() now = DateTime.now,
    MedicineReminders reminders = const NoReminders(),
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final store = MedicineStore._(prefs, now, reminders);
    // Riprogramma gli avvisi a ogni avvio, nel caso siano andati persi.
    await reminders.sync(store._medicines);
    return store;
  }

  static const _medicinesKey = 'medicines';
  static const _takenKey = 'medicines_taken';
  static const _remindersAskedKey = 'medicines_reminders_asked';

  final SharedPreferences _prefs;
  final DateTime Function() _now;
  final MedicineReminders _reminders;
  final List<Medicine> _medicines = [];

  // Assunzioni fatte nel giorno _takenDate (si azzerano a mezzanotte).
  String _takenDate = '';
  final Set<String> _taken = {};

  List<Medicine> get medicines => List.unmodifiable(_medicines);

  /// Tutte le assunzioni di oggi, in ordine di orario.
  List<ScheduledDose> todayDoses() {
    final doses = [
      for (final m in _medicines)
        for (final t in m.times) ScheduledDose(m, t),
    ];
    doses.sort((a, b) => minutesOf(a.time).compareTo(minutesOf(b.time)));
    return doses;
  }

  bool isTaken(ScheduledDose dose) {
    _resetIfNewDay();
    return _taken.contains(dose.key);
  }

  /// Vero se l'orario è passato e la medicina non è ancora stata presa.
  bool isLate(ScheduledDose dose) {
    final now = _now();
    return !isTaken(dose) && minutesOf(dose.time) < now.hour * 60 + now.minute;
  }

  /// Segna come presa, o annulla se era già segnata.
  Future<void> toggleTaken(ScheduledDose dose) async {
    _resetIfNewDay();
    if (!_taken.remove(dose.key)) _taken.add(dose.key);
    notifyListeners();
    await _prefs.setString(
      _takenKey,
      jsonEncode({'date': _takenDate, 'keys': _taken.toList()}),
    );
  }

  /// Aggiunge una medicina nuova o aggiorna quella con lo stesso id.
  Future<void> save(Medicine medicine) async {
    final index = _medicines.indexWhere((m) => m.id == medicine.id);
    if (index >= 0) {
      _medicines[index] = medicine;
    } else {
      _medicines.add(medicine);
    }
    _medicines.sort(
      (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
    );
    notifyListeners();
    await _saveMedicines();
  }

  Future<void> delete(String id) async {
    _medicines.removeWhere((m) => m.id == id);
    notifyListeners();
    await _saveMedicines();
  }

  /// Vero se conviene chiedere all'utente se vuole gli avvisi:
  /// solo dove funzionano e solo la prima volta.
  bool get shouldAskForReminders =>
      _reminders.isSupported && !(_prefs.getBool(_remindersAskedKey) ?? false);

  /// Ricorda la risposta e, se è sì, chiede il permesso al telefono.
  Future<void> answerRemindersQuestion({required bool wantsReminders}) async {
    await _prefs.setBool(_remindersAskedKey, true);
    if (!wantsReminders) return;
    await _reminders.requestPermission();
    // Con il permesso ottenuto gli avvisi possono diventare puntuali.
    await _reminders.sync(_medicines);
  }

  /// Un identificativo nuovo per una medicina.
  static String newId() => DateTime.now().microsecondsSinceEpoch.toString();

  void _load() {
    final raw = _prefs.getString(_medicinesKey);
    if (raw != null) {
      final list = jsonDecode(raw) as List;
      _medicines.addAll(
        list.map((m) => Medicine.fromJson(m as Map<String, dynamic>)),
      );
    }
    final takenRaw = _prefs.getString(_takenKey);
    if (takenRaw != null) {
      final data = jsonDecode(takenRaw) as Map<String, dynamic>;
      _takenDate = data['date'] as String;
      _taken.addAll((data['keys'] as List).cast<String>());
    }
  }

  Future<void> _saveMedicines() async {
    await _prefs.setString(
      _medicinesKey,
      jsonEncode(_medicines.map((m) => m.toJson()).toList()),
    );
    await _reminders.sync(_medicines);
  }

  void _resetIfNewDay() {
    final now = _now();
    final today = '${now.year}-${now.month}-${now.day}';
    if (_takenDate != today) {
      _takenDate = today;
      _taken.clear();
    }
  }
}
