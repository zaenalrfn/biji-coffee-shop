import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../providers/store_provider.dart';
import '../../data/models/store_model.dart';

class AddEditStorePage extends StatefulWidget {
  final StoreModel? store;

  const AddEditStorePage({super.key, this.store});

  @override
  State<AddEditStorePage> createState() => _AddEditStorePageState();
}

class _AddEditStorePageState extends State<AddEditStorePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _addressController;
  late TextEditingController _latController;
  late TextEditingController _longController;
  late TextEditingController _openTimeController;
  late TextEditingController _closeTimeController;
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.store?.name ?? '');
    _addressController =
        TextEditingController(text: widget.store?.address ?? '');
    _latController =
        TextEditingController(text: widget.store?.latitude.toString() ?? '');
    _longController =
        TextEditingController(text: widget.store?.longitude.toString() ?? '');
    _openTimeController =
        TextEditingController(text: widget.store?.openTime ?? '');
    _closeTimeController =
        TextEditingController(text: widget.store?.closeTime ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _latController.dispose();
    _longController.dispose();
    _openTimeController.dispose();
    _closeTimeController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
    }
  }

  Future<void> _saveStore() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = Provider.of<StoreProvider>(context, listen: false);
    final isEdit = widget.store != null;

    try {
      if (isEdit) {
        await provider.updateStore(
          id: widget.store!.id,
          name: _nameController.text.trim(),
          address: _addressController.text.trim(),
          latitude: double.parse(_latController.text.trim()),
          longitude: double.parse(_longController.text.trim()),
          openTime: _openTimeController.text.trim(),
          closeTime: _closeTimeController.text.trim(),
          imageFile: _selectedImage,
        );
      } else {
        await provider.addStore(
          name: _nameController.text.trim(),
          address: _addressController.text.trim(),
          latitude: double.parse(_latController.text.trim()),
          longitude: double.parse(_longController.text.trim()),
          openTime: _openTimeController.text.trim(),
          closeTime: _closeTimeController.text.trim(),
          imageFile: _selectedImage,
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(isEdit ? 'Store updated' : 'Store added')),
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
    final isEdit = widget.store != null;
    final provider = Provider.of<StoreProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Store' : 'Add Store'),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
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
              // Image Picker
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  width: double.infinity,
                  height: 180,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: _selectedImage != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(_selectedImage!, fit: BoxFit.cover),
                        )
                      : widget.store?.image != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                widget.store!.image!,
                                fit: BoxFit.cover,
                                errorBuilder: (ctx, err, stack) =>
                                    const Center(child: Icon(Icons.error)),
                              ),
                            )
                          : const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.camera_alt,
                                    size: 40, color: Colors.grey),
                                SizedBox(height: 8),
                                Text('Tap to select image',
                                    style: TextStyle(color: Colors.grey)),
                              ],
                            ),
                ),
              ),
              const SizedBox(height: 24),

              // Forms
              TextFormField(
                controller: _nameController,
                decoration: _inputDecoration('Store Name'),
                validator: (val) =>
                    val == null || val.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _addressController,
                decoration: _inputDecoration('Address'),
                maxLines: 2,
                validator: (val) =>
                    val == null || val.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _latController,
                      decoration: _inputDecoration('Latitude'),
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      validator: (val) =>
                          val == null || val.isEmpty ? 'Required' : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _longController,
                      decoration: _inputDecoration('Longitude'),
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      validator: (val) =>
                          val == null || val.isEmpty ? 'Required' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _openTimeController,
                      decoration: _inputDecoration('Open Time (e.g. 09:00 AM)'),
                      validator: (val) =>
                          val == null || val.isEmpty ? 'Required' : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _closeTimeController,
                      decoration:
                          _inputDecoration('Close Time (e.g. 10:00 PM)'),
                      validator: (val) =>
                          val == null || val.isEmpty ? 'Required' : null,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: provider.isLoading ? null : _saveStore,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6E4C77),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: provider.isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          isEdit ? 'Update Store' : 'Add Store',
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

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
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
    );
  }
}
