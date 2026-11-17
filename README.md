# 👑 MyPortfolio Mobile - Awiddy Munaya

Nama : Awiddy Munaya Rajanadoli

NPM : 2506622872

Kelas : PBP D

Aplikasi mobile Flutter untuk portofolio pribadi saya. Aplikasi ini adalah versi mobile dari [web portofolio Django](https://github.com/awiddymunaya/myportofolio) dan memakai tema yang sama, yaitu **Royal Blue & Gold**. Proyek ini dikerjakan untuk Tugas Individu mata kuliah Pemrograman Berbasis Platform (CSGE602022), Fakultas Ilmu Komputer, Universitas Indonesia.

## 🚀 Fitur Saat Ini

* **Kartu identitas (`InfoCard`):** tiga kartu berisi NPM, nama, dan kelas, dengan aksen garis emas.
* **Menu aksi (`ItemCard`):** tombol **Lihat Experience** (biru), **Tambah Experience** (hijau), **Tambah Proyek** (ungu), dan **Logout** (merah). Warna tiap tombol disimpan di model `ItemHomepage`.
* **SnackBar interaktif:** menekan tombol memunculkan pesan "Kamu telah menekan tombol [Nama Tombol]!" dengan warna yang sama seperti tombolnya.
* **Drawer navigasi (`LeftDrawer`):** opsi **Home**, **Add Project**, dan **Add Experience**, dipakai bersama oleh halaman menu dan kedua halaman form.
* **Form Tambah Proyek (Tutorial 09):** nama, deskripsi, kategori, teknologi, dan tautan proyek, dengan validasi dan pop-up ringkasan.
* **Form Tambah Experience (Tugas 8):** field mengikuti model `Experience` di web Django: judul, deskripsi, kategori (Internship, Research, Volunteer, Part-Time, Full-Time, Freelance), thumbnail, logo organisasi, tanggal mulai, dan tanggal selesai lewat `showDatePicker()`, plus *switch* "Masih berlangsung". Setelah lolos validasi, semua isian tampil di `AlertDialog`.
* **Widget test:** 15 test untuk menu, drawer, kedua form, validasi, dialog, dan navigasi kembali.

## 📅 Progres Mingguan

| Minggu | Tugas | Progres |
| --- | --- | --- |
| 8 | Tutorial 08 | Inisialisasi proyek Flutter, memisahkan `menu.dart` dari `main.dart`, `MyHomePage` menjadi `StatelessWidget`, membuat `InfoCard` dan `ItemCard` |
| 8 | Tugas 7 | Data identitas sendiri, tombol portofolio dengan warna berbeda, tema Royal Blue & Gold, SnackBar berwarna, widget test |
| 9 | Tutorial 09 | Package `material_ui`, form Tambah Proyek, `LeftDrawer`, tombol Tambah Proyek, refactor ke `screens/` dan `widgets/` |
| 9 | Tugas 8 | Form Tambah Experience sesuai model Django, kartu dan opsi drawer untuk membukanya, validasi panjang/URL/urutan tanggal, test baru |

## 🗂️ Struktur Kode

```
lib/
├── main.dart                   # titik masuk aplikasi: main() dan MyApp (MaterialApp + tema)
├── screens/
│   ├── menu.dart               # MyHomePage, InfoCard, ItemHomepage
│   ├── project_form.dart       # ProjectFormPage (Tutorial 09)
│   └── experience_form.dart    # ExperienceFormPage (Tugas 8)
└── widgets/
    ├── left_drawer.dart        # LeftDrawer: Home, Add Project, Add Experience
    └── project_card.dart       # ItemCard: kartu aksi + navigasi ke form
test/
├── widget_test.dart            # menu, drawer, form proyek
└── experience_form_test.dart   # form experience
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

## Tugas 8

1. **Perbedaan `Navigator.push()`, `Navigator.pushReplacement()`, dan `Navigator.pop()`, serta mana yang dipakai di aplikasi ini.**
   `Navigator` menyimpan halaman (*route*) sebagai tumpukan (*stack*). `push()` menaruh route baru di atas stack, jadi halaman lama masih ada di bawahnya. `pushReplacement()` mengganti route paling atas dengan route baru, jadi halaman lama dibuang dari stack. `pop()` membuang route paling atas sehingga pengguna kembali ke halaman di bawahnya.
   Kartu **Tambah Experience** di menu membuka `ExperienceFormPage` dengan `Navigator.push()`. Karena menu masih ada di bawah stack, tombol kembali bawaan perangkat menjalankan `pop()` dan membawa pengguna ke menu lagi. Opsi drawer memakai `Navigator.pushReplacement()`. Saat pengguna menekan **Home** di drawer pada halaman form, route form diganti dengan `MyHomePage` yang baru, sehingga pengguna kembali ke halaman utama tanpa menumpuk halaman form di stack.

2. **Bagaimana `Scaffold`, `AppBar`, dan `Drawer` menjaga struktur halaman tetap konsisten? Contoh warna tema di lebih dari satu halaman.**
   `Scaffold` adalah kerangka yang sama untuk setiap halaman: slot `appBar` di atas, `drawer` di samping, dan `body` di tengah. Karena menu, form proyek, dan form experience semuanya memakai `Scaffold` dengan `AppBar` dan `LeftDrawer` yang sama, pengguna selalu menemukan judul halaman dan menu navigasi di posisi yang sama. `LeftDrawer` ditulis sekali di `lib/widgets/left_drawer.dart` lalu dipakai di ketiga halaman, jadi menambah opsi **Add Experience** cukup di satu tempat.
   Contoh warna tema: warna primer Royal Blue (`#1E3A8A`) diatur sekali di `MaterialApp` (`lib/main.dart`), lalu diambil lewat `Theme.of(context).colorScheme.primary` untuk latar `AppBar` di menu dan form experience, latar `DrawerHeader`, dan tombol **Save** di kedua form.

3. **Mengapa tata letak ini dipilih untuk formulir, dan apa peran widget pengatur jarak dan penggulir?**
   Form experience disusun dalam satu `Column` vertikal, satu field per baris, karena di layar ponsel yang sempit field yang ditumpuk ke bawah lebih mudah dibaca dan diisi daripada disusun menyamping. Urutannya mengikuti model `Experience`: judul, deskripsi, kategori, gambar, lalu tanggal, dan tombol **Save** di paling bawah.
   Setiap field dibungkus `Padding` (`EdgeInsets.all(8.0)`) supaya ada jarak yang sama antarfield dan dari tepi layar, sehingga label dan pesan kesalahan tidak saling menempel. Seluruh `Column` dibungkus `SingleChildScrollView`. Form ini cukup panjang (tujuh input, *switch*, dan tombol), dan ketika papan ketik muncul, ruang layar makin kecil. Tanpa penggulir, isi yang tidak muat akan *overflow* dan tombol **Save** tidak bisa dijangkau. Dengan `SingleChildScrollView`, pengguna tinggal menggulir untuk mencapai field mana pun.

4. **Peran `GlobalKey<FormState>`, `validator`, dan `validate()`, dan contoh nilai yang ditolak.**
   `GlobalKey<FormState>` (`_formKey`) dipasang di widget `Form` sehingga kita bisa mengakses state form dari luar, misalnya dari tombol **Save**. Setiap `TextFormField` punya fungsi `validator` yang mengembalikan pesan kesalahan jika nilainya tidak valid, atau `null` jika valid. Saat **Save** ditekan, `_formKey.currentState!.validate()` menjalankan semua validator sekaligus, menampilkan pesan kesalahan di bawah field yang bermasalah, dan mengembalikan `true` hanya jika semuanya lolos. Hanya pada kondisi itu `showDialog()` dipanggil untuk menampilkan ringkasan.
   Contoh nilai yang ditolak: thumbnail diisi `bukan url`. Field ini memakai `keyboardType: TextInputType.url`, tetapi papan ketik URL hanya memudahkan mengetik karakter seperti `/` dan `.`, bukan membatasi isinya. Pengguna tetap bisa mengetik teks apa saja atau menempelkan teks. Karena itu validator memeriksa bahwa isinya berupa URL `http(s)` atau path seperti `/static/img/Compfest.jpg`, sesuai cara web Django saya menyimpan gambar. Contoh lain: judul yang hanya berisi spasi ditolak karena di-`trim()` dulu, dan tanggal selesai yang lebih awal dari tanggal mulai ditolak walaupun keduanya dipilih lewat `showDatePicker()` yang sah.

### AI Disclosure (Tugas 8)

* **Tools yang Digunakan:** Claude (Anthropic), lewat fitur proyek di claude.ai. Seperti di Tugas 7, Claude bekerja di *sandbox* terpisah tanpa akses push, jadi hasilnya dikirim sebagai file *patch* dan panduan. Saya sendiri yang menjalankan `git am`, `flutter analyze`, `flutter test`, dan `git push`.
* **Bagian yang Dibantu:**
  * Membuat `lib/screens/experience_form.dart` dengan field yang dicocokkan ke model `Experience` di `main/models.py` repositori Django saya, termasuk validasi kosong/spasi, panjang maksimal 255 dan 500 karakter, format URL/path, dan urutan tanggal.
  * Menyambungkan kartu **Tambah Experience** (yang sudah ada sejak Tugas 7) ke form dengan `Navigator.push()`, dan menambah opsi **Add Experience** di `LeftDrawer`.
  * Menulis `test/experience_form_test.dart` (5 test) dan memecah perubahan menjadi beberapa commit dengan format *conventional commits*.
  * Menyusun draf README ini, termasuk jawaban pertanyaan reflektif Tugas 8.
* **Strategi Prompting:** Saya meminta AI mengerjakan Tugas 8 di atas hasil Tutorial 09 yang sudah saya push, lalu mengunggah PDF soal Individual Assignment 8 supaya pekerjaannya mengikuti checklist dan rubrik. Sebelum PDF diunggah, AI memilih bagian Experience karena tombol **Tambah Experience** sudah disiapkan sejak Tugas 7.
* **Keterbatasan AI & Perbaikan Manual:**
  * AI menguji di Flutter versi Linux dan build web di *sandbox*, bukan di laptop saya. Saya menjalankan ulang `flutter analyze` dan `flutter test`, lalu mengetes form di browser saya sendiri (termasuk layar selebar ponsel).
  * Isian contoh di test (misalnya "Staff IT Compfest") hanya data uji, bukan data experience saya yang sebenarnya.
  * [Tuliskan di sini perbaikan atau pengecekan manual yang kamu lakukan sendiri.]

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

