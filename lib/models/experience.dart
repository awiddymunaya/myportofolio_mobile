import 'package:json_annotation/json_annotation.dart';

part 'experience.g.dart';

/// Satu Experience portofolio, sama dengan ExperienceSerializer di Django
/// (Tutorial 07, endpoint /api/v1/experiences/).
///
/// Di proyekku, peran "Project" pada soal tutorial dipegang oleh Experience.
@JsonSerializable(fieldRename: FieldRename.snake)
class Experience {
  const Experience({
    required this.title,
    required this.description,
    this.category = 'full-time',
    this.thumbnail = '',
    this.logoUrl = '',
    this.startedAt,
    this.endedAt,
    this.id,
    this.categoryDisplay = '',
    this.isOngoing = false,
    this.starCount = 0,
  });

  factory Experience.fromJson(Map<String, dynamic> json) =>
      _$ExperienceFromJson(json);

  /// UUID dibuat oleh Django, jadi tidak ikut dikirim saat POST.
  @JsonKey(includeToJson: false)
  final String? id;

  final String title;
  final String description;

  /// Nilai pilihan EXPERIENCE_CHOICES, misalnya `part-time`.
  @JsonKey(defaultValue: 'full-time')
  final String category;

  /// Foto bukti kegiatan (boleh kosong / null di Django).
  @JsonKey(defaultValue: '')
  final String thumbnail;

  /// Lambang organisasi (boleh kosong / null di Django).
  @JsonKey(defaultValue: '')
  final String logoUrl;

  /// Tanggal mulai, format `YYYY-MM-DD`.
  final String? startedAt;

  /// Tanggal selesai. Django mengirim datetime ISO 8601 dan menerima
  /// `YYYY-MM-DD`. `null` berarti masih berlangsung.
  final String? endedAt;

  // Field di bawah dihitung oleh server (read-only), jadi tidak dikirim saat POST.
  @JsonKey(includeToJson: false, defaultValue: '')
  final String categoryDisplay;

  @JsonKey(includeToJson: false, defaultValue: false)
  final bool isOngoing;

  @JsonKey(includeToJson: false, defaultValue: 0)
  final int starCount;

  Map<String, dynamic> toJson() => _$ExperienceToJson(this);

  /// Label kategori untuk ditampilkan, misalnya "Part-Time".
  String get categoryLabel =>
      categoryDisplay.isNotEmpty ? categoryDisplay : category;

  /// Rentang waktu singkat, misalnya "2025-01-10 - Sekarang".
  /// Data lama yang belum punya tanggal mulai ditampilkan tanpa "?".
  String get period {
    final end = endedAt == null ? 'Sekarang' : _dateOnly(endedAt!);
    if (startedAt == null) {
      return endedAt == null ? 'Tanggal belum diisi' : 'Sampai $end';
    }
    return '${_dateOnly(startedAt!)} - $end';
  }

  static String _dateOnly(String value) =>
      value.length >= 10 ? value.substring(0, 10) : value;
}
