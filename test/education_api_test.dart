import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:myportofolio_mobile/models/education.dart';
import 'package:myportofolio_mobile/services/api_client.dart';

import 'fake_backend.dart';

void main() {
  group('Education (json_serializable)', () {
    test('fromJson membaca snake_case dari EducationSerializer', () {
      final education = Education.fromJson(FakeBackend.sampleEducation());

      expect(education.id, 'e0000000-0000-4000-8000-000000000001');
      expect(education.level, 'S1');
      expect(education.institutionName, 'Universitas Indonesia');
      expect(education.startYear, 2025);
      expect(education.endYear, 'Sekarang');
      expect(education.logoUrl, '/static/img/logo-ui.png');
      expect(education.starCount, 2);
      expect(education.period, '2025 - Sekarang');
    });

    test('description dan logo_url null dari Django menjadi string kosong', () {
      final json = FakeBackend.sampleEducation(logoUrl: null)
        ..['description'] = null;

      final education = Education.fromJson(json);

      expect(education.description, '');
      expect(education.logoUrl, '');
    });

    test('toJson tidak mengirim id dan field hitungan server', () {
      const education = Education(
        id: 'abc',
        level: 'SMA',
        institutionName: 'SMA Negeri 1 Depok',
        startYear: 2022,
        endYear: '2025',
        starCount: 9,
        isStarred: true,
      );

      expect(education.toJson(), {
        'level': 'SMA',
        'institution_name': 'SMA Negeri 1 Depok',
        'start_year': 2022,
        'end_year': '2025',
        'description': '',
        'logo_url': '',
      });
    });
  });

  group('ApiClient Education', () {
    test(
      'getEducations memanggil GET publik tanpa header Authorization',
      () async {
        late http.Request sent;
        final client = ApiClient(
          baseUrl: 'http://api',
          client: MockClient((request) async {
            sent = request;
            return http.Response(
              jsonEncode([FakeBackend.sampleEducation()]),
              200,
            );
          }),
        );

        final educations = await client.getEducations();

        expect(sent.method, 'GET');
        expect(sent.url.toString(), 'http://api/api/v1/education/');
        expect(sent.headers.containsKey('Authorization'), isFalse);
        expect(educations.single.institutionName, 'Universitas Indonesia');
      },
    );

    test('createEducation mengirim token dan body JSON', () async {
      late http.Request sent;
      final client = ApiClient(
        baseUrl: 'http://api',
        client: MockClient((request) async {
          sent = request;
          return http.Response(
            jsonEncode({
              ...jsonDecode(request.body) as Map<String, dynamic>,
              'id': 'new-id',
              'star_count': 0,
              'is_starred': false,
            }),
            201,
          );
        }),
      );

      final created = await client.createEducation(
        const Education(
          level: 'S1',
          institutionName: 'Universitas Indonesia',
          startYear: 2025,
          endYear: 'Sekarang',
        ),
        token: 'abc123',
      );

      expect(sent.method, 'POST');
      expect(sent.url.path, '/api/v1/education/');
      expect(sent.headers['Authorization'], 'Token abc123');
      expect(sent.headers['Content-Type'], startsWith('application/json'));
      expect(jsonDecode(sent.body), isNot(contains('id')));
      expect(created.id, 'new-id');
    });

    test('deleteEducation mengirim DELETE ke detail dengan token', () async {
      late http.Request sent;
      final client = ApiClient(
        baseUrl: 'http://api',
        client: MockClient((request) async {
          sent = request;
          return http.Response('', 204);
        }),
      );

      await client.deleteEducation('xyz', token: 'abc123');

      expect(sent.method, 'DELETE');
      expect(sent.url.path, '/api/v1/education/xyz/');
      expect(sent.headers['Authorization'], 'Token abc123');
    });

    test('status non-2xx dilempar sebagai ApiException, bukan null', () async {
      final client = ApiClient(
        baseUrl: 'http://api',
        client: MockClient(
          (request) async => http.Response(
            jsonEncode({
              'start_year': ['Tahun masuk harus di antara 1900 dan 2100.'],
            }),
            400,
          ),
        ),
      );

      await expectLater(
        client.createEducation(
          const Education(
            level: 'S1',
            institutionName: 'UI',
            startYear: 1800,
            endYear: '1804',
          ),
          token: 'abc123',
        ),
        throwsA(
          isA<ApiException>()
              .having((e) => e.statusCode, 'statusCode', 400)
              .having(
                (e) => e.validationMessage,
                'validationMessage',
                'start_year: Tahun masuk harus di antara 1900 dan 2100.',
              ),
        ),
      );
    });
  });
}
