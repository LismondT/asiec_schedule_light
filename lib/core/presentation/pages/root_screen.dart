import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class RootScreen extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const RootScreen({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true, // Важно для прозрачности!
      body: navigationShell,
      floatingActionButton: _buildCenterButton(context),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: _buildTransparentBottomAppBar(context),
    );
  }

  Widget _buildTransparentBottomAppBar(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 16, left: 16, right: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: const ColorFilter.mode(Colors.transparent, BlendMode.srcOver),
          child: Container(
            decoration: BoxDecoration(
              color: colorScheme.surface.withOpacity(0.8),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: colorScheme.primary.withOpacity(0.5),
              ),
            ),
            child: BottomAppBar(
              height: 60,
              padding: EdgeInsets.zero,
              color: Colors.transparent,
              surfaceTintColor: Colors.transparent,
              elevation: 16,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildNavItem(1, Icons.timer_outlined, 'Время', context),
                  const SizedBox(width: 40),
                  _buildNavItem(2, Icons.settings, 'Настройки', context),
                ],
              ),
            ),
          ),
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
      elevation: 2,
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
      int index,
      IconData icon,
      String label,
      BuildContext context,
      ) {
    final isSelected = navigationShell.currentIndex == index;
    final colorScheme = Theme.of(context).colorScheme;

    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _navigateToBranch(index),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            height: 56,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: isSelected
                  ? colorScheme.primary.withOpacity(0.15)
                  : Colors.transparent,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 24,
                  color: isSelected
                      ? colorScheme.primary
                      : colorScheme.onSurface,
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    color: isSelected
                        ? colorScheme.primary
                        : colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _navigateToBranch(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: false,
    );
  }
}