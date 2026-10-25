import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:calendula/app.dart';
import 'package:calendula/features/medicines/medicine_store.dart';
import 'package:calendula/features/walk_home/home_place.dart';

void main() {
  late MedicineStore store;
  late HomeStore homeStore;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    store = await MedicineStore.load();
    homeStore = await HomeStore.load();
  });

  testWidgets('La home mostra le sei funzioni', (WidgetTester tester) async {
    // Schermo di un telefono tipico (390x844 punti).
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      CalendulaApp(medicineStore: store, homeStore: homeStore),
    );

    expect(find.text('Medicine'), findsOneWidget);
    expect(find.text('Torna a casa'), findsOneWidget);
    expect(find.text('Dove sono'), findsOneWidget);
    expect(find.text('Ginnastica'), findsOneWidget);
    expect(find.text('Pasti'), findsOneWidget);
    expect(find.text('La mia giornata'), findsOneWidget);
  });

  testWidgets('Toccando Medicine si apre la sua schermata', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      CalendulaApp(medicineStore: store, homeStore: homeStore),
    );

    await tester.tap(find.text('Medicine'));
    await tester.pumpAndSettle();

    expect(find.text('Da prendere oggi'), findsOneWidget);
    expect(find.byType(BackButton), findsOneWidget);
  });
}
