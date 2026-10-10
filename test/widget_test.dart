import 'package:flutter_test/flutter_test.dart';
import 'package:app_peliculas/main.dart';

void main() {
  testWidgets('La aplicación muestra la pantalla principal', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const PeliculasApp());

    expect(find.text('CineHub'), findsOneWidget);
  });
}