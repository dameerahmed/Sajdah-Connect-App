import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:masjid_connect/l10n/app_localizations.dart';
import 'package:masjid_connect/core/theme/app_theme.dart';
import 'package:masjid_connect/features/masjid/data/masjid_repository.dart';
import 'dart:io';

class RegisterMasjidScreen extends ConsumerStatefulWidget {
  const RegisterMasjidScreen({super.key});
  @override
  ConsumerState<RegisterMasjidScreen> createState() => _RegisterMasjidScreenState();
}

class _RegisterMasjidScreenState extends ConsumerState<RegisterMasjidScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  
  String? _selectedMaslak;
  bool _isSubmitting = false;
  LatLng _selectedLocation = const LatLng(24.8607, 67.0011); // Default (Karachi)
  final List<File> _documents = [];
  final ImagePicker _picker = ImagePicker();

  final _maslaks = ['Sunni (Hanafi)', 'Sunni (Shafi\'i)', 'Deobandi', 'Barelvi', 'Ahle Hadith', 'Shia'];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: AppColors.primary, size: 20),
          onPressed: () => context.pop(),
        ),
        title: Image.asset('assets/images/premium_logo_final.png', height: 28),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Info Banner
              const _InfoBanner(text: 'Approval ke baad aapka masjid map par live ho jayegi.'),
              const SizedBox(height: 32),

              // Basic Info Section
              const _SectionHeader(title: 'BASIC INFORMATION'),
              const SizedBox(height: 12),
              const _FieldLabel('Masjid ka Naam'),
              _FormField(
                hint: 'Jamia Masjid ...', 
                controller: _nameController,
                validator: (v) => v!.isEmpty ? 'Zaroori ha' : null
              ),
              const SizedBox(height: 20),
              const _FieldLabel('Maslak'),
              _MaslakDropdown(
                value: _selectedMaslak,
                items: _maslaks,
                onChanged: (v) => setState(() => _selectedMaslak = v),
              ),
              const SizedBox(height: 20),
              const _FieldLabel('Address'),
              _FormField(
                hint: 'Area, City...', 
                controller: _addressController,
                validator: (v) => v!.isEmpty ? 'Zaroori ha' : null
              ),

              const SizedBox(height: 40),
              // Map Selection Section
              const _SectionHeader(title: 'LOCATION (DRAG TO SET)'),
              const SizedBox(height: 12),
              _MapPicker(
                initialLocation: _selectedLocation,
                onLocationChanged: (loc) => setState(() => _selectedLocation = loc),
              ),
              const SizedBox(height: 8),
              Center(
                child: Text('Lat: ${_selectedLocation.latitude.toStringAsFixed(4)} · Lon: ${_selectedLocation.longitude.toStringAsFixed(4)}', 
                     style: TextStyle(fontSize: 11, color: Colors.white.withOpacity(0.3), fontWeight: FontWeight.w600, letterSpacing: 0.5)),
              ),

              const SizedBox(height: 40),
              // Documents Section
              const _SectionHeader(title: 'PROOF DOCUMENTS'),
              const SizedBox(height: 12),
              _DocumentPicker(
                files: _documents,
                onPick: _pickDocument,
                onRemove: (idx) => setState(() => _documents.removeAt(idx)),
              ),

              const SizedBox(height: 60),
              // Submit Button (Interactive Gold)
              SizedBox(
                width: double.infinity,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(color: AppColors.primary.withOpacity(0.15), blurRadius: 40, offset: const Offset(0, 10))
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                      elevation: 0,
                    ),
                    child: _isSubmitting
                        ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2))
                        : Text(l10n.registerMasjid.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 3.0)),
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  void _pickDocument() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() => _documents.add(File(image.path)));
    }
  }

  void _submit() async {
    if (!_formKey.currentState!.validate() || _selectedMaslak == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill all fields and select Maslak')));
      return;
    }
    
    setState(() => _isSubmitting = true);
    
    try {
      await ref.read(masjidRepoProvider).registerMasjid(
        name: _nameController.text,
        address: _addressController.text,
        latitude: _selectedLocation.latitude,
        longitude: _selectedLocation.longitude,
        maslak: _selectedMaslak!,
        fajr: '05:00 AM', // TODO: Add time pickers to UI
        dhuhr: '01:30 PM',
        asr: '04:45 PM',
        maghrib: '06:40 PM',
        isha: '08:15 PM',
        jummah: '01:30 PM',
        documents: _documents,
      );
      
      if (mounted) {
        setState(() => _isSubmitting = false);
        _showSuccess();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  void _showSuccess() {
    showDialog(context: context, builder: (_) => SuccessDialog(onDone: () => context.go('/profile')));
  }
}

// ── Custom Widgets ────────────────────────────────────────────────────────

class _MapPicker extends StatelessWidget {
  final LatLng initialLocation;
  final Function(LatLng) onLocationChanged;

  const _MapPicker({required this.initialLocation, required this.onLocationChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 240,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24), 
        border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.2)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(23),
        child: FlutterMap(
          options: MapOptions(
            initialCenter: initialLocation,
            initialZoom: 15,
            onPositionChanged: (pos, hasGesture) {
               if (hasGesture && pos.center != null) onLocationChanged(pos.center!);
            },
          ),
          children: [
            TileLayer(urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png'),
            MarkerLayer(
              markers: [
                Marker(point: initialLocation, child: const Icon(Icons.location_on_rounded, color: AppColors.primary, size: 48)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DocumentPicker extends StatelessWidget {
  final List<File> files;
  final VoidCallback onPick;
  final Function(int) onRemove;

  const _DocumentPicker({required this.files, required this.onPick, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (files.isNotEmpty)
          SizedBox(
            height: 110,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: files.length,
              itemBuilder: (context, i) => Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Stack(
                  children: [
                    ClipRRect(borderRadius: BorderRadius.circular(16), child: Image.file(files[i], width: 110, height: 110, fit: BoxFit.cover)),
                    Positioned(right: 6, top: 6, child: InkWell(onTap: () => onRemove(i), child: const CircleAvatar(radius: 14, backgroundColor: Colors.black, child: Icon(Icons.close, size: 16, color: Color(0xFFD4AF37))))),
                  ],
                ),
              ),
            ),
          ),
        const SizedBox(height: 16),
        InkWell(
          onTap: onPick,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 32),
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFF121212), 
              borderRadius: BorderRadius.circular(20), 
              border: Border.all(color: Colors.white.withOpacity(0.05), style: BorderStyle.solid),
            ),
            child: Column(children: [
              Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), shape: BoxShape.circle), child: const Icon(Icons.add_photo_alternate_rounded, color: AppColors.primary, size: 32)),
              const SizedBox(height: 12),
              Text('Documents (Proof) Select Karein', style: TextStyle(fontFamily: 'Inter', fontSize: 13, color: Colors.white.withOpacity(0.5), fontWeight: FontWeight.w600))
            ]),
          ),
        ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});
  @override
  Widget build(BuildContext context) => Text(title, style: const TextStyle(fontFamily: 'Inter', fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.primary, letterSpacing: 1.5));
}

class _InfoBanner extends StatelessWidget {
  final String text;
  const _InfoBanner({required this.text});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: const Color(0xFFD4AF37).withOpacity(0.05), 
      borderRadius: BorderRadius.circular(16), 
      border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.2))
    ),
    child: Row(children: [
      const Icon(Icons.info_rounded, color: Color(0xFFD4AF37), size: 20), 
      const SizedBox(width: 14), 
      Expanded(child: Text(text, style: TextStyle(fontFamily: 'Inter', fontSize: 12, color: Colors.white.withOpacity(0.7), height: 1.5, fontWeight: FontWeight.w500)))
    ]),
  );
}

class _FormField extends StatelessWidget {
  final String hint;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  const _FormField({required this.hint, this.controller, this.validator});
  @override
  Widget build(BuildContext context) => TextFormField(
    controller: controller, 
    validator: validator, 
    style: const TextStyle(fontFamily: 'Inter', fontSize: 14, color: Colors.white),
    decoration: InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.white.withOpacity(0.2)),
      filled: true,
      fillColor: const Color(0xFF121212),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFFD4AF37), width: 1.5)),
    ),
  );
}

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8, top: 4), 
    child: Text(text, style: TextStyle(fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white.withOpacity(0.6)))
  );
}

class _MaslakDropdown extends StatelessWidget {
  final String? value;
  final List<String> items;
  final Function(String?) onChanged;
  const _MaslakDropdown({this.value, required this.items, required this.onChanged});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 20),
    decoration: BoxDecoration(color: const Color(0xFF121212), borderRadius: BorderRadius.circular(16)),
    child: DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        value: value, 
        isExpanded: true,
        dropdownColor: const Color(0xFF121212),
        hint: Text('Maslak select karein', style: TextStyle(fontFamily: 'Inter', color: Colors.white.withOpacity(0.2), fontSize: 14)),
        items: items.map((m) => DropdownMenuItem(value: m, child: Text(m, style: const TextStyle(fontFamily: 'Inter', fontSize: 14, color: Colors.white)))).toList(),
        onChanged: onChanged,
        icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFFD4AF37)),
      ),
    ),
  );
}

class SuccessDialog extends StatelessWidget {
  final VoidCallback onDone;
  const SuccessDialog({super.key, required this.onDone});
  @override
  Widget build(BuildContext context) => AlertDialog(
    backgroundColor: const Color(0xFF0A0A0A),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(24), 
      side: BorderSide(color: const Color(0xFFD4AF37).withOpacity(0.3)),
    ),
    content: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: const Color(0xFFD4AF37).withOpacity(0.1), shape: BoxShape.circle),
          child: const Icon(Icons.check_circle_rounded, color: Color(0xFFD4AF37), size: 84),
        ),
        const SizedBox(height: 24),
        const Text('Request Submit Ho Gayi!', style: TextStyle(fontFamily: 'Inter', fontSize: 22, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: -0.5)),
        const SizedBox(height: 12),
        Text('Super Admin approval ke baad masjid live ho jayegi.', textAlign: TextAlign.center, style: TextStyle(fontFamily: 'Inter', fontSize: 14, color: Colors.white.withOpacity(0.5), height: 1.5)),
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity, 
          child: ElevatedButton(
            onPressed: onDone, 
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD4AF37), foregroundColor: Colors.black, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), padding: const EdgeInsets.symmetric(vertical: 16)), 
            child: const Text('MashAllah, OK', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15))
          )
        ),
      ],
    ),
  );
}
