import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Un punto sulla mappa (latitudine e longitudine in gradi).
class GeoPoint {
  const GeoPoint(this.latitude, this.longitude);

  final double latitude;
  final double longitude;

  /// Distanza in metri "in linea d'aria" (formula dell'emisenoverso).
  double distanceTo(GeoPoint other) {
    const earthRadius = 6371000.0;
    double rad(double deg) => deg * pi / 180;
    final dLat = rad(other.latitude - latitude);
    final dLon = rad(other.longitude - longitude);
    final a =
        sin(dLat / 2) * sin(dLat / 2) +
        cos(rad(latitude)) *
            cos(rad(other.latitude)) *
            sin(dLon / 2) *
            sin(dLon / 2);
    return earthRadius * 2 * atan2(sqrt(a), sqrt(1 - a));
  }
}

/// Dove si trova casa: un indirizzo scritto, una posizione GPS, o entrambi.
class HomePlace {
  const HomePlace({this.address = '', this.point});

  final String address;
  final GeoPoint? point;

  Map<String, dynamic> toJson() => {
    'address': address,
    if (point != null) 'lat': point!.latitude,
    if (point != null) 'lng': point!.longitude,
  };

  factory HomePlace.fromJson(Map<String, dynamic> json) => HomePlace(
    address: json['address'] as String? ?? '',
    point: json['lat'] == null
        ? null
        : GeoPoint(
            (json['lat'] as num).toDouble(),
            (json['lng'] as num).toDouble(),
          ),
  );

  /// Indirizzo per Google Maps: la posizione GPS se c'è, perché è più
  /// precisa, altrimenti l'indirizzo scritto.
  Uri walkingDirectionsUrl() => Uri.https('www.google.com', '/maps/dir/', {
    'api': '1',
    'destination': point != null
        ? '${point!.latitude},${point!.longitude}'
        : address,
    'travelmode': 'walking',
  });
}

/// Testo semplice per la distanza: "circa 350 metri" o "circa 1,4 km".
String describeDistance(double meters) {
  if (meters < 100) return 'meno di 100 metri';
  if (meters < 1000) {
    final rounded = (meters / 50).round() * 50;
    return 'circa $rounded metri';
  }
  final km = (meters / 1000).toStringAsFixed(1).replaceAll('.', ',');
  return 'circa $km km';
}

/// Salva e legge la posizione di casa sul telefono.
class HomeStore extends ChangeNotifier {
  HomeStore._(this._prefs) {
    final raw = _prefs.getString(_key);
    if (raw != null) {
      _home = HomePlace.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    }
  }

  static Future<HomeStore> load() async =>
      HomeStore._(await SharedPreferences.getInstance());

  static const _key = 'home_place';

  final SharedPreferences _prefs;
  HomePlace? _home;

  /// null finché la casa non è stata impostata.
  HomePlace? get home => _home;

  Future<void> save(HomePlace home) async {
    _home = home;
    notifyListeners();
    await _prefs.setString(_key, jsonEncode(home.toJson()));
  }
}
