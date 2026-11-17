import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/widgets/left_drawer.dart';
import 'package:myportofolio_mobile/widgets/project_card.dart';

class MyHomePage extends StatelessWidget {
  MyHomePage({super.key});

  final String npm = "2506622872";
  final String nama = "Awiddy Munaya Rajanadoli";
  final String kelas = "PBP D";

  // Tiap tombol membawa warnanya sendiri, jadi ItemCard tidak perlu if-else.
  final List<ItemHomepage> items = [
    ItemHomepage("Lihat Experience", Icons.work, Colors.blue.shade700),
    ItemHomepage("Tambah Experience", Icons.add_circle, Colors.green.shade700),
    ItemHomepage("Tambah Proyek", Icons.add_box, Colors.purple.shade700),
    ItemHomepage("Logout", Icons.logout, Colors.red.shade700),
  ];

  @override
  Widget build(BuildContext context) {
    // Scaffold menyediakan struktur visual dasar halaman (AppBar, Body, SnackBar).
    return Scaffold(
      // AppBar menampilkan bar bagian atas halaman aplikasi.
      appBar: AppBar(
        title: const Text(
          'MyPortfolio',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        // Ikon hamburger drawer ikut berwarna putih.
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      // Drawer menu untuk berpindah antarhalaman.
      drawer: const LeftDrawer(),
      // Body dibungkus SingleChildScrollView supaya bisa digulir
      // ketika tombolnya tidak muat dalam satu layar.
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Baris horizontal untuk menampilkan 3 InfoCard secara sejajar.
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  InfoCard(title: 'NPM', content: npm),
                  InfoCard(title: 'Name', content: nama),
                  InfoCard(title: 'Class', content: kelas),
                ],
              ),

              const SizedBox(height: 16.0),

              // Bagian tengah: pesan sambutan dan kisi tombol menu portofolio.
              Center(
                child: Column(
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 16.0),
                      child: Text(
                        'Selamat datang di MyPortfolio Mobile!',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18.0,
                        ),
                      ),
                    ),

                    // GridView menampilkan kartu tombol dalam tata letak kisi 3 kolom.
                    GridView.count(
                      // GridView tidak menggulir sendiri, yang menggulir
                      // adalah SingleChildScrollView di luarnya.
                      primary: false,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(20),
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      crossAxisCount: 3,
                      // shrinkWrap agar ukuran kisi menyesuaikan tinggi konten anak.
                      shrinkWrap: true,
                      children: items.map((ItemHomepage item) {
                        return ItemCard(item);
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class InfoCard extends StatelessWidget {
  // Kartu informasi yang menampilkan judul (title) dan isi (content).
  final String title;
  final String content;

  const InfoCard({super.key, required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    return Card(
      // Memberikan efek bayangan kartu elevasi 2 unit.
      elevation: 2.0,
      // Memotong garis emas agar mengikuti sudut kartu yang membulat.
      clipBehavior: Clip.antiAlias,
      child: Container(
        // Menyesuaikan lebar kartu dengan proporsi layar (dibagi 3.5).
        width: MediaQuery.of(context).size.width / 3.5,
        padding: const EdgeInsets.all(16.0),
        // Garis emas di bagian atas kartu sebagai aksen tema.
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: Theme.of(context).colorScheme.secondary,
              width: 3,
            ),
          ),
        ),
        // Menyusun teks title dan content secara vertikal.
        child: Column(
          children: [
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 8.0),
            Text(content, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

/// Data satu tombol menu: nama, ikon, dan warna latar kartunya.
class ItemHomepage {
  final String name;
  final IconData icon;
  final Color color;

  ItemHomepage(this.name, this.icon, this.color);
}
