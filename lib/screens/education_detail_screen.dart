import 'package:http/http.dart' as http;
import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/models/education.dart';
import 'package:myportofolio_mobile/services/api_client.dart';
import 'package:myportofolio_mobile/services/auth_state.dart';
import 'package:myportofolio_mobile/widgets/auth_guard.dart';
import 'package:myportofolio_mobile/widgets/network_image_box.dart';
import 'package:provider/provider.dart';

/// Detail satu riwayat pendidikan yang dipilih dari daftar.
/// Semua field dari EducationSerializer ditampilkan. Pemilik yang sudah
/// login bisa menghapus entri ini (DELETE dengan token).
class EducationDetailScreen extends StatefulWidget {
  const EducationDetailScreen({required this.education, super.key});

  final Education education;

  @override
  State<EducationDetailScreen> createState() => _EducationDetailScreenState();
}

class _EducationDetailScreenState extends State<EducationDetailScreen> {
  bool _isDeleting = false;

  Education get education => widget.education;

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red.shade700),
      );
  }

  Future<bool> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Hapus Education?'),
        content: Text(
          '${education.title} akan dihapus dari portofolio. '
          'Tindakan ini tidak bisa dibatalkan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red.shade700),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    return confirmed ?? false;
  }

  /// Login jika perlu, minta konfirmasi, lalu kirim DELETE dengan token.
  /// Jika berhasil, layar ditutup dengan hasil true agar daftar dimuat ulang.
  Future<void> _delete() async {
    final loggedIn = await ensureLoggedIn(context);
    if (!loggedIn || !mounted) return;
    if (!await _confirmDelete() || !mounted) return;

    final auth = context.read<AuthState>();
    final apiClient = context.read<ApiClient>();
    setState(() {
      _isDeleting = true;
    });

    try {
      await apiClient.deleteEducation(education.id!, token: auth.token!);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${education.title} sudah dihapus.')),
      );
      Navigator.pop(context, true);
    } on ApiException catch (error) {
      if (!mounted) return;
      if (error.statusCode == 401) {
        // Token tidak berlaku lagi: hapus sesi, pengguna diminta login ulang.
        await auth.logout();
        if (!mounted) return;
        _showSnackBar(
          'Sesi login berakhir, silakan login ulang lalu coba lagi.',
        );
      } else if (error.statusCode == 403) {
        _showSnackBar(
          'Akunmu tidak boleh menghapus Education (hanya Pemilik/superuser).',
        );
      } else {
        _showSnackBar('Gagal menghapus Education (${error.statusCode}).');
      }
    } on http.ClientException {
      if (!mounted) return;
      _showSnackBar(
        'Tidak bisa terhubung ke server. Apakah Django sudah jalan?',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isDeleting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final apiClient = context.read<ApiClient>();
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: Text(education.institutionName),
        backgroundColor: primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            tooltip: 'Hapus Education',
            onPressed: _isDeleting || education.id == null ? null : _delete,
            icon: _isDeleting
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.delete_outline),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Logo hanya ditampilkan jika datanya tidak kosong.
                if (education.logoUrl.isNotEmpty) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: NetworkImageBox(
                      key: const Key('education-logo'),
                      url: apiClient.resolveImageUrl(education.logoUrl),
                      height: 64,
                      width: 64,
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: Text(
                    education.institutionName,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: primary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Card(
              child: Column(
                children: [
                  _InfoRow(
                    icon: Icons.school,
                    label: 'Jenjang',
                    value: education.level,
                  ),
                  _InfoRow(
                    icon: Icons.login,
                    label: 'Tahun Masuk',
                    value: '${education.startYear}',
                  ),
                  _InfoRow(
                    icon: Icons.flag,
                    label: 'Tahun Lulus',
                    value: education.endYear,
                  ),
                  _InfoRow(
                    icon: Icons.star,
                    label: 'Star',
                    value: education.isStarred
                        ? '${education.starCount} (termasuk kamu)'
                        : '${education.starCount}',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Catatan',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              education.description.isEmpty
                  ? 'Tidak ada catatan.'
                  : education.description,
            ),
          ],
        ),
      ),
    );
  }
}

/// Satu baris label + nilai di kartu detail.
class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
      title: Text(label),
      trailing: Text(
        value,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }
}
