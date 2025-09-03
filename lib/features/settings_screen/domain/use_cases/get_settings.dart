
import 'package:asiec_schedule/core/domain/use_cases/use_case.dart';
import 'package:asiec_schedule/features/settings_screen/domain/entities/settings_entity.dart';
import 'package:asiec_schedule/features/settings_screen/domain/repositories/settings_repository.dart';

class GetSettingsUseCase extends UseCase {
  final SettingsRepository repository;

  GetSettingsUseCase(this.repository);
  
  @override
  Future<SettingsEntity> call({params}) async {
    return await repository.getSettings();
  }
}