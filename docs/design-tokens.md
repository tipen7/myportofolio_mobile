# Design Tokens (Gojek-inspired)

Diadaptasi dari `static/css/tokens.css` pada proyek web `myportofolio`.
Kode: `lib/theme/app_tokens.dart` (token) dan `lib/theme/app_theme.dart` (ThemeData).

## Arsitektur 3 lapis

| Lapisan   | Kelas                                  | Dipakai di UI?            |
| --------- | -------------------------------------- | ------------------------- |
| Primitive | `AppPalette` (green50–900, ink0–950, …) | Hanya oleh lapisan semantic / aksen dekoratif |
| Semantic  | `AppSemantic` (`context.tokens`)        | Ya. Berbeda untuk light & dark |
| Scale     | `AppSpace`, `AppRadius`, `AppMotion`, `AppType`, `AppLayout` | Ya |

Aturan: widget **tidak** menulis hex atau angka mentah. Contoh:
`context.tokens.actionSoft`, `AppSpace.s4`, `AppRadius.lgAll`.

## Semantic penting

| Token | Light | Dark | Peran |
| --- | --- | --- | --- |
| `brand` | green500 `#00AA13` | sama | Identitas, gradien hero |
| `action` | green700 `#00880F` | sama | Tombol utama (kontras AA dengan putih) |
| `actionSoft` / `actionText` | green50 / green700 | green 16% / green300 | Latar lembut & teks aksi |
| `surface` / `bg` | ink0 / ink50 | ink900 / ink950 | Kartu / latar halaman |
| `border` | ink200 | ink800 | Garis tipis kartu & input |
| `danger`, `warning*`, `info*` | merah, kuning, biru | disesuaikan | Status |

## Skala

- **Spacing** (basis 4px): `s1`=4, `s2`=8, `s3`=12, `s4`=16, `s5`=20, `s6`=24, `s8`=32 …
- **Radius**: xs 6, sm 8, md 12, lg 16, xl 24, pill 999. Tombol = pill (`StadiumBorder`), kartu = xl.
- **Motion**: fast 120ms, normal 220ms, slow 380ms; kurva `easeOut`, `spring`.
- **Tipografi**: Plus Jakarta Sans; xs 12 → 2xl 36; bobot 500/700/800.
- **Layout**: konten maks. 600px, target sentuh minimal 48px.

## Komponen yang di-theme (tanpa override per halaman)

AppBar, Card, Drawer, ListTile (selected = pill hijau lembut), Input (fokus hijau 2px),
Filled/Outlined/Text/Icon button, Switch, Dialog, SnackBar (gelap, floating), Tooltip,
dan transisi halaman.

## Interaksi

- `PressableScale`: kartu layanan mengecil saat disentuh, plus ripple & haptic.
- `AnimatedSwitcher` pada ringkasan aktivitas.
- Drawer menandai halaman aktif; memilih halaman yang sama hanya menutup drawer.
- Dark mode otomatis mengikuti sistem (`ThemeMode.system`).

## Menambah token baru

1. Tambah primitive di `AppPalette` bila perlu.
2. Tambah field di `AppSemantic` (+ nilai `light`, `dark`, dan `lerp`).
3. Pakai lewat `context.tokens.<nama>`; jangan memakai primitive langsung di widget.
