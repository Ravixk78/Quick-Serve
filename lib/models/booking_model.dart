enum BookingStatus { pending, confirmed, completed, cancelled }

class BookingModel {
  final String id;
  final String serviceId;
  final String customerId;
  final String providerId;
  final BookingStatus status;
  final DateTime bookingDate;
  final String? notes;
  final double totalAmount;
  final DateTime createdAt;

  // Populated fields from joins
  final String? serviceName;
  final String? serviceImage;
  final String? providerName;
  final String? customerName;

  BookingModel({
    required this.id,
    required this.serviceId,
    required this.customerId,
    required this.providerId,
    required this.status,
    required this.bookingDate,
    this.notes,
    required this.totalAmount,
    required this.createdAt,
    this.serviceName,
    this.serviceImage,
    this.providerName,
    this.customerName,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      id: json['id'] as String,
      serviceId: json['service_id'] as String,
      customerId: json['customer_id'] as String,
      providerId: json['provider_id'] as String,
      status: _stringToBookingStatus(json['status'] as String),
      bookingDate: DateTime.parse(json['booking_date'] as String),
      notes: json['notes'] as String?,
      totalAmount: (json['total_amount'] as num).toDouble(),
      createdAt: DateTime.parse(json['created_at'] as String),
      serviceName: json['service_name'] as String?,
      serviceImage: json['service_image'] as String?,
      providerName: json['provider_name'] as String?,
      customerName: json['customer_name'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'service_id': serviceId,
      'customer_id': customerId,
      'provider_id': providerId,
      'status': _bookingStatusToString(status),
      'booking_date': bookingDate.toIso8601String(),
      'notes': notes,
      'total_amount': totalAmount,
      'created_at': createdAt.toIso8601String(),
    };
  }

  static BookingStatus _stringToBookingStatus(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return BookingStatus.pending;
      case 'confirmed':
        return BookingStatus.confirmed;
      case 'completed':
        return BookingStatus.completed;
      case 'cancelled':
        return BookingStatus.cancelled;
      default:
        return BookingStatus.pending;
    }
  }

  static String _bookingStatusToString(BookingStatus status) {
    return status.toString().split('.').last;
  }

  String get statusText {
    switch (status) {
      case BookingStatus.pending:
        return 'Pending';
      case BookingStatus.confirmed:
        return 'Confirmed';
      case BookingStatus.completed:
        return 'Completed';
      case BookingStatus.cancelled:
        return 'Cancelled';
    }
  }

  BookingModel copyWith({
    String? id,
    String? serviceId,
    String? customerId,
    String? providerId,
    BookingStatus? status,
    DateTime? bookingDate,
    String? notes,
    double? totalAmount,
    DateTime? createdAt,
    String? serviceName,
    String? serviceImage,
    String? providerName,
    String? customerName,
  }) {
    return BookingModel(
      id: id ?? this.id,
      serviceId: serviceId ?? this.serviceId,
      customerId: customerId ?? this.customerId,
      providerId: providerId ?? this.providerId,
      status: status ?? this.status,
      bookingDate: bookingDate ?? this.bookingDate,
      notes: notes ?? this.notes,
      totalAmount: totalAmount ?? this.totalAmount,
      createdAt: createdAt ?? this.createdAt,
      serviceName: serviceName ?? this.serviceName,
      serviceImage: serviceImage ?? this.serviceImage,
      providerName: providerName ?? this.providerName,
      customerName: customerName ?? this.customerName,
    );
  }
}
