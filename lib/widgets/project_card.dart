import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/screens/education_form.dart';
import 'package:myportofolio_mobile/screens/education_list_screen.dart';
import 'package:myportofolio_mobile/screens/experience_form.dart';
import 'package:myportofolio_mobile/screens/experience_list_screen.dart';
import 'package:myportofolio_mobile/screens/menu.dart';
import 'package:myportofolio_mobile/services/auth_state.dart';
import 'package:myportofolio_mobile/widgets/auth_guard.dart';
import 'package:provider/provider.dart';

class ItemCard extends StatelessWidget {
  // Kartu tombol aksi yang menampilkan ikon dan nama item.
  final ItemHomepage item;

  const ItemCard(this.item, {super.key});

  /// Menampilkan SnackBar yang warnanya sama dengan tombol yang ditekan.
  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: item.color,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
  }

  Future<void> _onTap(BuildContext context) async {
    switch (item.name) {
      case "Lihat Experience":
        _showSnackBar(context, "Kamu telah menekan tombol ${item.name}!");
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ExperienceListScreen()),
        );
      case "Tambah Experience":
        _showSnackBar(context, "Kamu telah menekan tombol ${item.name}!");
        // Belum login: buka halaman login dulu. Form dibuka hanya jika berhasil.
        final loggedIn = await ensureLoggedIn(context);
        if (!loggedIn || !context.mounted) return;
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ExperienceFormPage()),
        );
      case "Lihat Education":
        _showSnackBar(context, "Kamu telah menekan tombol ${item.name}!");
        // Daftar Education publik, tidak perlu login.
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const EducationListScreen()),
        );
      case "Tambah Education":
        _showSnackBar(context, "Kamu telah menekan tombol ${item.name}!");
        final loggedIn = await ensureLoggedIn(context);
        if (!loggedIn || !context.mounted) return;
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const EducationFormPage()),
        );
      case "Logout":
        final auth = context.read<AuthState>();
        if (!auth.isLoggedIn) {
          _showSnackBar(context, "Kamu belum login.");
          return;
        }
        await auth.logout();
        if (!context.mounted) return;
        _showSnackBar(context, "Kamu sudah logout.");
      default:
        _showSnackBar(context, "Kamu telah menekan tombol ${item.name}!");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      // Warna latar diambil dari data item, jadi setiap tombol berbeda.
      color: item.color,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        // Aksi ketika kartu ditekan oleh pengguna.
        onTap: () => _onTap(context),
        child: Container(
          padding: const EdgeInsets.all(8),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(item.icon, color: Colors.white, size: 30.0),
                const Padding(padding: EdgeInsets.all(3)),
                Text(
                  item.name,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
