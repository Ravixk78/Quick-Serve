import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/service_model.dart';
import '../../services/service_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class EditServiceScreen extends StatefulWidget {
  final ServiceModel service;

  const EditServiceScreen({super.key, required this.service});

  @override
  State<EditServiceScreen> createState() => _EditServiceScreenState();
}

class _EditServiceScreenState extends State<EditServiceScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _priceController;
  late TextEditingController _durationController;

  final _serviceService = ServiceService();
  bool _isLoading = false;
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.service.name);
    _descriptionController = TextEditingController(
      text: widget.service.description,
    );
    _priceController = TextEditingController(
      text: widget.service.price.toString(),
    );
    _durationController = TextEditingController(
      text: widget.service.duration ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _durationController.dispose();
    super.dispose();
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

    setState(() => _isLoading = true);

    try {
      String? imageUrl = widget.service.imageUrl;
      if (_imageFile != null) {
        try {
          imageUrl = await _serviceService.uploadServiceImage(_imageFile!);
        } catch (storageError) {
          debugPrint('Storage Update Error: $storageError');
          throw Exception(
            'Image Update Failed: Permission denied or bucket missing.',
          );
        }
      }

      final updateData = {
        'name': _nameController.text.trim(),
        'description': _descriptionController.text.trim(),
        'price': double.parse(_priceController.text),
        'duration': _durationController.text.trim(),
        'image_url': imageUrl,
      };

      await _serviceService.updateService(
        serviceId: widget.service.id,
        updateData: updateData,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile Updated Successfully!'),
          backgroundColor: AppTheme.successColor,
        ),
      );
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Update Error: ${e.toString().replaceAll('Exception: ', '')}',
          ),
          backgroundColor: AppTheme.errorColor,
          duration: const Duration(seconds: 5),
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : AppTheme.primaryNavy;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkBg : AppTheme.lightBg,
      appBar: AppBar(
        title: Text(
          'Edit Service Profile',
          style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: textColor),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Update Expert Details',
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
                    color: isDark ? Colors.white.withAlpha(5) : Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: AppTheme.premiumGold.withAlpha(100),
                      width: 2,
                    ),
                    image: _imageFile != null
                        ? DecorationImage(
                            image: FileImage(_imageFile!),
                            fit: BoxFit.cover,
                          )
                        : (widget.service.imageUrl != null
                              ? DecorationImage(
                                  image: NetworkImage(widget.service.imageUrl!),
                                  fit: BoxFit.cover,
                                )
                              : null),
                  ),
                  child: (_imageFile == null && widget.service.imageUrl == null)
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.add_photo_alternate_rounded,
                              size: 50,
                              color: AppTheme.premiumGold,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Change Profile Photo',
                              style: TextStyle(color: textColor),
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
                prefixIcon: Icons.star_border_rounded,
                validator: (v) =>
                    v == null || v.isEmpty ? 'Title required' : null,
              ),
              const SizedBox(height: 20),

              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      controller: _priceController,
                      label: 'Price (LKR)',
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
                      prefixIcon: Icons.watch_later_outlined,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              CustomTextField(
                controller: _descriptionController,
                label: 'Service Summary',
                maxLines: 5,
                validator: (v) =>
                    v == null || v.isEmpty ? 'Summary required' : null,
              ),
              const SizedBox(height: 40),

              CustomButton(
                text: 'Save All Changes',
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
