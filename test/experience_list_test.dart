import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'fake_backend.dart';

Future<void> openList(WidgetTester tester, FakeBackend backend) async {
  await pumpApp(tester, backend);
  await tester.ensureVisible(find.text('Lihat Experience'));
  await tester.tap(find.text('Lihat Experience'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('Daftar kosong menampilkan pesan dan tetap bisa di-refresh', (
    WidgetTester tester,
  ) async {
    final backend = FakeBackend(experiences: []);
    await openList(tester, backend);

    expect(find.text('No experiences found.'), findsOneWidget);
    expect(find.byType(RefreshIndicator), findsOneWidget);

    // Tarik ke bawah untuk refresh.
    backend.experiences.add(FakeBackend.sampleExperience());
    await tester.fling(
      find.text('No experiences found.'),
      const Offset(0, 400),
      1000,
    );
    await tester.pumpAndSettle();

    expect(backend.listCalls, 2);
    expect(find.text('Asisten Dosen PBP'), findsOneWidget);
  });

  testWidgets('Error dari server menampilkan pesan dan tombol Retry', (
    WidgetTester tester,
  ) async {
    final backend = FakeBackend()..listStatus = 500;
    await openList(tester, backend);

    expect(find.textContaining('Failed to load experiences'), findsOneWidget);
    expect(find.textContaining('ApiException(500)'), findsOneWidget);

    backend.listStatus = null;
    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();

    expect(find.text('Asisten Dosen PBP'), findsOneWidget);
  });

  testWidgets('Menekan item membuka detail dengan gambar', (
    WidgetTester tester,
  ) async {
    await openList(tester, FakeBackend());

    await tester.tap(find.text('Asisten Dosen PBP'));
    await tester.pumpAndSettle();

    expect(
      find.text('Membantu praktikum Pemrograman Berbasis Platform'),
      findsOneWidget,
    );
    expect(find.text('Part-Time'), findsOneWidget);
    expect(find.text('2026-02-01 - Sekarang'), findsOneWidget);
    expect(find.text('3 star'), findsOneWidget);

    // Thumbnail ada, path /static/... diubah menjadi URL lengkap.
    final image = tester.widget<Image>(
      find.descendant(
        of: find.byKey(const Key('experience-thumbnail')),
        matching: find.byType(Image),
      ),
    );
    expect(
      (image.image as NetworkImage).url,
      'http://api/static/img/asdos.jpg',
    );
    // logo_url null dari API: widget logo tidak ditampilkan.
    expect(find.byKey(const Key('experience-logo')), findsNothing);
  });

  testWidgets('Detail tanpa thumbnail tidak menampilkan gambar', (
    WidgetTester tester,
  ) async {
    await openList(
      tester,
      FakeBackend(
        experiences: [
          FakeBackend.sampleExperience(title: 'Tanpa Foto', thumbnail: ''),
        ],
      ),
    );

    await tester.tap(find.text('Tanpa Foto'));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('experience-thumbnail')), findsNothing);
    expect(find.byType(Image), findsNothing);
  });
}
