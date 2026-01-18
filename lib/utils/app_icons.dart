import 'package:flutter/material.dart';
import '../models/riwayat.dart';

/// Custom icons untuk aplikasi Warungku
/// Menggantikan emoji dengan Material Icons yang konsisten
class AppIcons {
  AppIcons._();

  // Pink color untuk konsistensi
  static const Color primaryPink = Color(0xFFE91E8C);

  // Navigation & Actions
  static const IconData home = Icons.home_rounded;
  static const IconData store = Icons.storefront_rounded;
  static const IconData inventory = Icons.inventory_2_rounded;
  static const IconData history = Icons.history_rounded;
  static const IconData settings = Icons.settings_rounded;
  static const IconData add = Icons.add_rounded;
  static const IconData remove = Icons.remove_rounded;
  static const IconData edit = Icons.edit_rounded;
  static const IconData delete = Icons.delete_rounded;
  static const IconData camera = Icons.camera_alt_rounded;
  static const IconData photo = Icons.photo_rounded;
  static const IconData search = Icons.search_rounded;
  static const IconData filter = Icons.filter_list_rounded;
  static const IconData sort = Icons.sort_rounded;
  static const IconData share = Icons.share_rounded;
  static const IconData download = Icons.download_rounded;

  // Stats & Info
  static const IconData package = Icons.inventory_2_rounded;
  static const IconData tag = Icons.local_offer_rounded;
  static const IconData warning = Icons.warning_amber_rounded;
  static const IconData money = Icons.attach_money_rounded;
  static const IconData info = Icons.info_rounded;
  static const IconData check = Icons.check_circle_rounded;
  static const IconData error = Icons.error_rounded;
  static const IconData empty = Icons.inbox_rounded;

  // Categories
  static const IconData babyBottle = Icons.baby_changing_station_rounded;
  static const IconData diaper = Icons.child_friendly_rounded;
  static const IconData food = Icons.restaurant_rounded;
  static const IconData soap = Icons.sanitizer_rounded;
  static const IconData clothes = Icons.checkroom_rounded;
  static const IconData toy = Icons.toys_rounded;
  static const IconData shopping = Icons.shopping_cart_rounded;
  static const IconData other = Icons.category_rounded;
  static const IconData all = Icons.apps_rounded;

  // Stock Status
  static const IconData stockOk = Icons.check_circle_rounded;
  static const IconData stockLow = Icons.warning_amber_rounded;
  static const IconData stockOut = Icons.error_rounded;

  // Time & Date
  static const IconData calendar = Icons.calendar_today_rounded;
  static const IconData clock = Icons.access_time_rounded;
  static const IconData morning = Icons.wb_sunny_rounded;
  static const IconData afternoon = Icons.wb_cloudy_rounded;
  static const IconData evening = Icons.wb_twilight_rounded;
  static const IconData night = Icons.nightlight_round;

  // User & Auth
  static const IconData person = Icons.person_rounded;
  static const IconData wave = Icons.waving_hand_rounded;

  // Transaction types
  static const IconData stockIn = Icons.add_circle_rounded;
  static const IconData stockOut2 = Icons.remove_circle_rounded;
  static const IconData adjustment = Icons.tune_rounded;
  static const IconData transfer = Icons.swap_horiz_rounded;

  // Theme
  static const IconData lightMode = Icons.light_mode_rounded;
  static const IconData darkMode = Icons.dark_mode_rounded;
  static const IconData autoMode = Icons.brightness_auto_rounded;

  // Misc
  static const IconData notification = Icons.notifications_rounded;
  static const IconData help = Icons.help_rounded;
  static const IconData about = Icons.info_outline_rounded;
  static const IconData arrowDown = Icons.keyboard_arrow_down_rounded;
  static const IconData arrowRight = Icons.arrow_forward_ios_rounded;

  /// Get icon for kategori based on icon name
  static IconData getKategoriIcon(String? iconName) {
    switch (iconName) {
      case 'baby_bottle':
        return babyBottle;
      case 'diaper':
        return diaper;
      case 'food':
        return food;
      case 'soap':
        return soap;
      case 'clothes':
        return clothes;
      case 'toy':
        return toy;
      case 'baby_items':
        return shopping;
      case 'other':
        return other;
      default:
        return package;
    }
  }

  /// Get icon for warung based on name
  static IconData getWarungIcon(String nama) {
    final lowerNama = nama.toLowerCase();
    if (lowerNama.contains('baby') || lowerNama.contains('bayi'))
      return Icons.child_friendly_rounded;
    if (lowerNama.contains('susu') || lowerNama.contains('milk'))
      return babyBottle;
    if (lowerNama.contains('popok') || lowerNama.contains('diaper'))
      return diaper;
    if (lowerNama.contains('mainan') || lowerNama.contains('toy')) return toy;
    return store;
  }

  /// Get icon for transaction type
  static IconData getRiwayatIcon(TipeRiwayat tipe) {
    switch (tipe) {
      case TipeRiwayat.tambahStok:
        return stockIn;
      case TipeRiwayat.kurangStok:
        return stockOut2;
      case TipeRiwayat.editHarga:
        return money;
      case TipeRiwayat.editBarang:
        return edit;
      case TipeRiwayat.tambahBarang:
        return add;
      case TipeRiwayat.hapusBarang:
        return delete;
      case TipeRiwayat.auditStok:
        return adjustment;
    }
  }
}
