import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppShell extends StatelessWidget {
  final Widget child;

  const AppShell({super.key, required this.child});

  int _indexFromLocation(String location) {
    if (location.startsWith('/subjects')) return 1;
    if (location.startsWith('/calendar')) return 2; // planner = calendar
    if (location.startsWith('/resources')) return 3;
    if (location.startsWith('/profile')) return 4;
    return 0; // home
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    final currentIndex = _indexFromLocation(location);

    return PopScope(
      // Only allow system back when on Home tab
      canPop: currentIndex == 0,

      // ✅ NEW API (Flutter 3.22+)
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;

        // If user presses back from any tab except Home
        if (currentIndex != 0) {
          context.go('/home');
        }
      },

      child: Scaffold(
        body: child,
        bottomNavigationBar: NavigationBar(
          selectedIndex: currentIndex,
          onDestinationSelected: (index) {
            switch (index) {
              case 0:
                context.go('/home');
                break;
              case 1:
                context.go('/subjects');
                break;
              case 2:
                context.go('/calendar');
                break;
              case 3:
                context.go('/resources');
                break;
              case 4:
                context.go('/profile');
                break;
            }
          },
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.menu_book_outlined),
              selectedIcon: Icon(Icons.menu_book),
              label: 'Subjects',
            ),
            NavigationDestination(
              icon: Icon(Icons.calendar_month_outlined),
              selectedIcon: Icon(Icons.calendar_month),
              label: 'Planner',
            ),
            NavigationDestination(
              icon: Icon(Icons.folder_outlined),
              selectedIcon: Icon(Icons.folder),
              label: 'Resources',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
