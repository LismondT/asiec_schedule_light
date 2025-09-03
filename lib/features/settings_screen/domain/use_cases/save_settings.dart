
import 'package:asiec_schedule/core/domain/use_cases/use_case.dart';
import 'package:asiec_schedule/features/settings_screen/domain/entities/settings_entity.dart';
import 'package:asiec_schedule/features/settings_screen/domain/repositories/settings_repository.dart';

class SaveSettingsUseCase extends UseCase {
  final SettingsRepository repository;

  SaveSettingsUseCase(this.repository);
  
  @override
  Future<void> call({params}) async {
    await repository.saveSettings(params as SettingsEntity);
  }

  
}