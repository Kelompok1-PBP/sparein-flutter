<p align="center">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="docs/brand/sparein-lockup-dark.svg">
    <img src="docs/brand/sparein-lockup.svg" alt="Sparein" width="420">
  </picture>
</p>

<p align="center"><em>Repair first, discard last.</em></p>

<p align="center">
  <a href="../../actions/workflows/ci.yml"><img alt="CI" src="../../actions/workflows/ci.yml/badge.svg?branch=staging"></a>
  <a href="../../actions/workflows/release-apk.yml"><img alt="Release APK" src="../../actions/workflows/release-apk.yml/badge.svg"></a>
  <img alt="Flutter" src="https://img.shields.io/badge/Flutter-3.47-02569B">
  <img alt="Dart" src="https://img.shields.io/badge/Dart-3.13-0175C2">
</p>

---

Aplikasi mobile Flutter untuk **Sparein**, panduan perbaikan barang dan direktori suku cadang untuk menekan limbah elektronik. Proyek Akhir Semester PBP Gasal 2026/2027, **Kelompok 1**.

> Status: kerangka awal (Checkpoint 1). Bagian bertanda `TODO` wajib dilengkapi sebelum tenggat.

## Anggota Kelompok

| Nama | NPM | GitHub | Modul |
| ---- | --- | ------ | ----- |
| Muhammad Sultan Zidan | 2506534876 | [@zidanristek](https://github.com/zidanristek) | M1 Devices |
| Kevin Fauzan Arjuna | 2506612266 | [@Kiara996](https://github.com/Kiara996) | M2 Diagnostics |
| Hanna Zerlina Razaq Putri Wicaksono | 2506594692 | [@hannazerlina](https://github.com/hannazerlina) | M3 Guides |
| Muhamad Ayrazhan | 2506586236 | [@muhamadayrazhan](https://github.com/muhamadayrazhan) | M4 Parts |
| Marsya Rizka Aulia | 2506537606 | [@msystemctrl](https://github.com/msystemctrl) | M5 Journal |

## Deskripsi Aplikasi

**Sparein** adalah aplikasi panduan perbaikan barang dan direktori suku cadang untuk pengguna Indonesia. Alurnya: cari perangkat, diagnosa gejala, ikuti panduan, temukan suku cadang, catat hasilnya. Setiap perbaikan yang dicatat dihitung sebagai barang yang tidak jadi dibuang, lengkap dengan estimasi limbah dan biaya yang terhindar.

## Modul dan Pembagian Kerja

| Modul | Fungsi | Penanggung jawab | Endpoint Django REST Framework |
| ----- | ------ | ---------------- | ------------------------------ |
| M1 Devices | Katalog perangkat | Muhammad Sultan Zidan | `/api/v1/devices/` |
| M2 Diagnostics | Diagnosa gejala kerusakan | Kevin Fauzan Arjuna | `/api/v1/symptoms/`, `/api/v1/diagnose/` |
| M3 Guides | Panduan perbaikan | Hanna Zerlina Razaq Putri Wicaksono | `/api/v1/guides/` |
| M4 Parts | Direktori suku cadang | Muhamad Ayrazhan | `/api/v1/parts/` |
| M5 Journal | Jurnal perbaikan dan dampak | Marsya Rizka Aulia | `/api/v1/journal/`, `/api/v1/journal/summary/` |

## Peran / Aktor Pengguna

| Peran | Akses |
| ----- | ----- |
| **Visitor**, belum login | Cari perangkat, baca ringkasan panduan, lihat katalog suku cadang tanpa harga dan kontak penjual |
| **Member**, pengguna terdaftar | Hak Visitor, ditambah langkah panduan lengkap, harga dan kontak penjual, serta jurnal perbaikan pribadi |
| **Contributor**, member terverifikasi | Hak Member, ditambah menulis panduan dan mendaftarkan suku cadang |
| **Admin** | Moderasi konten dan verifikasi Contributor |

## Alur Integrasi Data (Flutter ⇄ Django)

Data tetap disimpan di situs web Django PTS ([Kelompok1-PBP/sparein](https://github.com/Kelompok1-PBP/sparein)). Aplikasi Flutter tidak memakai data statis: ia memanggil endpoint **Django REST Framework** secara asinkron, mengolah respons JSON, lalu menampilkannya.

```
Flutter (lib/modules/*) --HTTP/JSON--> Django REST Framework (PWS) --> Database
```

Base URL diatur di [`lib/core/config/api_config.dart`](lib/core/config/api_config.dart) dan bisa di-override lewat `--dart-define=API_BASE_URL=...`.

TODO: jelaskan alur autentikasi dan contoh request/response.

## Desain

- Figma: [SPAREIN UI/UX](https://www.figma.com/design/3CLBNpsD0kUO5lSkgITv2U/SPAREIN-UI-UX?node-id=0-1)

## Unduh APK

- GitHub Releases: TODO
- Bitrise: TODO

## Menjalankan Secara Lokal

Prasyarat: Flutter 3.47.9 (stable), Android SDK/emulator. Versi dikunci di CI, samakan dengan `flutter --version`.

```bash
flutter pub get
# Emulator Android -> Django di localhost komputer:
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8000
```

Cek kualitas sebelum push:

```bash
dart format .
flutter analyze
flutter test
```

## Struktur Proyek

```
lib/
  main.dart            # entry point
  core/                # dipakai bersama: config, network, widget umum
    config/
    network/
    widgets/
  modules/             # satu folder per modul, satu pemilik per modul
docs/                  # catatan teknis, wireframe
.github/               # CI, template PR/issue
```

Panduan kolaborasi: [CONTRIBUTING.md](CONTRIBUTING.md).
