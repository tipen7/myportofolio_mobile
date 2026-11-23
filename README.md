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
