<div align="center">
  <img src="assets/images/logoamara.png" alt="Warung Amara Logo" width="150"/>
  
  # 🍼 Warung Amara
  
  **Aplikasi Manajemen Inventaris Toko Perlengkapan Bayi**
  
  [![Flutter](https://img.shields.io/badge/Flutter-3.9.2-02569B?logo=flutter)](https://flutter.dev)
  [![Dart](https://img.shields.io/badge/Dart-3.9-0175C2?logo=dart)](https://dart.dev)
  [![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
  [![Platform](https://img.shields.io/badge/Platform-Android-3DDC84?logo=android)](https://android.com)
</div>

---

## 📖 Tentang Aplikasi

**Warung Amara** adalah aplikasi Flutter offline-first yang dirancang khusus untuk membantu pemilik toko perlengkapan bayi dalam mengelola inventaris stok. Aplikasi ini mendukung manajemen multi-warung, sehingga cocok untuk pemilik yang memiliki lebih dari satu toko.

### ✨ Fitur Utama

| Fitur | Deskripsi |
|-------|-----------|
| 📦 **Manajemen Barang** | Tambah, edit, hapus produk dengan foto dari kamera atau galeri |
| 🏪 **Multi-Warung** | Kelola beberapa toko dalam satu aplikasi |
| 📊 **Dashboard** | Lihat statistik stok, barang hampir habis, dan ringkasan warung |
| 📝 **Riwayat Transaksi** | Catat semua perubahan stok masuk dan keluar |
| 🔍 **Pencarian & Filter** | Cari barang berdasarkan nama atau filter berdasarkan kategori |
| 🌙 **Dark Mode** | Tema gelap untuk kenyamanan mata |
| 💾 **Offline-First** | Data tersimpan lokal, tidak butuh internet |
| 📤 **Export Data** | Bagikan data inventaris dalam format teks |

### 🏷️ Kategori Produk

Aplikasi mendukung berbagai kategori perlengkapan bayi:

- 👶 Pakaian Bayi
- 🍼 Susu & Makanan
- 🧴 Perawatan & Kesehatan
- 🧸 Mainan
- 🛏️ Perlengkapan Tidur
- 🚗 Perlengkapan Jalan
- 🧹 Kebersihan
- 📦 Lainnya

---

## 🛠️ Teknologi

| Teknologi | Kegunaan |
|-----------|----------|
| **Flutter** | Framework UI cross-platform |
| **Provider** | State management |
| **SQLite (sqflite)** | Database lokal |
| **Image Picker** | Ambil foto dari kamera/galeri |
| **Google Fonts** | Tipografi (Poppins) |
| **Flutter Animate** | Animasi smooth |
| **Intl** | Format tanggal & mata uang Indonesia |

---

## 📁 Struktur Proyek

```
lib/
├── main.dart                 # Entry point aplikasi
├── models/                   # Data models
│   ├── barang.dart          # Model produk/barang
│   ├── kategori.dart        # Model kategori
│   ├── riwayat.dart         # Model riwayat transaksi
│   ├── user.dart            # Model pengguna
│   └── warung.dart          # Model warung/toko
├── providers/               # State management
│   ├── barang_provider.dart
│   ├── riwayat_provider.dart
│   ├── theme_provider.dart
│   ├── user_provider.dart
│   └── warung_provider.dart
├── screens/                 # Halaman UI
│   ├── splash_screen.dart   # Splash & onboarding
│   ├── home_screen.dart     # Dashboard utama
│   ├── tambah_barang_screen.dart
│   ├── detail_barang_screen.dart
│   ├── barang_list_screen.dart
│   ├── riwayat_screen.dart
│   └── settings_screen.dart
├── services/                # Business logic
│   ├── database_helper.dart # SQLite operations
│   ├── image_service.dart   # Image handling
│   ├── export_service.dart  # Data export
│   └── notification_service.dart
├── utils/                   # Utilities
│   ├── app_theme.dart       # Tema aplikasi
│   ├── app_icons.dart       # Icon definitions
│   └── formatters.dart      # Format currency & date
└── widgets/                 # Reusable widgets
    ├── barang_card.dart
    ├── stats_card.dart
    ├── warung_switcher.dart
    ├── kategori_chips.dart
    ├── search_bar_widget.dart
    └── empty_state.dart
```

---

## 🚀 Instalasi & Menjalankan

### Prasyarat
- Flutter SDK >= 3.9.2
- Dart >= 3.9
- Android Studio / VS Code
- Android Emulator atau device fisik

### Langkah Instalasi

```bash
# 1. Clone repository
git clone https://github.com/Faizpi/babyshop.git

# 2. Masuk ke direktori proyek
cd babyshop

# 3. Install dependencies
flutter pub get

# 4. Jalankan aplikasi
flutter run
```

### Build APK Release

```bash
flutter build apk --release
```

APK akan tersedia di `build/app/outputs/flutter-apk/app-release.apk`

---

## 📱 Screenshot

| Splash Screen | Dashboard | Tambah Barang |
|---------------|-----------|---------------|
| Onboarding dengan input nama & warung | Statistik stok dan daftar barang | Form input dengan photo picker |

| Detail Barang | Riwayat | Pengaturan |
|---------------|---------|------------|
| Info lengkap & manajemen stok | Histori transaksi masuk/keluar | Theme toggle & tentang aplikasi |

---

## 📄 Lisensi

Proyek ini dibuat untuk keperluan pembelajaran dan manajemen inventaris toko perlengkapan bayi.

---

## 👨‍💻 Developer

Dibuat dengan ❤️ menggunakan Flutter

---

<div align="center">
  <b>Warung Amara</b> - Kelola Stok Lebih Mudah!
</div>
