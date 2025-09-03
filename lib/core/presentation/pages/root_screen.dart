import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

import '../../../features/schedule_screen/presentation/bloc/schedule/remote/remote_schedule_bloc.dart';
import '../../../features/schedule_screen/presentation/pages/schedule_screen.dart';
import '../../../features/settings_screen/presentation/pages/settings_screen.dart';
import '../../../features/timer_screen/pair_timer_screen.dart';


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
            const SizedBox(width: 40), // Место для центральной кнопки
            _buildNavItem(2, Icons.settings, 'Настройки', context),
          ],
        ),
      ),
    );
  }

  Widget _buildCenterButton(BuildContext context) {
    final isCenterSelected = navigationShell.currentIndex == 0;
    return FloatingActionButton(
      onPressed: () => navigationShell.goBranch(0),
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
      onPressed: () => navigationShell.goBranch(
        index,
        initialLocation: index == navigationShell.currentIndex,
      ),
    );
  }
}
