import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import 'package:intl/intl.dart';
import '../../models/booking_model.dart';
import '../../services/booking_service.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_theme.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  final BookingService _bookingService = BookingService();
  List<BookingModel> _allBookings = [];
  bool _isLoading = true;
  String _filter = 'all'; // all, pending, completed, cancelled

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    setState(() => _isLoading = true);
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final userId = authProvider.currentUser?.id;
      final userRole = authProvider.currentUser?.role;

      if (userId != null) {
        List<BookingModel> bookings;
        if (userRole == 'service_provider') {
          bookings = await _bookingService.getProviderBookings(userId);
        } else {
          bookings = await _bookingService.getCustomerBookings(userId);
        }

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

  List<BookingModel> get _filteredBookings {
    if (_filter == 'all') return _allBookings;
    return _allBookings.where((b) => b.status.name == _filter).toList();
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
          'Order History',
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
      ),
      body: Column(
        children: [
          // Filter Chips
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            color: isDark ? AppTheme.darkCard : Colors.white,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip('All', 'all', isDark),
                  const SizedBox(width: 8),
                  _buildFilterChip('Pending', 'pending', isDark),
                  const SizedBox(width: 8),
                  _buildFilterChip('Confirmed', 'confirmed', isDark),
                  const SizedBox(width: 8),
                  _buildFilterChip('Completed', 'completed', isDark),
                  const SizedBox(width: 8),
                  _buildFilterChip('Cancelled', 'cancelled', isDark),
                ],
              ),
            ),
          ),

          // Orders List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredBookings.isEmpty
                ? _buildEmptyState()
                : RefreshIndicator(
                    onRefresh: _loadOrders,
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _filteredBookings.length,
                      itemBuilder: (context, index) {
                        return FadeInUp(
                          duration: Duration(milliseconds: 300 + (index * 50)),
                          child: _buildOrderCard(
                            _filteredBookings[index],
                            isDark,
                          ),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value, bool isDark) {
    final isSelected = _filter == value;

    return GestureDetector(
      onTap: () => setState(() => _filter = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.premiumGold
              : (isDark ? Colors.white10 : Colors.grey[200]),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? AppTheme.premiumGold
                : (isDark ? Colors.white24 : Colors.grey[300]!),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isSelected
                ? AppTheme.primaryNavy
                : (isDark ? Colors.white70 : Colors.black87),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
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

  Widget _buildOrderCard(BookingModel booking, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Order #${booking.id.substring(0, 8).toUpperCase()}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: isDark ? Colors.white : AppTheme.primaryNavy,
                    ),
                  ),
                ),
                _buildStatusBadge(booking.status.name),
              ],
            ),

            const SizedBox(height: 12),

            // Booking Date
            _buildInfoRow(
              Icons.calendar_today_outlined,
              'Booking Date',
              DateFormat('MMM dd, yyyy • hh:mm a').format(booking.bookingDate),
              isDark,
            ),

            const SizedBox(height: 8),

            // Amount
            _buildInfoRow(
              Icons.attach_money_outlined,
              'Amount',
              'LKR ${booking.totalAmount.toStringAsFixed(2)}',
              isDark,
            ),

            if (booking.notes != null && booking.notes!.isNotEmpty) ...[
              const SizedBox(height: 8),
              _buildInfoRow(
                Icons.note_outlined,
                'Notes',
                booking.notes!,
                isDark,
              ),
            ],

            const SizedBox(height: 12),

            // Created Date
            Text(
              'Created: ${DateFormat('MMM dd, yyyy').format(booking.createdAt)}',
              style: TextStyle(
                fontSize: 12,
                color: isDark ? Colors.white54 : Colors.black45,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, bool isDark) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AppTheme.premiumGold),
        const SizedBox(width: 8),
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
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.white : AppTheme.primaryNavy,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    switch (status) {
      case 'pending':
        color = Colors.orange;
        break;
      case 'confirmed':
        color = Colors.blue;
        break;
      case 'on_hold':
        color = Colors.purple;
        break;
      case 'completed':
        color = AppTheme.accentGreen;
        break;
      case 'cancelled':
        color = AppTheme.errorColor;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status.toUpperCase(),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
