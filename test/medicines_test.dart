import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:calendula/features/medicines/medicine.dart';
import 'package:calendula/features/medicines/medicine_reminders.dart';
import 'package:calendula/features/medicines/medicine_store.dart';
import 'package:calendula/features/medicines/medicines_screen.dart';

void main() {
  // Ora finta, così i test non dipendono da quando vengono eseguiti.
  late DateTime fakeNow;
  late MedicineStore store;

  const aspirina = Medicine(
    id: 'a',
    name: 'Aspirina',
    dose: '1 compressa',
    times: [TimeOfDay(hour: 20, minute: 0), TimeOfDay(hour: 8, minute: 0)],
  );
  const vitamina = Medicine(
    id: 'v',
    name: 'Vitamina D',
    dose: '10 gocce',
    times: [TimeOfDay(hour: 12, minute: 30)],
  );

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    fakeNow = DateTime(2026, 10, 24, 10, 0);
    store = await MedicineStore.load(now: () => fakeNow);
  });

  test('Medicine si salva e si rilegge uguale', () {
    final copy = Medicine.fromJson(aspirina.toJson());
    expect(copy.name, 'Aspirina');
    expect(copy.dose, '1 compressa');
    expect(copy.times.map(formatTime), ['20:00', '08:00']);
  });

  test('Le assunzioni di oggi sono in ordine di orario', () async {
    await store.save(aspirina);
    await store.save(vitamina);

    final doses = store.todayDoses();
    expect(doses.map((d) => '${formatTime(d.time)} ${d.medicine.name}'), [
      '08:00 Aspirina',
      '12:30 Vitamina D',
      '20:00 Aspirina',
    ]);
  });

  test('In ritardo, presa, e azzerata il giorno dopo', () async {
    await store.save(aspirina);
    final mattina = store.todayDoses().first; // 08:00, ora sono le 10:00

    expect(store.isLate(mattina), isTrue);

    await store.toggleTaken(mattina);
    expect(store.isTaken(mattina), isTrue);
    expect(store.isLate(mattina), isFalse);

    fakeNow = DateTime(2026, 10, 25, 7, 0);
    expect(store.isTaken(mattina), isFalse);
  });

  test('I dati restano salvati alla riapertura', () async {
    await store.save(aspirina);
    await store.toggleTaken(store.todayDoses().first);

    final reopened = await MedicineStore.load(now: () => fakeNow);
    expect(reopened.medicines.single.name, 'Aspirina');
    expect(reopened.isTaken(reopened.todayDoses().first), isTrue);
  });

  test('Modifica e cancellazione', () async {
    await store.save(aspirina);
    await store.save(
      const Medicine(
        id: 'a',
        name: 'Aspirina',
        dose: '2 compresse',
        times: [TimeOfDay(hour: 9, minute: 0)],
      ),
    );
    expect(store.medicines.single.dose, '2 compresse');

    await store.delete('a');
    expect(store.medicines, isEmpty);
  });

  group('Promemoria', () {
    late FakeReminders reminders;

    setUp(() async {
      reminders = FakeReminders();
      store = await MedicineStore.load(
        now: () => fakeNow,
        reminders: reminders,
      );
    });

    test('vengono riprogrammati a ogni modifica', () async {
      expect(reminders.syncedNames, [<String>[]]); // all'avvio

      await store.save(aspirina);
      await store.save(vitamina);
      expect(reminders.syncedNames.last, ['Aspirina', 'Vitamina D']);

      await store.delete('a');
      expect(reminders.syncedNames.last, ['Vitamina D']);
    });

    test('segnare una medicina come presa non li tocca', () async {
      await store.save(aspirina);
      final before = reminders.syncedNames.length;
      await store.toggleTaken(store.todayDoses().first);
      expect(reminders.syncedNames.length, before);
    });

    test('la domanda compare una volta sola', () async {
      expect(store.shouldAskForReminders, isTrue);

      await store.answerRemindersQuestion(wantsReminders: true);
      expect(reminders.permissionRequests, 1);
      expect(store.shouldAskForReminders, isFalse);

      // Anche riaprendo l'app non lo richiede.
      final reopened = await MedicineStore.load(reminders: reminders);
      expect(reopened.shouldAskForReminders, isFalse);
    });

    test('se la risposta è no, non chiede il permesso', () async {
      await store.answerRemindersQuestion(wantsReminders: false);
      expect(reminders.permissionRequests, 0);
      expect(store.shouldAskForReminders, isFalse);
    });

    test('dove gli avvisi non funzionano la domanda non compare', () async {
      final webStore = await MedicineStore.load(reminders: const NoReminders());
      expect(webStore.shouldAskForReminders, isFalse);
    });
  });

  testWidgets('Toccando "L\'ho presa" la medicina risulta presa', (
    WidgetTester tester,
  ) async {
    await store.save(vitamina);
    await tester.pumpWidget(MaterialApp(home: MedicinesScreen(store: store)));

    expect(find.text('Vitamina D'), findsOneWidget);
    expect(find.text('12:30'), findsOneWidget);

    await tester.tap(find.text("L'ho presa"));
    await tester.pump();

    expect(find.text('Presa (annulla)'), findsOneWidget);
  });
}

/// Promemoria finti: ricordano cosa è stato chiesto invece di mostrare notifiche.
class FakeReminders implements MedicineReminders {
  final List<List<String>> syncedNames = [];
  int permissionRequests = 0;

  @override
  bool get isSupported => true;

  @override
  Future<bool> requestPermission() async {
    permissionRequests++;
    return true;
  }

  @override
  Future<void> sync(List<Medicine> medicines) async {
    syncedNames.add(medicines.map((m) => m.name).toList());
  }
}
