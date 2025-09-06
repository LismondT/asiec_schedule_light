
import 'package:asiec_schedule/features/settings_screen/domain/entities/setting_ids_entity.dart';

abstract class RemoteIdsDatasource {
  Future<SettingIdsEntity> loadIds();
}