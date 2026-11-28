# MyPortfolio Mobile

[![CI](https://github.com/tipen7/myportofolio_mobile/actions/workflows/main.yaml/badge.svg?branch=main)](https://github.com/tipen7/myportofolio_mobile/actions/workflows/main.yaml)
[![style: very good analysis](https://img.shields.io/badge/style-very_good_analysis-B22C89.svg)](https://pub.dev/packages/very_good_analysis)

Aplikasi Flutter untuk portofolio pribadi yang terintegrasi dengan REST API Django REST Framework (DRF). Siapa pun boleh membaca data; menulis data memerlukan token.

| | |
| :-- | :-- |
| Repositori backend | <https://github.com/tipen7/my-portfolio> |
| URL API (deploy PWS) | <https://steven-dyanizha-myportofolio.pws.cs.ui.ac.id/api/v1/experiences/> |
| Artefak APK | tab **Actions** → run terbaru → **app-release-apk** |

### Information

Nama: Steven Dyanizha Ananda
NPM: 2506616112
Kelas: PBP A

---

## Fitur

| Bagian | Baca (publik) | Tulis (token) |
| :-- | :-- | :-- |
| Experience | daftar, detail semua field | tambah (POST), edit (PATCH), hapus (DELETE) |
| Project | daftar, detail | tambah (POST) |

- Daftar memiliki kondisi loading (skeleton), error dengan tombol **Retry**, kosong, dan *pull-to-refresh*, serta pencarian dan chip filter.
- Tampilan bergaya Gojek: header hijau dengan search pill, grid layanan, feed pengalaman terbaru, navigasi bawah, bottom sheet, dan tema terang/gelap. Lihat [`docs/design-tokens.md`](docs/design-tokens.md).
- Aksi tulis dijaga `ensureLoggedIn(context)`. Respons `401` menghapus sesi lalu meminta login ulang, dan isian formulir tidak hilang.
- Hak akses mengikuti backend: tambah dan hapus hanya untuk pemilik (superuser), edit untuk pemilik atau grup `Editor`. Akun lain mendapat pesan `403`.
- Token hanya disimpan di memori, sehingga menutup aplikasi sama dengan logout.

## Endpoint yang dipakai

| Method | Endpoint | Auth |
| :-- | :-- | :-- |
| `POST` | `/api/v1/auth/token/` | username + password |
| `POST` | `/api/v1/auth/logout/` | `Token <key>` |
| `GET` | `/api/v1/experiences/` | publik |
| `POST` | `/api/v1/experiences/` | `Token <key>` |
| `PATCH`, `DELETE` | `/api/v1/experiences/<id>/` | `Token <key>` |
| `GET` | `/api/v1/projects/` | publik |
| `POST` | `/api/v1/projects/` | `Token <key>` |

## Setup

Prasyarat: Flutter **3.47.9** (Dart 3.13) dan Python 3.11 untuk backend.

### 1. Jalankan backend Django

```bash
git clone https://github.com/tipen7/my-portfolio.git
cd my-portfolio
python -m venv env
env\Scripts\activate          # macOS/Linux: source env/bin/activate
pip install -r requirements.txt
cp .env.example .env           # PRODUCTION=False
python manage.py migrate
python manage.py createsuperuser
python manage.py runserver
```

### 2. Jalankan aplikasi Flutter

```bash
git clone https://github.com/tipen7/myportofolio_mobile.git
cd myportofolio_mobile
flutter pub get
dart run build_runner build --delete-conflicting-outputs
```

Berkas `*.g.dart` tidak ada di Git, jadi perintah `build_runner` wajib dijalankan setelah clone dan setiap kali model di `lib/models/` berubah.

Alamat backend diatur lewat `--dart-define=API_BASE_URL=...` (tanpa `/` di akhir):

| Target | Perintah |
| :-- | :-- |
| Emulator Android (default `http://10.0.2.2:8000`) | `flutter run` |
| Chrome | `flutter run -d chrome --dart-define=API_BASE_URL=http://localhost:8000` |
| Backend PWS (Android) | `flutter run --dart-define=API_BASE_URL=https://steven-dyanizha-myportofolio.pws.cs.ui.ac.id` |

Catatan:

- Flutter Web terhadap PWS diblokir CORS, kecuali `CORS_ALLOWED_ORIGINS` di server memuat origin aplikasi. Gunakan backend lokal untuk pengujian di Chrome.
- Akun superuser PWS tidak dibagikan. Untuk menguji operasi tulis secara *end-to-end*, gunakan backend lokal dengan superuser buatanmu sendiri.

### 3. Pemeriksaan kualitas

```bash
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test --coverage
```

### 4. Skenario uji manual

1. Tanpa login, buka **Lihat Pengalaman**, lalu ketuk satu entri.
2. Tekan **Tambah**; aplikasi meminta login.
3. Simpan entri baru, lalu segarkan halaman web Django untuk memastikan datanya tersimpan.
4. Edit dan hapus entri dari layar detail.
5. Hapus token di Django Admin, lalu kirim formulir; sesi terhapus dan login diminta kembali.
6. Logout lewat drawer.

## Struktur proyek

```text
lib/
  models/     Experience, Project (@JsonSerializable)
  services/   ApiClient, ApiException, AuthState
  screens/    daftar, detail, formulir, login, halaman utama
  widgets/    AsyncListView, auth guard, drawer, kartu
  utils/      format tanggal, validator formulir
  theme/      design token dan ThemeData
test/         unit test (MockClient) dan widget test
```

## CI/CD

`.github/workflows/main.yaml` berjalan pada push ke `main` atau `feat/**` dan pada setiap pull request:

1. **build** memakai `very_good_workflows`: format, analyze, test, dan coverage minimal 85%.
2. **build_apk** berjalan hanya jika `build` lulus, lalu mengunggah artefak `app-release-apk`.

URL backend untuk APK diambil dari *repository variable* `API_BASE_URL`; bila kosong, URL PWS di atas dipakai.

---

### Tugas 7

1. Jelaskan apa yang dimaksud dengan widget tree pada Flutter dan bagaimana hubungan induk-anak (parent-child) bekerja antar-widget!
2. Sebutkan semua widget yang kamu gunakan dalam proyek ini dan jelaskan fungsinya masing-masing!
3. Apa fungsi dari widget MaterialApp? Jelaskan mengapa widget ini umumnya digunakan sebagai root widget pada aplikasi Flutter!
4. Jelaskan perbedaan antara StatelessWidget dan StatefulWidget! Kapan kita sebaiknya memilih StatelessWidget dan kapan harus menggunakan StatefulWidget?
5. Apa itu BuildContext dan mengapa penting di Flutter? Bagaimana penggunaannya di dalam metode build?
6. Jelaskan konsep hot reload di Flutter dan apa perbedaannya dengan hot restart! Kapan kita tidak bisa hanya mengandalkan hot reload dan harus melakukan hot restart atau full restart?

---

### Jawaban

**1. Widget tree & hubungan parent-child**

Widget tree itu struktur berbentuk pohon yang menyusun seluruh UI di Flutter. Semua yang tampil di layar adalah widget, dan widget bisa ditaruh di dalam widget lain. Widget yang membungkus disebut *parent*, yang dibungkus disebut *child*. Parent menentukan batasan (constraint) dan posisi child, sedangkan child menentukan ukurannya sendiri dalam batasan itu. Data dan tema juga mengalir dari atas ke bawah. Di proyek ini misalnya: `MaterialApp` → `Scaffold` → `Column` → `Row`/`GridView` → `InfoCard`/`ItemCard`.

**2. Widget yang dipakai di proyek ini**

- `MaterialApp`: root aplikasi, menyediakan tema, judul, dan halaman awal (`home`).
- `Scaffold`: kerangka dasar halaman (AppBar, body, SnackBar).
- `AppBar`: bar judul di bagian atas.
- `IconButton`: tombol ikon di AppBar (reset penghitung).
- `SingleChildScrollView`: biar halaman bisa di-scroll dan tidak overflow.
- `Padding`, `SizedBox`: mengatur jarak/spasi.
- `Column`, `Row`: menyusun widget secara vertikal dan horizontal.
- `GridView.count`: menampilkan tombol menu dalam bentuk kisi 3 kolom.
- `Card`, `Container`: kartu dan wadah untuk InfoCard dan ActivityCard.
- `ListTile`: baris berisi ikon, judul, dan subjudul di ActivityCard.
- `Material`, `InkWell`: memberi warna latar, sudut membulat, dan efek sentuh pada ItemCard.
- `Icon`, `Text`: menampilkan ikon dan teks.
- `SnackBar` (lewat `ScaffoldMessenger`): notifikasi singkat saat tombol ditekan.
- Widget buatan sendiri: `MyHomePage`, `InfoCard`, `ItemCard`, `ActivityCard`.

**3. Fungsi `MaterialApp`**

`MaterialApp` membungkus aplikasi dengan fitur-fitur Material Design: tema (`ThemeData`), navigasi/routing, judul app, dan halaman awal. Widget ini biasanya jadi root karena hampir semua widget Material (Scaffold, AppBar, SnackBar, dll.) butuh konteks yang disediakannya, seperti tema, `Navigator`, dan `ScaffoldMessenger`. Jadi tidak perlu setup satu per satu.

**4. StatelessWidget vs StatefulWidget**

- `StatelessWidget`: tampilannya tetap, tidak punya state yang berubah. Isinya hanya bergantung pada data yang dikirim lewat konstruktor.
- `StatefulWidget`: punya state yang bisa berubah, dan UI di-rebuild lewat `setState()`.

Pakai Stateless kalau tampilannya statis (contoh: `InfoCard`, `ItemCard`). Pakai Stateful kalau UI perlu berubah karena interaksi atau data, seperti penghitung tombol di `MyHomePage` yang saya buat.

**5. BuildContext**

`BuildContext` adalah "penanda lokasi" sebuah widget di dalam widget tree. Lewat context, widget bisa mengakses hal-hal dari parent-nya, seperti tema (`Theme.of(context)`), ukuran layar (`MediaQuery.of(context)`), atau `ScaffoldMessenger.of(context)` untuk menampilkan SnackBar. Di dalam method `build(BuildContext context)`, context ini dipakai untuk mencari data/layanan dari widget di atasnya.

**6. Hot reload vs hot restart**

- **Hot reload**: memasukkan perubahan kode ke aplikasi yang sedang jalan tanpa mengulang dari awal, dan state tetap terjaga. Cepat, cocok untuk ubah tampilan.
- **Hot restart**: menjalankan ulang aplikasi dari awal dan semua state hilang, tapi tidak perlu build ulang total.

Hot reload tidak cukup (perlu hot restart) kalau menJgubah `main()`, nilai variabel global/static, inisialisasi state (`initState`), atau mengubah jenis widget (Stateless ↔ Stateful). Full restart (stop lalu run lagi) diperlukan kalau menambah dependency di `pubspec.yaml`, mengubah aset atau konfigurasi native (Android/iOS), atau menambah plugin baru.


### Tugas 8
1. Jelaskan perbedaan antara Navigator.push(), Navigator.pushReplacement(), dan Navigator.pop(). Metode apa yang digunakan untuk membuka formulir dari kartu aksi? Jelaskan juga bagaimana opsi Home di drawer membawa pengguna kembali ke halaman utama.
2. Bagaimana susunan Scaffold, AppBar, dan Drawer membantu menjaga struktur halaman tetap konsisten? Berikan satu contoh penggunaan warna tema portofolio di lebih dari satu halaman.
3. Mengapa tata letak tersebut dipilih untuk formulir? Jelaskan peran widget pengatur jarak dan widget penggulir ketika ruang layar terbatas.
4. Apa peran GlobalKey<FormState>, validator, dan validate() saat tombol Simpan ditekan? Berikan satu contoh nilai yang ditolak oleh validasi dan jelaskan mengapa memilih jenis input atau papan ketik saja belum cukup.

---

### Jawaban

**1. `push()` vs `pushReplacement()` vs `pop()`**

- `Navigator.push()`: menaruh halaman baru di atas tumpukan (stack), halaman lama tetap ada di bawahnya. Makanya muncul tombol kembali otomatis.
- `Navigator.pushReplacement()`: halaman saat ini diganti dengan halaman baru, jadi halaman lama hilang dari stack dan tidak bisa dikembalikan lewat tombol back.
- `Navigator.pop()`: membuang halaman paling atas dan kembali ke halaman di bawahnya (dipakai juga untuk menutup dialog).

Untuk membuka formulir dari kartu aksi saya pakai **`Navigator.push()`**, supaya pengguna bisa balik ke halaman utama dengan tombol back bawaan. Untuk opsi **Home** di drawer, saya pakai `Navigator.pushAndRemoveUntil(..., (route) => false)`: membuka `MyHomePage` sekaligus mengosongkan seluruh stack sebelumnya, jadi tidak ada halaman Home yang menumpuk dan pengguna benar-benar "reset" ke halaman utama. (Opsi Add Project dan Add Experience memakai `pushReplacement()` agar perpindahan antar-form lewat drawer tidak menumpuk halaman.)

**2. Scaffold, AppBar, dan Drawer untuk konsistensi**

`Scaffold` memberi kerangka standar (AppBar di atas, body di tengah, drawer di samping), jadi setiap halaman punya struktur yang sama. `AppBar` menjaga judul dan identitas visual tetap di tempat yang sama, sedangkan `LeftDrawer` dipakai ulang di semua halaman, sehingga menu navigasinya identik di mana pun pengguna berada. Satu perubahan di widget drawer langsung berlaku ke semua halaman.

Contoh warna tema: `Theme.of(context).colorScheme.primary` (indigo dari `seedColor`) dipakai sebagai `backgroundColor` AppBar di halaman utama, form Add Project, dan form Add Experience, serta sebagai warna `DrawerHeader`. Jadi ganti `seedColor` sekali di `main.dart`, semua halaman ikut berubah.

**3. Alasan tata letak formulir & peran spacing/scroll**

Formulir saya susun sebagai satu kolom vertikal, satu input per baris. Ini paling mudah dibaca dan diisi di layar HP, serta konsisten dengan urutan pengisian (institusi → posisi → tanggal → deskripsi → tautan). Lebar form juga dibatasi (`ConstrainedBox` maks. 600) supaya tidak melebar aneh di Chrome.

`SizedBox` dan `Padding` memberi jarak antar-kolom supaya tidak berdempetan dan pesan error tidak menimpa input di bawahnya. `SingleChildScrollView` penting ketika ruang terbatas, misalnya layar kecil atau keyboard muncul menutupi sebagian layar: tanpa itu, `Column` akan overflow dan tombol Simpan tidak terjangkau. Dengan scroll, semua input dan tombol tetap bisa digeser ke posisi yang terlihat (plus `keyboardDismissBehavior.onDrag` supaya keyboard tertutup saat di-scroll).

**4. `GlobalKey<FormState>`, `validator`, dan `validate()`**

- `GlobalKey<FormState>` adalah "pegangan" ke `Form`, sehingga di luar widget field (misalnya di tombol Simpan) kita bisa mengakses state form, termasuk memanggil `validate()` atau `reset()`.
- `validator` adalah fungsi di tiap `TextFormField` yang mengembalikan `String?`: pesan error kalau input salah, `null` kalau valid.
- `validate()` dipanggil saat Simpan ditekan; ia menjalankan semua validator, menampilkan pesan error di kolom yang bermasalah, dan mengembalikan `true` hanya jika semuanya lolos. Hanya kalau `true`, `AlertDialog` ringkasan ditampilkan.

Contoh nilai yang ditolak: nama institusi `"   "` (cuma spasi), atau tanggal selesai yang lebih awal dari tanggal mulai, atau tautan `"abc"` yang bukan URL. Jenis input/keyboard saja tidak cukup karena itu hanya mengatur *tampilan* papan ketik, bukan isi yang dimasukkan: `keyboardType: TextInputType.url` tetap membolehkan pengguna mengetik `"abc"`, atau menempelkan teks (paste) dan input dari keyboard fisik di Chrome yang sama sekali tidak dibatasi. Validasi di `validator` adalah penjaga terakhir yang memastikan data benar-benar sesuai aturan.

---

### Penggunaan AI (Tugas 8)

Saya memakai Claude Code sebagai asisten untuk membantu menyusun halaman `ExperienceFormPage`, validasi, navigasi drawer/kartu, dan tes widget. Seluruh kode saya tinjau, jalankan (`flutter analyze` dan `flutter test`), dan pahami sebelum dikumpulkan; jawaban reflektif di atas saya sesuaikan dengan implementasi di proyek ini.

---

### Assignment 9
1. Mengapa kita menggunakan `@JsonSerializable(fieldRename: FieldRename.snake)` dan `@JsonKey(includeToJson: false)` alih-alih mengirim objek `Map<String, dynamic>` mentah langsung dari widget? Jelaskan satu bug yang dicegah atau dapat dicegah oleh pendekatan ini pada model bagianmu.
2. Mengapa `Future` yang diteruskan ke `FutureBuilder` harus diinisialisasi di dalam `initState()` alih-alih langsung di dalam `build()`, dan mengapa `ApiClient` sebaiknya melempar `ApiException` daripada mengembalikan `null` pada respons HTTP non-2xx?
3. Bandingkan `SessionAuthentication` milik Django (dari Tutorial 04/07) dengan `TokenAuthentication` milik DRF (dari Tutorial 10). Mengapa myportfolio_mobile menggunakan `TokenAuthentication` sementara `SessionAuthentication` tetap diaktifkan pada backend Django?
4. Jelaskan peran job `build` (`very_good_workflows`) dan `build_apk` dalam pipeline `.github/workflows/main.yaml` milikmu (termasuk pemeriksaan apa saja yang dijalankan `very_good_workflows` di balik layar). Mengapa berkas `*.g.dart` dimasukkan ke `.gitignore` meskipun CI membutuhkannya untuk menganalisis dan membangun aplikasi?

---

### Jawaban

**1. `@JsonSerializable` vs `Map` mentah**

Dengan model, kontrak JSON ditulis **satu kali** di `lib/models/experience.dart` dan diperiksa compiler. Widget cukup mengisi properti bertipe (`DateTime`, `ExperienceCategory`), sedangkan `toJson()` hasil generate yang mengurus nama key dan format nilai. `FieldRename.snake` memetakan `startedAt` menjadi `started_at` sesuai serializer DRF, dan `@JsonEnum(fieldRename: FieldRename.kebab)` memetakan `partTime` menjadi `part-time` sesuai `choices` Django. `@JsonKey(includeToJson: false)` pada `id` dan field *read-only* lain (`star_count`, `comments`, `is_ongoing`, dst.) membuat body request hanya berisi data yang memang boleh ditulis klien.

Bug yang dicegah: kalau widget mengirim `Map` mentah lalu salah mengetik key `'startedAt'`, DRF **mengabaikan key yang tidak dikenal**. Karena `started_at` bersifat `required=False`, server tetap menjawab `201 Created` dan mengisi tanggal mulai dengan waktu saat ini. Tidak ada error sama sekali, tetapi datanya salah. Dengan model, nama key dibuat otomatis, dan salah ketik nama properti langsung gagal saat kompilasi.

Anotasi juga menangani perbedaan halus antara dua tanggal:

- `started_at` memakai `includeIfNull: false`, karena serializer menolak `started_at: null` dengan `400`.
- `ended_at` justru tetap dikirim saat `null`, supaya `PATCH` bisa mengubah entri menjadi "masih berlangsung". Kalau key-nya dihilangkan, tanggal selesai lama tetap tersimpan.

`id` sendiri sebenarnya sudah diabaikan DRF karena masuk `read_only_fields`. `includeToJson: false` menegaskan kontrak itu di sisi klien, sehingga tidak bergantung pada perilaku server.

**2. `Future` di `initState()` dan `ApiException`**

`build()` bisa dipanggil berkali-kali: keyboard muncul, ukuran layar berubah, tema berganti, atau `setState()`. Kalau `getExperiences()` dipanggil langsung di dalam `build()`, setiap rebuild membuat `Future` baru. Akibatnya request GET terkirim berulang, `FutureBuilder` kembali ke status *waiting*, dan data yang tampil bisa berkedip atau berganti tanpa diminta. `initState()` hanya berjalan sekali per `State`, jadi `Future`-nya stabil. `Future` baru hanya dibuat secara sengaja di `_reload()` untuk *pull-to-refresh*, Retry, atau setelah ada perubahan data. Perilaku ini diuji oleh tes "rebuild tidak mengulang permintaan GET".

Mengembalikan `null` menghilangkan informasi: `400` (input salah), `401` (token tidak berlaku), `403` (tidak punya izin), dan `500` (server rusak) terlihat sama, bahkan bisa tertukar dengan "data kosong". `ApiException` membawa `statusCode` dan isi respons, sehingga:

- `FutureBuilder` otomatis masuk ke `snapshot.hasError` dan menampilkan tombol Retry;
- `401` menghapus sesi dan membuka login, sedangkan error lain cukup ditampilkan di SnackBar;
- pesan validasi DRF seperti `ended_at: End date must be on or after the start date.` bisa sampai ke pengguna;
- kasus gagal tidak bisa diam-diam dianggap normal hanya karena pemanggil lupa memeriksa `null`.

**3. `SessionAuthentication` vs `TokenAuthentication`**

| Aspek | `SessionAuthentication` | `TokenAuthentication` |
| :-- | :-- | :-- |
| Kredensial | cookie `sessionid` | header `Authorization: Token <key>` |
| Pengiriman | otomatis oleh browser | ditambahkan klien secara eksplisit |
| CSRF | wajib untuk request tulis | tidak diperlukan |
| Penyimpanan server | tabel session | tabel `authtoken_token` |
| Masa berlaku | kedaluwarsa (`SESSION_COOKIE_AGE`) | tidak kedaluwarsa sampai dihapus |
| Klien yang cocok | halaman web Django | aplikasi mobile, skrip, layanan lain |

Aplikasi mobile bukan browser: tidak ada pengelolaan cookie dan token CSRF bawaan. Dengan token, `ApiClient` cukup menambahkan satu header pada request tulis. Karena header itu tidak dikirim otomatis, situs jahat tidak bisa menumpang kredensial pengguna (serangan CSRF). Token juga mudah dicabut: logout memanggil `/api/v1/auth/logout/` yang menghapus token di server.

`SessionAuthentication` tetap aktif karena halaman web Django (termasuk request AJAX-nya) dan *browsable API* DRF login memakai cookie. Menghapusnya akan merusak versi web. DRF mencoba kelas autentikasi secara berurutan, jadi kedua jenis klien dilayani endpoint yang sama. Urutannya juga penting: karena `TokenAuthentication` ditulis pertama, request tanpa kredensial atau dengan token tidak valid dibalas `401` (bukan `403`), dan itulah yang ditangani aplikasi.

Keterbatasannya: token bawaan DRF tidak punya masa berlaku, sehingga di produksi wajib lewat HTTPS. Aplikasi ini juga hanya menyimpan token di memori.

**4. Pipeline CI/CD dan `*.g.dart`**

Job **`build`** memanggil *reusable workflow* `very_good_workflows/flutter_package.yml@v2`, yang di balik layar menjalankan:

1. checkout repositori dan memasang Flutter 3.47.9 (dengan cache);
2. memasang `very_good_cli`, lalu `very_good packages get --recursive`;
3. perintah `setup`, yaitu `build_runner`;
4. `dart format --set-exit-if-changed lib test`;
5. `flutter analyze lib test` dengan aturan `very_good_analysis`;
6. `very_good test` dengan urutan acak, *test optimization*, coverage tanpa `*.g.dart`, dan gagal bila di bawah 85%.

(`bloc lint` dan *cognitive complexity* tersedia, tetapi tidak diaktifkan.)

Job **`build_apk`** memiliki `needs: build`, jadi hanya berjalan setelah semua pemeriksaan lulus. Job ini membangun APK release dengan `--dart-define=API_BASE_URL=...`, lalu mengunggahnya sebagai artefak `app-release-apk`. Singkatnya, `build` adalah gerbang kualitas dan `build_apk` adalah tahap *delivery*.

`*.g.dart` diabaikan Git karena merupakan **hasil turunan** dari model: bisa dibuat ulang kapan saja, hanya menambah *noise* dan *merge conflict*, serta bisa basi bila model berubah tetapi berkas generate lupa diperbarui. CI tetap mendapatkannya karena menjalankan `build_runner` sendiri. Perintah itu muncul dua kali (di `setup` milik `build` dan sebagai step di `build_apk`) karena tiap job berjalan di runner baru yang tidak berbagi berkas. Di `analysis_options.yaml` berkas tersebut juga dikecualikan agar analyzer tidak menilai kode yang tidak ditulis manual.

---

### AI Disclosure (Assignment 9)

**Alat:** Claude Code (model Claude Sonnet 5.5).

**Strategi prompting:** satu instruksi berbasis dokumen. Saya meminta Claude Code membaca spesifikasi tugas, mempelajari repositori Flutter ini dan repositori backend DRF terlebih dahulu, bekerja di branch `feat/tugas-9` tanpa melakukan commit, menargetkan nilai rubrik tertinggi, dan menjawab pertanyaan reflektif dengan format jawaban sebelumnya.

**Bagian yang dibantu:** hampir seluruh pekerjaan Assignment 9, yaitu model `Experience`, `ApiClient` dan penanganan error, layar daftar/detail/formulir, fitur edit dan hapus, penyesuaian lint, tes, workflow CI, serta README ini termasuk draf jawaban reflektif. Lewat instruksi lanjutan, Claude Code juga mendesain ulang UI/UX agar mirip Gojek dengan design system yang sudah ada dan merapikan komentar kode.

**Verifikasi di mesin lokal (dijalankan oleh Claude Code):** `dart format`, `flutter analyze`, 60 tes, build APK release, dan skrip *end-to-end* sementara yang menjalankan `ApiClient` terhadap server Django asli dengan database terpisah (mencakup operasi sukses serta respons `400`, `401`, `403`, `404`).

**Keterbatasan AI yang ditemukan dan perbaikannya** (terjadi dan diperbaiki dalam sesi pengerjaan):

| Masalah | Cara ketahuan | Perbaikan |
| :-- | :-- | :-- |
| `dart fix --apply` mengubah konstruktor ke sintaks `new(...)` yang tidak diinginkan dan meninggalkan *syntax error* saat menghapus `unawaited` | `flutter analyze` | konstruktor dikembalikan, kode diperbaiki, aturan lint terkait dimatikan dengan alasan tertulis |
| Spinner tombol Simpan terus berputar di balik dialog sukses dan layar login | widget test gagal karena `pumpAndSettle` *timeout* | `_isSubmitting` dimatikan sebelum membuka dialog atau login |
| Validasi tanggal berisiko menolak "hari ini" pada dini hari WIB (tanggal UTC dibandingkan dengan waktu lokal) | tinjauan kode saat refactor | tanggal dibandingkan per hari kalender |
| Tes mengasumsikan ada tombol kembali, padahal form dengan drawer menampilkan ikon menu | widget test gagal | skenario tes disesuaikan |

Catatan kritis: tes `MockClient` hanya meniru **asumsi** penulisnya tentang backend, sehingga tes hijau belum membuktikan integrasi benar. Karena itu kontrak API dibaca langsung dari serializer dan permission Django, lalu diuji ke server asli. Pengujian tersebut tidak mencakup interaksi UI di emulator atau perangkat fisik, sehingga skenario uji manual di atas tetap perlu dijalankan.
