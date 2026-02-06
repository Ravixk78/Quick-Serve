import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import '../../providers/theme_provider.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_theme.dart';
import 'help_support_screen.dart';

class EnhancedSettingsScreen extends StatelessWidget {
  const EnhancedSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Check if user is a service provider
    final isServiceProvider =
        authProvider.currentUser?.role == 'service_provider';

    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkBg : AppTheme.lightBg,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: isDark ? AppTheme.darkCard : Colors.white,
        title: Text(
          'Settings',
          style: TextStyle(
            color: isDark ? Colors.white : AppTheme.primaryNavy,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Appearance Section
          FadeInDown(
            child: _buildSection(
              context: context,
              title: 'Appearance',
              items: [
                _buildThemeOption(
                  context,
                  themeProvider,
                  title: 'Light Mode',
                  icon: Icons.light_mode_rounded,
                  mode: ThemeMode.light,
                  isDark: isDark,
                ),
                _buildThemeOption(
                  context,
                  themeProvider,
                  title: 'Dark Mode',
                  icon: Icons.dark_mode_rounded,
                  mode: ThemeMode.dark,
                  isDark: isDark,
                ),
                _buildThemeOption(
                  context,
                  themeProvider,
                  title: 'System Default',
                  icon: Icons.phone_android_rounded,
                  mode: ThemeMode.system,
                  isDark: isDark,
                ),
              ],
              isDark: isDark,
            ),
          ),

          const SizedBox(height: 24),

          // Notifications Section
          FadeInUp(
            delay: const Duration(milliseconds: 100),
            child: _buildSection(
              context: context,
              title: 'Notifications',
              items: [
                _buildSwitchTile(
                  context,
                  title: 'Push Notifications',
                  subtitle: 'Receive booking updates',
                  icon: Icons.notifications_rounded,
                  value: true,
                  onChanged: (value) {
                    // TODO: Implement notification toggle
                  },
                  isDark: isDark,
                ),
                _buildSwitchTile(
                  context,
                  title: 'Email Notifications',
                  subtitle: 'Receive updates via email',
                  icon: Icons.email_rounded,
                  value: true,
                  onChanged: (value) {
                    // TODO: Implement email notification toggle
                  },
                  isDark: isDark,
                ),
                _buildSwitchTile(
                  context,
                  title: 'Promotional Offers',
                  subtitle: 'Get notified about offers',
                  icon: Icons.local_offer_rounded,
                  value: false,
                  onChanged: (value) {
                    // TODO: Implement promotional toggle
                  },
                  isDark: isDark,
                ),
              ],
              isDark: isDark,
            ),
          ),

          const SizedBox(height: 24),

          // Account Section
          FadeInUp(
            delay: const Duration(milliseconds: 200),
            child: _buildSection(
              context: context,
              title: 'Account',
              items: [
                // Only show Payment Method for customers
                if (!isServiceProvider)
                  _buildListTile(
                    context,
                    title: 'Payment Methods',
                    subtitle: 'Manage payment options',
                    icon: Icons.payment_rounded,
                    onTap: () {
                      // TODO: Navigate to payment methods
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Payment methods coming soon!'),
                        ),
                      );
                    },
                    isDark: isDark,
                  ),
                _buildListTile(
                  context,
                  title: 'Change Password',
                  subtitle: 'Update your password',
                  icon: Icons.lock_outline_rounded,
                  onTap: () {
                    // TODO: Navigate to change password
                  },
                  isDark: isDark,
                ),
                _buildListTile(
                  context,
                  title: 'Language',
                  subtitle: 'English',
                  icon: Icons.language_rounded,
                  onTap: () {
                    // TODO: Navigate to language selection
                  },
                  isDark: isDark,
                ),
              ],
              isDark: isDark,
            ),
          ),

          const SizedBox(height: 24),

          // Support Section
          FadeInUp(
            delay: const Duration(milliseconds: 300),
            child: _buildSection(
              context: context,
              title: 'Support',
              items: [
                _buildListTile(
                  context,
                  title: 'Help & Support',
                  subtitle: 'Get help or contact us',
                  icon: Icons.help_outline_rounded,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const HelpSupportScreen(),
                      ),
                    );
                  },
                  isDark: isDark,
                ),
              ],
              isDark: isDark,
            ),
          ),

          const SizedBox(height: 24),

          // About Section
          FadeInUp(
            delay: const Duration(milliseconds: 400),
            child: _buildSection(
              context: context,
              title: 'About',
              items: [
                _buildListTile(
                  context,
                  title: 'About QuickServe',
                  subtitle: 'Learn more about us',
                  icon: Icons.info_outline_rounded,
                  onTap: () {
                    _showAboutDialog(context);
                  },
                  isDark: isDark,
                ),
                _buildListTile(
                  context,
                  title: 'Privacy Policy',
                  subtitle: 'How we handle your data',
                  icon: Icons.privacy_tip_outlined,
                  onTap: () {
                    // TODO: Navigate to privacy policy
                  },
                  isDark: isDark,
                  // Correcting here as well
                ),
                _buildListTile(
                  context,
                  title: 'Terms of Service',
                  subtitle: 'Our terms and conditions',
                  icon: Icons.description_outlined,
                  onTap: () {
                    // TODO: Navigate to terms
                  },
                  isDark: isDark,
                ),
              ],
              isDark: isDark,
            ),
          ),

          const SizedBox(height: 32),

          // Version
          FadeIn(
            delay: const Duration(milliseconds: 500),
            child: Center(
              child: Column(
                children: [
                  Text(
                    'QuickServe',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white70 : Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Version 1.0.0',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.white54 : Colors.black45,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildSection({
    required BuildContext context,
    required String title,
    required List<Widget> items,
    required bool isDark,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : AppTheme.primaryNavy,
              letterSpacing: 0.5,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: isDark ? AppTheme.darkCard : Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: List.generate(
              items.length,
              (index) => Column(
                children: [
                  items[index],
                  if (index < items.length - 1)
                    Divider(
                      height: 1,
                      indent: 60,
                      color: isDark
                          ? Colors.white10
                          : Colors.black.withOpacity(0.05),
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildThemeOption(
    BuildContext context,
    ThemeProvider themeProvider, {
    required String title,
    required IconData icon,
    required ThemeMode mode,
    required bool isDark,
  }) {
    final isSelected = themeProvider.themeMode == mode;

    return ListTile(
      leading: Icon(
        icon,
        color: isSelected
            ? AppTheme.premiumGold
            : (isDark ? Colors.white60 : Colors.black54),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          color: isSelected
              ? AppTheme.premiumGold
              : (isDark ? Colors.white : AppTheme.primaryNavy),
        ),
      ),
      trailing: isSelected
          ? const Icon(Icons.check_circle_rounded, color: AppTheme.premiumGold)
          : null,
      onTap: () {
        themeProvider.setThemeMode(mode);
      },
    );
  }

  Widget _buildSwitchTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required bool value,
    required ValueChanged<bool> onChanged,
    required bool isDark,
  }) {
    return ListTile(
      leading: Icon(icon, color: isDark ? Colors.white60 : Colors.black54),
      title: Text(
        title,
        style: TextStyle(color: isDark ? Colors.white : AppTheme.primaryNavy),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 12,
          color: isDark ? Colors.white54 : Colors.black45,
        ),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeThumbColor: AppTheme.premiumGold,
      ),
    );
  }

  Widget _buildListTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return ListTile(
      leading: Icon(icon, color: isDark ? Colors.white60 : Colors.black54),
      title: Text(
        title,
        style: TextStyle(color: isDark ? Colors.white : AppTheme.primaryNavy),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 12,
          color: isDark ? Colors.white54 : Colors.black45,
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios_rounded,
        size: 16,
        color: isDark ? Colors.white38 : Colors.black26,
      ),
      onTap: onTap,
    );
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'QuickServe',
      applicationVersion: '1.0.0',
      applicationIcon: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppTheme.premiumGold,
              AppTheme.premiumGold.withOpacity(0.7),
            ],
          ),
          borderRadius: BorderRadius.circular(15),
        ),
        child: const Icon(
          Icons.cleaning_services_rounded,
          size: 30,
          color: AppTheme.primaryNavy,
        ),
      ),
      children: const [
        Text(
          'QuickServe is your one-stop solution for booking professional services. '
          'Find trusted service providers, book appointments, and manage your bookings all in one place.',
        ),
      ],
    );
  }
}
