# Sparein Mobile

Aplikasi mobile Flutter untuk **Sparein** — panduan perbaikan barang dan direktori suku cadang untuk menekan limbah elektronik. Proyek Akhir Semester PBP Gasal 2026/2027, **Kelompok 1**.

> Status: kerangka awal (Checkpoint 1). Bagian bertanda `TODO` wajib dilengkapi sebelum tenggat.

## Anggota Kelompok

| Nama | NPM | GitHub | Modul |
| ---- | --- | ------ | ----- |
| TODO | TODO | [@hannazerlina](https://github.com/hannazerlina) | TODO |
| TODO | TODO | [@Kiara996](https://github.com/Kiara996) | TODO |
| TODO | TODO | [@msystemctrl](https://github.com/msystemctrl) | TODO |
| TODO | TODO | [@muhamadayrazhan](https://github.com/muhamadayrazhan) | TODO |
| TODO | TODO | [@zidanristek](https://github.com/zidanristek) | TODO |

## Deskripsi Aplikasi

**Sparein** — TODO: fungsi aplikasi (samakan dengan situs web PTS).

## Modul dan Pembagian Kerja

| Modul | Penanggung jawab | Endpoint Django REST Framework |
| ----- | ---------------- | ------------------------------ |
| Devices | TODO | TODO |
| Diagnostics | TODO | TODO |
| Guides | TODO | TODO |
| Journal | TODO | TODO |
| Parts | TODO | TODO |

> Kandidat modul diambil dari app Django `sparein` (`devices`, `diagnostics`, `guides`, `journal`, `parts`). Finalisasi scoping saat Checkpoint 1.

## Peran / Aktor Pengguna

TODO

## Alur Integrasi Data (Flutter ⇄ Django)

Data tetap disimpan di situs web Django PTS ([Kelompok1-PBP/sparein](https://github.com/Kelompok1-PBP/sparein)). Aplikasi Flutter tidak memakai data statis: ia memanggil endpoint **Django REST Framework** secara asinkron, mengolah respons JSON, lalu menampilkannya.

```
Flutter (lib/modules/*) --HTTP/JSON--> Django REST Framework (PWS) --> Database
```

Base URL diatur di [`lib/core/config/api_config.dart`](lib/core/config/api_config.dart) dan bisa di-override lewat `--dart-define=API_BASE_URL=...`.

TODO: jelaskan alur autentikasi dan contoh request/response.

## Desain

- Figma: TODO

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
