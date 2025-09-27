import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class RootScreen extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const RootScreen({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).colorScheme;

    return Scaffold(
      body: PageTransitionSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (
            Widget child,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
            ) {
          return SharedAxisTransition(
            animation: animation,
            secondaryAnimation: secondaryAnimation,
            transitionType: SharedAxisTransitionType.horizontal,
            child: child,
          );
        },
        child: navigationShell,
      ),
      floatingActionButton: _buildCenterButton(context),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        height: 70,
        padding: EdgeInsets.zero,
        color: theme.secondaryContainer,
        shape: const CircularNotchedRectangle(),
        notchMargin: 16,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(1, Icons.timer_outlined, 'Время', context),
            const SizedBox(width: 20),
            _buildNavItem(2, Icons.settings, 'Настройки', context),
          ],
        ),
      ),
    );
  }

  Widget _buildCenterButton(BuildContext context) {
    final isCenterSelected = navigationShell.currentIndex == 0;
    return FloatingActionButton(
      onPressed: () => _navigateToBranch(0),
      shape: const CircleBorder(),
      backgroundColor: isCenterSelected
          ? Theme.of(context).colorScheme.primary
          : Theme.of(context).colorScheme.primaryContainer,
      elevation: isCenterSelected ? 6 : 4,
      child: Icon(
        Icons.schedule,
        color: isCenterSelected
            ? Theme.of(context).colorScheme.onPrimary
            : Theme.of(context).colorScheme.onPrimaryContainer,
        size: 28,
      ),
    );
  }

  Widget _buildNavItem(
      int index, IconData icon, String label, BuildContext context) {
    final isSelected = navigationShell.currentIndex == index;
    return IconButton(
      icon: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.onSecondaryContainer,
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.onSecondaryContainer,
            ),
          ),
        ],
      ),
      onPressed: () => _navigateToBranch(index),
    );
  }

  void _navigateToBranch(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: false, //- это важно для анимации!
      //initialLocation: index == navigationShell.currentIndex,
    );
  }
}