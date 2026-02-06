import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';
import '../models/user_model.dart';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Get current user
  User? get currentUser => _supabase.auth.currentUser;

  // Check if user is logged in
  bool get isLoggedIn => currentUser != null;

  // Sign up with email and password
  Future<UserModel?> signUp({
    required String email,
    required String password,
    required String fullName,
    required String role,
    String? phoneNumber,
  }) async {
    try {
      // Attempt to sign up with Supabase Auth
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
      );

      if (response.user != null) {
        // Create user profile in users table
        final userProfile = {
          'id': response.user!.id,
          'email': email,
          'full_name': fullName,
          'role': role,
          'phone_number': phoneNumber,
          'created_at': DateTime.now().toIso8601String(),
        };

        try {
          await _supabase.from(SupabaseConfig.usersTable).insert(userProfile);
          return UserModel.fromJson(userProfile);
        } catch (dbError) {
          // If database insert fails, log the user out to clean up
          await _supabase.auth.signOut();
          throw Exception(
            'Database error: Failed to create user profile. Please check your database connection and table structure.',
          );
        }
      }
      return null;
    } on AuthException catch (authError) {
      // Handle specific Supabase auth errors
      String errorMessage;
      switch (authError.message.toLowerCase()) {
        case String msg when msg.contains('email'):
          errorMessage = 'Invalid email address';
          break;
        case String msg when msg.contains('password'):
          errorMessage = 'Password must be at least 6 characters';
          break;
        case String msg when msg.contains('already registered'):
          errorMessage = 'This email is already registered';
          break;
        default:
          errorMessage = authError.message;
      }
      throw Exception(errorMessage);
    } catch (e) {
      if (e.toString().contains('Database error')) {
        rethrow;
      }
      throw Exception('Sign up failed: ${e.toString()}');
    }
  }

  // Sign in with email and password
  Future<UserModel?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null) {
        // Fetch user profile
        try {
          final userProfile = await _supabase
              .from(SupabaseConfig.usersTable)
              .select()
              .eq('id', response.user!.id)
              .maybeSingle();

          if (userProfile == null) {
            // If profile doesn't exist, we might need to recreate it or log the error
            throw Exception('User profile not found in database.');
          }

          return UserModel.fromJson(userProfile);
        } catch (dbError) {
          throw Exception('Failed to load user profile: ${dbError.toString()}');
        }
      }
      return null;
    } on AuthException catch (authError) {
      throw Exception(authError.message);
    } catch (e) {
      throw Exception('Sign in failed: ${e.toString()}');
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
    } catch (e) {
      throw Exception('Sign out failed: $e');
    }
  }

  // Get user profile
  Future<UserModel?> getUserProfile(String userId) async {
    try {
      final userProfile = await _supabase
          .from(SupabaseConfig.usersTable)
          .select()
          .eq('id', userId)
          .single();

      return UserModel.fromJson(userProfile);
    } catch (e) {
      throw Exception('Failed to get user profile: $e');
    }
  }

  // Update user profile
  Future<UserModel?> updateUserProfile({
    required String userId,
    String? fullName,
    String? phoneNumber,
    String? profileImage,
  }) async {
    try {
      final updates = <String, dynamic>{};
      if (fullName != null) updates['full_name'] = fullName;
      if (phoneNumber != null) updates['phone_number'] = phoneNumber;
      if (profileImage != null) updates['profile_image'] = profileImage;

      final response = await _supabase
          .from(SupabaseConfig.usersTable)
          .update(updates)
          .eq('id', userId)
          .select()
          .single();

      return UserModel.fromJson(response);
    } catch (e) {
      throw Exception('Failed to update profile: $e');
    }
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      await _supabase.auth.resetPasswordForEmail(email);
    } catch (e) {
      throw Exception('Password reset failed: $e');
    }
  }

  // Upload profile image
  Future<String> uploadProfileImage(File imageFile, String userId) async {
    try {
      final fileExt = imageFile.path.split('.').last;
      final fileName =
          '$userId-${DateTime.now().millisecondsSinceEpoch}.$fileExt';
      final filePath = '$userId/$fileName';

      await _supabase.storage
          .from(SupabaseConfig.profilesBucket)
          .upload(filePath, imageFile);

      final imageUrl = _supabase.storage
          .from(SupabaseConfig.profilesBucket)
          .getPublicUrl(filePath);

      return imageUrl;
    } catch (e) {
      throw Exception('Failed to upload profile image: $e');
    }
  }
}
