import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:weather_app/main.dart'; // Hauptdatei der App
import 'package:weather_app/screens/home_screen.dart'; // HomeScreen importieren

void main() {
  testWidgets('HomeScreen UI Tests - Überprüfen der grundlegenden Elemente',
          (WidgetTester tester) async {
        // Baue die App und lade das Haupt-Widget
        await tester.pumpWidget(MyApp());

        // Überprüfe, ob der Titel "Wetter App" in der AppBar angezeigt wird
        expect(find.text("Wetter App"), findsOneWidget);

        // Überprüfe, ob das Suchfeld (TextField) vorhanden ist
        expect(find.byType(TextField), findsOneWidget);

        // Überprüfe, ob mindestens ein ElevatedButton vorhanden ist
        expect(find.byType(ElevatedButton), findsWidgets);

        // Überprüfe, ob das HomeScreen-Widget geladen wird
        expect(find.byType(HomeScreen), findsOneWidget);

        // Überprüfe, ob eine leere Wetteranzeige oder ein Platzhalter sichtbar ist
        expect(find.text("Keine aktuellen Warnungen"), findsWidgets);
      });

  testWidgets('HomeScreen-Interaktion - Eingaben und Buttons',
          (WidgetTester tester) async {
        // Baue die App und lade das Haupt-Widget
        await tester.pumpWidget(MaterialApp(home: HomeScreen()));

        // Simuliere die Eingabe eines Suchbegriffs in das TextField
        await tester.enterText(find.byType(TextField), 'Berlin');
        await tester.pump();

        // Überprüfe, ob der eingegebene Text korrekt angezeigt wird
        expect(find.text('Berlin'), findsOneWidget);

        // Drücke den ersten ElevatedButton
        await tester.tap(find.byType(ElevatedButton).first);
        await tester.pump();

        // Optional: Überprüfe, ob nach der Aktion ein bestimmtes Element erscheint
        // (z. B. Wetterdaten, Fehlermeldung, Lade-Widget etc.)
        expect(find.byType(CircularProgressIndicator), findsNothing); // Beispiel
      });
}
