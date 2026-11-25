import 'package:material_ui/material_ui.dart';

/// Image.network dengan tampilan cadangan kalau gambar gagal dimuat.
/// Dipakai di layar detail Experience dan Education.
class NetworkImageBox extends StatelessWidget {
  const NetworkImageBox({
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
