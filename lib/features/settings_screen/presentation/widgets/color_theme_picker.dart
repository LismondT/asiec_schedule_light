import 'package:asiec_schedule/core/bloc/theme/theme_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'color_picker_dialog.dart';

class ColorThemePicker extends StatelessWidget {
  const ColorThemePicker({super.key});

  @override
  Widget build(BuildContext context) {
    final Color currentSeedColor = context.watch<ThemeCubit>().state.seedColor;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.palette,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        title: const Text(
          'Цвет темы',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: const Text('Настройте основной цвет приложения'),
        trailing: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
            border: Border.all(
              color: Theme.of(context).colorScheme.secondaryContainer,
              width: 2,
            ),
          ),
        ),
        onTap: () => _showColorPickerDialog(context),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    );
  }

  void _showColorPickerDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return const ColorPickerDialog();
      },
    );
  }
}
