import 'package:asiec_schedule/core/config/flavor_config.dart';
import 'package:asiec_schedule/features/settings_screen/data/data_sources/remote/github_update_datasource.dart';
import 'package:asiec_schedule/features/settings_screen/data/data_sources/remote/update_remote_datasource.dart';
import 'package:asiec_schedule/features/settings_screen/domain/entities/update_info.dart';
import 'package:asiec_schedule/features/settings_screen/domain/repositories/update_repository.dart';
import 'package:asiec_schedule/injection_container.dart';

class UpdateRepositoryImpl implements UpdateRepository {
  final UpdateRemoteDataSource remoteDataSource;

  UpdateRepositoryImpl({required this.remoteDataSource});

  @override
  Future<UpdateInfo> checkForUpdate() async {
    try {
      final currentVersion = FlavorConfig.instance.version;

      final latestRelease = await remoteDataSource.getLatestRelease();

      if (_isNewVersionAvailable(currentVersion, latestRelease.tagName)) {
        final downloadUrl = (remoteDataSource as GithubUpdateDataSource)
            .getCorrectApkAssetUrl(latestRelease.assets);

        if (downloadUrl == null) {
          return UpdateInfo.error(
            currentVersion: currentVersion,
            error: 'APK файл не найден',
          );
        }

        return UpdateInfo(
          hasUpdate: true,
          currentVersion: currentVersion,
          latestVersion: latestRelease.tagName,
          releaseName: latestRelease.name,
          releaseBody: latestRelease.body,
          downloadUrl: downloadUrl,
        );
      }

      return UpdateInfo.noUpdate(currentVersion: currentVersion);
    } catch (e) {
      return UpdateInfo.error(
        currentVersion: FlavorConfig.instance.version,
        error: e.toString(),
      );
    }
  }

  @override
  Future<String> downloadUpdate(String downloadUrl) async {
    final savePath =
        await (remoteDataSource as GithubUpdateDataSource).getApkSavePath();
    return await remoteDataSource.downloadApk(downloadUrl, savePath);
  }

  bool _isNewVersionAvailable(String currentVersion, String latestVersion) {
    final current = currentVersion.replaceAll('v', '');
    final latest = latestVersion.replaceAll('v', '');

    final currentParts =
        current.split('.').map((e) => int.tryParse(e) ?? 0).toList();
    final latestParts =
        latest.split('.').map((e) => int.tryParse(e) ?? 0).toList();

    while (currentParts.length < latestParts.length) {
      currentParts.add(0);
    }
    while (latestParts.length < currentParts.length) {
      latestParts.add(0);
    }

    for (int i = 0; i < latestParts.length; i++) {
      if (latestParts[i] > currentParts[i]) return true;
      if (latestParts[i] < currentParts[i]) return false;
    }
    return false;
  }
}
