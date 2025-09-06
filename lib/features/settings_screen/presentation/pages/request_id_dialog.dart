import 'package:asiec_schedule/features/schedule_screen/presentation/cubit/schedule_cubit.dart';
import 'package:asiec_schedule/features/settings_screen/presentation/cubit/settings_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RequestIdDialog extends StatelessWidget {
  final Map<String, String> ids;

  const RequestIdDialog({super.key, required this.ids});

  @override
  Widget build(BuildContext context) {
    final keys = ids.keys;

    return AlertDialog(
      title: const Text('Выберите '),
      content: SingleChildScrollView(
        child: ListBody(
          children: keys.map((idKey) {
            return InkWell(
              onTap: () async {
                final id = ids[idKey] ?? '';
                _handleIdSelection(context, id);
              },
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(idKey),
              ),
            );
          }).toList(),
        ),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Закрыть'))
      ],
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
