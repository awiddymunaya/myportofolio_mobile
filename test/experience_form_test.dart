import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:myportofolio_mobile/main.dart';

/// Font bawaan flutter test (Ahem) jauh lebih lebar dari font asli,
/// sehingga teks DrawerHeader dianggap overflow. Abaikan khusus error itu.
void ignoreOverflowErrors() {
  final originalOnError = FlutterError.onError;
  FlutterError.onError = (details) {
    if (!details.exceptionAsString().contains('overflowed')) {
      originalOnError?.call(details);
    }
  };
  addTearDown(() => FlutterError.onError = originalOnError);
}

/// Membuka form Experience lewat kartu Tambah Experience di menu.
Future<void> openExperienceForm(WidgetTester tester) async {
  await tester.pumpWidget(const MyApp());
  await tester.ensureVisible(find.text('Tambah Experience'));
  await tester.tap(find.text('Tambah Experience'));
  await tester.pumpAndSettle();
  // Tunggu SnackBar dari menu hilang supaya tidak menutupi tombol Save.
  await tester.pump(const Duration(seconds: 3));
  await tester.pumpAndSettle();
}

/// Memilih tanggal [day] pada bulan yang sedang tampil di date picker.
Future<void> pickDay(WidgetTester tester, String label, String day) async {
  await tester.ensureVisible(find.widgetWithText(TextFormField, label));
  await tester.tap(find.widgetWithText(TextFormField, label));
  await tester.pumpAndSettle();
  await tester.tap(find.text(day).last);
  await tester.tap(find.text('OK'));
  await tester.pumpAndSettle();
}

Future<void> tapSave(WidgetTester tester) async {
  await tester.ensureVisible(find.text('Save'));
  await tester.tap(find.text('Save'));
  await tester.pumpAndSettle();
}

Finder field(String label) => find.widgetWithText(TextFormField, label);

void main() {
  testWidgets('Kartu Tambah Experience membuka form, Back kembali ke menu', (
    WidgetTester tester,
  ) async {
    await openExperienceForm(tester);

    expect(find.text('Add Experience Form'), findsOneWidget);

    // Navigator.push menyisakan menu di bawah stack, jadi tombol Back
    // perangkat (di sini disimulasikan) kembali ke menu.
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    expect(find.text('Selamat datang di MyPortfolio Mobile!'), findsOneWidget);
  });

  testWidgets('Drawer punya Add Experience, dan Home dari form ke menu', (
    WidgetTester tester,
  ) async {
    ignoreOverflowErrors();
    await tester.pumpWidget(const MyApp());

    await tester.tap(find.byTooltip('Open navigation menu'));
    await tester.pumpAndSettle();
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Add Project'), findsOneWidget);
    expect(find.text('Add Experience'), findsOneWidget);

    await tester.tap(find.text('Add Experience'));
    await tester.pumpAndSettle();
    expect(find.text('Add Experience Form'), findsOneWidget);

    // Halaman form memakai drawer yang sama.
    await tester.tap(find.byTooltip('Open navigation menu'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Home'));
    await tester.pumpAndSettle();
    expect(find.text('Selamat datang di MyPortfolio Mobile!'), findsOneWidget);
  });

  testWidgets('Form kosong menampilkan pesan kesalahan di tiap kolom wajib', (
    WidgetTester tester,
  ) async {
    await openExperienceForm(tester);

    // Isian yang hanya berisi spasi tetap dianggap kosong.
    await tester.enterText(field('Judul Experience'), '   ');
    await tapSave(tester);

    expect(find.text('Judul experience tidak boleh kosong!'), findsOneWidget);
    expect(find.text('Deskripsi tidak boleh kosong!'), findsOneWidget);
    expect(find.text('Tanggal mulai harus dipilih!'), findsOneWidget);
    expect(
      find.text("Pilih tanggal selesai atau aktifkan 'Masih berlangsung'!"),
      findsOneWidget,
    );
    expect(find.byType(AlertDialog), findsNothing);
  });

  testWidgets(
    'Form menolak URL salah, deskripsi pendek, dan tanggal terbalik',
    (WidgetTester tester) async {
      await openExperienceForm(tester);

      await tester.enterText(field('Judul Experience'), 'x' * 256);
      await tester.enterText(field('Deskripsi'), 'Pendek');
      await tester.enterText(field('Thumbnail (opsional)'), 'bukan url');
      await pickDay(tester, 'Tanggal Mulai', '15');
      await pickDay(tester, 'Tanggal Selesai', '1');
      await tapSave(tester);

      expect(find.text('Judul maksimal 255 karakter!'), findsOneWidget);
      expect(find.text('Deskripsi minimal 10 karakter!'), findsOneWidget);
      expect(
        find.text(
          'Isi dengan URL http(s) atau path seperti /static/img/foto.jpg',
        ),
        findsOneWidget,
      );
      expect(
        find.text('Tanggal selesai tidak boleh sebelum tanggal mulai!'),
        findsOneWidget,
      );
      expect(find.byType(AlertDialog), findsNothing);
    },
  );

  testWidgets('Form valid menampilkan semua isian lalu OK mengosongkan form', (
    WidgetTester tester,
  ) async {
    await openExperienceForm(tester);

    await tester.enterText(field('Judul Experience'), 'Staff IT Compfest');
    await tester.enterText(
      field('Deskripsi'),
      'Mengembangkan website acara Compfest',
    );
    await tester.enterText(
      field('Thumbnail (opsional)'),
      '/static/img/Compfest.jpg',
    );
    await tester.enterText(
      field('Logo Organisasi (opsional)'),
      'https://compfest.id/logo.png',
    );

    // Pilih kategori Volunteer lewat dropdown.
    await tester.tap(find.text('Full-Time'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Volunteer').last);
    await tester.pumpAndSettle();

    await pickDay(tester, 'Tanggal Mulai', '1');

    // Masih berlangsung: tanggal selesai tidak wajib.
    await tester.ensureVisible(find.text('Masih berlangsung'));
    await tester.tap(find.text('Masih berlangsung'));
    await tester.pumpAndSettle();

    await tapSave(tester);

    final now = DateTime.now();
    final start = '${now.year}-${now.month.toString().padLeft(2, '0')}-01';

    expect(find.text('Experience berhasil ditambahkan!'), findsOneWidget);
    expect(find.text('Judul: Staff IT Compfest'), findsOneWidget);
    expect(
      find.text('Deskripsi: Mengembangkan website acara Compfest'),
      findsOneWidget,
    );
    expect(find.text('Kategori: Volunteer'), findsOneWidget);
    expect(find.text('Thumbnail: /static/img/Compfest.jpg'), findsOneWidget);
    expect(find.text('Logo: https://compfest.id/logo.png'), findsOneWidget);
    expect(find.text('Mulai: $start'), findsOneWidget);
    expect(find.text('Selesai: Masih berlangsung'), findsOneWidget);

    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsNothing);

    // Form kembali kosong dan siap diisi lagi.
    expect(find.text('Staff IT Compfest'), findsNothing);
    expect(find.text('Full-Time'), findsOneWidget);
  });
}
