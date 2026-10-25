import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:calendula/features/walk_home/home_place.dart';
import 'package:calendula/features/walk_home/location_service.dart';
import 'package:calendula/features/walk_home/walk_home_screen.dart';
import 'package:calendula/theme/app_theme.dart';

// Duomo di Milano e Castello Sforzesco: circa 1 km in linea d'aria.
const duomo = GeoPoint(45.4642, 9.1900);
const castello = GeoPoint(45.4705, 9.1795);

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('Distanza in linea d\'aria', () {
    final meters = duomo.distanceTo(castello);
    expect(meters, closeTo(1080, 60));
    expect(duomo.distanceTo(duomo), 0);
  });

  test('Distanza scritta in modo semplice', () {
    expect(describeDistance(30), 'meno di 100 metri');
    expect(describeDistance(812), 'circa 800 metri');
    expect(describeDistance(1430), 'circa 1,4 km');
  });

  test('Link di Google Maps a piedi', () {
    final withPoint = const HomePlace(
      address: 'Via Roma 1',
      point: duomo,
    ).walkingDirectionsUrl();
    expect(withPoint.host, 'www.google.com');
    expect(withPoint.queryParameters['destination'], '45.4642,9.19');
    expect(withPoint.queryParameters['travelmode'], 'walking');

    final onlyAddress = const HomePlace(address: 'Via Roma 1, Milano')
        .walkingDirectionsUrl();
    expect(onlyAddress.queryParameters['destination'], 'Via Roma 1, Milano');
  });

  test('La casa resta salvata', () async {
    final store = await HomeStore.load();
    expect(store.home, isNull);

    await store.save(const HomePlace(address: 'Via Roma 1', point: duomo));

    final reopened = await HomeStore.load();
    expect(reopened.home!.address, 'Via Roma 1');
    expect(reopened.home!.point!.latitude, 45.4642);
  });

  testWidgets('Imposto casa da qui e poi "Portami a casa" apre la mappa', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    final store = await HomeStore.load();
    final location = FakeLocation(duomo);
    final openedUrls = <Uri>[];

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: WalkHomeScreen(
          homeStore: store,
          location: location,
          openUrl: (url) async {
            openedUrls.add(url);
            return true;
          },
        ),
      ),
    );

    // Casa non ancora impostata.
    await tester.tap(find.text('Imposta la mia casa'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Sono a casa adesso'));
    await tester.pumpAndSettle();
    expect(find.text('Posizione di casa salvata'), findsOneWidget);

    await tester.tap(find.text('Salva'));
    await tester.pumpAndSettle();

    // Ora siamo a casa...
    expect(find.text('Sei a casa!'), findsOneWidget);

    // ...ci spostiamo al castello e riapriamo la schermata.
    location.current = castello;
    await tester.tap(find.text('Cambia la mia casa'));
    await tester.pumpAndSettle();
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('Sei a circa 1,1 km da casa'), findsOneWidget);

    await tester.tap(find.text('Portami a casa'));
    await tester.pump();
    expect(openedUrls.single.queryParameters['travelmode'], 'walking');
  });

  testWidgets('Se la posizione non è disponibile lo dice chiaramente', (
    tester,
  ) async {
    final store = await HomeStore.load();
    await store.save(const HomePlace(point: duomo));

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: WalkHomeScreen(
          homeStore: store,
          location: FakeLocation(null),
          openUrl: (_) async => true,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.textContaining('posizione del telefono è spenta'),
      findsOneWidget,
    );
    // Il pulsante per tornare a casa funziona comunque.
    expect(find.text('Portami a casa'), findsOneWidget);
  });
}

/// Posizione finta: [current] null simula il GPS spento.
class FakeLocation implements LocationService {
  FakeLocation(this.current);

  GeoPoint? current;

  @override
  Future<GeoPoint> currentPosition() async {
    if (current == null) {
      throw const LocationException('La posizione del telefono è spenta.');
    }
    return current!;
  }
}
