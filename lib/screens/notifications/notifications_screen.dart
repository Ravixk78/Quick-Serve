import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../utils/datetime_helper.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Placeholder notifications
    final notifications = [
      {
        'title': 'Booking Confirmed',
        'message': 'Your booking for Deep House Cleaning has been confirmed',
        'time': DateTime.now().subtract(const Duration(hours: 2)),
        'read': false,
      },
      {
        'title': 'New Service Available',
        'message': 'Check out our new Gardening services',
        'time': DateTime.now().subtract(const Duration(days: 1)),
        'read': true,
      },
      {
        'title': 'Service Completed',
        'message':
            'Office Cleaning service has been completed. Please rate your experience',
        'time': DateTime.now().subtract(const Duration(days: 10)),
        'read': true,
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          TextButton(
            onPressed: () {
              // Mark all as read
            },
            child: const Text('Mark all read'),
          ),
        ],
      ),
      body: notifications.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_none,
                    size: 64,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No notifications',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final notification = notifications[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  color: notification['read'] as bool
                      ? null
                      : AppTheme.primaryColor.withAlpha((0.05 * 255).toInt()),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppTheme.primaryColor.withAlpha((0.1 * 255).toInt()),
                      child: Icon(
                        Icons.notifications,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                    title: Text(
                      notification['title'] as String,
                      style: TextStyle(
                        fontWeight: notification['read'] as bool
                            ? FontWeight.w500
                            : FontWeight.w700,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(notification['message'] as String),
                        const SizedBox(height: 4),
                        Text(
                          DateTimeHelper.formatRelativeTime(
                            notification['time'] as DateTime,
                          ),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                    isThreeLine: true,
                  ),
                );
              },
            ),
    );
  }
}
