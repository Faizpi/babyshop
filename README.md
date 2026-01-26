<div align="center">
  <img src="assets/images/logoamara.png" alt="Warung Amara Logo" width="180"/>
  
  # 🍼 Warung Amara
  
  ### **Aplikasi Manajemen Inventaris & POS Toko Perlengkapan Bayi**
  
  *Solusi lengkap untuk mengelola stok, penjualan, dan bisnis multi-warung Anda*
  
  [![Flutter](https://img.shields.io/badge/Flutter-3.9.2-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
  [![Dart](https://img.shields.io/badge/Dart-3.9-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev)
  [![Firebase](https://img.shields.io/badge/Firebase-Cloud-FFCA28?style=for-the-badge&logo=firebase&logoColor=black)](https://firebase.google.com)
  [![Platform](https://img.shields.io/badge/Platform-Android-3DDC84?style=for-the-badge&logo=android&logoColor=white)](https://android.com)
  
  <br/>
  
  [📥 Download APK](https://github.com/Faizpi/warungku/releases) • [🐛 Laporkan Bug](https://github.com/Faizpi/warungku/issues) • [✨ Minta Fitur](https://github.com/Faizpi/warungku/issues)

</div>

---

## 🌟 Mengapa Warung Amara?

**Warung Amara** adalah aplikasi Flutter yang dirancang khusus untuk pemilik toko perlengkapan bayi. Dengan pendekatan **offline-first** dan sinkronisasi cloud via **Firebase**, aplikasi ini memastikan bisnis Anda tetap berjalan lancar - dengan atau tanpa internet!

<div align="center">

| 🚀 Cepat | 🔒 Aman | ☁️ Cloud Sync | 📱 User-Friendly |
|:--------:|:-------:|:-------------:|:----------------:|
| Performa optimal dengan SQLite lokal | Data terenkripsi & backup otomatis | Pindah HP? Data ikut! | UI/UX modern & intuitif |

</div>

---

## ✨ Fitur Lengkap

### 📦 **Manajemen Inventaris**
| Fitur | Deskripsi |
|-------|-----------|
| ➕ **CRUD Barang** | Tambah, edit, hapus produk dengan mudah |
| 📸 **Photo Picker** | Ambil foto barang dari kamera atau galeri |
| 🏷️ **Kategori Fleksibel** | 8+ kategori produk perlengkapan bayi |
| 🔔 **Notifikasi Stok** | Peringatan otomatis saat stok menipis |
| 🔍 **Pencarian Cerdas** | Filter berdasarkan nama, kategori, atau warung |

### 💰 **Manajemen Penjualan**
| Fitur | Deskripsi |
|-------|-----------|
| 📝 **Catat Penjualan** | Input "Sisa stok berapa?" → otomatis hitung laku |
| 💵 **Kalkulasi Otomatis** | Total pendapatan dihitung secara real-time |
| ➕ **Tambah Stok** | Restok barang dengan catatan otomatis |
| 📊 **Riwayat Lengkap** | Histori semua transaksi masuk/keluar |

### 🏪 **Multi-Warung Support**
| Fitur | Deskripsi |
|-------|-----------|
| 🏬 **Banyak Toko** | Kelola beberapa warung dalam satu aplikasi |
| 🔄 **Switch Warung** | Pindah antar warung dengan sekali tap |
| 📈 **Dashboard Per-Warung** | Statistik terpisah untuk setiap toko |

### 🔐 **Autentikasi & Keamanan**
| Fitur | Deskripsi |
|-------|-----------|
| 📧 **Email & Password** | Login dengan email dan password |
| 📱 **Phone OTP** | Verifikasi via nomor telepon |
| 🔵 **Google Sign-In** | Login cepat dengan akun Google |
| 👤 **Profil Pengguna** | Kelola informasi akun Anda |

### ☁️ **Cloud Sync & Backup**
| Fitur | Deskripsi |
|-------|-----------|
| 🔄 **Offline-First** | Bekerja tanpa internet, sync saat online |
| ☁️ **Firebase Firestore** | Data tersimpan aman di cloud |
| 📲 **Ganti HP?** | Login di device baru, data otomatis tersinkron |
| 🔒 **Secure Rules** | Data hanya bisa diakses pemilik akun |

### 🎨 **UI/UX Modern**
| Fitur | Deskripsi |
|-------|-----------|
| 🌙 **Dark Mode** | Tema gelap untuk kenyamanan mata |
| ✨ **Animasi Smooth** | Transisi halus dengan Flutter Animate |
| 🎯 **Material Design 3** | Desain modern mengikuti standar terbaru |
| 📱 **Responsive** | Tampilan optimal di berbagai ukuran layar |

---

## 🏷️ Kategori Produk

<div align="center">

| 👶 Pakaian Bayi | 🍼 Susu & Makanan | 🧴 Perawatan | 🧸 Mainan |
|:---------------:|:-----------------:|:------------:|:---------:|
| 🛏️ **Perlengkapan Tidur** | 🚗 **Perlengkapan Jalan** | 🧹 **Kebersihan** | 📦 **Lainnya** |

</div>

---

## 🛠️ Tech Stack

<div align="center">

| Layer | Teknologi |
|:-----:|:---------:|
| **Frontend** | Flutter 3.9.2, Dart 3.9 |
| **State Management** | Provider |
| **Local Database** | SQLite (sqflite) |
| **Cloud Backend** | Firebase (Auth, Firestore) |
| **Authentication** | Email, Phone OTP, Google Sign-In |
| **Connectivity** | connectivity_plus |
| **UI/Animation** | Flutter Animate, Google Fonts |
| **Image Handling** | Image Picker, path_provider |

</div>

---

## 📁 Arsitektur Proyek

```
lib/
├── main.dart                    # Entry point + Firebase init
├── firebase_options.dart        # Firebase configuration
│
├── models/                      # 📋 Data Models
│   ├── barang.dart             # Model produk/barang
│   ├── kategori.dart           # Model kategori
│   ├── riwayat.dart            # Model riwayat transaksi
│   ├── user.dart               # Model pengguna (+ Firebase UID)
│   └── warung.dart             # Model warung/toko
│
├── providers/                   # 🔄 State Management
│   ├── auth_provider.dart      # Firebase Auth state
│   ├── sync_provider.dart      # Cloud sync state
│   ├── barang_provider.dart    # Product state
│   ├── riwayat_provider.dart   # Transaction history state
│   ├── theme_provider.dart     # Theme (dark/light) state
│   ├── user_provider.dart      # User session state
│   └── warung_provider.dart    # Multi-store state
│
├── screens/                     # 📱 UI Screens
│   ├── splash_screen.dart      # Splash + Onboarding
│   ├── login_screen.dart       # Login, Register, Phone OTP
│   ├── home_screen.dart        # Dashboard utama
│   ├── barang_list_screen.dart # Daftar produk
│   ├── detail_barang_screen.dart # Detail + Manajemen stok
│   ├── tambah_barang_screen.dart # Form tambah produk
│   ├── riwayat_screen.dart     # Riwayat transaksi
│   └── settings_screen.dart    # Pengaturan & profil
│
├── services/                    # ⚙️ Business Logic
│   ├── auth_service.dart       # Firebase Authentication
│   ├── firebase_sync_service.dart # Cloud sync operations
│   ├── connectivity_service.dart  # Internet monitoring
│   ├── database_helper.dart    # SQLite operations
│   ├── image_service.dart      # Image handling
│   ├── export_service.dart     # Data export
│   └── notification_service.dart # Local notifications
│
├── utils/                       # 🔧 Utilities
│   ├── app_theme.dart          # Tema & warna aplikasi
│   ├── app_icons.dart          # Custom icons
│   └── formatters.dart         # Format currency & date
│
└── widgets/                     # 🧩 Reusable Components
    ├── barang_card.dart        # Kartu produk
    ├── stats_card.dart         # Kartu statistik
    ├── warung_switcher.dart    # Pemilih warung
    ├── kategori_chips.dart     # Filter kategori
    ├── search_bar_widget.dart  # Search bar
    └── empty_state.dart        # Empty placeholder
```

---

## 🚀 Instalasi & Setup

### 📋 Prasyarat
- Flutter SDK >= 3.9.2
- Dart >= 3.9
- Android Studio / VS Code
- Firebase CLI (opsional, untuk konfigurasi sendiri)
- Android device atau emulator

### ⚡ Quick Start

```bash
# 1. Clone repository
git clone https://github.com/Faizpi/warungku.git

# 2. Masuk ke direktori proyek
cd warungku

# 3. Install dependencies
flutter pub get

# 4. Jalankan aplikasi
flutter run
```

### 🔥 Setup Firebase (Opsional - Untuk Development)

```bash
# Install FlutterFire CLI
dart pub global activate flutterfire_cli

# Login ke Firebase
firebase login

# Konfigurasi project
flutterfire configure
```

### 📦 Build APK Release

```bash
flutter build apk --release
```

APK tersedia di: `build/app/outputs/flutter-apk/app-release.apk`

---

## 📱 Screenshot

<div align="center">

| Splash Screen | Login | Dashboard |
|:-------------:|:-----:|:---------:|
| Branding & loading | Multi-method auth | Statistik real-time |

| Daftar Barang | Detail & Stok | Catat Penjualan |
|:-------------:|:-------------:|:---------------:|
| Grid view + filter | Info lengkap produk | Input sisa → hitung laku |

| Riwayat | Pengaturan | Multi-Warung |
|:-------:|:----------:|:------------:|
| Histori transaksi | Dark mode & profil | Switch antar toko |

</div>

---

## 🔮 Roadmap

- [x] Manajemen inventaris dasar
- [x] Multi-warung support
- [x] Dark mode
- [x] Firebase Authentication
- [x] Cloud sync (Firestore)
- [x] Offline-first architecture
- [x] Catat penjualan dengan input sisa stok
- [ ] Laporan penjualan bulanan
- [ ] Export ke Excel/PDF
- [ ] Barcode/QR scanner
- [ ] Notifikasi push
- [ ] Bahasa Inggris

---

## 🤝 Kontribusi

Kontribusi sangat diterima! Silakan:

1. Fork repository ini
2. Buat branch fitur (`git checkout -b feature/FiturBaru`)
3. Commit perubahan (`git commit -m 'Tambah fitur baru'`)
4. Push ke branch (`git push origin feature/FiturBaru`)
5. Buat Pull Request

---

## 📄 Lisensi

Proyek ini dilisensikan di bawah [MIT License](LICENSE).

---

## 👨‍💻 Developer

<div align="center">

Dibuat dengan ❤️ oleh **Faiz**

[![GitHub](https://img.shields.io/badge/GitHub-Faizpi-181717?style=for-the-badge&logo=github)](https://github.com/Faizpi)

</div>

---

<div align="center">
  
  ### 🍼 **Warung Amara**
  *Kelola Stok Lebih Mudah, Bisnis Lebih Untung!*
  
  ⭐ Star repo ini jika bermanfaat!
  
</div>
