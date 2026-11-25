import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/models/education.dart';
import 'package:myportofolio_mobile/services/api_client.dart';
import 'package:myportofolio_mobile/widgets/network_image_box.dart';
import 'package:provider/provider.dart';

/// Detail satu riwayat pendidikan yang dipilih dari daftar.
/// Semua field dari EducationSerializer ditampilkan.
class EducationDetailScreen extends StatelessWidget {
  const EducationDetailScreen({required this.education, super.key});

  final Education education;

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
