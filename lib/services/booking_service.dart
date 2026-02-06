import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';
import '../models/booking_model.dart';
import './notification_service.dart';

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
          .select(
            '*, service:services(name, image_url), provider:users!bookings_provider_id_fkey(full_name)',
          )
          .eq('customer_id', customerId)
          .order('booking_date', ascending: false);

      return (response as List).map((item) {
        final data = Map<String, dynamic>.from(item);
        if (data['service'] != null) {
          data['service_name'] = data['service']['name'];
          data['service_image'] = data['service']['image_url'];
        }
        if (data['provider'] != null) {
          data['provider_name'] = data['provider']['full_name'];
        }
        return BookingModel.fromJson(data);
      }).toList();
    } catch (e) {
      debugPrint('Error loading customer bookings: $e');
      final response = await _supabase
          .from(SupabaseConfig.bookingsTable)
          .select()
          .eq('customer_id', customerId)
          .order('booking_date', ascending: false);
      return (response as List)
          .map((item) => BookingModel.fromJson(item))
          .toList();
    }
  }

  Future<List<BookingModel>> getProviderBookings(String providerId) async {
    try {
      final response = await _supabase
          .from(SupabaseConfig.bookingsTable)
          .select(
            '*, service:services(name, image_url), customer:users!bookings_customer_id_fkey(full_name)',
          )
          .eq('provider_id', providerId)
          .order('booking_date', ascending: false);

      return (response as List).map((item) {
        final data = Map<String, dynamic>.from(item);
        if (data['service'] != null) {
          data['service_name'] = data['service']['name'];
          data['service_image'] = data['service']['image_url'];
        }
        if (data['customer'] != null) {
          data['customer_name'] = data['customer']['full_name'];
        }
        return BookingModel.fromJson(data);
      }).toList();
    } catch (e) {
      debugPrint('Error loading provider bookings with joins: $e');
      // If joined query fails, try to fetch with explicit columns to skip any schema cache issues
      final response = await _supabase
          .from(SupabaseConfig.bookingsTable)
          .select(
            'id, service_id, customer_id, provider_id, status, booking_date, notes, total_amount, created_at',
          )
          .eq('provider_id', providerId)
          .order('booking_date', ascending: false);

      return (response as List)
          .map((item) => BookingModel.fromJson(item))
          .toList();
    }
  }

  // Real-time stream for bookings
  Stream<List<BookingModel>> getProviderBookingsStream(String providerId) {
    return _supabase
        .from(SupabaseConfig.bookingsTable)
        .stream(primaryKey: ['id'])
        .eq('provider_id', providerId)
        .order('booking_date', ascending: false)
        .map(
          (data) => data.map((item) => BookingModel.fromJson(item)).toList(),
        );
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
          .select(
            'id, service_id, customer_id, provider_id, status, booking_date, notes, total_amount, created_at',
          )
          .single();

      return BookingModel.fromJson(response);
    } catch (e) {
      throw Exception('Failed to update booking status: $e');
    }
  }

  // Update booking status with string (for provider screens)
  Future<void> changeBookingStatus(String bookingId, String status) async {
    try {
      Map<String, dynamic> data;
      const String bookingColumns =
          'id, service_id, customer_id, provider_id, status, booking_date, notes, total_amount, created_at';
      try {
        final response = await _supabase
            .from(SupabaseConfig.bookingsTable)
            .update({'status': status})
            .eq('id', bookingId)
            .select(
              '$bookingColumns, service:services(name, image_url), customer:users!bookings_customer_id_fkey(full_name)',
            )
            .single();
        data = Map<String, dynamic>.from(response);
      } catch (e) {
        debugPrint('Update with joins failed, falling back: $e');
        final response = await _supabase
            .from(SupabaseConfig.bookingsTable)
            .update({'status': status})
            .eq('id', bookingId)
            .select(bookingColumns)
            .single();
        data = Map<String, dynamic>.from(response);
      }

      if (data['service'] != null) {
        data['service_name'] = data['service']['name'];
        data['service_image'] = data['service']['image_url'];
      }
      if (data['customer'] != null) {
        data['customer_name'] = data['customer']['full_name'];
      }

      final booking = BookingModel.fromJson(data);

      // 2. Create notification for the customer
      final notificationService = NotificationService();
      String title = 'Booking Update';
      String message =
          'Your booking for ${booking.serviceName ?? "service"} has been $status.';

      switch (status) {
        case 'confirmed':
          title = 'Booking Confirmed! ✅';
          message =
              'Great news! Your booking for ${booking.serviceName ?? 'a service'} with ${booking.customerName ?? 'a customer'} has been confirmed by the professional.';
          break;
        case 'on_hold':
          title = 'Booking On Hold ⏳';
          message =
              'Your booking has been put on hold. Please check for further updates.';
          break;
        case 'completed':
          title = 'Service Completed! 🎉';
          message =
              'The service has been marked as completed. Thank you for using QuickServe!';
          break;
        case 'cancelled':
          title = 'Booking Cancelled ❌';
          message = 'Unfortunately, your booking has been cancelled.';
          break;
      }

      await notificationService.addNotification(
        userId: booking.customerId,
        title: title,
        message: message,
        type: 'order_$status',
      );
    } catch (e) {
      throw Exception('Failed to update booking status: $e');
    }
  }

  // Get provider stats
  Future<Map<String, dynamic>> getProviderStats(String providerId) async {
    try {
      final response = await _supabase
          .from(SupabaseConfig.bookingsTable)
          .select('status')
          .eq('provider_id', providerId);

      int completed = 0;
      int pending = 0;

      for (final booking in response) {
        final status = (booking['status'] as String).toLowerCase();
        if (status == 'completed') completed++;
        if (status == 'pending') pending++;
      }

      int currentLevel = (completed ~/ 10) + 1;
      int nextBookingTarget = currentLevel * 10;
      double progress = (completed % 10) / 10.0;

      return {
        'completed': completed,
        'pending': pending,
        'level': currentLevel,
        'nextLevelTarget': nextBookingTarget,
        'progress': progress,
      };
    } catch (e) {
      return {
        'completed': 0,
        'pending': 0,
        'level': 1,
        'nextLevelTarget': 10,
        'progress': 0.0,
      };
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
