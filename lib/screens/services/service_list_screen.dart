import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../../models/service_model.dart';
import '../../theme/app_theme.dart';
import '../../widgets/animated_service_icon.dart';

class ServiceListScreen extends StatefulWidget {
  final String? categoryId;
  final String? searchQuery;

  const ServiceListScreen({super.key, this.categoryId, this.searchQuery});

  @override
  State<ServiceListScreen> createState() => _ServiceListScreenState();
}

class _ServiceListScreenState extends State<ServiceListScreen> {
  final List<ServiceModel> _allServices = [
    // 1. Cleaning
    ServiceModel(
      id: '00000000-0000-0000-0001-000000000001',
      name: 'Deep Home Cleaning',
      description: 'Intensive cleaning for every corner of your house.',
      price: 4500.0,
      categoryId: '1',
      providerId: '00000000-0000-0000-0000-000000000010',
      providerName: 'CleanPro Solutions',
      rating: 4.8,
      reviewCount: 210,
      duration: '4-5 hours',
      createdAt: DateTime.now(),
    ),
    ServiceModel(
      id: '00000000-0000-0000-0001-000000000002',
      name: 'Premium Office Cleaning',
      description: 'Keep your workspace sparkling and professional.',
      price: 8000.0,
      categoryId: '1',
      providerId: '00000000-0000-0000-0000-000000000010',
      providerName: 'CleanPro Solutions',
      rating: 4.9,
      reviewCount: 156,
      duration: '6 hours',
      createdAt: DateTime.now(),
    ),

    // 2. Plumbing
    ServiceModel(
      id: '00000000-0000-0000-0002-000000000001',
      name: 'Leak Detection & Fix',
      description: 'Locate and repair underground or wall leaks.',
      price: 2500.0,
      categoryId: '2',
      providerId: '00000000-0000-0000-0000-000000000011',
      providerName: 'QuickFix Plumbers',
      rating: 4.7,
      reviewCount: 98,
      duration: '2 hours',
      createdAt: DateTime.now(),
    ),
    ServiceModel(
      id: '00000000-0000-0000-0002-000000000002',
      name: 'Full Bathroom Fitting',
      description: 'Install new pipes, taps, and shower systems.',
      price: 15000.0,
      categoryId: '2',
      providerId: '00000000-0000-0000-0000-000000000011',
      providerName: 'QuickFix Plumbers',
      rating: 5.0,
      reviewCount: 45,
      duration: '1 day',
      createdAt: DateTime.now(),
    ),

    // 3. Electrical
    ServiceModel(
      id: '00000000-0000-0000-0003-000000000001',
      name: 'AC Unit Inverter Fix',
      description: 'Specialized repair for modern AC inverter boards.',
      price: 3500.0,
      categoryId: '3',
      providerId: '00000000-0000-0000-0000-000000000012',
      providerName: 'ElectroSpark Masters',
      rating: 4.6,
      reviewCount: 112,
      duration: '3 hours',
      createdAt: DateTime.now(),
    ),
    ServiceModel(
      id: '00000000-0000-0000-0003-000000000002',
      name: 'Smart Home Wiring',
      description: 'Ethernet, CCTV, and smart switch installations.',
      price: 12000.0,
      categoryId: '3',
      providerId: '00000000-0000-0000-0000-000000000012',
      providerName: 'ElectroSpark Masters',
      rating: 4.9,
      reviewCount: 67,
      duration: '5 hours',
      createdAt: DateTime.now(),
    ),

    // 4. Carpentry
    ServiceModel(
      id: '00000000-0000-0000-0004-000000000001',
      name: 'Custom Sofa Making',
      description: 'Premium hardwood sofas with luxury fabric.',
      price: 45000.0,
      categoryId: '4',
      providerId: '00000000-0000-0000-0000-000000000013',
      providerName: 'Craftsman Woodwork',
      rating: 4.8,
      reviewCount: 32,
      duration: '1 week',
      createdAt: DateTime.now(),
    ),
    ServiceModel(
      id: '00000000-0000-0000-0004-000000000002',
      name: 'Door & Frame Repair',
      description: 'Fixing squeaky doors or installing new ones.',
      price: 5000.0,
      categoryId: '4',
      providerId: '00000000-0000-0000-0000-000000000013',
      providerName: 'Craftsman Woodwork',
      rating: 4.5,
      reviewCount: 54,
      duration: '4 hours',
      createdAt: DateTime.now(),
    ),

    // 5. Painting
    ServiceModel(
      id: '00000000-0000-0000-0005-000000000001',
      name: 'Full Interior Paint',
      description: 'Sanding, base coat, and two finish coats.',
      price: 20000.0,
      categoryId: '5',
      providerId: '00000000-0000-0000-0000-000000000014',
      providerName: 'Artisan Finishers',
      rating: 4.7,
      reviewCount: 88,
      duration: '3 days',
      createdAt: DateTime.now(),
    ),
    ServiceModel(
      id: '00000000-0000-0000-0005-000000000002',
      name: 'Luxury Wall Texture',
      description: 'Add 3D textures and patterns to your main walls.',
      price: 12000.0,
      categoryId: '5',
      providerId: '00000000-0000-0000-0000-000000000014',
      providerName: 'Artisan Finishers',
      rating: 4.9,
      reviewCount: 39,
      duration: '1 day',
      createdAt: DateTime.now(),
    ),

    // 6. Landscaping
    ServiceModel(
      id: '00000000-0000-0000-0006-000000000001',
      name: 'Garden Re-design',
      description: 'New plants, grass turfing, and lighting.',
      price: 35000.0,
      categoryId: '6',
      providerId: '00000000-0000-0000-0000-000000000015',
      providerName: 'GreenThumb Pro',
      rating: 5.0,
      reviewCount: 12,
      duration: '4 days',
      createdAt: DateTime.now(),
    ),
    ServiceModel(
      id: '00000000-0000-0000-0006-000000000002',
      name: 'Monthly Lawn Care',
      description: 'Weed control, trimming, and fertilizing.',
      price: 3500.0,
      categoryId: '6',
      providerId: '00000000-0000-0000-0000-000000000015',
      providerName: 'GreenThumb Pro',
      rating: 4.4,
      reviewCount: 145,
      duration: 'Monthly',
      createdAt: DateTime.now(),
    ),
  ];

  List<ServiceModel> get _filteredServices {
    var list = _allServices;
    if (widget.categoryId != null) {
      list = list.where((s) => s.categoryId == widget.categoryId).toList();
    }
    if (widget.searchQuery != null && widget.searchQuery!.isNotEmpty) {
      list = list
          .where(
            (s) => s.name.toLowerCase().contains(
              widget.searchQuery!.toLowerCase(),
            ),
          )
          .toList();
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final results = _filteredServices;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkBg : AppTheme.lightBg,
      appBar: AppBar(
        title: Text(
          widget.searchQuery != null
              ? 'Search: ${widget.searchQuery}'
              : 'Premium Services',
          style: TextStyle(
            color: isDark ? Colors.white : AppTheme.primaryNavy,
            fontWeight: FontWeight.w900,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(
          color: isDark ? Colors.white : AppTheme.primaryNavy,
        ),
      ),
      body: results.isEmpty
          ? Center(
              child: Text(
                'No services found',
                style: TextStyle(
                  color: isDark ? Colors.white60 : AppTheme.lightTextSecondary,
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              physics: const BouncingScrollPhysics(),
              itemCount: results.length,
              itemBuilder: (context, index) {
                return FadeInUp(
                  delay: Duration(milliseconds: index * 100),
                  child: _buildServiceCardPremium(results[index]),
                );
              },
            ),
    );
  }

  Widget _buildServiceCardPremium(ServiceModel service) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: () =>
          Navigator.pushNamed(context, '/service-details', arguments: service),
      child: Container(
        margin: const EdgeInsets.only(bottom: 24),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.darkCard : Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(isDark ? 50 : 10),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: IntrinsicHeight(
          child: Row(
            children: [
              Container(
                width: 100,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.horizontal(
                    left: Radius.circular(24),
                  ),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppTheme.primaryNavy, AppTheme.lightNavy],
                  ),
                ),
                child: Center(
                  child: AnimatedServiceIcon(
                    category: service.name.split(' ').first,
                    size: 40,
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        service.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'By ${service.providerName}',
                        style: TextStyle(
                          fontSize: 11,
                          fontStyle: FontStyle.italic,
                          color: isDark
                              ? Colors.white38
                              : AppTheme.lightTextSecondary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.star_rounded,
                                color: AppTheme.premiumGold,
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${service.rating}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            'LKR ${service.price.toStringAsFixed(0)}',
                            style: const TextStyle(
                              color: AppTheme.premiumGold,
                              fontWeight: FontWeight.w900,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: AppTheme.premiumGold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
