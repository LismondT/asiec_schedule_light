import 'package:asiec_schedule/features/settings_screen/data/models/github_release_model.dart';

abstract class UpdateRemoteDataSource {
  Future<GitHubReleaseModel> getLatestRelease();
  Future<String> downloadApk(String downloadUrl, String savePath);
}