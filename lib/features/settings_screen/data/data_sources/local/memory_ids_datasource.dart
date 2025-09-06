import 'package:asiec_schedule/features/settings_screen/data/data_sources/local/local_ids_datasource.dart';
import 'package:asiec_schedule/features/settings_screen/domain/entities/setting_ids_entity.dart';

class MemoryIdsDatasource extends LocalIdsDatasource {
  SettingIdsEntity _ids =
      SettingIdsEntity(groupIds: {}, teacherIds: {}, classroomIds: {});

  @override
  Future<SettingIdsEntity> loadIds() async {
    return _ids;
  }

  @override
  Future<void> saveIds(SettingIdsEntity ids) async {
    _ids = ids;
  }
}
