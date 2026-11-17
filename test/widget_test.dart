import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:myportofolio_mobile/main.dart';

const buttonNames = [
  'Lihat Experience',
  'Tambah Experience',
  'Tambah Proyek',
  'Logout',
];

/// Menggulir sampai tombol terlihat, lalu menekannya.
Future<void> tapButton(WidgetTester tester, String name) async {
  await tester.ensureVisible(find.text(name));
  await tester.tap(find.text(name));
}

/// Membuka halaman form lewat tombol Tambah Proyek di menu.
Future<void> openProjectForm(WidgetTester tester) async {
  await tester.pumpWidget(const MyApp());
  await tapButton(tester, 'Tambah Proyek');
  await tester.pumpAndSettle();
  // Tunggu SnackBar dari menu hilang supaya tidak menutupi tombol Save.
  await tester.pump(const Duration(seconds: 3));
  await tester.pumpAndSettle();
}

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

      await tapButton(tester, name);
      await tester.pump();

      expect(find.text('Kamu telah menekan tombol $name!'), findsOneWidget);
    });
  }

  testWidgets('Tombol Tambah Proyek membuka form, Back kembali ke menu', (
    WidgetTester tester,
  ) async {
    await openProjectForm(tester);

    expect(find.text('Add Project Form'), findsOneWidget);

    // Navigator.push menyisakan menu di bawah stack, jadi tombol Back
    // sistem (di sini disimulasikan) kembali ke menu.
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    expect(find.text('Selamat datang di MyPortfolio Mobile!'), findsOneWidget);
  });

  testWidgets('Drawer berisi Home dan Add Project, dan bisa pindah halaman', (
    WidgetTester tester,
  ) async {
    // Font bawaan flutter test (Ahem) jauh lebih lebar dari font asli,
    // sehingga teks DrawerHeader dianggap overflow. Abaikan khusus error itu.
    final originalOnError = FlutterError.onError;
    FlutterError.onError = (details) {
      if (!details.exceptionAsString().contains('overflowed')) {
        originalOnError?.call(details);
      }
    };
    addTearDown(() => FlutterError.onError = originalOnError);

    await tester.pumpWidget(const MyApp());

    await tester.tap(find.byTooltip('Open navigation menu'));
    await tester.pumpAndSettle();

    expect(find.text('My Portfolio'), findsOneWidget);
    expect(find.text('Home'), findsOneWidget);

    await tester.tap(find.text('Add Project'));
    await tester.pumpAndSettle();
    expect(find.text('Add Project Form'), findsOneWidget);

    await tester.tap(find.byTooltip('Open navigation menu'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Home'));
    await tester.pumpAndSettle();
    expect(find.text('Selamat datang di MyPortfolio Mobile!'), findsOneWidget);
  });

  testWidgets('Form menolak nama dan deskripsi yang kosong', (
    WidgetTester tester,
  ) async {
    await openProjectForm(tester);

    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.text('Nama proyek tidak boleh kosong!'), findsOneWidget);
    expect(find.text('Deskripsi proyek tidak boleh kosong!'), findsOneWidget);
    expect(find.byType(AlertDialog), findsNothing);
  });

  testWidgets('Form valid menampilkan semua isian di pop-up', (
    WidgetTester tester,
  ) async {
    await openProjectForm(tester);

    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'MyPortfolio Mobile');
    await tester.enterText(fields.at(1), 'Aplikasi portofolio Flutter');
    await tester.enterText(fields.at(2), 'Flutter, Django');
    await tester.enterText(fields.at(3), 'https://github.com/awiddymunaya');

    // Pilih kategori lain lewat dropdown.
    await tester.tap(find.text('Web Development'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Mobile Development').last);
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Save'));
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.text('Proyek berhasil ditambahkan!'), findsOneWidget);
    expect(find.text('Nama Proyek: MyPortfolio Mobile'), findsOneWidget);
    expect(find.text('Deskripsi: Aplikasi portofolio Flutter'), findsOneWidget);
    expect(find.text('Kategori: Mobile Development'), findsOneWidget);
    expect(find.text('Teknologi: Flutter, Django'), findsOneWidget);
    expect(
      find.text('Tautan: https://github.com/awiddymunaya'),
      findsOneWidget,
    );

    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsNothing);
  });
}
