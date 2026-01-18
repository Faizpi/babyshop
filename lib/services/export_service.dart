import 'dart:io';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/barang.dart';

class ExportService {
  static final ExportService instance = ExportService._internal();

  factory ExportService() => instance;

  ExportService._internal();

  /// Export barang list to CSV format
  Future<String?> exportToCSV(
    List<Barang> barangList,
    String warungNama,
  ) async {
    try {
      if (barangList.isEmpty) return null;

      final buffer = StringBuffer();

      // Header
      buffer.writeln(
        'Nama Barang,Stok,Harga,Stok Minimum,Satuan,Tanggal Dibuat,Terakhir Update',
      );

      // Data rows
      for (var barang in barangList) {
        final nama = _escapeCSV(barang.nama);
        final stok = barang.stok;
        final harga = barang.harga;
        final stokMin = barang.stokMinimum;
        final satuan = barang.satuan;
        final createdAt = _formatDate(barang.createdAt.toIso8601String());
        final updatedAt = _formatDate(barang.updatedAt.toIso8601String());

        buffer.writeln(
          '$nama,$stok,$harga,$stokMin,$satuan,$createdAt,$updatedAt',
        );
      }

      // Save to file
      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final fileName = 'stok_${_sanitizeFileName(warungNama)}_$timestamp.csv';
      final file = File('${directory.path}/$fileName');
      await file.writeAsString(buffer.toString());

      return file.path;
    } catch (e) {
      // ignore: avoid_print
      print('Error exporting to CSV: $e');
      return null;
    }
  }

  /// Export barang list to simple text format (more readable)
  Future<String?> exportToText(
    List<Barang> barangList,
    String warungNama,
  ) async {
    try {
      if (barangList.isEmpty) return null;

      final buffer = StringBuffer();
      final now = DateFormat(
        'dd MMMM yyyy, HH:mm',
        'id_ID',
      ).format(DateTime.now());
      final formatter = NumberFormat.currency(
        locale: 'id_ID',
        symbol: 'Rp ',
        decimalDigits: 0,
      );

      // Calculate stats
      int totalStok = 0;
      double totalNilai = 0;
      int stokMenipis = 0;
      for (var barang in barangList) {
        totalStok += barang.stok;
        totalNilai += barang.stok * barang.harga;
        if (barang.stok <= barang.stokMinimum) stokMenipis++;
      }

      // Header
      buffer.writeln('═══════════════════════════════════════════');
      buffer.writeln('📦 LAPORAN STOK BARANG');
      buffer.writeln('═══════════════════════════════════════════');
      buffer.writeln('Warung: $warungNama');
      buffer.writeln('Tanggal: $now');
      buffer.writeln('═══════════════════════════════════════════\n');

      // Summary
      buffer.writeln('📊 RINGKASAN:');
      buffer.writeln('   Total Jenis Barang: ${barangList.length}');
      buffer.writeln('   Total Stok: $totalStok item');
      buffer.writeln('   Stok Menipis: $stokMenipis barang');
      buffer.writeln('   Total Nilai: ${formatter.format(totalNilai)}');
      buffer.writeln('');
      buffer.writeln('───────────────────────────────────────────');

      for (var barang in barangList) {
        String stokIcon = barang.stok <= 0
            ? '❌'
            : (barang.stok <= barang.stokMinimum ? '⚠️' : '✅');

        buffer.writeln('');
        buffer.writeln('   $stokIcon ${barang.nama}');
        buffer.writeln(
          '      Stok: ${barang.stok} ${barang.satuan} ${barang.stok <= barang.stokMinimum ? "(MENIPIS!)" : ""}',
        );
        buffer.writeln('      Harga: ${formatter.format(barang.harga)}');
      }

      buffer.writeln('\n═══════════════════════════════════════════');
      buffer.writeln('Dibuat dengan ❤️ oleh Warungku App');
      buffer.writeln('═══════════════════════════════════════════');

      // Save to file
      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final fileName =
          'laporan_${_sanitizeFileName(warungNama)}_$timestamp.txt';
      final file = File('${directory.path}/$fileName');
      await file.writeAsString(buffer.toString());

      return file.path;
    } catch (e) {
      // ignore: avoid_print
      print('Error exporting to text: $e');
      return null;
    }
  }

  /// Share report directly via share dialog
  Future<void> shareReport(List<Barang> barangList, String warungNama) async {
    try {
      if (barangList.isEmpty) return;

      final formatter = NumberFormat.currency(
        locale: 'id_ID',
        symbol: 'Rp ',
        decimalDigits: 0,
      );

      // Calculate stats
      int totalStok = 0;
      double totalNilai = 0;
      for (var barang in barangList) {
        totalStok += barang.stok;
        totalNilai += barang.stok * barang.harga;
      }

      final buffer = StringBuffer();
      buffer.writeln('📦 STOK $warungNama');
      buffer.writeln('📅 ${DateFormat('dd/MM/yyyy').format(DateTime.now())}');
      buffer.writeln('');
      buffer.writeln('Total: ${barangList.length} barang');
      buffer.writeln('Nilai: ${formatter.format(totalNilai)}');
      buffer.writeln('');

      for (var barang in barangList) {
        String icon = barang.stok <= 0
            ? '❌'
            : (barang.stok <= barang.stokMinimum ? '⚠️' : '✅');
        buffer.writeln('$icon ${barang.nama}: ${barang.stok} ${barang.satuan}');
      }

      await Share.share(buffer.toString(), subject: 'Stok $warungNama');
    } catch (e) {
      // ignore: avoid_print
      print('Error sharing report: $e');
    }
  }

  String _escapeCSV(String value) {
    if (value.contains(',') || value.contains('"') || value.contains('\n')) {
      return '"${value.replaceAll('"', '""')}"';
    }
    return value;
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return '';
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('dd/MM/yyyy HH:mm').format(date);
    } catch (e) {
      return dateStr;
    }
  }

  String _sanitizeFileName(String name) {
    return name
        .replaceAll(RegExp(r'[^\w\s-]'), '')
        .replaceAll(' ', '_')
        .toLowerCase();
  }
}
