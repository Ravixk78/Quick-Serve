import 'package:supabase_flutter/supabase_flutter.dart';

class NotificationModel {
  final String id;
  final String userId;
  final String title;
  final String message;
  final String? type;
  final bool isRead;
  final DateTime createdAt;

  NotificationModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.message,
    this.type,
    required this.isRead,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      title: json['title'] as String,
      message: json['message'] as String,
      type: json['notification_type'] as String?,
      isRead: json['is_read'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}

class NotificationService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Real-time stream for notifications
  Stream<List<NotificationModel>> getNotificationStream(String userId) {
    return _supabase
        .from('notifications')
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .order('created_at', ascending: false)
        .map(
          (data) =>
              data.map((json) => NotificationModel.fromJson(json)).toList(),
        );
  }

  // Mark all as read
  Future<void> markAllAsRead(String userId) async {
    await _supabase
        .from('notifications')
        .update({'is_read': true})
        .eq('user_id', userId);
  }

  // Mark specific as read
  Future<void> markAsRead(String notificationId) async {
    await _supabase
        .from('notifications')
        .update({'is_read': true})
        .eq('id', notificationId);
  }

  // Add notification (normally done via DB triggers, but can be done here too)
  Future<void> addNotification({
    required String userId,
    required String title,
    required String message,
    String? type,
  }) async {
    await _supabase.from('notifications').insert({
      'user_id': userId,
      'title': title,
      'message': message,
      'notification_type': type ?? 'system',
      'is_read': false,
      'created_at': DateTime.now().toIso8601String(),
    });
  }
}
