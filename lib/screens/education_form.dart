import 'package:http/http.dart' as http;
import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/models/education.dart';
import 'package:myportofolio_mobile/screens/education_list_screen.dart';
import 'package:myportofolio_mobile/services/api_client.dart';
import 'package:myportofolio_mobile/services/auth_state.dart';
import 'package:myportofolio_mobile/widgets/auth_guard.dart';
import 'package:myportofolio_mobile/widgets/left_drawer.dart';
import 'package:provider/provider.dart';

/// Form untuk menambah riwayat pendidikan. Field-nya mengikuti
/// EducationSerializer di Django, dan data dikirim lewat
/// POST /api/v1/education/ dengan token login.
class EducationFormPage extends StatefulWidget {
  const EducationFormPage({this.openedFromList = false, super.key});

  /// true jika form dibuka dari tombol + di EducationListScreen. Setelah
  /// berhasil, form cukup di-pop dan daftar di bawahnya memuat ulang data.
  final bool openedFromList;

  @override
  State<EducationFormPage> createState() => _EducationFormPageState();
}

class _EducationFormPageState extends State<EducationFormPage> {
  final _formKey = GlobalKey<FormState>();

  // Jenjang yang sering dipakai, untuk chip isian cepat. Tetap bisa diketik
  // bebas karena di Django level adalah CharField biasa (maks. 50).
  static const List<String> levelSuggestions = ['SMA', 'D3', 'S1', 'S2'];

  /// Teks yang disimpan di end_year saat masih menempuh pendidikan,
  /// sama dengan petunjuk di form web Django.
  static const String ongoingLabel = 'Sekarang';

  final _levelController = TextEditingController();
  String _institutionName = "";
  String _startYear = "";
  String _endYear = "";
  bool _isOngoing = false;
  String _description = "";
  String _logoUrl = "";

  // Dinaikkan setiap form dikosongkan, supaya semua field dibuat ulang.
  int _formVersion = 0;

  // true selama request POST berjalan, supaya tombol Save tidak ditekan dua kali.
  bool _isSubmitting = false;

  @override
  void dispose() {
    _levelController.dispose();
    super.dispose();
  }

  void _resetForm() {
    setState(() {
      _levelController.clear();
      _institutionName = "";
      _startYear = "";
      _endYear = "";
      _isOngoing = false;
      _description = "";
      _logoUrl = "";
      _formVersion++;
    });
  }

  InputDecoration _decoration(String label, {String? hint}) {
    return InputDecoration(
      hintText: hint ?? label,
      labelText: label,
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

  /// Teks wajib dengan batas panjang yang sama dengan max_length di Django.
  String? _validateRequired(String? value, String label, int maxLength) {
    final text = value?.trim() ?? "";
    if (text.isEmpty) return "$label tidak boleh kosong!";
    if (text.length > maxLength) return "$label maksimal $maxLength karakter!";
    return null;
  }

  /// Tahun masuk: angka 1900 sampai 2100, sama dengan validate_start_year.
  String? _validateStartYear(String? value) {
    final text = value?.trim() ?? "";
    if (text.isEmpty) return "Tahun masuk tidak boleh kosong!";
    final year = int.tryParse(text);
    if (year == null) return "Tahun masuk harus berupa angka!";
    if (year < 1900 || year > 2100) {
      return "Tahun masuk harus di antara 1900 dan 2100!";
    }
    return null;
  }

  /// Tahun lulus: angka yang tidak sebelum tahun masuk.
  String? _validateEndYear(String? value) {
    if (_isOngoing) return null;
    final text = value?.trim() ?? "";
    if (text.isEmpty) {
      return "Isi tahun lulus atau aktifkan 'Masih menempuh pendidikan'!";
    }
    final year = int.tryParse(text);
    if (year == null) return "Tahun lulus harus berupa angka!";
    if (year < 1900 || year > 2100) {
      return "Tahun lulus harus di antara 1900 dan 2100!";
    }
    final start = int.tryParse(_startYear.trim());
    if (start != null && year < start) {
      return "Tahun lulus tidak boleh sebelum tahun masuk!";
    }
    return null;
  }

  /// Logo opsional: boleh kosong, path lokal (/static/...), atau URL http(s).
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
      return "Isi dengan URL http(s) atau path seperti /static/img/logo.png";
    }
    return null;
  }

  /// Validasi form, pastikan sudah login, lalu kirim POST ke Django.
  Future<void> _submit({bool isRetry = false}) async {
    if (!_formKey.currentState!.validate()) return;

    final loggedIn = await ensureLoggedIn(context);
    if (!loggedIn || !mounted) return;

    final auth = context.read<AuthState>();
    final apiClient = context.read<ApiClient>();
    final token = auth.token!;

    final newEducation = Education(
      level: _levelController.text.trim(),
      institutionName: _institutionName.trim(),
      startYear: int.parse(_startYear.trim()),
      endYear: _isOngoing ? ongoingLabel : _endYear.trim(),
      description: _description.trim(),
      logoUrl: _logoUrl,
    );

    setState(() {
      _isSubmitting = true;
    });

    try {
      final created = await apiClient.createEducation(
        newEducation,
        token: token,
      );
      if (!mounted) return;
      _showSummary(created);
    } on ApiException catch (error) {
      if (!mounted) return;
      if (error.statusCode == 401 && !isRetry) {
        // Token sudah tidak berlaku (misalnya dihapus lewat Django Admin):
        // hapus sesi, minta login ulang, lalu kirim ulang sekali.
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
          'Akunmu tidak boleh menambah Education (hanya Pemilik/superuser).',
        );
      } else if (error.statusCode == 400) {
        _showSnackBar(error.validationMessage);
      } else {
        _showSnackBar('Gagal menyimpan Education (${error.statusCode}).');
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

  /// Membuka daftar Education supaya entri baru langsung terlihat.
  void _goToList() {
    if (widget.openedFromList) {
      // Daftar ada tepat di bawah form dan akan memuat ulang datanya.
      Navigator.pop(context, true);
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const EducationListScreen()),
      );
    }
  }

  /// Pop-up konfirmasi berisi data yang dikembalikan Django (201 Created).
  void _showSummary(Education created) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Education berhasil ditambahkan!'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Jenjang: ${created.level}'),
                Text('Institusi: ${created.institutionName}'),
                Text('Periode: ${created.period}'),
                Text(
                  'Catatan: ${created.description.isEmpty ? "-" : created.description}',
                ),
                Text(
                  'Logo: ${created.logoUrl.isEmpty ? "-" : created.logoUrl}',
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text('Tambah Lagi'),
              onPressed: () {
                Navigator.pop(dialogContext);
                _resetForm();
              },
            ),
            FilledButton(
              child: const Text('Lihat Daftar'),
              onPressed: () {
                Navigator.pop(dialogContext);
                _goToList();
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
        title: const Center(child: Text('Add Education Form')),
        backgroundColor: primary,
        foregroundColor: Colors.white,
      ),
      drawer: const LeftDrawer(),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            // Key berganti saat reset, jadi semua field kembali kosong.
            key: ValueKey(_formVersion),
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // === Level ===
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  controller: _levelController,
                  decoration: _decoration(
                    "Jenjang Pendidikan",
                    hint: "Contoh: S1, SMA, SMP",
                  ),
                  validator: (value) =>
                      _validateRequired(value, "Jenjang pendidikan", 50),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Wrap(
                  spacing: 8,
                  children: levelSuggestions
                      .map(
                        (level) => ActionChip(
                          label: Text(level),
                          onPressed: () {
                            setState(() {
                              _levelController.text = level;
                            });
                          },
                        ),
                      )
                      .toList(),
                ),
              ),

              // === Institution name ===
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  decoration: _decoration(
                    "Nama Institusi",
                    hint: "Contoh: Universitas Indonesia",
                  ),
                  onChanged: (String value) {
                    setState(() {
                      _institutionName = value;
                    });
                  },
                  validator: (value) =>
                      _validateRequired(value, "Nama institusi", 255),
                ),
              ),

              // === Start year ===
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  keyboardType: TextInputType.number,
                  decoration: _decoration("Tahun Masuk", hint: "Contoh: 2025"),
                  onChanged: (String value) {
                    setState(() {
                      _startYear = value;
                    });
                  },
                  validator: _validateStartYear,
                ),
              ),

              // === Ongoing switch ===
              SwitchListTile(
                title: const Text('Masih menempuh pendidikan'),
                subtitle: const Text('Tahun lulus diisi "Sekarang"'),
                value: _isOngoing,
                activeThumbColor: primary,
                onChanged: (bool value) {
                  setState(() {
                    _isOngoing = value;
                  });
                },
              ),

              // === End year ===
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  // Field dibuat ulang saat switch berubah, supaya isinya ikut.
                  key: ValueKey('end-year-$_isOngoing'),
                  initialValue: _isOngoing ? ongoingLabel : _endYear,
                  enabled: !_isOngoing,
                  keyboardType: TextInputType.number,
                  decoration: _decoration("Tahun Lulus", hint: "Contoh: 2029"),
                  onChanged: (String value) {
                    setState(() {
                      _endYear = value;
                    });
                  },
                  validator: _validateEndYear,
                ),
              ),

              // === Description ===
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  maxLines: 3,
                  decoration: _decoration(
                    "Catatan (opsional)",
                    hint: "Jurusan, prestasi, atau organisasi",
                  ),
                  onChanged: (String value) {
                    setState(() {
                      _description = value;
                    });
                  },
                ),
              ),

              // === Logo URL ===
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  keyboardType: TextInputType.url,
                  decoration: _decoration(
                    "Logo Institusi (opsional)",
                    hint: "/static/img/logo-ui.png atau https://...",
                  ),
                  onChanged: (String value) {
                    setState(() {
                      _logoUrl = value.trim();
                    });
                  },
                  validator: _validateImagePath,
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
