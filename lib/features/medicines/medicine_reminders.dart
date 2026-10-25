import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import 'medicine.dart';

/// Avvisi all'orario delle medicine.
/// È un'interfaccia (come Interface in VB.NET): sul telefono si usa
/// [LocalNotificationReminders], nel browser e nei test [NoReminders].
abstract class MedicineReminders {
  /// Vero se su questo dispositivo gli avvisi funzionano.
  bool get isSupported;

  /// Chiede all'utente il permesso di mostrare avvisi.
  Future<bool> requestPermission();

  /// Riprogramma tutti gli avvisi in base all'elenco delle medicine.
  Future<void> sync(List<Medicine> medicines);
}

/// Versione che non fa nulla (browser, test).
class NoReminders implements MedicineReminders {
  const NoReminders();

  @override
  bool get isSupported => false;

  @override
  Future<bool> requestPermission() async => false;

  @override
  Future<void> sync(List<Medicine> medicines) async {}
}

/// Avvisi veri con le notifiche di Android e iOS.
class LocalNotificationReminders implements MedicineReminders {
  LocalNotificationReminders._(this._plugin);

  final FlutterLocalNotificationsPlugin _plugin;

  static const _details = NotificationDetails(
    android: AndroidNotificationDetails(
      'medicine_reminders',
      'Promemoria medicine',
      channelDescription: "Avvisa quando è l'ora di prendere una medicina",
      importance: Importance.max,
      priority: Priority.high,
      category: AndroidNotificationCategory.reminder,
    ),
    iOS: DarwinNotificationDetails(presentSound: true),
  );

  /// Prepara gli avvisi. Dove non sono disponibili restituisce [NoReminders].
  static Future<MedicineReminders> create() async {
    final mobile =
        !kIsWeb &&
        (defaultTargetPlatform == TargetPlatform.android ||
            defaultTargetPlatform == TargetPlatform.iOS);
    if (!mobile) return const NoReminders();

    // Gli orari vanno espressi nel fuso orario del telefono.
    tz.initializeTimeZones();
    try {
      final zone = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(zone.identifier));
    } catch (_) {
      tz.setLocalLocation(tz.getLocation('Europe/Rome'));
    }

    final plugin = FlutterLocalNotificationsPlugin();
    await plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        // Il permesso su iOS lo chiediamo noi al momento giusto.
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
      ),
    );
    return LocalNotificationReminders._(plugin);
  }

  AndroidFlutterLocalNotificationsPlugin? get _android => _plugin
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >();

  @override
  bool get isSupported => true;

  @override
  Future<bool> requestPermission() async {
    final android = _android;
    if (android != null) {
      final granted = await android.requestNotificationsPermission() ?? false;
      // Per avvisi puntuali Android vuole anche il permesso "sveglie e
      // promemoria": se manca apre la pagina delle impostazioni.
      if (granted && !(await android.canScheduleExactNotifications() ?? true)) {
        await android.requestExactAlarmsPermission();
      }
      return granted;
    }
    final ios = _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();
    return await ios?.requestPermissions(alert: true, sound: true) ?? false;
  }

  @override
  Future<void> sync(List<Medicine> medicines) async {
    await _plugin.cancelAll();

    // Se manca il permesso "sveglie e promemoria" usiamo avvisi meno
    // precisi (possono arrivare con qualche minuto di ritardo).
    final exact = await _android?.canScheduleExactNotifications() ?? true;
    final mode = exact
        ? AndroidScheduleMode.exactAllowWhileIdle
        : AndroidScheduleMode.inexactAllowWhileIdle;

    var id = 0;
    for (final m in medicines) {
      for (final time in m.times) {
        await _plugin.zonedSchedule(
          id: id++,
          title: "È l'ora della medicina",
          body: [m.name, if (m.dose.isNotEmpty) m.dose].join(' - '),
          scheduledDate: _nextInstanceOf(time),
          notificationDetails: _details,
          androidScheduleMode: mode,
          // Ripete l'avviso ogni giorno alla stessa ora.
          matchDateTimeComponents: DateTimeComponents.time,
          payload: m.id,
        );
      }
    }
  }

  /// La prossima volta che sarà quell'ora: oggi, oppure domani se è passata.
  static tz.TZDateTime _nextInstanceOf(TimeOfDay time) {
    final now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime at(int day) => tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      day,
      time.hour,
      time.minute,
    );
    final today = at(now.day);
    // day + 1 (non "+ 24 ore") resta giusto anche al cambio dell'ora legale.
    return today.isAfter(now) ? today : at(now.day + 1);
  }
}
