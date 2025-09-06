import 'package:asiec_schedule/features/settings_screen/domain/entities/settings_entity.dart';
import 'package:asiec_schedule/features/settings_screen/domain/repositories/settings_repository.dart';

class GetSettings {
  final SettingsRepository repository;

  GetSettings(this.repository);

  Future<SettingsEntity> call() async {
    return await repository.getSettings();
  }
}
