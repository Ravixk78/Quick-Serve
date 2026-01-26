import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:lottie/lottie.dart';
import '../theme/app_theme.dart';

class AnimatedServiceIcon extends StatelessWidget {
  final String category;
  final double size;

  const AnimatedServiceIcon({
    super.key,
    required this.category,
    this.size = 60,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    switch (category.toLowerCase()) {
      case 'cleaning':
        return _buildLottie(
          'https://assets2.lottiefiles.com/packages/lf20_tursm6id.json',
          Icons.cleaning_services_rounded,
        );
      case 'plumbing':
        return _buildLottie(
          'https://assets10.lottiefiles.com/private_files/lf30_8u9v6x.json',
          Icons.plumbing_rounded,
        );
      case 'electrical':
        return _buildLottie(
          'https://assets9.lottiefiles.com/packages/lf20_bolt.json',
          Icons.bolt_rounded,
        );
      case 'carpentry':
        return _buildLottie(
          'https://assets5.lottiefiles.com/packages/lf20_constructor.json',
          Icons.handyman_rounded,
        );
      case 'painting':
        return _buildLottie(
          'https://assets3.lottiefiles.com/packages/lf20_paint.json',
          Icons.format_paint_rounded,
        );
      case 'landscaping':
        return _buildLottie(
          'https://assets7.lottiefiles.com/packages/lf20_garden.json',
          Icons.park_rounded,
        );
      default:
        return _buildDefaultAnimation(isDark);
    }
  }

  Widget _buildLottie(String url, IconData fallback) {
    return SizedBox(
      width: size * 1.5,
      height: size * 1.5,
      child: Lottie.network(
        url,
        repeat: true,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return Pulse(
            child: Icon(fallback, size: size, color: AppTheme.premiumGold),
          );
        },
      ),
    );
  }

  Widget _buildDefaultAnimation(bool isDark) {
    return Pulse(
      infinite: true,
      child: Icon(
        Icons.home_repair_service_rounded,
        size: size,
        color: AppTheme.premiumGold,
      ),
    );
  }
}
