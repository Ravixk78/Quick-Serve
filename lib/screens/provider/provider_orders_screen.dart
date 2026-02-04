import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import 'package:intl/intl.dart';
import '../../models/booking_model.dart';
import '../../services/booking_service.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_theme.dart';

class ProviderOrdersScreen extends StatefulWidget {
  const ProviderOrdersScreen({super.key});

  @override
  State<ProviderOrdersScreen> createState() => _ProviderOrdersScreenState();
}

class _ProviderOrdersScreenState extends State<ProviderOrdersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final BookingService _bookingService = BookingService();
  List<BookingModel> _allBookings = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _loadOrders();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadOrders() async {
    setState(() => _isLoading = true);
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final providerId = authProvider.currentUser?.id;

      if (providerId != null) {
        final bookings = await _bookingService.getProviderBookings(providerId);
        setState(() {
          _allBookings = bookings;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading orders: $e')));
      }
    }
  }

  List<BookingModel> _filterBookingsByStatus(String status) {
    return _allBookings.where((b) => b.status == status).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkBg : AppTheme.lightBg,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: isDark ? AppTheme.darkCard : Colors.white,
        title: Text(
          'My Orders',
          style: TextStyle(
            color: isDark ? Colors.white : AppTheme.primaryNavy,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _loadOrders,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: AppTheme.premiumGold,
          labelColor: AppTheme.premiumGold,
          unselectedLabelColor: isDark ? Colors.white60 : Colors.black54,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold),
          tabs: const [
            Tab(text: 'Pending'),
            Tab(text: 'Confirmed'),
            Tab(text: 'On Hold'),
            Tab(text: 'Completed'),
            Tab(text: 'Cancelled'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildOrdersList(_filterBookingsByStatus('pending')),
                _buildOrdersList(_filterBookingsByStatus('confirmed')),
                _buildOrdersList(_filterBookingsByStatus('on_hold')),
                _buildOrdersList(_filterBookingsByStatus('completed')),
                _buildOrdersList(_filterBookingsByStatus('cancelled')),
              ],
            ),
    );
  }

  Widget _buildOrdersList(List<BookingModel> bookings) {
    if (bookings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No orders found',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadOrders,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: bookings.length,
        itemBuilder: (context, index) {
          return FadeInUp(
            duration: Duration(milliseconds: 300 + (index * 50)),
            child: _buildOrderCard(bookings[index]),
          );
        },
      ),
    );
  }

  Widget _buildOrderCard(BookingModel booking) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Order Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _getStatusColor(booking.status.name).withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  _getStatusIcon(booking.status.name),
                  color: _getStatusColor(booking.status.name),
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Order #${booking.id.substring(0, 8).toUpperCase()}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: isDark ? Colors.white : AppTheme.primaryNavy,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        DateFormat(
                          'MMM dd, yyyy • hh:mm a',
                        ).format(booking.createdAt),
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.white60 : Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(booking.status.name),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _getStatusLabel(booking.status.name),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Order Details
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildDetailRow(
                  Icons.person_outline,
                  'Customer',
                  'Customer Name',
                ),
                const SizedBox(height: 12),
                _buildDetailRow(
                  Icons.calendar_today_outlined,
                  'Booking Date',
                  DateFormat('MMM dd, yyyy').format(booking.bookingDate),
                ),
                const SizedBox(height: 12),
                _buildDetailRow(
                  Icons.attach_money_outlined,
                  'Amount',
                  'LKR ${booking.totalAmount.toStringAsFixed(2)}',
                ),
                if (booking.notes != null && booking.notes!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  _buildDetailRow(Icons.note_outlined, 'Notes', booking.notes!),
                ],
              ],
            ),
          ),

          // Action Buttons (based on status)
          if (booking.status == BookingStatus.pending)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Row(
                children: [
                  Expanded(
                    child: _buildActionButton(
                      label: 'Confirm',
                      icon: Icons.check_circle_outline,
                      color: AppTheme.accentGreen,
                      onTap: () => _updateOrderStatus(booking.id, 'confirmed'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildActionButton(
                      label: 'Hold',
                      icon: Icons.pause_circle_outline,
                      color: Colors.orange,
                      onTap: () => _updateOrderStatus(booking.id, 'on_hold'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildActionButton(
                      label: 'Cancel',
                      icon: Icons.cancel_outlined,
                      color: AppTheme.errorColor,
                      onTap: () => _updateOrderStatus(booking.id, 'cancelled'),
                    ),
                  ),
                ],
              ),
            ),

          // Complete/Cancel Button (for confirmed orders)
          if (booking.status == BookingStatus.confirmed ||
              booking.status == BookingStatus.on_hold)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Row(
                children: [
                  if (booking.status == BookingStatus.on_hold)
                    Expanded(
                      child: _buildActionButton(
                        label: 'Resume (Confirm)',
                        icon: Icons.play_circle_outline,
                        color: AppTheme.infoColor,
                        onTap: () =>
                            _updateOrderStatus(booking.id, 'confirmed'),
                      ),
                    )
                  else
                    Expanded(
                      child: _buildActionButton(
                        label: 'Complete Order',
                        icon: Icons.check_circle,
                        color: AppTheme.accentGreen,
                        onTap: () =>
                            _updateOrderStatus(booking.id, 'completed'),
                      ),
                    ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildActionButton(
                      label: 'Cancel',
                      icon: Icons.cancel_outlined,
                      color: AppTheme.errorColor,
                      onTap: () => _updateOrderStatus(booking.id, 'cancelled'),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      children: [
        Icon(icon, size: 20, color: AppTheme.premiumGold),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? Colors.white60 : Colors.black54,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : AppTheme.primaryNavy,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 18),
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _updateOrderStatus(String bookingId, String newStatus) async {
    try {
      // Show confirmation dialog
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Confirm ${_getStatusLabel(newStatus)}'),
          content: Text('Are you sure you want to ${newStatus} this order?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: _getStatusColor(newStatus),
              ),
              child: const Text('Confirm'),
            ),
          ],
        ),
      );

      if (confirmed == true) {
        await _bookingService.changeBookingStatus(bookingId, newStatus);
        await _loadOrders();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Order ${_getStatusLabel(newStatus).toLowerCase()} successfully',
              ),
              backgroundColor: AppTheme.accentGreen,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating order: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'confirmed':
        return Colors.blue;
      case 'on_hold':
        return Colors.purple;
      case 'completed':
        return AppTheme.accentGreen;
      case 'cancelled':
        return AppTheme.errorColor;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'pending':
        return Icons.hourglass_empty_rounded;
      case 'confirmed':
        return Icons.check_circle_outline;
      case 'on_hold':
        return Icons.pause_circle_outline;
      case 'completed':
        return Icons.done_all_rounded;
      case 'cancelled':
        return Icons.cancel_outlined;
      default:
        return Icons.info_outline;
    }
  }

  String _getStatusLabel(String status) {
    switch (status) {
      case 'pending':
        return 'Pending';
      case 'confirmed':
        return 'Confirmed';
      case 'on_hold':
        return 'On Hold';
      case 'completed':
        return 'Completed';
      case 'cancelled':
        return 'Cancelled';
      default:
        return status;
    }
  }
}
