import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import 'package:intl/intl.dart';
import '../../services/notification_service.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_theme.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final userId = authProvider.currentUser?.id;
    final notificationService = NotificationService();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (userId == null) {
      return const Scaffold(
        body: Center(child: Text('Please login to see notifications')),
      );
    }

    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkBg : AppTheme.lightBg,
      appBar: AppBar(
        title: const Text(
          'Notifications',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        actions: [
          TextButton(
            onPressed: () => notificationService.markAllAsRead(userId),
            child: const Text(
              'Mark all as read',
              style: TextStyle(color: AppTheme.premiumGold),
            ),
          ),
        ],
      ),
      body: StreamBuilder<List<NotificationModel>>(
        stream: notificationService.getNotificationStream(userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppTheme.premiumGold),
            );
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final notifications = snapshot.data ?? [];

          if (notifications.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_none_rounded,
                    size: 80,
                    color: Colors.grey.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No notifications yet',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notification = notifications[index];
              return FadeInRight(
                delay: Duration(milliseconds: index * 100),
                child: _NotificationCard(
                  notification: notification,
                  onTap: () => notificationService.markAsRead(notification.id),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback onTap;

  const _NotificationCard({required this.notification, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: notification.isRead
              ? (isDark ? AppTheme.darkCard : Colors.white)
              : (isDark
                    ? AppTheme.premiumGold.withOpacity(0.1)
                    : AppTheme.premiumGold.withOpacity(0.05)),
          borderRadius: BorderRadius.circular(16),
          border: notification.isRead
              ? Border.all(color: Colors.transparent)
              : Border.all(color: AppTheme.premiumGold.withOpacity(0.3)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundColor: _getIconColor(notification.type),
              child: Icon(
                _getIcon(notification.type),
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        notification.title,
                        style: TextStyle(
                          fontWeight: notification.isRead
                              ? FontWeight.w600
                              : FontWeight.w900,
                          fontSize: 16,
                          color: isDark ? Colors.white : AppTheme.primaryNavy,
                        ),
                      ),
                      if (!notification.isRead)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppTheme.premiumGold,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notification.message,
                    style: TextStyle(
                      color: isDark ? Colors.white70 : Colors.black87,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    DateFormat(
                      'MMM dd, hh:mm a',
                    ).format(notification.createdAt),
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIcon(String? type) {
    switch (type) {
      case 'order_confirmed':
        return Icons.check_circle_rounded;
      case 'order_cancelled':
        return Icons.cancel_rounded;
      case 'order_on_hold':
        return Icons.pause_circle_filled_rounded;
      case 'booking_new':
        return Icons.new_releases_rounded;
      default:
        return Icons.notifications_rounded;
    }
  }

  Color _getIconColor(String? type) {
    switch (type) {
      case 'order_confirmed':
        return AppTheme.successColor;
      case 'order_cancelled':
        return AppTheme.errorColor;
      case 'order_on_hold':
        return Colors.orange;
      case 'booking_new':
        return AppTheme.infoColor;
      default:
        return AppTheme.premiumGold;
    }
  }
}
