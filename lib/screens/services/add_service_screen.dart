import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/service_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/service_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class AddServiceScreen extends StatefulWidget {
  const AddServiceScreen({super.key});

  @override
  State<AddServiceScreen> createState() => _AddServiceScreenState();
}

class _AddServiceScreenState extends State<AddServiceScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _durationController = TextEditingController();

  final _serviceService = ServiceService();

  List<ServiceCategory> _dbCategories = [];
  String? _selectedCategoryId;
  bool _isLoading = false;
  bool _isFetchingCategories = true;
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      final categories = await _serviceService.getCategories();
      if (mounted) {
        setState(() {
          _dbCategories = categories;
          _isFetchingCategories = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching categories: $e');
      if (mounted) {
        setState(() => _isFetchingCategories = false);
        // Fallback or show error
      }
    }
  }

  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
      );
      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
        });
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
    }
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a professional category')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final user = authProvider.currentUser;

      if (user == null) throw Exception('Authentication required.');

      String? imageUrl;
      if (_imageFile != null) {
        imageUrl = await _serviceService.uploadServiceImage(_imageFile!);
      }

      await _serviceService.createService(
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        price: double.parse(_priceController.text),
        categoryId: _selectedCategoryId!,
        providerId: user.id,
        providerName: user.fullName,
        duration: _durationController.text.trim(),
        imageUrl: imageUrl,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Service Successfully Published!'),
          backgroundColor: AppTheme.successColor,
        ),
      );
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      debugPrint('PUBLISH ERROR: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Publish Failed: ${e.toString().replaceAll('Exception: ', '')}',
          ),
          backgroundColor: AppTheme.errorColor,
          duration: const Duration(seconds: 6),
          action: SnackBarAction(
            label: 'Details',
            textColor: Colors.white,
            onPressed: () {
              _showErrorDialog(e.toString());
            },
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showErrorDialog(String error) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Developer Technical Details'),
        content: SingleChildScrollView(child: Text(error)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : AppTheme.primaryNavy;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkBg : AppTheme.lightBg,
      appBar: AppBar(
        title: Text(
          'New Service Listing',
          style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: textColor),
      ),
      body: _isFetchingCategories
          ? const Center(
              child: CircularProgressIndicator(color: AppTheme.premiumGold),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tell us about your skill',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 32),

                    GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        height: 200,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.white.withAlpha(5)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: AppTheme.premiumGold.withAlpha(80),
                            width: 2,
                          ),
                          image: _imageFile != null
                              ? DecorationImage(
                                  image: FileImage(_imageFile!),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child: _imageFile == null
                            ? Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.add_photo_alternate_rounded,
                                    size: 50,
                                    color: AppTheme.premiumGold,
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    'Add Work Photo',
                                    style: TextStyle(
                                      color: textColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              )
                            : Container(
                                alignment: Alignment.topRight,
                                padding: const EdgeInsets.all(12),
                                child: CircleAvatar(
                                  backgroundColor: AppTheme.premiumGold,
                                  child: const Icon(
                                    Icons.edit,
                                    color: AppTheme.primaryNavy,
                                  ),
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    CustomTextField(
                      controller: _nameController,
                      label: 'Service Title',
                      hint: 'e.g. Master Painting & Decor',
                      prefixIcon: Icons.handyman_rounded,
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Title required' : null,
                    ),
                    const SizedBox(height: 20),

                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.white.withAlpha(10)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isDark ? Colors.white10 : Colors.grey.shade300,
                        ),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButtonFormField<String>(
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            labelText: 'Expertise Category',
                          ),
                          dropdownColor: isDark
                              ? AppTheme.darkCard
                              : Colors.white,
                          style: TextStyle(
                            color: textColor,
                            fontWeight: FontWeight.w500,
                          ),
                          value: _selectedCategoryId,
                          items: _dbCategories.isNotEmpty
                              ? _dbCategories
                                    .map(
                                      (c) => DropdownMenuItem(
                                        value: c.id,
                                        child: Text(
                                          c.name,
                                          style: TextStyle(color: textColor),
                                        ),
                                      ),
                                    )
                                    .toList()
                              : [
                                  const DropdownMenuItem(
                                    value: '1',
                                    child: Text('No categories in DB'),
                                  ),
                                ],
                          onChanged: (val) =>
                              setState(() => _selectedCategoryId = val),
                          validator: (v) =>
                              v == null ? 'Selection required' : null,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    Row(
                      children: [
                        Expanded(
                          child: CustomTextField(
                            controller: _priceController,
                            label: 'Cost (LKR)',
                            prefixIcon: Icons.payments_outlined,
                            keyboardType: TextInputType.number,
                            validator: (v) =>
                                v == null || v.isEmpty ? 'Required' : null,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: CustomTextField(
                            controller: _durationController,
                            label: 'Work Timing',
                            prefixIcon: Icons.timer_outlined,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    CustomTextField(
                      controller: _descriptionController,
                      label: 'Details of Service',
                      maxLines: 5,
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Summary required' : null,
                    ),
                    const SizedBox(height: 40),

                    CustomButton(
                      text: 'Publish Profile',
                      onPressed: _handleSubmit,
                      isLoading: _isLoading,
                      backgroundColor: AppTheme.premiumGold,
                      textColor: AppTheme.primaryNavy,
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
    );
  }
}
