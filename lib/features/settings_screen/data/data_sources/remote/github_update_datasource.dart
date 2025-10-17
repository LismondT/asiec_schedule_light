import 'package:asiec_schedule/features/settings_screen/data/data_sources/remote/update_remote_datasource.dart';
import 'package:asiec_schedule/features/settings_screen/data/models/github_release_model.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';

class GithubUpdateDataSource implements UpdateRemoteDataSource {
  final Dio dio;
  final String repoOwner;
  final String repoName;
  final bool isAltag;

  GithubUpdateDataSource({
    required this.dio,
    required this.repoOwner,
    required this.repoName,
    required this.isAltag,
  });

  @override
  Future<GitHubReleaseModel> getLatestRelease() async {
    final response = await dio.get(
      'https://api.github.com/repos/$repoOwner/$repoName/releases/latest',
    );

    if (response.statusCode == 200) {
      return GitHubReleaseModel.fromJson(response.data);
    } else {
      throw Exception('Failed to fetch latest release');
    }
  }

  @override
  Future<String> downloadApk(String downloadUrl, String savePath) async {
    await dio.download(downloadUrl, savePath);
    return savePath;
  }

  String? getCorrectApkAssetUrl(List<GitHubAssetModel> assets) {
    final prefix = isAltag ? 'altag_schedule' : 'asiec_schedule';

    try {
      final asset = assets.firstWhere(
        (asset) => asset.name.startsWith(prefix) && asset.name.endsWith('.apk'),
      );
      return asset.browserDownloadUrl;
    } catch (e) {
      return null;
    }
  }

  Future<String> getApkSavePath() async {
    final directory = await getTemporaryDirectory();
    return '${directory.path}/app-update.apk';
  }
}
