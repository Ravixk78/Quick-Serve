class ServiceCategory {
  final String id;
  final String name;
  final String icon;
  final String description;

  ServiceCategory({
    required this.id,
    required this.name,
    required this.icon,
    required this.description,
  });

  factory ServiceCategory.fromJson(Map<String, dynamic> json) {
    return ServiceCategory(
      id: json['id'] as String,
      name: json['name'] as String,
      icon: json['icon'] as String,
      description: json['description'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'icon': icon, 'description': description};
  }
}

class ServiceModel {
  final String id;
  final String name;
  final String description;
  final double price;
  final String categoryId;
  final String providerId;
  final String? imageUrl;
  final double? rating;
  final int? reviewCount;
  final String? duration;
  final String providerName;
  final bool isActive;
  final DateTime createdAt;

  ServiceModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.categoryId,
    required this.providerId,
    this.imageUrl,
    this.rating,
    this.reviewCount,
    this.duration,
    required this.providerName,
    this.isActive = true,
    required this.createdAt,
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    return ServiceModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      price: (json['price'] as num).toDouble(),
      categoryId: json['category_id'] as String,
      providerId: json['provider_id'] as String,
      imageUrl: json['image_url'] as String?,
      rating: json['rating'] != null
          ? (json['rating'] as num).toDouble()
          : null,
      reviewCount: json['review_count'] as int?,
      duration: json['duration'] as String?,
      providerName: json['provider_name'] as String,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'category_id': categoryId,
      'provider_id': providerId,
      'image_url': imageUrl,
      'rating': rating,
      'review_count': reviewCount,
      'duration': duration,
      'provider_name': providerName,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
