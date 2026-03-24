import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/navigation_provider.dart';
import 'home/home_screen.dart';
import 'bookings/my_bookings_screen.dart';
import 'notifications/notifications_screen.dart';
import 'profile/profile_screen.dart';
import 'package:quick_serve/screens/provider/provider_home_screen.dart';
import 'package:quick_serve/screens/provider/provider_orders_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _providerOrdersTabIndex = 0;

  @override
  void initState() {
    super.initState();
    // Check for initial index argument
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      if (args != null && args.containsKey('index')) {
        context.read<NavigationProvider>().setIndex(args['index'] as int);
      }
    });
  }

  final List<Widget> _screens = [
    const HomeScreen(),
    const MyBookingsScreen(),
    const NotificationsScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    // Safety check: Redirect to login if user is not authenticated
    // This prevents any guest access to the main parts of the app
    if (authProvider.currentUser == null && !authProvider.isLoading) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, '/login');
      });
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: Colors.amber)),
      );
    }

    final isProvider = authProvider.currentUser?.role == 'service_provider';

    final screens = isProvider
        ? [
            ProviderHomeScreen(
              onSwitchTab: (index, {int subIndex = 0}) {
                context.read<NavigationProvider>().setIndex(index);
                if (index == 1) {
                  setState(() {
                    _providerOrdersTabIndex = subIndex;
                  });
                }
              },
            ),
            ProviderOrdersScreen(
              providerId: authProvider.currentUser?.id ?? '',
              initialTabIndex: _providerOrdersTabIndex,
            ),
            const NotificationsScreen(),
            const ProfileScreen(),
          ]
        : _screens;

    final navProvider = Provider.of<NavigationProvider>(context);

    return Scaffold(
      body: screens[navProvider.currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: navProvider.currentIndex,
          onTap: (index) {
            navProvider.setIndex(index);
          },
          items: [
            BottomNavigationBarItem(
              icon: Icon(
                isProvider ? Icons.dashboard_outlined : Icons.home_outlined,
              ),
              activeIcon: Icon(isProvider ? Icons.dashboard : Icons.home),
              label: isProvider ? 'Dashboard' : 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(
                isProvider
                    ? Icons.list_alt_outlined
                    : Icons.calendar_today_outlined,
              ),
              activeIcon: Icon(
                isProvider ? Icons.list_alt : Icons.calendar_today,
              ),
              label: isProvider ? 'Orders' : 'Bookings',
            ),
            // The following _buildOptionCard is not a valid BottomNavigationBarItem.
            // Assuming this was intended for a different part of the UI or a misunderstanding
            // of BottomNavigationBar's `items` property, it cannot be directly inserted here.
            // If the intention was to make the Notifications item navigate differently,
            // that logic would typically be handled in the onTap of the BottomNavigationBar
            // or within the NotificationsScreen itself.
            // For now, I will keep the original BottomNavigationBarItem for Notifications
            // to maintain syntactical correctness.
            const BottomNavigationBarItem(
              icon: Icon(Icons.notifications_outlined),
              activeIcon: Icon(Icons.notifications),
              label: 'Notifications',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
