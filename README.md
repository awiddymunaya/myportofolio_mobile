[![CI](https://github.com/awiddymunaya/myportofolio_mobile/actions/workflows/main.yaml/badge.svg)](https://github.com/awiddymunaya/myportofolio_mobile/actions/workflows/main.yaml)

# 👑 MyPortfolio Mobile - Awiddy Munaya

Nama : Awiddy Munaya Rajanadoli

NPM : 2506622872

Kelas : PBP D

Aplikasi mobile Flutter untuk portofolio pribadi saya. Aplikasi ini adalah versi mobile dari [web portofolio Django](https://github.com/awiddymunaya/myportofolio) dan memakai tema yang sama, yaitu **Royal Blue & Gold**. Sejak Tutorial 10, data Experience dan Education diambil langsung dari API Django REST Framework, dan menambah atau menghapus data memakai login token. Proyek ini dikerjakan untuk Tugas Individu mata kuliah Pemrograman Berbasis Platform (CSGE602022), Fakultas Ilmu Komputer, Universitas Indonesia.

## 🔗 Backend

* Repositori Django: https://github.com/awiddymunaya/myportofolio
* Web yang sudah di-deploy (PWS): https://awiddy-munaya-myportofolio.pws.cs.ui.ac.id
* Endpoint yang dipakai aplikasi ini:

| Method | Endpoint | Login |
| --- | --- | --- |
| `POST` | `/api/v1/auth/token/` | tidak (username + password, dibalas `{"token": "..."}`) |
| `POST` | `/api/v1/auth/logout/` | token |
| `GET` | `/api/v1/experiences/` | tidak |
| `POST` | `/api/v1/experiences/` | token (superuser) |
| `GET` | `/api/v1/education/` | tidak |
| `POST` | `/api/v1/education/` | token (superuser) |
| `DELETE` | `/api/v1/education/<id>/` | token (superuser) |

## 🚀 Fitur Saat Ini

* **Kartu identitas (`InfoCard`):** NPM, nama, dan kelas dengan aksen garis emas.
* **Menu aksi (`ItemCard`):** **Lihat Experience** (biru), **Tambah Experience** (hijau), **Lihat Education** (teal), **Tambah Education** (oranye), dan **Logout** (merah). Warna tiap tombol disimpan di model `ItemHomepage`, dan SnackBar ikut berwarna sama.
* **Drawer navigasi (`LeftDrawer`):** Home, Experiences, Add Experience, Education, Add Education, serta Login atau Logout sesuai status login.
* **Daftar dan detail Experience (Tutorial 10):** diambil dari `GET /api/v1/experiences/` tanpa login.
* **Daftar dan detail Education (Tugas 9):** diambil dari `GET /api/v1/education/` tanpa login, dengan `FutureBuilder`, tarik untuk refresh, pesan kosong, dan tombol **Retry** saat gagal. Detail menampilkan jenjang, tahun masuk, tahun lulus, jumlah star, catatan, dan logo.
* **Login token:** `LoginScreen` dan `AuthState` (`ChangeNotifier`) menyimpan token selama aplikasi berjalan. `ensureLoggedIn(context)` membuka halaman Login sebelum aksi yang butuh login.
* **Form Tambah Experience (Tugas 8, Tutorial 10)** dan **Form Tambah Education (Tugas 9):** field dan validasinya mengikuti serializer Django, lalu data dikirim lewat `POST` dengan header `Authorization: Token <key>`. Status 401 menghapus sesi dan meminta login ulang, 403 dan 400 ditampilkan lewat SnackBar.
* **Hapus Education:** tombol tempat sampah di halaman detail mengirim `DELETE` dengan token setelah konfirmasi.
* **CI/CD:** GitHub Actions menjalankan format, analyze, dan test, lalu membangun APK release (artefak `app-release-apk`).
* **Test otomatis:** 52 unit dan widget test. Semua request HTTP di test memakai `MockClient` dari `package:http/testing.dart`.

## 📅 Progres Mingguan

| Minggu | Tugas | Progres |
| --- | --- | --- |
| 8 | Tutorial 08 | Inisialisasi proyek Flutter, memisahkan `menu.dart` dari `main.dart`, `MyHomePage` menjadi `StatelessWidget`, membuat `InfoCard` dan `ItemCard` |
| 8 | Tugas 7 | Data identitas sendiri, tombol portofolio dengan warna berbeda, tema Royal Blue & Gold, SnackBar berwarna, widget test |
| 9 | Tutorial 09 | Package `material_ui`, form Tambah Proyek, `LeftDrawer`, tombol Tambah Proyek, refactor ke `screens/` dan `widgets/` |
| 9 | Tugas 8 | Form Tambah Experience sesuai model Django, kartu dan opsi drawer untuk membukanya, validasi panjang/URL/urutan tanggal, test baru |
| 10 | Tutorial 10 | `http`, `provider`, `json_serializable`, `ApiClient`, daftar/detail Experience dari API, login token, form Experience mengirim POST, CI GitHub Actions. Form Tambah Proyek tiruan dihapus |
| 10 | Tugas 9 | Integrasi Education: model `@JsonSerializable`, GET/POST/DELETE, daftar + detail, form Education dengan token, kartu menu dan drawer, 22 test baru |

## 🗂️ Struktur Kode

```
lib/
├── config.dart                       # apiBaseUrl dari --dart-define (default http://10.0.2.2:8000)
├── main.dart                         # MyApp + MultiProvider (ApiClient, AuthState) + tema
├── models/
│   ├── education.dart                # Education (+ education.g.dart hasil build_runner)
│   └── experience.dart               # Experience (+ experience.g.dart hasil build_runner)
├── screens/
│   ├── menu.dart                     # MyHomePage, InfoCard, ItemHomepage
│   ├── login_screen.dart             # LoginScreen
│   ├── education_list_screen.dart    # daftar Education (FutureBuilder)
│   ├── education_detail_screen.dart  # detail + hapus Education
│   ├── education_form.dart           # form Tambah Education (POST)
│   ├── experience_list_screen.dart   # daftar Experience
│   ├── experience_detail_screen.dart # detail Experience
│   └── experience_form.dart          # form Tambah Experience (POST)
├── services/
│   ├── api_client.dart               # ApiClient + ApiException
│   └── auth_state.dart               # AuthState (token)
└── widgets/
    ├── auth_guard.dart               # ensureLoggedIn(context)
    ├── left_drawer.dart              # LeftDrawer
    ├── network_image_box.dart        # Image.network dengan gambar cadangan
    └── project_card.dart             # ItemCard: kartu aksi di menu
test/
├── fake_backend.dart                 # backend Django tiruan (MockClient)
├── api_client_test.dart              # model Experience, ApiClient, AuthState
├── education_api_test.dart           # model Education dan ApiClient Education
├── education_screens_test.dart       # daftar, detail, form, hapus Education
├── experience_form_test.dart         # form Experience
├── experience_list_test.dart         # daftar dan detail Experience
└── widget_test.dart                  # menu, login, logout, drawer
```

File `*.g.dart` tidak di-commit (ada di `.gitignore` dan dikecualikan di `analysis_options.yaml`), jadi harus dibuat dulu dengan `build_runner`.

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
4. Buat kode model JSON (`*.g.dart`):
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```
5. Cek kualitas kode dan jalankan test:
   ```bash
   dart format --output=none --set-exit-if-changed .
   flutter analyze
   flutter test
   ```
6. Jalankan backend Django (lihat README [repositori Django](https://github.com/awiddymunaya/myportofolio)) di `http://localhost:8000`:
   ```bash
   python manage.py runserver
   ```
7. Jalankan aplikasi dengan alamat backend lewat `--dart-define=API_BASE_URL`:
   * Browser: `flutter run -d chrome --dart-define=API_BASE_URL=http://localhost:8000`. Tanpa Chrome (misalnya Safari), pakai `flutter run -d web-server --web-port 8080 --dart-define=API_BASE_URL=http://localhost:8000` lalu buka `http://localhost:8080`.
   * macOS: `flutter run -d macos --dart-define=API_BASE_URL=http://localhost:8000`
   * Emulator Android: `flutter run` saja, karena alamat default `http://10.0.2.2:8000` sudah mengarah ke komputer.
   * Backend PWS: `--dart-define=API_BASE_URL=https://awiddy-munaya-myportofolio.pws.cs.ui.ac.id`
8. Login memakai akun superuser Django. Hanya superuser (Pemilik) yang boleh menambah dan menghapus data.

Untuk CI, variabel repositori `API_BASE_URL` (Settings > Secrets and variables > Actions > Variables) dipakai saat membangun APK release. Jika kosong, APK memakai `http://10.0.2.2:8000`.

---

## Tugas 9

### Assignment 9

1. **Mengapa memakai `@JsonSerializable(fieldRename: FieldRename.snake)` dan `@JsonKey(includeToJson: false)` daripada mengirim `Map<String, dynamic>` mentah dari widget? Satu bug yang dicegah di model Education.**
   Dengan `@JsonSerializable`, bentuk data Education ditulis sekali di `lib/models/education.dart` sebagai class bertipe, lalu `build_runner` membuat `fromJson` dan `toJson`. Widget cukup memakai `education.institutionName` atau `education.startYear` yang dicek oleh compiler, bukan mengetik `map['institution_name']` di banyak tempat. `fieldRename: FieldRename.snake` mengubah nama camelCase Dart (`institutionName`, `startYear`, `logoUrl`) menjadi snake_case yang dipakai `EducationSerializer` (`institution_name`, `start_year`, `logo_url`) secara otomatis. Salah ketik satu kunci di map mentah, misalnya `institutionName`, tidak akan ketahuan saat compile. DRF akan mengabaikan kunci itu lalu membalas 400 "institution_name: This field is required". `@JsonKey(includeToJson: false)` pada `id`, `star_count`, dan `is_starred` memastikan field yang ditentukan server tidak ikut dikirim saat POST.
   Bug nyata yang dicegah: tiga data Education lama di database saya (SMA, SMP, SD) punya `description` dan `logo_url` bernilai `null`. Kalau dibaca dari map mentah dengan `json['description'] as String`, aplikasi langsung error `type 'Null' is not a subtype of type 'String'` saat membuka daftar. Di model saya, kedua field itu memakai `@JsonKey(defaultValue: '')`, sehingga `null` diubah menjadi string kosong dan layar detail cukup mengecek `isEmpty` untuk menampilkan "Tidak ada catatan." atau menyembunyikan logo. Ada test khusus untuk kasus ini di `test/education_api_test.dart`.

2. **Mengapa Future untuk `FutureBuilder` dibuat di `initState()` dan bukan di `build()`, dan mengapa `ApiClient` melempar `ApiException` daripada mengembalikan `null`?**
   `build()` bisa dipanggil berkali-kali, misalnya saat `setState()`, saat drawer dibuka, saat keyboard muncul, atau saat `AuthState` berubah. Kalau `getEducations()` dipanggil di dalam `build()`, setiap rebuild membuat Future baru dan mengirim request HTTP baru. `FutureBuilder` juga akan kembali ke status loading setiap kali menerima Future baru, sehingga layar berkedip dan bisa terjadi request berulang tanpa henti. `initState()` hanya dijalankan sekali saat state dibuat, jadi di `EducationListScreen` Future disimpan di `_educationsFuture` dan hanya diganti dengan sengaja lewat `_reload()` (tarik untuk refresh, tombol Retry, atau setelah menambah/menghapus data).
   `null` tidak membawa informasi apa pun tentang penyebab gagal. Dengan `ApiException(statusCode, message)`, pemanggil bisa membedakan penyebabnya: form Education menghapus sesi dan meminta login ulang pada 401, menampilkan "Akunmu tidak boleh menambah Education" pada 403, dan menampilkan pesan validasi dari body pada 400 (`ApiException.validationMessage`). Exception juga otomatis diteruskan ke `snapshot.hasError` di `FutureBuilder`, sehingga daftar menampilkan pesan error dan tombol Retry tanpa harus menulis pengecekan `null` di setiap layar. Kalau `null` dipakai, kegagalan mudah tertukar dengan "datanya memang kosong".

3. **Bandingkan `SessionAuthentication` dan `TokenAuthentication`. Mengapa aplikasi mobile memakai token, sementara session tetap aktif di backend?**
   `SessionAuthentication` memakai cookie `sessionid` yang disimpan dan dikirim otomatis oleh browser setelah login di halaman web. Data sesinya disimpan di server. Karena cookie dikirim otomatis, setiap request yang mengubah data juga wajib membawa token CSRF. `TokenAuthentication` memakai satu kunci acak per user (tabel `authtoken_token`) yang didapat dari `POST /api/v1/auth/token/`, lalu dikirim sendiri oleh klien di header `Authorization: Token <key>`. Karena tidak dikirim otomatis oleh browser, token tidak butuh CSRF.
   Aplikasi Flutter bukan browser: tidak ada cookie jar dan formulir HTML yang otomatis membawa CSRF, jadi mengelola cookie + CSRF di Flutter merepotkan dan rawan salah. Menyimpan token di `AuthState` lalu menambahkannya ke header di `ApiClient` jauh lebih sederhana. Logout cukup memanggil `/api/v1/auth/logout/` yang menghapus token di server.
   `SessionAuthentication` tetap aktif karena web Django saya masih memakainya: halaman Education dari Tugas 6 memanggil `/api/v1/education/` dengan `fetch` memakai cookie login dan header CSRF, begitu pula Django Admin dan browsable API. Di `REST_FRAMEWORK`, `TokenAuthentication` ditaruh di urutan pertama, sehingga request tanpa login dibalas 401 (dengan header `WWW-Authenticate`), sedangkan request dari browser yang sudah login tetap dikenali lewat session.

4. **Peran job `build` (`very_good_workflows`) dan `build_apk` di `.github/workflows/main.yaml`, serta alasan `*.g.dart` ada di `.gitignore`.**
   Job `build` memakai workflow siap pakai `flutter_package.yml` dari Very Good Ventures. Di balik layar workflow ini menyiapkan Flutter, menjalankan `flutter pub get` dan perintah `setup` yang saya isi `dart run build_runner build --delete-conflicting-outputs`, memeriksa format dengan `dart format --set-exit-if-changed`, menjalankan `flutter analyze`, dan menjalankan `flutter test` dengan coverage. Coverage dicek terhadap `min_coverage` (di repo ini 0, dan `**/*.g.dart` dikecualikan). Jika salah satu langkah gagal, job merah dan perubahan tidak dianggap layak rilis.
   Job `build_apk` memakai `needs: build`, jadi hanya jalan kalau `build` hijau. Job ini menyiapkan Flutter, menjalankan `flutter pub get` dan `build_runner`, membangun `flutter build apk --release` (dengan `--dart-define=API_BASE_URL` dari variabel repo jika ada), lalu mengunggah `app-release.apk` sebagai artefak `app-release-apk` lewat `actions/upload-artifact`. Jadi `build` adalah bagian CI (memeriksa kualitas kode), dan `build_apk` adalah bagian CD (menghasilkan APK yang bisa diunduh dan dipasang).
   `*.g.dart` adalah hasil generate yang selalu bisa dibuat ulang dari file model, jadi menyimpannya di Git hanya menambah file yang bisa basi (lupa generate ulang setelah model diubah), diff yang berisik, dan konflik merge. CI tidak butuh file itu dari repositori karena kedua job menjalankan `build_runner` sendiri sebelum analyze, test, dan build. Hasilnya selalu sesuai dengan kode model di commit tersebut.

### AI Disclosure (Tugas 9)

* **Tools yang Digunakan:** Claude (Anthropic), lewat fitur proyek di claude.ai. Claude bekerja di *sandbox* terpisah tanpa akses push, jadi hasilnya dikirim sebagai file *patch* dan panduan. Saya sendiri yang menjalankan `git am`, `build_runner`, `flutter analyze`, `flutter test`, dan `git push`.
* **Bagian yang Dibantu:**
  * Model `Education` dengan `@JsonSerializable` yang dicocokkan ke `EducationSerializer` di repositori Django saya, serta `getEducations()`, `createEducation()`, dan `deleteEducation()` di `ApiClient`.
  * `EducationListScreen`, `EducationDetailScreen`, dan `EducationFormPage`, termasuk penanganan 401/403/400 dan fitur hapus.
  * Kartu menu dan opsi drawer untuk Education, serta refactor kecil (`NetworkImageBox` dan `ApiException.validationMessage`) supaya kode Experience dan Education tidak duplikat.
  * 22 test baru dengan `MockClient` dan pemecahan perubahan menjadi 7 commit dengan format *conventional commits*.
  * Draf README ini, termasuk jawaban pertanyaan reflektif Assignment 9.
* **Strategi Prompting:** Saya mengunggah PDF soal Individual Assignment 9 dan meminta AI mengerjakannya di atas hasil Tutorial 10 yang sudah saya push. Soal saya jadikan acuan utama supaya AI mengikuti checklist dan rubrik, bukan menebak.
* **Keterbatasan AI & Perbaikan Manual:**
  * AI sempat salah membaca permintaan saya soal README dan awalnya hanya menulis cuplikan prompting. Setelah diluruskan, AI menulis README ini.
  * Form dari Assignment 8 saya adalah form Experience, dan form itu sudah dipakai sebagai pengganti "Project" di Tutorial 10. Karena itu AI membuat form Education baru, bukan me-refactor form lama. Soal sendiri meminta "setidaknya satu bagian portofolio selain Project".
  * AI menguji di Flutter versi Linux dan Chromium *headless* terhadap salinan database Django di *sandbox*, bukan di laptop saya. Saya menjalankan ulang semua langkah di Mac, mengetes alur daftar, tambah, 401 (menghapus token lewat Django Admin), dan hapus di Safari, lalu mengecek data barunya di web Django.
  * Token hanya disimpan di memori (`AuthState`), jadi setelah aplikasi ditutup saya harus login ulang. Ini disengaja mengikuti Tutorial 10, bukan bug.
  * Isian contoh di test (misalnya "SMA Negeri 1 Depok") hanya data uji, bukan riwayat pendidikan saya.

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

