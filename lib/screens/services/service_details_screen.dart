import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import '../../models/service_model.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/animated_service_icon.dart';

class ServiceDetailsScreen extends StatelessWidget {
  final ServiceModel service;

  const ServiceDetailsScreen({super.key, required this.service});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : AppTheme.primaryNavy;
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.currentUser;
    final isProviderOfService = user?.id == service.providerId;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkBg : AppTheme.lightBg,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Elegant Header
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            stretch: true,
            backgroundColor: AppTheme.primaryNavy,
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [AppTheme.primaryNavy, AppTheme.accentColor],
                  ),
                ),
                child: Center(
                  child: ZoomIn(
                    child: AnimatedServiceIcon(
                      category: service.name.split(' ').first,
                      size: 100,
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FadeInUp(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            service.name,
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                              color: textColor,
                            ),
                          ),
                        ),
                        if (isProviderOfService ||
                            user?.role == 'service_provider')
                          IconButton(
                            icon: Icon(
                              Icons.edit_note_rounded,
                              color: AppTheme.premiumGold,
                              size: 30,
                            ),
                            onPressed: () {
                              Navigator.pushNamed(
                                context,
                                '/edit-service',
                                arguments: service,
                              );
                            },
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  FadeInUp(
                    delay: const Duration(milliseconds: 100),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.verified_rounded,
                          color: AppTheme.successColor,
                          size: 20,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          service.providerName,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: isDark
                                ? Colors.white70
                                : AppTheme.lightTextSecondary,
                          ),
                        ),
                        const Spacer(),
                        const Icon(
                          Icons.star_rounded,
                          color: AppTheme.premiumGold,
                          size: 22,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${service.rating}',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: textColor,
                          ),
                        ),
                        Text(
                          ' (${service.reviewCount})',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark
                                ? Colors.white38
                                : AppTheme.lightTextSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Pricing Section
                  FadeInUp(
                    delay: const Duration(milliseconds: 200),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.white.withAlpha(5)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: isDark
                              ? Colors.white10
                              : Colors.black.withAlpha(5),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Service Cost',
                                style: TextStyle(
                                  color: isDark
                                      ? Colors.white38
                                      : AppTheme.lightTextSecondary,
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'LKR ${service.price.toStringAsFixed(0)}',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w900,
                                  color: AppTheme.premiumGold,
                                ),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                'Duration',
                                style: TextStyle(
                                  color: isDark
                                      ? Colors.white38
                                      : AppTheme.lightTextSecondary,
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                service.duration ?? '1-2 hrs',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: textColor,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  FadeInUp(
                    delay: const Duration(milliseconds: 300),
                    child: Text(
                      'About This Service',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: textColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  FadeInUp(
                    delay: const Duration(milliseconds: 400),
                    child: Text(
                      service.description,
                      style: TextStyle(
                        fontSize: 15,
                        height: 1.6,
                        color: isDark
                            ? Colors.white70
                            : AppTheme.lightTextSecondary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  FadeInUp(
                    delay: const Duration(milliseconds: 500),
                    child: Text(
                      'Service Highlights',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: textColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildHighlight(
                    context,
                    'Professional Equipment',
                    Icons.handyman_rounded,
                  ),
                  _buildHighlight(
                    context,
                    'On-time Arrival Guarantee',
                    Icons.timer_rounded,
                  ),
                  _buildHighlight(
                    context,
                    'Certified & Verified Pros',
                    Icons.verified_user_rounded,
                  ),
                  _buildHighlight(
                    context,
                    'Safe & Contactless Service',
                    Icons.health_and_safety_rounded,
                  ),

                  const SizedBox(height: 120),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: user?.role != 'service_provider'
          ? Container(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
              decoration: BoxDecoration(
                color: isDark ? AppTheme.darkBg : Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(isDark ? 100 : 5),
                    blurRadius: 20,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: CustomButton(
                text: 'Book This Service',
                onPressed: () => Navigator.pushNamed(
                  context,
                  '/booking',
                  arguments: service,
                ),
                backgroundColor: AppTheme.premiumGold,
                textColor: AppTheme.primaryNavy,
              ),
            )
          : null,
    );
  }

  Widget _buildHighlight(BuildContext context, String text, IconData icon) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: FadeInLeft(
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppTheme.premiumGold.withAlpha(20),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 18, color: AppTheme.premiumGold),
            ),
            const SizedBox(width: 16),
            Text(
              text,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : AppTheme.primaryNavy,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
