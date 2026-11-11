# 👑 MyPortfolio Mobile - Awiddy Munaya

Nama : Awiddy Munaya Rajanadoli

NPM : 2506622872

Kelas : PBP D

Aplikasi mobile Flutter untuk portofolio pribadi saya. Aplikasi ini adalah versi mobile dari [web portofolio Django](https://github.com/awiddymunaya/myportofolio) dan memakai tema yang sama, yaitu **Royal Blue & Gold**. Proyek ini dikerjakan untuk Tugas Individu mata kuliah Pemrograman Berbasis Platform (CSGE602022), Fakultas Ilmu Komputer, Universitas Indonesia.

## 🚀 Fitur Saat Ini

* **Kartu identitas (`InfoCard`):** tiga kartu berisi NPM, nama, dan kelas, dengan aksen garis emas.
* **Menu aksi (`ItemCard`):** tombol **Lihat Experience** (biru), **Tambah Experience** (hijau), dan **Logout** (merah). Warna tiap tombol disimpan di model `ItemHomepage`.
* **SnackBar interaktif:** menekan tombol memunculkan pesan "Kamu telah menekan tombol [Nama Tombol]!" dengan warna yang sama seperti tombolnya.
* **Widget test:** 5 test untuk data identitas, warna tombol yang berbeda, dan SnackBar tiap tombol.

## 📅 Progres Mingguan

| Minggu | Tugas | Progres |
| --- | --- | --- |
| 8 | Tutorial 08 | Inisialisasi proyek Flutter, memisahkan `menu.dart` dari `main.dart`, `MyHomePage` menjadi `StatelessWidget`, membuat `InfoCard` dan `ItemCard` |
| 8 | Tugas 7 | Data identitas sendiri, tombol portofolio dengan warna berbeda, tema Royal Blue & Gold, SnackBar berwarna, widget test |

## 🗂️ Struktur Kode

```
lib/
├── main.dart   # titik masuk aplikasi: main() dan MyApp (MaterialApp + tema)
└── menu.dart   # MyHomePage, InfoCard, ItemHomepage, ItemCard
test/
└── widget_test.dart
```

## 🛠️ Instruksi Setup Lokal

1. Pasang [Flutter SDK](https://docs.flutter.dev/get-started/install) lalu cek dengan `flutter doctor`.
2. Clone repositori:
   ```bash
   git clone https://github.com/awiddymunaya/myportofolio_mobile.git
   cd myportofolio_mobile
   ```
3. Unduh dependensi:
   ```bash
   flutter pub get
   ```
4. Cek kualitas kode dan jalankan test:
   ```bash
   flutter analyze
   flutter test
   ```
5. Jalankan aplikasi di Chrome:
   ```bash
   flutter run -d chrome
   ```
   Tanpa Chrome (misalnya memakai Safari), jalankan `flutter run -d web-server --web-port 8080` lalu buka `http://localhost:8080`.

---

## Tugas 7

1. **Apa itu widget tree dan bagaimana hubungan parent-child bekerja?**
   Di Flutter, seluruh tampilan dibangun dari widget yang tersusun bertingkat seperti pohon, disebut *widget tree*. Setiap widget bisa punya satu anak (`child`) atau banyak anak (`children`). Di aplikasi ini, `MaterialApp` adalah akar, anaknya `MyHomePage`, yang berisi `Scaffold`, lalu `Padding`, `Column`, `Row`, sampai `InfoCard` dan `ItemCard` di bagian paling bawah.
   Hubungan parent-child bekerja dua arah. Parent memberi data dan batasan ukuran (*constraints*) ke child, misalnya `Padding` memberi ruang kosong di sekeliling `Column`, dan `Row` menyusun tiga `InfoCard` secara horizontal. Child lalu menentukan ukurannya sendiri di dalam batasan itu, dan parent menentukan posisi child. Child juga bisa membaca data dari leluhurnya lewat `BuildContext`, contohnya `Theme.of(context)` membaca tema dari `MaterialApp`.

2. **Widget apa saja yang dipakai dan apa fungsinya?**
   * `MaterialApp`: root aplikasi, mengatur judul, tema (`ThemeData` + `ColorScheme`), dan halaman awal (`home`).
   * `MyHomePage` (`StatelessWidget`): halaman utama yang menyimpan data NPM, nama, kelas, dan daftar tombol.
   * `Scaffold`: kerangka halaman Material, menyediakan slot `appBar` dan `body` serta tempat munculnya SnackBar.
   * `AppBar`: bar judul "MyPortfolio" di bagian atas.
   * `Text`: menampilkan tulisan, dengan `TextStyle` untuk tebal, ukuran, dan warna.
   * `Padding`: memberi jarak di sekeliling widget anak.
   * `Column`: menyusun widget secara vertikal.
   * `Row`: menyusun tiga `InfoCard` secara horizontal.
   * `SizedBox`: memberi jarak kosong dengan ukuran tetap.
   * `Center`: menaruh anak di tengah.
   * `GridView.count`: menampilkan tombol dalam kisi 3 kolom. `shrinkWrap: true` membuat tingginya mengikuti isi karena berada di dalam `Column`.
   * `InfoCard` (custom): kartu identitas berisi judul dan isi.
   * `Card`: wadah dengan bayangan (`elevation`) dan sudut membulat untuk `InfoCard`.
   * `Container`: mengatur lebar, padding, dan dekorasi (garis emas di atas `InfoCard`).
   * `ItemCard` (custom): kartu tombol yang menampilkan ikon dan nama dari `ItemHomepage`.
   * `Material`: memberi warna latar tombol (`item.color`) dan sudut membulat, sekaligus permukaan untuk efek ripple.
   * `InkWell`: membuat kartu bisa ditekan (`onTap`) dan menampilkan efek ripple.
   * `Icon`: menampilkan ikon tombol (`work`, `add_circle`, `logout`).
   * `SnackBar`: pesan singkat di bawah layar saat tombol ditekan, dimunculkan lewat `ScaffoldMessenger`.
   * `ItemHomepage` bukan widget, melainkan model data biasa berisi `name`, `icon`, dan `color` untuk tiap tombol.

3. **Apa fungsi `MaterialApp` dan mengapa umumnya dipakai sebagai root widget?**
   `MaterialApp` membungkus aplikasi dengan semua hal yang dibutuhkan widget bergaya Material Design: tema global (`theme`), navigasi antarhalaman (`Navigator` dan *routes*), `ScaffoldMessenger` untuk SnackBar, lokalisasi, serta arah teks. Widget seperti `Scaffold`, `AppBar`, `Card`, dan `SnackBar` membutuhkan data tersebut dari leluhurnya, jadi `MaterialApp` perlu berada di paling atas widget tree. Dengan begitu semua halaman di bawahnya otomatis mendapat tema dan navigasi yang sama. Di proyek ini, warna Royal Blue (`#1E3A8A`) dan Gold (`#D4AF37`) cukup diatur sekali di `MaterialApp` lalu dipakai di mana saja lewat `Theme.of(context)`.

4. **Apa perbedaan `StatelessWidget` dan `StatefulWidget`, dan kapan memakai masing-masing?**
   `StatelessWidget` tidak punya *state* yang bisa berubah. Tampilannya hanya bergantung pada data yang diberikan saat dibuat, dan baru berubah kalau parent membangunnya ulang dengan data baru. `StatefulWidget` punya objek `State` terpisah yang menyimpan data yang bisa berubah selama widget hidup. Saat data berubah, kita memanggil `setState()` agar Flutter menjalankan ulang `build()`.
   Pilih `StatelessWidget` kalau tampilan statis atau hanya bergantung pada input, seperti `MyHomePage`, `InfoCard`, dan `ItemCard` di proyek ini. Data identitas dan daftar tombolnya tetap, dan SnackBar dimunculkan lewat `ScaffoldMessenger`, bukan lewat state halaman. Pilih `StatefulWidget` kalau tampilan harus berubah karena interaksi atau data dari luar, misalnya counter, form input, *checkbox*, animasi, atau data yang diambil dari API Django nanti.

5. **Apa itu `BuildContext`, mengapa penting, dan bagaimana dipakai di metode `build`?**
   `BuildContext` adalah penanda posisi sebuah widget di dalam widget tree. Setiap metode `build(BuildContext context)` menerima context miliknya sendiri. Context ini penting karena menjadi jalan bagi widget untuk mencari data dari leluhurnya di tree.
   Di proyek ini context dipakai untuk:
   * `Theme.of(context).colorScheme.primary` agar warna AppBar dan judul `InfoCard` mengikuti tema dari `MaterialApp`.
   * `MediaQuery.of(context).size.width` agar lebar `InfoCard` menyesuaikan lebar layar.
   * `ScaffoldMessenger.of(context)` agar `ItemCard` bisa menampilkan SnackBar pada `Scaffold` terdekat.
   Karena pencarian dimulai dari posisi context, context yang dipakai harus berada di bawah widget yang dicari. Misalnya `ScaffoldMessenger.of(context)` hanya berhasil kalau context berada di bawah `MaterialApp`.

6. **Apa itu hot reload, apa bedanya dengan hot restart, dan kapan hot reload tidak cukup?**
   *Hot reload* (tekan `r`) menyuntikkan kode Dart yang berubah ke aplikasi yang sedang berjalan lalu membangun ulang widget tree, tanpa menghapus *state*. Hasil perubahan UI terlihat dalam hitungan detik. *Hot restart* (tekan `R`) memuat ulang seluruh kode dan menjalankan aplikasi dari awal, sehingga semua state kembali ke nilai awal. Hot restart lebih lambat, tapi tetap lebih cepat daripada menghentikan dan menjalankan ulang aplikasi.
   Hot reload tidak cukup dan perlu hot restart kalau perubahan tidak dijalankan ulang oleh `build()`, misalnya:
   * mengubah fungsi `main()` atau nilai awal di `initState()`,
   * mengubah inisialisasi variabel global atau `static`,
   * mengubah struktur class, misalnya `StatelessWidget` menjadi `StatefulWidget`, atau mengubah tipe generik dan enum.
   *Full restart* (hentikan dengan `q`, lalu `flutter run` lagi) diperlukan kalau ada perubahan di luar kode Dart, seperti menambah *package* di `pubspec.yaml`, menambah *asset* baru, atau mengubah kode native Android/iOS. Pada Flutter web, hot reload juga tidak selalu tersedia (terutama dengan `web-server`), sehingga hot restart atau refresh browser sering dibutuhkan.

### AI Disclosure

* **Tools yang Digunakan:** Claude (Anthropic), lewat fitur proyek di claude.ai. Claude bekerja di *sandbox* terpisah dan tidak punya akses push ke repositori saya, jadi hasilnya dikirim sebagai file *patch* dan panduan langkah demi langkah. Saya sendiri yang menjalankan `git am`, `flutter analyze`, `flutter test`, dan `git push` di Mac saya.
* **Bagian yang Dibantu:**
  * Menambahkan atribut `color` pada `ItemHomepage` dan memakai `item.color` di `ItemCard` agar setiap tombol punya warna berbeda tanpa `if-else`.
  * Mengganti data contoh Burhan dengan data saya, dan mengganti tombol menjadi Lihat Experience, Tambah Experience, dan Logout.
  * Menyesuaikan tema menjadi Royal Blue & Gold seperti web Django saya, serta membuat SnackBar ikut berwarna sesuai tombol.
  * Menulis ulang widget test (5 test) dan memecah perubahan menjadi 5 commit dengan format *conventional commits*.
  * Menyusun draf README ini, termasuk jawaban pertanyaan reflektif Tugas 7.
* **Strategi Prompting:** Saya memberikan PDF soal Individual Assignment 7 dan tautan repositori publik `myportofolio_mobile` yang berisi hasil Tutorial 08, lalu meminta AI mengerjakan tugas di atas kode tersebut. Setelah itu saya bertanya lanjutan secara iteratif: memastikan commit tercatat atas nama saya, mengecek apakah tugas sudah lengkap, lalu meminta draf README.
* **Keterbatasan AI & Perbaikan Manual:**
  * AI tidak bisa melihat laptop saya. Data NPM dan kelas diambil dari README repositori Django saya, jadi saya cek ulang kebenarannya secara manual.
  * Panduan bawaan tutorial memakai `flutter run -d chrome`, padahal saya tidak memakai Chrome. Saya menjalankan aplikasi dengan `flutter run -d web-server --web-port 8080` dan mengecek tampilan serta SnackBar setiap tombol langsung di Safari.
  * AI sempat menyarankan perintah `git rebase --reset-author-date` untuk memperbaiki nama committer, padahal perintah itu tidak mengubah nama. AI kemudian meralatnya sendiri, dan saya memverifikasi author serta committer lewat `git log` sebelum push.
  * Jawaban reflektif dari AI saya baca ulang dan cocokkan dengan kode di `lib/menu.dart` dan `lib/main.dart` sebelum dikumpulkan.
* **Cuplikan Log Prompting:**
  * "kamu perlu repo yang mana buat ceknya bilang aja"
  * "berarti udah selesai?" (dengan tangkapan layar aplikasi di Safari)

