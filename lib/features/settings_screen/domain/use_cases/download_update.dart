import 'package:asiec_schedule/features/settings_screen/domain/repositories/update_repository.dart';

class DownloadUpdate {
  final UpdateRepository repository;

  DownloadUpdate(this.repository);

  Future<String> call(String downloadUrl) async {
    return await repository.downloadUpdate(downloadUrl);
  }
}
