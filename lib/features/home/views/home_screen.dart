import 'package:flutter/material.dart';
import 'package:gifting/core/theme/theme_toggle_button.dart';
import 'package:gifting/features/cart/views/cart_bell_button.dart';
import 'package:gifting/features/home/views/dashboard_screen.dart';
import 'package:gifting/features/home/views/widgets/logout_dialog_box.dart';
import 'package:gifting/features/notifications/views/notifications_screen.dart';
import 'package:gifting/features/order/views/order_screen.dart';
import 'package:gifting/features/profile/views/profile_dashboard_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int selectedIndex = 0;
  List<Widget> get screens => [
    const DashboardScreen(),
    // const EnquiryScreen(),
    // const CartScreen(),
    const OrderScreen(),
    const ProfileDashboardScreen(),
    const NotificationsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        bool isMobile = constraints.maxWidth < 750;

        return Scaffold(
          body: isMobile
              ? IndexedStack(index: selectedIndex, children: screens)
              : Row(
                  children: [
                    NavigationRail(
                      onDestinationSelected: (value) {
                        selectedIndex = value;
                        setState(() {});
                      },
                      leading: const SizedBox(height: 16),
                      trailingAtBottom: true,
                      trailing: Padding(
                        padding: const EdgeInsets.only(bottom: 30),
                        child: Column(
                          spacing: 2,
                          children: [
                            const CartBellButton(),
                            // const NotificationBellButton(),
                            const ThemeToggleButton(),
                            IconButton(
                              tooltip: 'Sign out',
                              onPressed: () {
                                openLogoutDialogBox();
                              },
                              icon: const Icon(
                                Icons.logout,
                                size: 20,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                      ),
                      destinations: const [
                        NavigationRailDestination(
                          icon: Icon(Icons.home_outlined),
                          selectedIcon: Icon(Icons.home),
                          label: Text('Home'),
                        ),
                        // NavigationRailDestination(
                        //   icon: Icon(Icons.shopping_cart_outlined),
                        //   selectedIcon: Icon( Icons.shopping_cart),
                        //   label: Text('Cart'),
                        // ),
                        NavigationRailDestination(
                          icon: Icon(Icons.shop_2_outlined),
                          selectedIcon: Icon(Icons.shop_2),
                          label: Text('Orders'),
                        ),

                        NavigationRailDestination(
                          icon: Icon(Icons.person_outline),
                          selectedIcon: Icon(Icons.person),
                          label: Text('Profile'),
                        ),
                        NavigationRailDestination(
                          icon: Icon(Icons.notifications_outlined),
                          selectedIcon: Icon(Icons.notifications),
                          label: Text('Alerts'),
                        ),
                      ],
                      selectedIndex: selectedIndex,
                    ),
                    Expanded(
                      child: IndexedStack(
                        index: selectedIndex,
                        children: screens,
                      ),
                    ),
                  ],
                ),
          // floatingActionButton: FloatingActionButton.small(
          //   onPressed: () {
          //     Get.toNamed(AppRoutes.support);
          //   },
          //   child: const Icon(Icons.support),
          // ),
          bottomNavigationBar: isMobile
              ? BottomNavigationBar(
                  type: BottomNavigationBarType.fixed,
                  items: const [
                    BottomNavigationBarItem(
                      icon: Icon(Icons.home_outlined),
                      activeIcon: Icon(Icons.home),
                      label: 'Home',
                    ),
                    // BottomNavigationBarItem(
                    //   icon: Icon( Icons.shopping_cart_outlined),
                    //   activeIcon: Icon( Icons.shopping_cart),
                    //   label: 'Cart',
                    // ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.shop_2_outlined),
                      activeIcon: Icon(Icons.shop_2),
                      label: 'Orders',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.person_outline),
                      activeIcon: Icon(Icons.person),
                      label: 'Profile',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.notifications_outlined),
                      activeIcon: Icon(Icons.notifications),
                      label: 'Alerts',
                    ),
                  ],
                  currentIndex: selectedIndex,
                  onTap: (value) {
                    selectedIndex = value;
                    setState(() {});
                  },
                )
              : null,
        );
      },
    );
  }
}
