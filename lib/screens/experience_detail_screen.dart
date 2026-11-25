import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/models/experience.dart';
import 'package:myportofolio_mobile/services/api_client.dart';
import 'package:provider/provider.dart';

/// Detail satu Experience yang dipilih dari daftar.
class ExperienceDetailScreen extends StatelessWidget {
  const ExperienceDetailScreen({required this.experience, super.key});

  final Experience experience;

  @override
  Widget build(BuildContext context) {
    final apiClient = context.read<ApiClient>();
    final primary = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: Text(experience.title),
        backgroundColor: primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Gambar hanya ditampilkan jika datanya tidak kosong.
            if (experience.thumbnail.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: _NetworkImage(
                  key: const Key('experience-thumbnail'),
                  url: apiClient.resolveImageUrl(experience.thumbnail),
                  height: 200,
                ),
              ),
            if (experience.thumbnail.isNotEmpty) const SizedBox(height: 16),
            Row(
              children: [
                if (experience.logoUrl.isNotEmpty) ...[
                  _NetworkImage(
                    key: const Key('experience-logo'),
                    url: apiClient.resolveImageUrl(experience.logoUrl),
                    height: 48,
                    width: 48,
                  ),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: Text(
                    experience.title,
                    style: Theme.of(context).textTheme.headlineSmall
                        ?.copyWith(fontWeight: FontWeight.bold, color: primary),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                Chip(
                  avatar: const Icon(Icons.category, size: 18),
                  label: Text(experience.categoryLabel),
                ),
                Chip(
                  avatar: const Icon(Icons.date_range, size: 18),
                  label: Text(experience.period),
                ),
                Chip(
                  avatar: const Icon(Icons.star, size: 18),
                  label: Text('${experience.starCount} star'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Deskripsi',
              style: Theme.of(context).textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(experience.description),
          ],
        ),
      ),
    );
  }
}

/// Image.network dengan tampilan cadangan kalau gambar gagal dimuat.
class _NetworkImage extends StatelessWidget {
  const _NetworkImage({
    required this.url,
    required this.height,
    this.width,
    super.key,
  });

  final String url;
  final double height;
  final double? width;

  @override
  Widget build(BuildContext context) {
    return Image.network(
      url,
      height: height,
      width: width ?? double.infinity,
      fit: BoxFit.cover,
      // Di web, pakai elemen <img> biasa jika gambar diblokir CORS.
      webHtmlElementStrategy: WebHtmlElementStrategy.fallback,
      errorBuilder: (context, error, stackTrace) => Container(
        height: height,
        width: width ?? double.infinity,
        color: Colors.grey.shade300,
        child: const Icon(Icons.broken_image, color: Colors.grey),
      ),
    );
  }
}
