
import 'package:asiec_schedule/core/domain/use_cases/use_case.dart';
import 'package:asiec_schedule/core/enums/schedule_request_type.dart';
import 'package:asiec_schedule/features/settings_screen/domain/repositories/settings_fields_repository.dart';

class GetSettingsFieldsUseCase extends UseCase {
  final SettingsFieldsRepository _repository;

  GetSettingsFieldsUseCase(this._repository);
  
  @override
  Future<Map<ScheduleRequestType, Map<String, String>>> call({params}) async {
    return await _repository.getSettingsFields();
  }
}