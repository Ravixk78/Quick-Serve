import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';
import '../models/service_model.dart';

class ServiceService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Upload image to Supabase Storage
  Future<String> uploadServiceImage(File imageFile) async {
    try {
      debugPrint('Uploading image: ${imageFile.path}');
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      final path = 'service_images/$fileName';

      final response = await _supabase.storage
          .from(SupabaseConfig.servicesBucket)
          .upload(
            path,
            imageFile,
            fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
          );
      debugPrint('Upload successful: $response');

      final String publicUrl = _supabase.storage
          .from(SupabaseConfig.servicesBucket)
          .getPublicUrl(path);

      debugPrint('Public URL: $publicUrl');
      return publicUrl;
    } catch (e) {
      debugPrint('Upload failed: $e');
      throw Exception('Failed to upload image: $e');
    }
  }

  // Create new service
  Future<ServiceModel> createService({
    required String name,
    required String description,
    required double price,
    required String categoryId,
    required String providerId,
    required String providerName,
    String? duration,
    String? imageUrl,
  }) async {
    try {
      debugPrint('Creating service: $name for provider: $providerId');
      final serviceData = {
        'name': name,
        'description': description,
        'price': price,
        'category_id': categoryId,
        'provider_id': providerId,
        'provider_name': providerName,
        'duration': duration,
        'image_url': imageUrl,
        'rating': 0.0,
        'review_count': 0,
        'is_active': true,
        'created_at': DateTime.now().toIso8601String(),
      };

      final response = await _supabase
          .from(SupabaseConfig.servicesTable)
          .insert(serviceData)
          .select()
          .single();

      debugPrint('Service created: ${response['id']}');
      return ServiceModel.fromJson(response);
    } catch (e) {
      debugPrint('Service creation failed: $e');
      throw Exception('Failed to create service: $e');
    }
  }

  // Get all categories
  Future<List<ServiceCategory>> getCategories() async {
    try {
      final response = await _supabase
          .from(SupabaseConfig.categoriesTable)
          .select()
          .order('name');

      return (response as List)
          .map((item) => ServiceCategory.fromJson(item))
          .toList();
    } catch (e) {
      throw Exception('Failed to load categories: $e');
    }
  }

  // Get all services
  Future<List<ServiceModel>> getAllServices() async {
    try {
      final response = await _supabase
          .from(SupabaseConfig.servicesTable)
          .select()
          .eq('is_active', true)
          .order('created_at', ascending: false);

      return (response as List)
          .map((item) => ServiceModel.fromJson(item))
          .toList();
    } catch (e) {
      throw Exception('Failed to load services: $e');
    }
  }

  // Get services by category
  Future<List<ServiceModel>> getServicesByCategory(String categoryId) async {
    try {
      final response = await _supabase
          .from(SupabaseConfig.servicesTable)
          .select()
          .eq('category_id', categoryId)
          .eq('is_active', true)
          .order('name');

      return (response as List)
          .map((item) => ServiceModel.fromJson(item))
          .toList();
    } catch (e) {
      throw Exception('Failed to load services: $e');
    }
  }

  // Get service by ID
  Future<ServiceModel?> getServiceById(String serviceId) async {
    try {
      final response = await _supabase
          .from(SupabaseConfig.servicesTable)
          .select()
          .eq('id', serviceId)
          .single();

      return ServiceModel.fromJson(response);
    } catch (e) {
      throw Exception('Failed to load service: $e');
    }
  }

  // Search services
  Future<List<ServiceModel>> searchServices(String query) async {
    try {
      final response = await _supabase
          .from(SupabaseConfig.servicesTable)
          .select()
          .ilike('name', '%$query%')
          .eq('is_active', true)
          .order('name');

      return (response as List)
          .map((item) => ServiceModel.fromJson(item))
          .toList();
    } catch (e) {
      throw Exception('Failed to search services: $e');
    }
  }

  // Get featured services (top rated)
  Future<List<ServiceModel>> getFeaturedServices({int limit = 10}) async {
    try {
      final response = await _supabase
          .from(SupabaseConfig.servicesTable)
          .select()
          .eq('is_active', true)
          .order('rating', ascending: false)
          .limit(limit);

      return (response as List)
          .map((item) => ServiceModel.fromJson(item))
          .toList();
    } catch (e) {
      throw Exception('Failed to load featured services: $e');
    }
  }

  // Update existing service
  Future<ServiceModel> updateService({
    required String serviceId,
    required Map<String, dynamic> updateData,
  }) async {
    try {
      debugPrint('Updating service: $serviceId');
      final response = await _supabase
          .from(SupabaseConfig.servicesTable)
          .update(updateData)
          .eq('id', serviceId)
          .select()
          .single();

      debugPrint('Service updated: ${response['id']}');
      return ServiceModel.fromJson(response);
    } catch (e) {
      debugPrint('Service update failed: $e');
      throw Exception('Failed to update service: $e');
    }
  }
}
