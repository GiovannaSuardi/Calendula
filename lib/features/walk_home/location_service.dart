import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';

import 'home_place.dart';

/// Errore con un messaggio già pronto da mostrare alla persona.
class LocationException implements Exception {
  const LocationException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Dove mi trovo adesso. Interfaccia, così nei test si usa una posizione finta.
abstract class LocationService {
  /// Lancia [LocationException] se la posizione non è disponibile.
  Future<GeoPoint> currentPosition();
}

/// Posizione vera dal GPS del telefono (o del browser).
class GeolocatorLocationService implements LocationService {
  const GeolocatorLocationService();

  @override
  Future<GeoPoint> currentPosition() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      throw const LocationException(
        'La posizione del telefono è spenta.\n'
        'Accendila dalle impostazioni rapide (icona "Posizione").',
      );
    }
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      throw const LocationException(
        'Calendula non ha il permesso di sapere dove ti trovi.\n'
        'Puoi darlo dalle impostazioni del telefono, alla voce Calendula.',
      );
    }
    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 20),
        ),
      );
      return GeoPoint(position.latitude, position.longitude);
    } catch (_) {
      throw const LocationException(
        'Non riesco a trovare la tua posizione.\n'
        "Prova all'aperto, lontano da muri spessi.",
      );
    }
  }
}

/// Apre un indirizzo web o un'app (Google Maps). Restituisce false se non ci riesce.
typedef UrlOpener = Future<bool> Function(Uri url);

/// Apre il link fuori dall'app: su Android si apre Google Maps se c'è.
Future<bool> openExternally(Uri url) =>
    launchUrl(url, mode: LaunchMode.externalApplication);
