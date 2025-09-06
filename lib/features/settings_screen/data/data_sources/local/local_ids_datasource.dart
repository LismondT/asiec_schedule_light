
import 'package:asiec_schedule/features/settings_screen/domain/entities/setting_ids_entity.dart';

abstract class LocalIdsDatasource {
  Future<SettingIdsEntity> loadIds();
  Future<void> saveIds(SettingIdsEntity ids);
}