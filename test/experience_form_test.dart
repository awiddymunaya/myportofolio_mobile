import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fake_backend.dart';

/// Membuka form Experience lewat kartu Tambah Experience di menu.
/// Karena belum login, halaman Login muncul dulu.
Future<void> openExperienceForm(
  WidgetTester tester, {
  FakeBackend? backend,
  String username = 'owner',
}) async {
  await pumpApp(tester, backend ?? FakeBackend());
  await tester.ensureVisible(find.text('Tambah Experience'));
  await tester.tap(find.text('Tambah Experience'));
  await tester.pumpAndSettle();
  await submitLogin(tester, username: username);
  // Tunggu SnackBar dari menu hilang supaya tidak menutupi tombol Save.
  await waitSnackBar(tester);
}

/// Mengisi semua kolom wajib dengan data yang valid.
Future<void> fillValidForm(WidgetTester tester) async {
  await tester.enterText(field('Judul Experience'), 'Staff IT Compfest');
  await tester.enterText(
    field('Deskripsi'),
    'Mengembangkan website acara Compfest',
  );
  await pickDay(tester, 'Tanggal Mulai', '1');
  await tester.ensureVisible(find.text('Masih berlangsung'));
  await tester.tap(find.text('Masih berlangsung'));
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
    await pumpApp(tester, FakeBackend());

    await tester.tap(find.byTooltip('Open navigation menu'));
    await tester.pumpAndSettle();
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Add Experience'), findsOneWidget);

    // Belum login: Add Experience membuka Login dulu, lalu form.
    await tester.tap(find.text('Add Experience'));
    await tester.pumpAndSettle();
    await submitLogin(tester);
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

  testWidgets('Form valid dikirim ke API lalu OK mengosongkan form', (
    WidgetTester tester,
  ) async {
    final backend = FakeBackend();
    await openExperienceForm(tester, backend: backend);

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

    // Data benar-benar dikirim dengan token, sesuai skema serializer Django.
    expect(backend.createAuthHeaders, ['Token ${FakeBackend.ownerToken}']);
    expect(backend.createdBodies.single, {
      'title': 'Staff IT Compfest',
      'description': 'Mengembangkan website acara Compfest',
      'category': 'volunteer',
      'thumbnail': '/static/img/Compfest.jpg',
      'logo_url': 'https://compfest.id/logo.png',
      'started_at': start,
      'ended_at': null,
    });

    // Pop-up menampilkan data balasan Django (201 Created).
    expect(find.text('Experience berhasil ditambahkan!'), findsOneWidget);
    expect(find.text('Judul: Staff IT Compfest'), findsOneWidget);
    expect(
      find.text('Deskripsi: Mengembangkan website acara Compfest'),
      findsOneWidget,
    );
    expect(find.text('Kategori: Volunteer'), findsOneWidget);
    expect(find.text('Thumbnail: /static/img/Compfest.jpg'), findsOneWidget);
    expect(find.text('Logo: https://compfest.id/logo.png'), findsOneWidget);
    expect(find.text('Periode: $start - Sekarang'), findsOneWidget);

    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsNothing);

    // Form kembali kosong dan siap diisi lagi.
    expect(find.text('Staff IT Compfest'), findsNothing);
    expect(find.text('Full-Time'), findsOneWidget);
  });
  testWidgets('Form tidak dikirim jika validasi gagal', (
    WidgetTester tester,
  ) async {
    final backend = FakeBackend();
    await openExperienceForm(tester, backend: backend);

    await tapSave(tester);
    expect(backend.createdBodies, isEmpty);
    expect(backend.createAuthHeaders, isEmpty);
  });

  testWidgets('Token kedaluwarsa (401): logout lalu diminta login ulang', (
    WidgetTester tester,
  ) async {
    final backend = FakeBackend();
    await openExperienceForm(tester, backend: backend);
    await fillValidForm(tester);

    backend.tokenExpired = true;
    await tapSave(tester);

    // Token lama ditolak, aplikasi logout dan membuka halaman Login.
    expect(find.text('Sesi login berakhir, silakan login ulang.'), findsOne);
    expect(find.widgetWithText(ElevatedButton, 'Login'), findsOneWidget);
    expect(backend.logoutCalls, 1);

    // Setelah login ulang, form otomatis dikirim lagi.
    backend.tokenExpired = false;
    await submitLogin(tester);
    expect(backend.createAuthHeaders.length, 2);
    expect(find.text('Experience berhasil ditambahkan!'), findsOneWidget);
  });

  testWidgets('Akun bukan Pemilik (403) mendapat SnackBar', (
    WidgetTester tester,
  ) async {
    final backend = FakeBackend();
    await openExperienceForm(tester, backend: backend, username: 'visitor');
    await fillValidForm(tester);

    await tapSave(tester);

    expect(
      find.text(
        'Akunmu tidak boleh menambah Experience (hanya Pemilik/superuser).',
      ),
      findsOneWidget,
    );
    expect(find.byType(AlertDialog), findsNothing);
    expect(backend.createdBodies, isEmpty);
  });
}
