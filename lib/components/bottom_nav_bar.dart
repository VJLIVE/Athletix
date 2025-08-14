import 'package:flutter/material.dart';
import 'package:athletix/l10n/app_localizations.dart';

/// A reusable bottom navigation bar widget that adapts to user role.
class BottomNavBar extends StatelessWidget {
  /// The currently selected index in the navigation bar.
  final int currentIndex;

  /// Callback when a navigation item is tapped.
  final ValueChanged<int> onTap;

  /// The role of the current user (affects navigation items).
  final String role;

  /// Creates a [BottomNavBar] widget.
  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.role,
  });

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final List<BottomNavigationBarItem> items;

    if (role == 'Organization') {
      items = [
        BottomNavigationBarItem(
          icon: const Icon(Icons.home),
          label: localizations.homeLabel,
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.people),
          label: localizations.playersLabel,
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.event),
          label: localizations.tournamentsLabel,
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.person),
          label: localizations.profileLabel,
        ),
      ];
    } else {
      // fallback for Athlete, Coach, Doctor
      items = [
        BottomNavigationBarItem(
          icon: const Icon(Icons.home),
          label: localizations.homeLabel,
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.calendar_today),
          label: localizations.timeTableLabel,
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.location_on),
          label: localizations.tournamentsLabel,
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.person),
          label: localizations.profileLabel,
        ),
      ];
    }

    return BottomNavigationBar(
      currentIndex: currentIndex,
      selectedItemColor: Colors.blue,
      unselectedItemColor: Colors.grey,
      type: BottomNavigationBarType.fixed,
      onTap: onTap,
      items: items,
    );
  }
}
