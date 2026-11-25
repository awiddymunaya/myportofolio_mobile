import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/models/education.dart';
import 'package:myportofolio_mobile/screens/education_detail_screen.dart';
import 'package:myportofolio_mobile/screens/education_form.dart';
import 'package:myportofolio_mobile/services/api_client.dart';
import 'package:myportofolio_mobile/widgets/auth_guard.dart';
import 'package:myportofolio_mobile/widgets/left_drawer.dart';
import 'package:provider/provider.dart';

/// Daftar riwayat pendidikan dari GET /api/v1/education/.
/// Bisa dibuka tanpa login.
class EducationListScreen extends StatefulWidget {
  const EducationListScreen({super.key});

  @override
  State<EducationListScreen> createState() => _EducationListScreenState();
}

class _EducationListScreenState extends State<EducationListScreen> {
  late Future<List<Education>> _educationsFuture;

  @override
  void initState() {
    super.initState();
    // Future dibuat sekali di initState (bukan di build), supaya request
    // HTTP tidak dikirim ulang setiap kali widget di-build ulang.
    _educationsFuture = context.read<ApiClient>().getEducations();
  }

  Future<void> _reload() async {
    final future = context.read<ApiClient>().getEducations();
    setState(() {
      _educationsFuture = future;
    });
    try {
      await future;
    } on Exception {
      // Error ditampilkan oleh FutureBuilder, di sini cukup menunggu selesai.
    }
  }

  Future<void> _openDetail(Education education) async {
    // Detail mengembalikan true jika entri dihapus, jadi daftar dimuat ulang.
    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => EducationDetailScreen(education: education),
      ),
    );
    if (changed == true && mounted) await _reload();
  }

  /// Tombol +: login dulu jika perlu, lalu buka form. Jika ada entri baru,
  /// daftar langsung dimuat ulang.
  Future<void> _openForm() async {
    final loggedIn = await ensureLoggedIn(context);
    if (!loggedIn || !mounted) return;
    final created = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => const EducationFormPage(openedFromList: true),
      ),
    );
    if (created == true && mounted) await _reload();
  }

  Widget _scrollableMessage(Widget child) {
    // Tetap bisa ditarik untuk refresh walaupun isinya hanya pesan.
    return RefreshIndicator(
      onRefresh: _reload,
      child: LayoutBuilder(
        builder: (context, constraints) => SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: SizedBox(
            height: constraints.maxHeight,
            child: Center(child: child),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Education'),
        backgroundColor: primary,
        foregroundColor: Colors.white,
      ),
      drawer: const LeftDrawer(),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Tambah Education',
        backgroundColor: Theme.of(context).colorScheme.secondary,
        onPressed: _openForm,
        child: const Icon(Icons.add),
      ),
      body: FutureBuilder<List<Education>>(
        future: _educationsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return _scrollableMessage(
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.cloud_off, size: 48, color: Colors.grey),
                    const SizedBox(height: 8),
                    Text(
                      'Failed to load education: ${snapshot.error}',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: _reload,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          final educations = snapshot.data ?? const <Education>[];
          if (educations.isEmpty) {
            return _scrollableMessage(const Text('No education found.'));
          }

          return RefreshIndicator(
            onRefresh: _reload,
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(8),
              itemCount: educations.length,
              itemBuilder: (context, index) {
                final education = educations[index];
                return Card(
                  child: ListTile(
                    leading: Icon(Icons.school, color: primary),
                    title: Text(
                      education.institutionName,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      '${education.level} | ${education.period}',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => _openDetail(education),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
