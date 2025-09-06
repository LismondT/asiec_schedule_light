

import 'package:asiec_schedule/features/settings_screen/domain/entities/setting_ids_entity.dart';
import 'package:asiec_schedule/features/settings_screen/domain/repositories/settings_repository.dart';

class GetLocalSettingIds {
  final SettingsRepository _repository;

  GetLocalSettingIds(this._repository);

  Future<SettingIdsEntity> call() async {
    return await _repository.getIdsLocal();
  }
}