import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'fake_backend.dart';

Future<void> tapMenu(WidgetTester tester, String name) async {
  await tester.ensureVisible(find.text(name));
  await tester.tap(find.text(name));
  await tester.pumpAndSettle();
}

/// Membuka daftar Education dari kartu menu (tanpa login).
Future<void> openEducationList(WidgetTester tester, FakeBackend backend) async {
  await pumpApp(tester, backend);
  await tapMenu(tester, 'Lihat Education');
  await waitSnackBar(tester);
}

/// Membuka form Education dari kartu menu. Belum login, jadi Login dulu.
Future<void> openEducationForm(
  WidgetTester tester, {
  required FakeBackend backend,
  String username = 'owner',
}) async {
  await pumpApp(tester, backend);
  await tapMenu(tester, 'Tambah Education');
  await submitLogin(tester, username: username);
  await waitSnackBar(tester);
}

Finder field(String label) => find.widgetWithText(TextFormField, label);

Future<void> fillValidForm(WidgetTester tester) async {
  await tester.enterText(field('Jenjang Pendidikan'), 'SMA');
  await tester.enterText(field('Nama Institusi'), 'SMA Negeri 1 Depok');
  await tester.enterText(field('Tahun Masuk'), '2022');
  await tester.enterText(field('Tahun Lulus'), '2025');
  await tester.enterText(field('Catatan (opsional)'), 'Jurusan IPA');
}

Future<void> tapSave(WidgetTester tester) async {
  await tester.ensureVisible(find.text('Save'));
  await tester.tap(find.text('Save'));
  await tester.pumpAndSettle();
}

void main() {
  group('Daftar dan detail Education', () {
    testWidgets('Daftar tampil tanpa login, detail menampilkan semua field', (
      WidgetTester tester,
    ) async {
      final backend = FakeBackend();
      await openEducationList(tester, backend);

      expect(find.text('Education'), findsOneWidget);
      expect(find.text('Universitas Indonesia'), findsOneWidget);
      expect(find.text('S1 | 2025 - Sekarang'), findsOneWidget);
      expect(backend.educationListCalls, 1);

      await tester.tap(find.text('Universitas Indonesia'));
      await tester.pumpAndSettle();

      expect(find.text('S1'), findsOneWidget);
      expect(find.text('2025'), findsOneWidget);
      expect(find.text('Sekarang'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);
      expect(find.text('Ilmu Komputer, Fasilkom UI'), findsOneWidget);
      final logo = tester.widget<Image>(
        find.descendant(
          of: find.byKey(const Key('education-logo')),
          matching: find.byType(Image),
        ),
      );
      expect(
        (logo.image as NetworkImage).url,
        'http://api/static/img/logo-ui.png',
      );
    });

    testWidgets(
      'Logo kosong tidak ditampilkan dan catatan kosong diberi teks',
      (WidgetTester tester) async {
        final education = FakeBackend.sampleEducation(logoUrl: null)
          ..['description'] = null;
        await openEducationList(tester, FakeBackend(educations: [education]));

        await tester.tap(find.text('Universitas Indonesia'));
        await tester.pumpAndSettle();

        expect(find.byKey(const Key('education-logo')), findsNothing);
        expect(find.text('Tidak ada catatan.'), findsOneWidget);
      },
    );

    testWidgets('Daftar kosong tetap bisa ditarik untuk refresh', (
      WidgetTester tester,
    ) async {
      final backend = FakeBackend(educations: []);
      await openEducationList(tester, backend);

      expect(find.text('No education found.'), findsOneWidget);

      backend.educations.add(FakeBackend.sampleEducation());
      await tester.fling(
        find.text('No education found.'),
        const Offset(0, 400),
        1000,
      );
      await tester.pumpAndSettle();

      expect(backend.educationListCalls, 2);
      expect(find.text('Universitas Indonesia'), findsOneWidget);
    });

    testWidgets('Error server menampilkan pesan dan tombol Retry', (
      WidgetTester tester,
    ) async {
      final backend = FakeBackend()..listStatus = 500;
      await openEducationList(tester, backend);

      expect(find.textContaining('Failed to load education'), findsOneWidget);
      expect(find.textContaining('ApiException(500)'), findsOneWidget);

      backend.listStatus = null;
      await tester.tap(find.text('Retry'));
      await tester.pumpAndSettle();

      expect(find.text('Universitas Indonesia'), findsOneWidget);
    });

    testWidgets('Drawer punya Education dan Add Education', (
      WidgetTester tester,
    ) async {
      ignoreOverflowErrors();
      await pumpApp(tester, FakeBackend());
      await openDrawer(tester);

      await tester.tap(find.text('Education'));
      await tester.pumpAndSettle();
      expect(find.text('Universitas Indonesia'), findsOneWidget);

      await openDrawer(tester);
      await tester.tap(find.text('Add Education'));
      await tester.pumpAndSettle();
      // Belum login: halaman Login muncul sebelum form.
      expect(find.widgetWithText(ElevatedButton, 'Login'), findsOneWidget);
      await submitLogin(tester);
      expect(find.text('Add Education Form'), findsOneWidget);
    });
  });

  group('Form Education (POST dengan token)', () {
    testWidgets(
      'Tambah Education tanpa login membuka Login, batal = tidak ada form',
      (WidgetTester tester) async {
        await pumpApp(tester, FakeBackend());
        await tapMenu(tester, 'Tambah Education');

        expect(find.widgetWithText(ElevatedButton, 'Login'), findsOneWidget);
        await tester.binding.handlePopRoute();
        await tester.pumpAndSettle();
        expect(find.text('Add Education Form'), findsNothing);
      },
    );

    testWidgets('Validasi: kosong, tahun bukan angka, dan tahun lulus mundur', (
      WidgetTester tester,
    ) async {
      final backend = FakeBackend();
      await openEducationForm(tester, backend: backend);

      await tapSave(tester);
      expect(
        find.text('Jenjang pendidikan tidak boleh kosong!'),
        findsOneWidget,
      );
      expect(find.text('Nama institusi tidak boleh kosong!'), findsOneWidget);
      expect(find.text('Tahun masuk tidak boleh kosong!'), findsOneWidget);

      await tester.enterText(field('Tahun Masuk'), 'dua ribu');
      await tester.enterText(field('Tahun Lulus'), '2020');
      await tapSave(tester);
      expect(find.text('Tahun masuk harus berupa angka!'), findsOneWidget);

      await tester.enterText(field('Tahun Masuk'), '2022');
      await tapSave(tester);
      expect(
        find.text('Tahun lulus tidak boleh sebelum tahun masuk!'),
        findsOneWidget,
      );
      expect(backend.educationAuthHeaders, isEmpty);
    });

    testWidgets(
      'Save mengirim POST bertoken, lalu Lihat Daftar memuat entri baru',
      (WidgetTester tester) async {
        final backend = FakeBackend();
        await openEducationForm(tester, backend: backend);

        // Chip jenjang mengisi field Jenjang.
        await tester.tap(find.widgetWithText(ActionChip, 'S2'));
        await tester.pump();
        await fillValidForm(tester);
        await tapSave(tester);

        expect(backend.educationAuthHeaders, [
          'Token ${FakeBackend.ownerToken}',
        ]);
        expect(backend.createdEducationBodies.single, {
          'level': 'SMA',
          'institution_name': 'SMA Negeri 1 Depok',
          'start_year': 2022,
          'end_year': '2025',
          'description': 'Jurusan IPA',
          'logo_url': '',
        });
        expect(find.text('Education berhasil ditambahkan!'), findsOneWidget);
        expect(find.text('Periode: 2022 - 2025'), findsOneWidget);

        await tester.tap(find.text('Lihat Daftar'));
        await tester.pumpAndSettle();

        expect(find.text('SMA Negeri 1 Depok'), findsOneWidget);
        expect(find.text('Universitas Indonesia'), findsOneWidget);
      },
    );

    testWidgets('Switch Masih menempuh pendidikan mengirim end_year Sekarang', (
      WidgetTester tester,
    ) async {
      final backend = FakeBackend();
      await openEducationForm(tester, backend: backend);
      await fillValidForm(tester);

      await tester.ensureVisible(find.text('Masih menempuh pendidikan'));
      await tester.tap(find.text('Masih menempuh pendidikan'));
      await tester.pumpAndSettle();
      await tapSave(tester);

      expect(backend.createdEducationBodies.single['end_year'], 'Sekarang');

      // Tambah Lagi mengosongkan form.
      await tester.tap(find.text('Tambah Lagi'));
      await tester.pumpAndSettle();
      expect(find.text('SMA Negeri 1 Depok'), findsNothing);
    });

    testWidgets(
      'Token dihapus di server (401): sesi dihapus, login ulang, kirim ulang',
      (WidgetTester tester) async {
        final backend = FakeBackend();
        await openEducationForm(tester, backend: backend);
        await fillValidForm(tester);

        backend.tokenExpired = true;
        await tapSave(tester);

        expect(
          find.text('Sesi login berakhir, silakan login ulang.'),
          findsOne,
        );
        expect(find.widgetWithText(ElevatedButton, 'Login'), findsOneWidget);
        expect(backend.logoutCalls, 1);

        backend.tokenExpired = false;
        await submitLogin(tester);

        expect(backend.educationAuthHeaders.length, 2);
        expect(find.text('Education berhasil ditambahkan!'), findsOneWidget);
      },
    );

    testWidgets('Akun bukan Pemilik (403) mendapat SnackBar', (
      WidgetTester tester,
    ) async {
      final backend = FakeBackend();
      await openEducationForm(tester, backend: backend, username: 'visitor');
      await fillValidForm(tester);
      await tapSave(tester);

      expect(
        find.text(
          'Akunmu tidak boleh menambah Education (hanya Pemilik/superuser).',
        ),
        findsOneWidget,
      );
      expect(backend.createdEducationBodies, isEmpty);
    });

    testWidgets('Error validasi Django (400) ditampilkan di SnackBar', (
      WidgetTester tester,
    ) async {
      final backend = FakeBackend()..createEducationStatus = 400;
      await openEducationForm(tester, backend: backend);
      await fillValidForm(tester);
      await tapSave(tester);

      expect(
        find.text('end_year: Tahun lulus tidak boleh sebelum tahun masuk.'),
        findsOneWidget,
      );
      expect(find.byType(AlertDialog), findsNothing);
    });

    testWidgets('Tombol + di daftar: setelah simpan, daftar dimuat ulang', (
      WidgetTester tester,
    ) async {
      final backend = FakeBackend();
      await openEducationList(tester, backend);

      await tester.tap(find.byTooltip('Tambah Education'));
      await tester.pumpAndSettle();
      await submitLogin(tester);
      await fillValidForm(tester);
      await tapSave(tester);
      await tester.tap(find.text('Lihat Daftar'));
      await tester.pumpAndSettle();

      // Kembali ke daftar yang sama (bukan menumpuk daftar baru).
      expect(backend.educationListCalls, 2);
      expect(find.text('SMA Negeri 1 Depok'), findsOneWidget);
      // Back sekali kembali ke menu, berarti tidak ada daftar ganda di stack.
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(
        find.text('Selamat datang di MyPortfolio Mobile!'),
        findsOneWidget,
      );
    });
  });

  group('Hapus Education (DELETE dengan token)', () {
    testWidgets('Pemilik menghapus dari detail, daftar dimuat ulang', (
      WidgetTester tester,
    ) async {
      final backend = FakeBackend();
      await openEducationList(tester, backend);
      await tester.tap(find.text('Universitas Indonesia'));
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip('Hapus Education'));
      await tester.pumpAndSettle();
      await submitLogin(tester);

      // Dialog konfirmasi: Batal tidak menghapus apa pun.
      expect(find.text('Hapus Education?'), findsOneWidget);
      await tester.tap(find.text('Batal'));
      await tester.pumpAndSettle();
      expect(backend.deletedEducationIds, isEmpty);

      await tester.tap(find.byTooltip('Hapus Education'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Hapus'));
      await tester.pumpAndSettle();

      expect(backend.deletedEducationIds, [
        'e0000000-0000-4000-8000-000000000001',
      ]);
      expect(
        backend.educationAuthHeaders.last,
        'Token ${FakeBackend.ownerToken}',
      );
      expect(find.text('No education found.'), findsOneWidget);
    });

    testWidgets('Akun bukan Pemilik (403) tidak bisa menghapus', (
      WidgetTester tester,
    ) async {
      final backend = FakeBackend();
      await openEducationList(tester, backend);
      await tester.tap(find.text('Universitas Indonesia'));
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip('Hapus Education'));
      await tester.pumpAndSettle();
      await submitLogin(tester, username: 'visitor');
      await tester.tap(find.text('Hapus'));
      await tester.pumpAndSettle();

      expect(
        find.text(
          'Akunmu tidak boleh menghapus Education (hanya Pemilik/superuser).',
        ),
        findsOneWidget,
      );
      expect(backend.educations, hasLength(1));
    });
  });
}
