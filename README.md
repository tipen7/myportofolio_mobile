### Information

Nama: Steven Dyanizha Ananda
NPM: 2506616112
Kelas: PBP A

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