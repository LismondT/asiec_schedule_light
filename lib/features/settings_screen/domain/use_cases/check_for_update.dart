import 'package:asiec_schedule/features/settings_screen/domain/entities/update_info.dart';
import 'package:asiec_schedule/features/settings_screen/domain/repositories/update_repository.dart';

class CheckForUpdate {
  final UpdateRepository repository;

  CheckForUpdate(this.repository);

  Future<UpdateInfo> call() async {
    return await repository.checkForUpdate();
  }
}
