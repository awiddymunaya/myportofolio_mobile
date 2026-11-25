import 'package:json_annotation/json_annotation.dart';

part 'education.g.dart';

/// Satu riwayat pendidikan, sama dengan EducationSerializer di Django
/// (Tugas 6, endpoint /api/v1/education/).
@JsonSerializable(fieldRename: FieldRename.snake)
class Education {
  const Education({
    required this.level,
    required this.institutionName,
    required this.startYear,
    required this.endYear,
    this.description = '',
    this.logoUrl = '',
    this.id,
    this.starCount = 0,
    this.isStarred = false,
  });

  factory Education.fromJson(Map<String, dynamic> json) =>
      _$EducationFromJson(json);

  /// UUID dibuat oleh Django, jadi tidak ikut dikirim saat POST.
  @JsonKey(includeToJson: false)
  final String? id;

  /// Jenjang pendidikan, misalnya `S1` atau `SMA`.
  final String level;

  final String institutionName;

  /// Tahun masuk (IntegerField di Django).
  final int startYear;

  /// Tahun lulus. CharField di Django, jadi boleh berisi `Sekarang`.
  final String endYear;

  /// Catatan tambahan (boleh kosong / null di Django).
  @JsonKey(defaultValue: '')
  final String description;

  /// Logo institusi (boleh kosong / null di Django).
  @JsonKey(defaultValue: '')
  final String logoUrl;

  // Field di bawah dihitung oleh server (read-only), jadi tidak dikirim saat POST.
  @JsonKey(includeToJson: false, defaultValue: 0)
  final int starCount;

  @JsonKey(includeToJson: false, defaultValue: false)
  final bool isStarred;

  Map<String, dynamic> toJson() => _$EducationToJson(this);

  /// Rentang tahun singkat, misalnya "2025 - Sekarang".
  String get period => '$startYear - $endYear';

  /// Judul singkat untuk daftar, misalnya "S1 - Universitas Indonesia".
  String get title => '$level - $institutionName';
}
