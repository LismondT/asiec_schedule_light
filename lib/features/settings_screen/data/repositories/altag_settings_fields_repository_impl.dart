import 'package:asiec_schedule/core/enums/schedule_request_type.dart';
import 'package:asiec_schedule/features/settings_screen/data/data_sources/remote/altag_ids_api.dart';
import 'package:asiec_schedule/features/settings_screen/domain/repositories/settings_fields_repository.dart';

class AltagSettingsFieldsRepositoryImpl extends SettingsFieldsRepository{
  final AltagIdsApi _api;

  AltagSettingsFieldsRepositoryImpl(this._api);
  
  @override
  Future<Map<ScheduleRequestType, Map<String, String>>> getSettingsFields() async {
    return await _api.getIds();
  }
}