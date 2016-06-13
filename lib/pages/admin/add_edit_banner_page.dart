import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../providers/banner_provider.dart';
import '../../data/models/banner_model.dart';

class AddEditBannerPage extends StatefulWidget {
  final BannerModel? banner; // Null means Add Mode

  const AddEditBannerPage({super.key, this.banner});

  @override
  State<AddEditBannerPage> createState() => _AddEditBannerPageState();
}

class _AddEditBannerPageState extends State<AddEditBannerPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  File? _selectedImage;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.banner?.name ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _saveBanner() async {
    if (!_formKey.currentState!.validate()) return;

    // Check if image is provided for new banners
    if (widget.banner == null && _selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an image')),
      );
      return;
    }

    final provider = Provider.of<BannerProvider>(context, listen: false);
    final isEdit = widget.banner != null;

    try {
      if (isEdit) {
        await provider.updateBanner(
          widget.banner!.id,
          _nameController.text.trim(),
          imageFile: _selectedImage,
        );
      } else {
        await provider.addBanner(
          _nameController.text.trim(),
          imageFile: _selectedImage,
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(isEdit ? 'Banner updated' : 'Banner added')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.banner != null;
    final provider = Provider.of<BannerProvider>(context);

    // Image Preview Logic
    ImageProvider? imageProvider;
    if (_selectedImage != null) {
      imageProvider = FileImage(_selectedImage!);
    } else if (widget.banner?.imageUrl != null) {
      final url = widget.banner!.imageUrl!;
      if (url.startsWith('http')) {
        imageProvider = NetworkImage(url);
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Banner' : 'Add Banner'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: const TextStyle(
            color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image Preview Area
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  width: double.infinity,
                  height: 180,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                    image: imageProvider != null
                        ? DecorationImage(
                            image: imageProvider, fit: BoxFit.cover)
                        : null,
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: imageProvider == null
                      ? const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_photo_alternate,
                                size: 50, color: Colors.grey),
                            SizedBox(height: 8),
                            Text('Tap to select from Gallery',
                                style: TextStyle(color: Colors.grey)),
                          ],
                        )
                      : null,
                ),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Banner Name',
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF6E4C77)),
                  ),
                ),
                validator: (val) =>
                    val == null || val.isEmpty ? 'Required' : null,
              ),

              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: provider.isLoading ? null : _saveBanner,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6E4C77),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: provider.isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          isEdit ? 'Update Banner' : 'Add Banner',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
