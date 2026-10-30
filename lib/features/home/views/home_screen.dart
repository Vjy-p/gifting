import 'package:flutter/material.dart';
import 'package:gifting/core/theme/app_colors.dart';
import 'package:gifting/features/enquiries/views/enquiry_screen.dart';
import 'package:gifting/features/home/views/dashboard_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int selectedIndex = 0;
  List<Widget> screens = [DashboardScreen(), EnquiryScreen()];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        bool isMobile = constraints.maxWidth < 750;

        return Scaffold(
          // appBar: AppBar(
          //   automaticallyImplyLeading: false,
          //   title: Row(
          //     spacing: 8,
          //     children: [
          //       const Icon(
          //         Icons.eco_outlined,
          //         color: AppColors.primary,
          //         size: 30,
          //       ),
          //       const Text(
          //         'TRIBE GREEN',
          //         style: TextStyle(
          //           fontWeight: FontWeight.w800,
          //           letterSpacing: 1.5,
          //           color: AppColors.darkGreen,
          //         ),
          //       ),
          //     ],
          //   ),
          // ),
          body: isMobile
              ? IndexedStack(index: selectedIndex, children: screens)
              : Row(
                  children: [
                    NavigationRail(
                      onDestinationSelected: (value) {
                        selectedIndex = value;
                        setState(() {});
                      },
                      leading: SizedBox(height: 20),
                      destinations: [
                        NavigationRailDestination(
                          icon: Icon(Icons.home),
                          label: Text("Home"),
                        ),
                        NavigationRailDestination(
                          icon: Icon(Icons.question_answer),
                          label: Text("Enquiry"),
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
                  backgroundColor: AppColors.background,
                  items: [
                    BottomNavigationBarItem(
                      icon: Icon(Icons.home_outlined),
                      activeIcon: Icon(Icons.home),
                      label: "Home",
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.question_answer_outlined),
                      activeIcon: Icon(Icons.question_answer),
                      label: "Enquiry",
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
