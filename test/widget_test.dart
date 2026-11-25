import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'fake_backend.dart';

const buttonNames = [
  'Lihat Experience',
  'Tambah Experience',
  'Lihat Education',
  'Tambah Education',
  'Logout',
];

/// Menggulir sampai tombol terlihat, lalu menekannya.
Future<void> tapButton(WidgetTester tester, String name) async {
  await tester.ensureVisible(find.text(name));
  await tester.tap(find.text(name));
}

void main() {
  testWidgets('Halaman menu menampilkan InfoCard dengan data saya', (
    WidgetTester tester,
  ) async {
    await pumpApp(tester, FakeBackend());

    expect(find.text('MyPortfolio'), findsOneWidget);
    expect(find.text('Selamat datang di MyPortfolio Mobile!'), findsOneWidget);
    expect(find.text('2506622872'), findsOneWidget);
    expect(find.text('Awiddy Munaya Rajanadoli'), findsOneWidget);
    expect(find.text('PBP D'), findsOneWidget);
  });

  testWidgets('Setiap tombol punya warna latar yang berbeda', (
    WidgetTester tester,
  ) async {
    await pumpApp(tester, FakeBackend());

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

  testWidgets('Lihat Experience menampilkan data dari API tanpa login', (
    WidgetTester tester,
  ) async {
    final backend = FakeBackend();
    await pumpApp(tester, backend);

    await tapButton(tester, 'Lihat Experience');
    await tester.pump();
    expect(find.text('Kamu telah menekan tombol Lihat Experience!'), findsOne);

    await tester.pumpAndSettle();
    expect(find.text('Achievements: Experiences'), findsOneWidget);
    expect(find.text('Asisten Dosen PBP'), findsOneWidget);
    expect(find.textContaining('Part-Time | 2026-02-01 - Sekarang'), findsOne);
    expect(backend.listCalls, 1);
  });

  testWidgets('Tambah Experience tanpa login membuka halaman Login dulu', (
    WidgetTester tester,
  ) async {
    await pumpApp(tester, FakeBackend());

    await tapButton(tester, 'Tambah Experience');
    await tester.pumpAndSettle();

    expect(find.widgetWithText(ElevatedButton, 'Login'), findsOneWidget);
    expect(find.text('Add Experience Form'), findsNothing);

    // Kolom kosong ditolak validator.
    await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
    await tester.pumpAndSettle();
    expect(find.text('Username cannot be empty!'), findsOneWidget);
    expect(find.text('Password cannot be empty!'), findsOneWidget);

    // Password salah: tetap di halaman Login dan muncul SnackBar.
    await submitLogin(tester, password: 'salah');
    expect(
      find.text('Login gagal (400): username atau password salah.'),
      findsOneWidget,
    );
    expect(find.text('Add Experience Form'), findsNothing);

    // Password benar: langsung diteruskan ke form.
    await submitLogin(tester);
    expect(find.text('Add Experience Form'), findsOneWidget);
  });

  testWidgets('Back dari halaman Login tidak membuka form', (
    WidgetTester tester,
  ) async {
    await pumpApp(tester, FakeBackend());

    await tapButton(tester, 'Tambah Experience');
    await tester.pumpAndSettle();
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    expect(find.text('Selamat datang di MyPortfolio Mobile!'), findsOneWidget);
    expect(find.text('Add Experience Form'), findsNothing);
  });

  testWidgets('Logout: belum login vs sudah login', (
    WidgetTester tester,
  ) async {
    final backend = FakeBackend();
    await pumpApp(tester, backend);

    await tapButton(tester, 'Logout');
    await tester.pump();
    expect(find.text('Kamu belum login.'), findsOneWidget);
    expect(backend.logoutCalls, 0);
    await waitSnackBar(tester);

    // Login lewat Tambah Experience, lalu kembali ke menu.
    await tapButton(tester, 'Tambah Experience');
    await tester.pumpAndSettle();
    await submitLogin(tester);
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    await waitSnackBar(tester);

    await tapButton(tester, 'Logout');
    await tester.pumpAndSettle();
    expect(find.text('Kamu sudah logout.'), findsOneWidget);
    expect(backend.logoutCalls, 1);
    await waitSnackBar(tester);

    // Setelah logout, Tambah Experience meminta login lagi.
    await tapButton(tester, 'Tambah Experience');
    await tester.pumpAndSettle();
    expect(find.widgetWithText(ElevatedButton, 'Login'), findsOneWidget);
  });

  testWidgets('Drawer menampilkan Login atau Logout sesuai status', (
    WidgetTester tester,
  ) async {
    ignoreOverflowErrors();
    final backend = FakeBackend();
    await pumpApp(tester, backend);

    await openDrawer(tester);
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Experiences'), findsOneWidget);
    expect(find.text('Add Experience'), findsOneWidget);
    expect(find.widgetWithText(ListTile, 'Login'), findsOneWidget);
    expect(find.widgetWithText(ListTile, 'Logout'), findsNothing);

    await tester.tap(find.widgetWithText(ListTile, 'Login'));
    await tester.pumpAndSettle();
    await submitLogin(tester);
    expect(find.text('Login berhasil!'), findsOneWidget);

    // Drawer masih terbuka dan langsung berganti menjadi Logout.
    expect(find.widgetWithText(ListTile, 'Logout'), findsOneWidget);
    expect(find.widgetWithText(ListTile, 'Login'), findsNothing);

    await tester.tap(find.widgetWithText(ListTile, 'Logout'));
    await tester.pumpAndSettle();
    expect(backend.logoutCalls, 1);
    expect(find.widgetWithText(ListTile, 'Login'), findsOneWidget);
  });

  testWidgets('Drawer Experiences membuka daftar, Home kembali ke menu', (
    WidgetTester tester,
  ) async {
    ignoreOverflowErrors();
    await pumpApp(tester, FakeBackend());

    await openDrawer(tester);
    await tester.tap(find.text('Experiences'));
    await tester.pumpAndSettle();
    expect(find.text('Asisten Dosen PBP'), findsOneWidget);

    await openDrawer(tester);
    await tester.tap(find.text('Home'));
    await tester.pumpAndSettle();
    expect(find.text('Selamat datang di MyPortfolio Mobile!'), findsOneWidget);
  });
}
