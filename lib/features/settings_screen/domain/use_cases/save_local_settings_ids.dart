import 'package:asiec_schedule/features/settings_screen/domain/entities/setting_ids_entity.dart';
import 'package:asiec_schedule/features/settings_screen/domain/repositories/settings_repository.dart';

class SaveLocalSettingIds {
  final SettingsRepository _repository;

  SaveLocalSettingIds(this._repository);

  Future<void> call(SettingIdsEntity ids) async {
    await _repository.saveIds(ids);
  }
}