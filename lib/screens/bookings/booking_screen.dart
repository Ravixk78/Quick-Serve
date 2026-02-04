import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import 'package:lottie/lottie.dart';
import '../../models/service_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/booking_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/custom_button.dart';

class BookingScreen extends StatefulWidget {
  final ServiceModel service;

  const BookingScreen({super.key, required this.service});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  final _bookingService = BookingService();
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  final _notesController = TextEditingController();
  bool _isLoading = false;
  bool _isSuccess = false;
  String _paymentMethod = 'cash'; // 'cash' or 'card'

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _handleBooking() async {
    if (_paymentMethod == 'card') {
      final success = await _showCardPaymentDialog();
      if (!success) return;
    }

    setState(() => _isLoading = true);

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final customerId = authProvider.currentUser?.id;

      if (customerId == null) throw Exception('Please login to book a service');

      await _bookingService.createBooking(
        serviceId: widget.service.id,
        customerId: customerId,
        providerId: widget.service.providerId,
        bookingDate: _selectedDate,
        totalAmount: widget.service.price,
        notes: _notesController.text.trim(),
      );

      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _isSuccess = true;
      });

      // Navigate back after delay
      await Future.delayed(const Duration(seconds: 3));
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Booking Error: $e'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }

  Future<bool> _showCardPaymentDialog() async {
    bool isProcessing = false;
    final cardNumberController = TextEditingController();
    final expiryController = TextEditingController();
    final cvvController = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          final isDark = Theme.of(context).brightness == Brightness.dark;

          return AlertDialog(
            backgroundColor: isDark ? AppTheme.darkCard : Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: const Text(
              'Enter Card Details',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            content: isProcessing
                ? Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(
                        color: AppTheme.premiumGold,
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Processing Payment...',
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ],
                  )
                : SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextField(
                          controller: cardNumberController,
                          decoration: const InputDecoration(
                            labelText: 'Card Number',
                            hintText: '1234 5678 9101 1121',
                          ),
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: expiryController,
                                decoration: const InputDecoration(
                                  labelText: 'Expiry Date',
                                  hintText: 'MM/YY',
                                ),
                                keyboardType: TextInputType.datetime,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextField(
                                controller: cvvController,
                                decoration: const InputDecoration(
                                  labelText: 'CVV',
                                  hintText: '123',
                                ),
                                keyboardType: TextInputType.number,
                                obscureText: true,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
            actions: [
              if (!isProcessing) ...[
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    setDialogState(() => isProcessing = true);
                    await Future.delayed(const Duration(seconds: 2));
                    if (context.mounted) Navigator.pop(context, true);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.premiumGold,
                    foregroundColor: AppTheme.primaryNavy,
                  ),
                  child: const Text('Pay Now'),
                ),
              ],
            ],
          );
        },
      ),
    );

    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : AppTheme.primaryNavy;

    if (_isSuccess) {
      return Scaffold(
        backgroundColor: isDark ? AppTheme.darkBg : Colors.white,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Lottie.network(
                'https://assets10.lottiefiles.com/packages/lf20_pqnfmone.json', // Premium success check
                repeat: false,
                width: 200,
              ),
              const SizedBox(height: 24),
              FadeInUp(
                child: Text(
                  'Booking Successful!',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: textColor,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              FadeInUp(
                delay: const Duration(milliseconds: 200),
                child: Text(
                  'Your professional has been notified.',
                  style: TextStyle(
                    color: isDark
                        ? Colors.white70
                        : AppTheme.lightTextSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkBg : AppTheme.lightBg,
      appBar: AppBar(
        title: Text('Book Service', style: TextStyle(color: textColor)),
        iconTheme: IconThemeData(color: textColor),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Service Brief
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? AppTheme.darkCard : Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(isDark ? 50 : 5),
                    blurRadius: 20,
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: AppTheme.premiumGold.withAlpha(20),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.home_repair_service_rounded,
                      color: AppTheme.premiumGold,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.service.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'By ${widget.service.providerName}',
                          style: TextStyle(
                            color: isDark
                                ? Colors.white60
                                : AppTheme.lightTextSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            Text(
              'Select Date',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () => _selectDate(context),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white.withAlpha(5) : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.premiumGold.withAlpha(50)),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.calendar_today_rounded,
                      color: AppTheme.premiumGold,
                    ),
                    const SizedBox(width: 16),
                    Text(
                      '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    const Spacer(),
                    const Icon(
                      Icons.edit_calendar_rounded,
                      color: AppTheme.premiumGold,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            Text(
              'Payment Method',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isDark ? Colors.white.withAlpha(5) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.premiumGold.withAlpha(50)),
              ),
              child: Column(
                children: [
                  RadioListTile<String>(
                    title: const Text('Cash on Service'),
                    secondary: const Icon(
                      Icons.money_outlined,
                      color: Colors.green,
                    ),
                    value: 'cash',
                    groupValue: _paymentMethod,
                    activeColor: AppTheme.premiumGold,
                    onChanged: (val) => setState(() => _paymentMethod = val!),
                  ),
                  const Divider(height: 1),
                  RadioListTile<String>(
                    title: const Text('Credit / Debit Card'),
                    secondary: const Icon(
                      Icons.credit_card_rounded,
                      color: Colors.blue,
                    ),
                    value: 'card',
                    groupValue: _paymentMethod,
                    activeColor: AppTheme.premiumGold,
                    onChanged: (val) => setState(() => _paymentMethod = val!),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            Text(
              'Special Notes',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _notesController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Any specific instructions for the provider?',
                hintStyle: TextStyle(
                  color: isDark ? Colors.white24 : Colors.black26,
                ),
                filled: true,
                fillColor: isDark ? Colors.white.withAlpha(5) : Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
              style: TextStyle(color: textColor),
            ),
            const SizedBox(height: 40),

            CustomButton(
              text: 'Confirm Booking',
              onPressed: _handleBooking,
              isLoading: _isLoading,
              backgroundColor: AppTheme.premiumGold,
              textColor: AppTheme.primaryNavy,
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }
}
