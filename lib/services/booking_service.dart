import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';
import '../models/booking_model.dart';

class BookingService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Create a new booking
  Future<BookingModel?> createBooking({
    required String serviceId,
    required String customerId,
    required String providerId,
    required DateTime bookingDate,
    required double totalAmount,
    String? notes,
  }) async {
    try {
      debugPrint('Attempting to create booking for service: $serviceId');
      final bookingData = {
        'service_id': serviceId,
        'customer_id': customerId,
        'provider_id': providerId,
        'status': 'pending',
        'booking_date': bookingDate.toIso8601String(),
        'total_amount': totalAmount,
        'notes': notes,
        'created_at': DateTime.now().toIso8601String(),
      };

      final response = await _supabase
          .from(SupabaseConfig.bookingsTable)
          .insert(bookingData)
          .select()
          .single();

      debugPrint('Booking created successfully: ${response['id']}');
      return BookingModel.fromJson(response);
    } catch (e) {
      debugPrint('Booking creation failed: $e');
      throw Exception('Failed to create booking: $e');
    }
  }

  // Get bookings for a customer
  Future<List<BookingModel>> getCustomerBookings(String customerId) async {
    try {
      final response = await _supabase
          .from(SupabaseConfig.bookingsTable)
          .select()
          .eq('customer_id', customerId)
          .order('booking_date', ascending: false);

      return (response as List)
          .map((item) => BookingModel.fromJson(item))
          .toList();
    } catch (e) {
      throw Exception('Failed to load bookings: $e');
    }
  }

  // Get bookings for a service provider
  Future<List<BookingModel>> getProviderBookings(String providerId) async {
    try {
      final response = await _supabase
          .from(SupabaseConfig.bookingsTable)
          .select()
          .eq('provider_id', providerId)
          .order('booking_date', ascending: false);

      return (response as List)
          .map((item) => BookingModel.fromJson(item))
          .toList();
    } catch (e) {
      throw Exception('Failed to load bookings: $e');
    }
  }

  // Get booking by ID
  Future<BookingModel?> getBookingById(String bookingId) async {
    try {
      final response = await _supabase
          .from(SupabaseConfig.bookingsTable)
          .select()
          .eq('id', bookingId)
          .single();

      return BookingModel.fromJson(response);
    } catch (e) {
      throw Exception('Failed to load booking: $e');
    }
  }

  // Update booking status
  Future<BookingModel?> updateBookingStatus({
    required String bookingId,
    required BookingStatus status,
  }) async {
    try {
      final response = await _supabase
          .from(SupabaseConfig.bookingsTable)
          .update({'status': status.toString().split('.').last})
          .eq('id', bookingId)
          .select()
          .single();

      return BookingModel.fromJson(response);
    } catch (e) {
      throw Exception('Failed to update booking status: $e');
    }
  }

  // Cancel booking
  Future<BookingModel?> cancelBooking(String bookingId) async {
    return updateBookingStatus(
      bookingId: bookingId,
      status: BookingStatus.cancelled,
    );
  }

  // Get bookings by status
  Future<List<BookingModel>> getBookingsByStatus({
    required String userId,
    required BookingStatus status,
    bool isProvider = false,
  }) async {
    try {
      final field = isProvider ? 'provider_id' : 'customer_id';
      final response = await _supabase
          .from(SupabaseConfig.bookingsTable)
          .select()
          .eq(field, userId)
          .eq('status', status.toString().split('.').last)
          .order('booking_date', ascending: false);

      return (response as List)
          .map((item) => BookingModel.fromJson(item))
          .toList();
    } catch (e) {
      throw Exception('Failed to load bookings: $e');
    }
  }
}
