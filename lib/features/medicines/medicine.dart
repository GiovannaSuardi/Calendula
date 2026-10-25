import 'package:flutter/material.dart';

/// Una medicina con i suoi orari giornalieri
/// (come una classe con proprietà ReadOnly in VB.NET).
class Medicine {
  const Medicine({
    required this.id,
    required this.name,
    required this.dose,
    required this.times,
    this.notes = '',
  });

  final String id;
  final String name;

  /// Quantità da prendere, es. "1 compressa" o "10 gocce".
  final String dose;

  /// Orari in cui prenderla, ogni giorno.
  final List<TimeOfDay> times;

  /// Es. "Dopo mangiato".
  final String notes;

  /// Converte in una mappa da salvare come JSON.
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'dose': dose,
    'times': times.map(formatTime).toList(),
    'notes': notes,
  };

  factory Medicine.fromJson(Map<String, dynamic> json) => Medicine(
    id: json['id'] as String,
    name: json['name'] as String,
    dose: json['dose'] as String? ?? '',
    times: (json['times'] as List).map((t) => parseTime(t as String)).toList(),
    notes: json['notes'] as String? ?? '',
  );
}

/// Una singola assunzione di oggi: una medicina a un certo orario.
class ScheduledDose {
  const ScheduledDose(this.medicine, this.time);

  final Medicine medicine;
  final TimeOfDay time;

  /// Chiave unica usata per ricordare se questa assunzione è stata fatta.
  String get key => '${medicine.id}@${formatTime(time)}';
}

/// 8:05 -> "08:05"
String formatTime(TimeOfDay t) =>
    '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

/// "08:05" -> 8:05
TimeOfDay parseTime(String s) {
  final parts = s.split(':');
  return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
}

/// Minuti dalla mezzanotte, utile per ordinare e confrontare gli orari.
int minutesOf(TimeOfDay t) => t.hour * 60 + t.minute;
