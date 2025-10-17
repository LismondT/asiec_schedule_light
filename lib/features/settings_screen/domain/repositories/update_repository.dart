import 'package:asiec_schedule/features/settings_screen/domain/entities/update_info.dart';

abstract class UpdateRepository {
  Future<UpdateInfo> checkForUpdate();

  Future<String> downloadUpdate(String downloadUrl);
}
