// Punto di ingresso dell'app (come Sub Main in VB.NET).
import 'package:flutter/material.dart';

import 'app.dart';
import 'features/medicines/medicine_reminders.dart';
import 'features/medicines/medicine_store.dart';
import 'features/walk_home/home_place.dart';

Future<void> main() async {
  // Necessario prima di leggere dati salvati sul telefono.
  WidgetsFlutterBinding.ensureInitialized();
  final reminders = await LocalNotificationReminders.create();
  final medicineStore = await MedicineStore.load(reminders: reminders);
  final homeStore = await HomeStore.load();
  runApp(CalendulaApp(medicineStore: medicineStore, homeStore: homeStore));
}
