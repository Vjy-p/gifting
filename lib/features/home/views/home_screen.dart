import 'package:flutter/material.dart';
import 'package:gifting/core/theme/theme_toggle_button.dart';
import 'package:gifting/features/enquiries/views/enquiry_screen.dart';
import 'package:gifting/features/home/views/dashboard_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int selectedIndex = 0;
  List<Widget> get screens => [const DashboardScreen(), const EnquiryScreen()];

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
                      leading: const Column(
                        children: [
                          SizedBox(height: 16),
                          ThemeToggleButton(),
                          SizedBox(height: 12),
                        ],
                      ),
                      destinations: const [
                        NavigationRailDestination(
                          icon: Icon(Icons.home_outlined),
                          selectedIcon: Icon(Icons.home),
                          label: Text('Home'),
                        ),
                        NavigationRailDestination(
                          icon: Icon(Icons.query_stats_outlined),
                          selectedIcon: Icon(Icons.query_stats),
                          label: Text('Enquiry'),
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
          bottomNavigationBar: isMobile
              ? BottomNavigationBar(
                  items: const [
                    BottomNavigationBarItem(
                      icon: Icon(Icons.home_outlined),
                      activeIcon: Icon(Icons.home),
                      label: 'Home',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.query_stats_outlined),
                      activeIcon: Icon(Icons.query_stats),
                      label: 'Enquiry',
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
