import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:weather_app/models/weather_model.dart';
import 'package:weather_app/main.dart';
import 'package:weather_app/services/api_service.dart';
import 'package:weather_app/services/favorite_service.dart';

class MockApiService extends Mock implements ApiService {}
class MockFavoriteService extends Mock implements FavoriteService {}

void main() {
  late MockApiService mockApiService;
  late MockFavoriteService mockFavoriteService;

  setUp(() {
    mockApiService = MockApiService();
    mockFavoriteService = MockFavoriteService();
  });

  group('UI Tests', () {
    testWidgets('Home screen has necessary elements', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());

      // Überprüfe, ob die Suchleiste und Wetterdaten vorhanden sind
      expect(find.byType(TextField), findsOneWidget);
      expect(find.textContaining('°C'), findsNothing); // Initially no weather data
    });

    testWidgets('Search for a city and display results', (WidgetTester tester) async {
      // Mocking the response when fetchWeatherByCity is called
      when(mockApiService.fetchWeatherByCity(captureAnyNamed('city') ?? 'Berlin')).thenAnswer(
            (_) async => WeatherModel(
          cityName: 'Berlin',
          temperature: 20,
          condition: 'Klarer Himmel',
          windSpeed: 10,
          humidity: 80,
          icon: '01d',
          sunrise: 1675171663,
          sunset: 1675206502,
        ),
      );



      await tester.pumpWidget(const MyApp());

      // Finde die Suchleiste und gebe einen Text ein
      await tester.enterText(find.byType(TextField), 'Berlin');
      await tester.tap(find.byType(IconButton)); // Trigger search button if exists
      await tester.pumpAndSettle();

      // Verifiziere, dass die Ergebnisse angezeigt werden
      expect(find.text('Berlin'), findsWidgets);
      expect(find.text('20°C - Klarer Himmel'), findsWidgets);
    });

    testWidgets('Displays error message on API failure', (WidgetTester tester) async {
      // Simulieren eines API-Fehlers
      when(mockApiService.fetchWeatherByCity(captureAnyNamed('city') ?? 'InvalidCity')).thenAnswer((_) async =>
      throw Exception('API-Fehler')
      );


      await tester.pumpWidget(const MyApp());

      await tester.enterText(find.byType(TextField), 'InvalidCity');
      await tester.tap(find.byType(IconButton)); // Trigger search button if exists
      await tester.pumpAndSettle();

      // Verifiziere, dass die Fehlermeldung angezeigt wird
      expect(find.text('Fehler beim Abrufen der Daten'), findsOneWidget);
    });

    testWidgets('Favorites screen displays favorite cities', (WidgetTester tester) async {
      when(mockFavoriteService.getFavorites()).thenAnswer((_) async => ['Berlin', 'Hamburg']);

      await tester.pumpWidget(const MyApp());
      await tester.tap(find.text('Favoriten'));
      await tester.pumpAndSettle();

      expect(find.text('Berlin'), findsOneWidget);
      expect(find.text('Hamburg'), findsOneWidget);
    });

    testWidgets('Settings screen updates language preference', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.tap(find.text('Einstellungen'));
      await tester.pumpAndSettle();

      expect(find.text('Deutsch'), findsOneWidget);

      await tester.tap(find.text('Sprache auswählen'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Englisch'));
      await tester.pumpAndSettle();

      expect(find.text('Englisch'), findsOneWidget);
    });
  });

  group('API Tests', () {
    test('Mocked API returns weather data', () async {
      when(mockApiService.fetchWeatherByCity('Berlin')).thenAnswer(
            (_) async => WeatherModel(
          cityName: 'Berlin',
          temperature: 20,
          condition: 'Klarer Himmel',
          windSpeed: 10,
          humidity: 80,
          icon: '01d',
          sunrise: 1675171663,
          sunset: 1675206502,
        ),
      );

      final weatherData = await mockApiService.fetchWeatherByCity('Berlin');
      expect(weatherData.temperature, 20);
      expect(weatherData.condition, 'Klarer Himmel');
    });

    test('Mocked API returns 7-day forecast', () async {
      when(mockApiService.fetch7DayForecast('Berlin')).thenAnswer(
            (_) async => [
          WeatherModel(
            cityName: 'Berlin',
            temperature: 20,
            condition: 'Klarer Himmel',
            windSpeed: 10,
            humidity: 80,
            icon: '01d',
            sunrise: 1675171663,
            sunset: 1675206502,
          ),
          WeatherModel(
            cityName: 'Berlin',
            temperature: 22,
            condition: 'Leichter Regen',
            windSpeed: 10,
            humidity: 80,
            icon: '01d',
            sunrise: 1675171663,
            sunset: 1675206502,
          ),
        ],
      );

      final forecastData = await mockApiService.fetch7DayForecast('Berlin');
      expect(forecastData, isNotEmpty);
      expect(forecastData[0].cityName, 'Berlin');
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

  group('Performance Tests', () {
    testWidgets('Handles long list of favorites gracefully', (WidgetTester tester) async {
      final mockFavorites = List.generate(100, (index) => 'City $index');
      when(mockFavoriteService.getFavorites()).thenAnswer((_) async => mockFavorites);

      await tester.pumpWidget(const MyApp());
      await tester.tap(find.text('Favoriten'));
      await tester.pumpAndSettle();

      expect(find.text('City 99'), findsOneWidget);
    });
  });
}









