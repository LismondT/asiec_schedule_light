import 'package:asiec_schedule/features/settings_screen/presentation/bloc/settings_bloc.dart';
import 'package:asiec_schedule/features/settings_screen/presentation/bloc/settings_event.dart';
import 'package:flutter/material.dart';

class RequestIdDialog extends StatelessWidget {
  final SettingsBloc settingsBloc;
  
  const RequestIdDialog({super.key, required this.settingsBloc});

  @override
  Widget build(BuildContext context) { 
    final ids = settingsBloc.currentRequestIds.keys;

    return AlertDialog(
      title: const Text('Выберите '),
      content: SingleChildScrollView(
        child: ListBody(
          children: ids.map((idKey) {
            
            return InkWell(
              onTap: () {
                settingsBloc.add(SelectRequestIdEvent(idKey));
                Navigator.of(context).pop();
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
          child: const Text('Закрыть')
        )
      ],
    );
  }
}