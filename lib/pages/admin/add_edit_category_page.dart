import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/product_provider.dart';
import '../../data/models/category_model.dart';

class AddEditCategoryPage extends StatefulWidget {
  final Category? category; // Null means Add Mode

  const AddEditCategoryPage({super.key, this.category});

  @override
  State<AddEditCategoryPage> createState() => _AddEditCategoryPageState();
}

class _AddEditCategoryPageState extends State<AddEditCategoryPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  String? _selectedIconName;

  final Map<String, IconData> _availableIcons = {
    'coffee': Icons.coffee,
    'local_cafe': Icons.local_cafe,
    'fastfood': Icons.fastfood,
    'cake': Icons.cake,
    'icecream': Icons.icecream,
    'local_bar': Icons.local_bar,
    'local_pizza': Icons.local_pizza,
    'restaurant': Icons.restaurant,
    'bakery_dining': Icons.bakery_dining,
    'local_drink': Icons.local_drink,
  };

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.category?.name ?? '');

    // Check if category has iconName and if it exists in our map
    if (widget.category?.iconName != null &&
        _availableIcons.containsKey(widget.category!.iconName)) {
      _selectedIconName = widget.category!.iconName;
    } else {
      // Default or null if adding
      _selectedIconName = null;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _saveCategory() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = Provider.of<ProductProvider>(context, listen: false);
    final isEdit = widget.category != null;

    try {
      if (isEdit) {
        await provider.editCategory(
          widget.category!.id,
          _nameController.text.trim(),
          iconName: _selectedIconName, // Pass selected icon
        );
      } else {
        await provider.addCategory(
          _nameController.text.trim(),
          iconName: _selectedIconName, // Pass selected icon
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(isEdit ? 'Category updated' : 'Category added')),
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
    final isEdit = widget.category != null;
    final provider = Provider.of<ProductProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Category' : 'Add Category'),
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
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Category Name',
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
              const SizedBox(height: 24),

              // Dropdown for Icon
              DropdownButtonFormField<String>(
                value: _selectedIconName,
                decoration: InputDecoration(
                  labelText: 'Select Icon',
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                items: _availableIcons.entries.map((entry) {
                  return DropdownMenuItem<String>(
                    value: entry.key,
                    child: Row(
                      children: [
                        Icon(entry.value, color: const Color(0xFF6E4C77)),
                        const SizedBox(width: 10),
                        Text(entry.key),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedIconName = value;
                  });
                },
                hint: const Text('Choose an icon for this category'),
              ),

              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: provider.isLoading ? null : _saveCategory,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6E4C77),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: provider.isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          isEdit ? 'Update Category' : 'Add Category',
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
