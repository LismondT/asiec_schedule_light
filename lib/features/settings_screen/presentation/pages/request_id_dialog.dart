import 'package:asiec_schedule/features/schedule_screen/presentation/cubit/schedule_cubit.dart';
import 'package:asiec_schedule/features/settings_screen/presentation/cubit/settings_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RequestIdDialog extends StatelessWidget {
  final Map<String, String> ids;

  const RequestIdDialog({super.key, required this.ids});

  @override
  Widget build(BuildContext context) {
    final keys = ids.keys.toList()..sort();

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              'Выберите',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 400),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: keys.length,
              itemBuilder: (context, index) {
                final idKey = keys[index];
                return ListTile(
                  title: Text(idKey),
                  onTap: () => _handleIdSelection(context, ids[idKey]!),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Закрыть'),
            ),
          ),
        ],
      ),
    );
  }

  void _handleIdSelection(BuildContext context, String id) {
    final settingsCubit = context.read<SettingsCubit>();
    final scheduleCubit = context.read<ScheduleCubit>();

    Navigator.of(context).pop();

    Future.microtask(() async {
      await settingsCubit.changeRequestId(id);
      await scheduleCubit.loadDefaultSchedule();
    });
  }
}