import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:weather_app/main.dart';
import 'package:weather_app/services/api_service.dart';

class MockApiService extends Mock implements ApiService {}

void main() {
  late MockApiService mockApiService;

  setUp(() {
    mockApiService = MockApiService();
  });

  group('UI Tests', () {
    testWidgets('Home screen has necessary elements', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());

      // Überprüfe, ob die Suchleiste und Wetterdaten vorhanden sind
      expect(find.byType(TextField), findsOneWidget);
      expect(find.textContaining('°C'), findsNothing); // Initially no weather data
    });

    testWidgets('Search for a city and display results', (WidgetTester tester) async {
      when(mockApiService.fetchWeatherByCity('Berlin')).thenAnswer(
            (_) async => {'temperature': 20, 'description': 'Klarer Himmel'},
      );

      await tester.pumpWidget(const MyApp());

      // Finde die Suchleiste und gebe einen Text ein
      await tester.enterText(find.byType(TextField), 'Berlin');
      await tester.pump();

      // Verifiziere, dass die Ergebnisse angezeigt werden
      expect(find.text('Berlin'), findsWidgets);
      expect(find.text('20°C - Klarer Himmel'), findsWidgets);
    });

    testWidgets('Displays error message on API failure', (WidgetTester tester) async {
      when(mockApiService.fetchWeatherByCity(any<String>())).thenThrow(Exception('API-Fehler'));

      await tester.pumpWidget(const MyApp());

      await tester.enterText(find.byType(TextField), 'InvalidCity');
      await tester.pump();

      // Verifiziere, dass die Fehlermeldung angezeigt wird
      expect(find.text('Fehler beim Abrufen der Daten'), findsOneWidget);
    });
  });

  group('API Tests', () {
    test('Mocked API returns weather data', () async {
      when(mockApiService.fetchWeatherByCity('Berlin')).thenAnswer(
            (_) async => {'temperature': 20, 'description': 'Klarer Himmel'},
      );

      final weatherData = await mockApiService.fetchWeatherByCity('Berlin');
      expect(weatherData['temperature'], 20);
      expect(weatherData['description'], 'Klarer Himmel');
    });

    test('Mocked API returns 7-day forecast', () async {
      when(mockApiService.fetch7DayForecast('Berlin')).thenAnswer(
            (_) async => [
          {'day': 'Montag', 'temperature': 20, 'description': 'Klarer Himmel'},
          {'day': 'Dienstag', 'temperature': 22, 'description': 'Leichter Regen'},
        ],
      );

      final forecastData = await mockApiService.fetch7DayForecast('Berlin');
      expect(forecastData, isNotEmpty);
      expect(forecastData[0]['day'], 'Montag');
    });

    test('API error is handled gracefully', () async {
      when(mockApiService.fetchWeatherByCity('InvalidCity')).thenThrow(Exception('Stadt nicht gefunden'));

      try {
        await mockApiService.fetchWeatherByCity('InvalidCity');
      } catch (e) {
        expect(e.toString(), contains('Stadt nicht gefunden'));
      }
    });
  });
}




