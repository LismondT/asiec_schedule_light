import 'package:asiec_schedule/core/enums/schedule_request_type.dart';
import 'package:asiec_schedule/features/settings_screen/domain/repositories/settings_fields_repository.dart';

import '../data_sources/remote/asiec_ids_api.dart';

class AsiecSettingsFieldsRepositoryImpl extends SettingsFieldsRepository{
  final AsiecIdsApi _api;

  AsiecSettingsFieldsRepositoryImpl(this._api);

  @override
  Future<Map<ScheduleRequestType, Map<String, String>>> getSettingsFields() async {
    return await _api.getIds();
  }
}