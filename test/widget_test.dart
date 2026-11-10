import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:myportofolio_mobile/main.dart';

const buttonNames = ['Lihat Experience', 'Tambah Experience', 'Logout'];

void main() {
  testWidgets('Halaman menu menampilkan InfoCard dengan data saya', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('MyPortfolio'), findsOneWidget);
    expect(find.text('Selamat datang di MyPortfolio Mobile!'), findsOneWidget);
    expect(find.text('2506622872'), findsOneWidget);
    expect(find.text('Awiddy Munaya Rajanadoli'), findsOneWidget);
    expect(find.text('PBP D'), findsOneWidget);
  });

  testWidgets('Setiap tombol punya warna latar yang berbeda', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    final colors = <Color?>{};
    for (final name in buttonNames) {
      expect(find.text(name), findsOneWidget);
      final card = tester.widget<Material>(
        find
            .ancestor(of: find.text(name), matching: find.byType(Material))
            .first,
      );
      colors.add(card.color);
    }

    expect(colors.length, buttonNames.length);
  });

  for (final name in buttonNames) {
    testWidgets('Menekan $name memunculkan SnackBar yang sesuai', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MyApp());

      await tester.tap(find.text(name));
      await tester.pump();

      expect(find.text('Kamu telah menekan tombol $name!'), findsOneWidget);
    });
  }
}
