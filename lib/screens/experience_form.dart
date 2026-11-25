import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/models/experience.dart';
import 'package:myportofolio_mobile/services/api_client.dart';
import 'package:myportofolio_mobile/services/auth_state.dart';
import 'package:myportofolio_mobile/widgets/auth_guard.dart';
import 'package:myportofolio_mobile/widgets/left_drawer.dart';
import 'package:provider/provider.dart';

/// Form untuk menambah Experience. Field-nya mengikuti ExperienceSerializer
/// di proyek Django myportofolio, dan data dikirim lewat
/// POST /api/v1/experiences/ dengan token login.
class ExperienceFormPage extends StatefulWidget {
  const ExperienceFormPage({super.key});

  @override
  State<ExperienceFormPage> createState() => _ExperienceFormPageState();
}

class _ExperienceFormPageState extends State<ExperienceFormPage> {
  // Kunci untuk mengakses state Form: validasi isian.
  final _formKey = GlobalKey<FormState>();

  // Pilihan kategori sama dengan EXPERIENCE_CHOICES di model Django:
  // kunci = nilai yang disimpan, nilai = label yang ditampilkan.
  static const Map<String, String> categories = {
    'internship': 'Internship',
    'research': 'Research',
    'volunteer': 'Volunteer',
    'part-time': 'Part-Time',
    'full-time': 'Full-Time',
    'freelance': 'Freelance',
  };

  // Variabel penampung isi setiap field.
  String _title = "";
  String _description = "";
  String _category = "full-time"; // default sama dengan model Django
  String _thumbnail = "";
  String _logoUrl = "";
  DateTime? _startedAt;
  DateTime? _endedAt;
  bool _isOngoing = false;

  // Controller untuk field tanggal, karena isinya diisi lewat date picker.
  final _startedAtController = TextEditingController();
  final _endedAtController = TextEditingController();

  // Dinaikkan setiap form dikosongkan, supaya semua field dibuat ulang.
  int _formVersion = 0;

  // true selama request POST berjalan, supaya tombol Save tidak ditekan dua kali.
  bool _isSubmitting = false;

  @override
  void dispose() {
    _startedAtController.dispose();
    _endedAtController.dispose();
    super.dispose();
  }

  /// Format tanggal sederhana YYYY-MM-DD, sama seperti DateField Django.
  String _formatDate(DateTime? date) {
    if (date == null) return "-";
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return "${date.year}-$month-$day";
  }

  /// Validasi URL/path opsional: boleh kosong, path lokal (/static/...),
  /// atau URL http(s).
  String? _validateImagePath(String? value) {
    final text = value?.trim() ?? "";
    if (text.isEmpty) return null;
    if (text.length > 500) return "Maksimal 500 karakter!";
    if (text.startsWith('/')) return null;
    final uri = Uri.tryParse(text);
    final isWebUrl =
        uri != null &&
        (uri.scheme == 'http' || uri.scheme == 'https') &&
        uri.host.isNotEmpty;
    if (!isWebUrl) {
      return "Isi dengan URL http(s) atau path seperti /static/img/foto.jpg";
    }
    return null;
  }

  /// Membuka date picker lalu menyimpan tanggal yang dipilih.
  Future<void> _pickDate({required bool isStart}) async {
    final initial =
        (isStart ? _startedAt : _endedAt) ?? _startedAt ?? DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1990),
      lastDate: DateTime(2100),
    );
    if (picked == null) return;
    setState(() {
      if (isStart) {
        _startedAt = picked;
        _startedAtController.text = _formatDate(picked);
      } else {
        _endedAt = picked;
        _endedAtController.text = _formatDate(picked);
      }
    });
  }

  /// Mengosongkan semua isian setelah data berhasil disimpan.
  void _resetForm() {
    setState(() {
      _title = "";
      _description = "";
      _category = "full-time";
      _thumbnail = "";
      _logoUrl = "";
      _startedAt = null;
      _endedAt = null;
      _isOngoing = false;
      _startedAtController.clear();
      _endedAtController.clear();
      _formVersion++;
    });
  }

  InputDecoration _decoration(String label, {String? hint, Widget? suffix}) {
    return InputDecoration(
      hintText: hint ?? label,
      labelText: label,
      suffixIcon: suffix,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(5.0)),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red.shade700),
      );
  }

  /// Mengambil pesan error validasi dari body 400 DRF,
  /// misalnya {"title": ["Nama posisi tidak boleh kosong."]}.
  String _validationMessage(String body) {
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic>) {
        return decoded.entries
            .map((entry) {
              final value = entry.value;
              final text = value is List ? value.join(' ') : '$value';
              return '${entry.key}: $text';
            })
            .join('\n');
      }
    } on FormatException {
      // Body bukan JSON, pakai pesan umum di bawah.
    }
    return 'Data tidak valid.';
  }

  /// Validasi form, pastikan sudah login, lalu kirim POST ke Django.
  Future<void> _submit({bool isRetry = false}) async {
    // validate() menjalankan semua validator di dalam Form.
    if (!_formKey.currentState!.validate()) return;

    final loggedIn = await ensureLoggedIn(context);
    if (!loggedIn || !mounted) return;

    final auth = context.read<AuthState>();
    final apiClient = context.read<ApiClient>();
    final token = auth.token!;

    final newExperience = Experience(
      title: _title.trim(),
      description: _description.trim(),
      category: _category,
      thumbnail: _thumbnail,
      logoUrl: _logoUrl,
      startedAt: _formatDate(_startedAt),
      // null = masih berlangsung
      endedAt: _isOngoing ? null : _formatDate(_endedAt),
    );

    setState(() {
      _isSubmitting = true;
    });

    try {
      final created = await apiClient.createExperience(
        newExperience,
        token: token,
      );
      if (!mounted) return;
      _showSummary(created);
    } on ApiException catch (error) {
      if (!mounted) return;
      if (error.statusCode == 401 && !isRetry) {
        // Token sudah tidak berlaku: logout, minta login ulang, lalu coba lagi.
        await auth.logout();
        if (!mounted) return;
        _showSnackBar('Sesi login berakhir, silakan login ulang.');
        setState(() {
          _isSubmitting = false;
        });
        await _submit(isRetry: true);
        return;
      }
      if (error.statusCode == 403) {
        _showSnackBar(
          'Akunmu tidak boleh menambah Experience (hanya Pemilik/superuser).',
        );
      } else if (error.statusCode == 400) {
        _showSnackBar(_validationMessage(error.message));
      } else {
        _showSnackBar('Gagal menyimpan Experience (${error.statusCode}).');
      }
    } on http.ClientException {
      if (!mounted) return;
      _showSnackBar(
        'Tidak bisa terhubung ke server. Apakah Django sudah jalan?',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  /// Pop-up konfirmasi berisi data yang dikembalikan Django (201 Created).
  void _showSummary(Experience created) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Experience berhasil ditambahkan!'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Judul: ${created.title}'),
                Text('Deskripsi: ${created.description}'),
                Text('Kategori: ${created.categoryLabel}'),
                Text(
                  'Thumbnail: ${created.thumbnail.isEmpty ? "-" : created.thumbnail}',
                ),
                Text(
                  'Logo: ${created.logoUrl.isEmpty ? "-" : created.logoUrl}',
                ),
                Text('Periode: ${created.period}'),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.pop(context);
                _resetForm();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: const Center(child: Text('Add Experience Form')),
        backgroundColor: primary,
        foregroundColor: Colors.white,
      ),
      drawer: const LeftDrawer(),
      body: Form(
        key: _formKey,
        // SingleChildScrollView agar form tetap bisa digulir di layar kecil.
        child: SingleChildScrollView(
          child: Column(
            // Key berganti saat reset, jadi semua field kembali kosong.
            key: ValueKey(_formVersion),
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // === Title ===
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  decoration: _decoration(
                    "Judul Experience",
                    hint: "Contoh: Software Engineer Intern di Compfest",
                  ),
                  onChanged: (String value) {
                    setState(() {
                      _title = value;
                    });
                  },
                  validator: (String? value) {
                    final text = value?.trim() ?? "";
                    if (text.isEmpty) {
                      return "Judul experience tidak boleh kosong!";
                    }
                    if (text.length > 255) {
                      return "Judul maksimal 255 karakter!";
                    }
                    return null;
                  },
                ),
              ),

              // === Description ===
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  maxLines: 5,
                  decoration: _decoration(
                    "Deskripsi",
                    hint: "Ceritakan peran dan pencapaianmu",
                  ),
                  onChanged: (String value) {
                    setState(() {
                      _description = value;
                    });
                  },
                  validator: (String? value) {
                    final text = value?.trim() ?? "";
                    if (text.isEmpty) {
                      return "Deskripsi tidak boleh kosong!";
                    }
                    if (text.length < 10) {
                      return "Deskripsi minimal 10 karakter!";
                    }
                    return null;
                  },
                ),
              ),

              // === Category ===
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: DropdownButtonFormField<String>(
                  decoration: _decoration("Kategori"),
                  initialValue: _category,
                  items: categories.entries
                      .map(
                        (entry) => DropdownMenuItem(
                          value: entry.key,
                          child: Text(entry.value),
                        ),
                      )
                      .toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _category = newValue!;
                    });
                  },
                ),
              ),

              // === Thumbnail ===
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  keyboardType: TextInputType.url,
                  decoration: _decoration(
                    "Thumbnail (opsional)",
                    hint: "/static/img/Compfest.jpg atau https://...",
                  ),
                  onChanged: (String value) {
                    setState(() {
                      _thumbnail = value.trim();
                    });
                  },
                  validator: _validateImagePath,
                ),
              ),

              // === Logo URL ===
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  keyboardType: TextInputType.url,
                  decoration: _decoration(
                    "Logo Organisasi (opsional)",
                    hint: "URL atau path logo organisasi",
                  ),
                  onChanged: (String value) {
                    setState(() {
                      _logoUrl = value.trim();
                    });
                  },
                  validator: _validateImagePath,
                ),
              ),

              // === Started At ===
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  controller: _startedAtController,
                  readOnly: true,
                  decoration: _decoration(
                    "Tanggal Mulai",
                    hint: "Pilih tanggal mulai",
                    suffix: const Icon(Icons.calendar_today),
                  ),
                  onTap: () => _pickDate(isStart: true),
                  validator: (_) {
                    if (_startedAt == null) {
                      return "Tanggal mulai harus dipilih!";
                    }
                    return null;
                  },
                ),
              ),

              // === Ongoing switch ===
              SwitchListTile(
                title: const Text('Masih berlangsung'),
                subtitle: const Text('Aktifkan jika kegiatan belum selesai'),
                value: _isOngoing,
                activeThumbColor: primary,
                onChanged: (bool value) {
                  setState(() {
                    _isOngoing = value;
                    if (value) {
                      _endedAt = null;
                      _endedAtController.clear();
                    }
                  });
                },
              ),

              // === Ended At ===
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  controller: _endedAtController,
                  readOnly: true,
                  enabled: !_isOngoing,
                  decoration: _decoration(
                    "Tanggal Selesai",
                    hint: _isOngoing
                        ? "Masih berlangsung"
                        : "Pilih tanggal selesai",
                    suffix: const Icon(Icons.event),
                  ),
                  onTap: () => _pickDate(isStart: false),
                  validator: (_) {
                    if (_isOngoing) return null;
                    if (_endedAt == null) {
                      return "Pilih tanggal selesai atau aktifkan 'Masih berlangsung'!";
                    }
                    if (_startedAt != null && _endedAt!.isBefore(_startedAt!)) {
                      return "Tanggal selesai tidak boleh sebelum tanggal mulai!";
                    }
                    return null;
                  },
                ),
              ),

              // === Tombol Simpan ===
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: WidgetStateProperty.all(primary),
                    ),
                    onPressed: _isSubmitting ? null : () => _submit(),
                    child: _isSubmitting
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            "Save",
                            style: TextStyle(color: Colors.white),
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
