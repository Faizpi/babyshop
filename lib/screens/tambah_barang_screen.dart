import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/providers.dart';
import '../widgets/widgets.dart';
import '../utils/formatters.dart';
import '../utils/app_theme.dart';
import '../services/image_service.dart';

class TambahBarangScreen extends StatefulWidget {
  final String warungId;
  final String? initialPhotoPath;

  const TambahBarangScreen({
    super.key,
    required this.warungId,
    this.initialPhotoPath,
  });

  @override
  State<TambahBarangScreen> createState() => _TambahBarangScreenState();
}

class _TambahBarangScreenState extends State<TambahBarangScreen> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _hargaController = TextEditingController();
  final _stokController = TextEditingController(text: '0');
  final _stokMinController = TextEditingController(text: '5');

  String? _photoPath;
  String? _selectedKategoriId;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _photoPath = widget.initialPhotoPath;

    // Show photo source picker if no initial photo
    if (_photoPath == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showPhotoSourcePicker();
      });
    }
  }

  @override
  void dispose() {
    _namaController.dispose();
    _hargaController.dispose();
    _stokController.dispose();
    _stokMinController.dispose();
    super.dispose();
  }

  Future<void> _showPhotoSourcePicker() async {
    final result = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Pilih Sumber Foto',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Ambil foto baru atau pilih dari galeri',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: _PhotoSourceButton(
                      icon: Icons.camera_alt_rounded,
                      label: 'Kamera',
                      onTap: () => Navigator.pop(context, 'camera'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _PhotoSourceButton(
                      icon: Icons.photo_library_rounded,
                      label: 'Galeri',
                      onTap: () => Navigator.pop(context, 'gallery'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => Navigator.pop(context, 'cancel'),
                child: const Text('Batal'),
              ),
            ],
          ),
        ),
      ),
    );

    if (result == 'camera') {
      await _takePhoto();
    } else if (result == 'gallery') {
      await _pickFromGallery();
    } else if (mounted && _photoPath == null) {
      // User cancelled and no photo, go back
      Navigator.pop(context);
    }
  }

  Future<void> _takePhoto() async {
    final path = await ImageService.instance.takePhoto();
    if (path != null && mounted) {
      setState(() => _photoPath = path);
    }
  }

  Future<void> _pickFromGallery() async {
    final path = await ImageService.instance.pickFromGallery();
    if (path != null && mounted) {
      setState(() => _photoPath = path);
    }
  }

  Future<void> _saveBarang() async {
    if (!_formKey.currentState!.validate()) return;
    if (_photoPath == null || _photoPath!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Foto barang wajib diisi ya!'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    if (_selectedKategoriId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih kategori dulu ya!'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final barangProvider = context.read<BarangProvider>();
      final harga = CurrencyFormatter.parse(_hargaController.text) ?? 0;
      final stok = int.tryParse(_stokController.text) ?? 0;
      final stokMin = int.tryParse(_stokMinController.text) ?? 5;

      final success = await barangProvider.addBarang(
        warungId: widget.warungId,
        kategoriId: _selectedKategoriId!,
        nama: _namaController.text.trim(),
        fotoPath: _photoPath!,
        stok: stok,
        stokMinimum: stokMin,
        harga: harga,
      );

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Barang berhasil ditambahkan!'),
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menyimpan: $e'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Barang'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Photo picker
              Center(
                child: PhotoPicker(
                  currentPhotoPath: _photoPath,
                  onPhotoPicked: (path) => setState(() => _photoPath = path),
                  size: 180,
                ),
              ).animate().fadeIn(duration: 400.ms),

              const SizedBox(height: 24),

              // Name field
              Text(
                'Nama Barang *',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _namaController,
                decoration: const InputDecoration(
                  hintText: 'Contoh: Susu SGM 400gr',
                  prefixIcon: Icon(Icons.label_outline),
                ),
                textCapitalization: TextCapitalization.words,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nama barang harus diisi';
                  }
                  return null;
                },
              ).animate().fadeIn(delay: 100.ms),

              const SizedBox(height: 20),

              // Category selector
              Text(
                'Kategori *',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Consumer<BarangProvider>(
                builder: (context, barangProvider, child) {
                  return KategoriSelector(
                    kategoriList: barangProvider.kategoriList,
                    selectedId: _selectedKategoriId,
                    onSelected: (id) =>
                        setState(() => _selectedKategoriId = id),
                  );
                },
              ).animate().fadeIn(delay: 200.ms),

              const SizedBox(height: 20),

              // Price field
              Text(
                'Harga',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _hargaController,
                decoration: const InputDecoration(
                  hintText: '0',
                  prefixIcon: Icon(Icons.payments_outlined),
                  prefixText: 'Rp ',
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  _ThousandsSeparatorFormatter(),
                ],
              ).animate().fadeIn(delay: 300.ms),

              const SizedBox(height: 20),

              // Stock fields
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Stok Awal',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _stokController,
                          decoration: const InputDecoration(
                            hintText: '0',
                            prefixIcon: Icon(Icons.inventory_2_outlined),
                          ),
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Stok Minimum',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _stokMinController,
                          decoration: const InputDecoration(
                            hintText: '5',
                            prefixIcon: Icon(Icons.warning_amber_outlined),
                          ),
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ).animate().fadeIn(delay: 400.ms),

              const SizedBox(height: 8),
              Text(
                '💡 Kamu akan mendapat notifikasi jika stok kurang dari stok minimum',
                style: theme.textTheme.bodySmall,
              ),

              const SizedBox(height: 32),

              // Save button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _saveBarang,
                  icon: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.save),
                  label: Text(_isLoading ? 'Menyimpan...' : 'Simpan Barang'),
                ),
              ).animate().fadeIn(delay: 500.ms),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

class _ThousandsSeparatorFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    final number = int.tryParse(newValue.text.replaceAll('.', ''));
    if (number == null) {
      return oldValue;
    }

    final formatted = CurrencyFormatter.formatNumber(number);

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

class _PhotoSourceButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _PhotoSourceButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 24),
          decoration: BoxDecoration(
            color: AppTheme.primaryPink.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppTheme.primaryPink.withValues(alpha: 0.3),
            ),
          ),
          child: Column(
            children: [
              Icon(icon, size: 40, color: AppTheme.primaryPink),
              const SizedBox(height: 8),
              Text(
                label,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primaryPink,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
