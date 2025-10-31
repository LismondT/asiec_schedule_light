import 'package:asiec_schedule/core/bloc/theme/color_options.dart';
import 'package:asiec_schedule/core/bloc/theme/theme_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'color_option_item.dart';

class ColorPickerDialog extends StatelessWidget {
  const ColorPickerDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeCubit themeCubit = context.read<ThemeCubit>();
    final Color currentColor = themeCubit.state.seedColor;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: _ColorPickerContent(
        currentColor: currentColor,
        onColorSelected: (color) {
          themeCubit.setSeedColor(color);
          Navigator.of(context).pop();
          _showColorChangeSnackbar(context, color);
        },
      ),
    );
  }

  void _showColorChangeSnackbar(BuildContext context, Color color) {
    final colorName = _getColorName(color);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.palette, color: Colors.white),
            const SizedBox(width: 8),
            Text('Тема изменена на $colorName'),
          ],
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  String _getColorName(Color color) {
    for (var option in colorOptions) {
      if ((option['color'] as Color).value == color.value) {
        return option['name'] as String;
      }
    }
    return 'Пользовательский';
  }
}

class _ColorPickerContent extends StatelessWidget {
  final Color currentColor;
  final ValueChanged<Color> onColorSelected;

  const _ColorPickerContent({
    required this.currentColor,
    required this.onColorSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Заголовок с градиентом
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  currentColor.withOpacity(0.8),
                  currentColor.withOpacity(0.4),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.palette,
                  size: 40,
                  color: Colors.white,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Выберите цвет темы',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Текущий цвет: ${_getCurrentColorName(currentColor)}',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),

          // Палитра цветов
          Padding(
            padding: const EdgeInsets.all(20),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
                childAspectRatio: 0.78,
              ),
              itemCount: colorOptions.length,
              itemBuilder: (context, index) {
                final colorData = colorOptions[index];
                final color = colorData['color'] as Color;
                final isSelected = color.value == currentColor.value;

                return ColorOptionItem(
                  color: color,
                  name: colorData['name'] as String,
                  icon: colorData['icon'] as IconData,
                  isSelected: isSelected,
                  onTap: () => onColorSelected(color),
                );
              },
            ),
          ),

          // Кнопка закрытия
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.1),
                      foregroundColor: Theme.of(context).colorScheme.onSurface,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('Закрыть'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getCurrentColorName(Color color) {
    for (var option in colorOptions) {
      if ((option['color'] as Color).value == color.value) {
        return option['name'] as String;
      }
    }
    return 'Пользовательский';
  }
}
