import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import '../../providers/auth_provider.dart';
import '../../services/service_service.dart';
import '../../theme/app_theme.dart';
import '../../models/service_model.dart';
import '../../widgets/animated_service_icon.dart';
import '../services/enhanced_service_list_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  final _serviceService = ServiceService();

  List<ServiceCategory> _categories = [];
  List<ServiceModel> _featuredServices = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final categories = await _serviceService.getCategories();
      final services = await _serviceService.getFeaturedServices();

      if (mounted) {
        setState(() {
          _categories = categories;
          _featuredServices = services;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('HOME LOAD ERROR: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkBg : AppTheme.lightBg,
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppTheme.premiumGold),
            )
          : RefreshIndicator(
              onRefresh: _loadData,
              color: AppTheme.premiumGold,
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  // Header
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 60, 24, 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          FadeInLeft(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Hello, ${user?.fullName.split(' ').first ?? 'Guest'}! 👋',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w900,
                                    color: isDark
                                        ? Colors.white
                                        : AppTheme.primaryNavy,
                                  ),
                                ),
                                Text(
                                  'Find your premium helper today',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: isDark
                                        ? Colors.white60
                                        : AppTheme.lightTextSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          FadeInRight(
                            child: Container(
                              height: 50,
                              width: 50,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppTheme.premiumGold,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2,
                                ),
                              ),
                              child: const Icon(
                                Icons.person,
                                color: AppTheme.primaryNavy,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Search
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: FadeInUp(
                        child: Container(
                          decoration: BoxDecoration(
                            color: isDark
                                ? Colors.white.withAlpha(10)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              if (!isDark)
                                BoxShadow(
                                  color: Colors.black.withAlpha(5),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                            ],
                          ),
                          child: TextField(
                            controller: _searchController,
                            onSubmitted: (val) {
                              if (val.isNotEmpty) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        EnhancedServiceListScreen(
                                          categoryName: 'Search: $val',
                                        ),
                                  ),
                                );
                              }
                            },
                            decoration: InputDecoration(
                              hintText: 'Search for services...',
                              prefixIcon: const Icon(
                                Icons.search_rounded,
                                color: AppTheme.premiumGold,
                              ),
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Categories
                  SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.fromLTRB(24, 32, 24, 16),
                          child: Text(
                            'Expert Categories',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 130,
                          child: _categories.isEmpty
                              ? Center(
                                  child: Text(
                                    'No categories active',
                                    style: TextStyle(
                                      color: isDark
                                          ? Colors.white24
                                          : Colors.grey,
                                    ),
                                  ),
                                )
                              : ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                  ),
                                  itemCount: _categories.length,
                                  itemBuilder: (context, index) {
                                    return FadeInRight(
                                      delay: Duration(
                                        milliseconds: index * 100,
                                      ),
                                      child: _buildCategoryCard(
                                        _categories[index],
                                      ),
                                    );
                                  },
                                ),
                        ),
                      ],
                    ),
                  ),

                  // Featured List
                  SliverToBoxAdapter(
                    child: const Padding(
                      padding: EdgeInsets.fromLTRB(24, 32, 24, 16),
                      child: Text(
                        'Highly Recommended',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),

                  _featuredServices.isEmpty
                      ? SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.all(40),
                            child: Center(
                              child: Text(
                                'No featured services yet',
                                style: TextStyle(
                                  color: isDark ? Colors.white24 : Colors.grey,
                                ),
                              ),
                            ),
                          ),
                        )
                      : SliverPadding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          sliver: SliverList(
                            delegate: SliverChildBuilderDelegate((
                              context,
                              index,
                            ) {
                              return FadeInUp(
                                delay: Duration(
                                  milliseconds: 200 + (index * 100),
                                ),
                                child: _buildServiceCard(
                                  _featuredServices[index],
                                ),
                              );
                            }, childCount: _featuredServices.length),
                          ),
                        ),

                  const SliverToBoxAdapter(child: SizedBox(height: 100)),
                ],
              ),
            ),
      floatingActionButton: user?.role == 'service_provider'
          ? FloatingActionButton.extended(
              onPressed: () => Navigator.pushNamed(context, '/add-service'),
              backgroundColor: AppTheme.premiumGold,
              label: const Text(
                'Add Service',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryNavy,
                ),
              ),
              icon: const Icon(Icons.add, color: AppTheme.primaryNavy),
            )
          : null,
    );
  }

  Widget _buildCategoryCard(ServiceCategory category) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EnhancedServiceListScreen(
              categoryId: category.id,
              categoryName: category.name,
            ),
          ),
        );
      },
      child: Container(
        width: 110,
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withAlpha(10) : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isDark
                ? Colors.white.withAlpha(10)
                : Colors.black.withAlpha(5),
          ),
          boxShadow: [
            if (!isDark)
              BoxShadow(
                color: Colors.black.withAlpha(5),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.premiumGold.withAlpha(20),
                shape: BoxShape.circle,
              ),
              child: AnimatedServiceIcon(category: category.name, size: 35),
            ),
            const SizedBox(height: 12),
            Text(
              category.name,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : AppTheme.primaryNavy,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceCard(ServiceModel service) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: () =>
          Navigator.pushNamed(context, '/service-details', arguments: service),
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 160,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
                gradient: LinearGradient(
                  colors: [AppTheme.primaryNavy, AppTheme.lightNavy],
                ),
              ),
              child: Stack(
                children: [
                  if (service.imageUrl != null)
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(24),
                      ),
                      child: Image.network(
                        service.imageUrl!,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: 160,
                      ),
                    ),
                  if (service.imageUrl == null)
                    Center(
                      child: AnimatedServiceIcon(
                        category: service.name.split(' ').first,
                        size: 70,
                      ),
                    ),
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'LKR ${service.price.toStringAsFixed(0)}',
                        style: const TextStyle(
                          color: AppTheme.premiumGold,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    service.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'By ${service.providerName}',
                    style: TextStyle(
                      color: isDark
                          ? Colors.white38
                          : AppTheme.lightTextSecondary,
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(
                        Icons.star_rounded,
                        color: AppTheme.premiumGold,
                        size: 20,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${service.rating ?? 0.0}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const Spacer(),
                      const Icon(
                        Icons.schedule_rounded,
                        size: 16,
                        color: AppTheme.premiumGold,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        service.duration ?? '1 hr',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
