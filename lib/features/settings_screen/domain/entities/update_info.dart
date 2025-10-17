
class UpdateInfo {
  final bool hasUpdate;
  final String currentVersion;
  final String latestVersion;
  final String releaseName;
  final String releaseBody;
  final String downloadUrl;
  final String? error;

  UpdateInfo({
    required this.hasUpdate,
    required this.currentVersion,
    required this.latestVersion,
    required this.releaseName,
    required this.releaseBody,
    required this.downloadUrl,
    this.error,
  });

  factory UpdateInfo.noUpdate({required String currentVersion}) {
    return UpdateInfo(
      hasUpdate: false,
      currentVersion: currentVersion,
      latestVersion: currentVersion,
      releaseName: '',
      releaseBody: '',
      downloadUrl: '',
    );
  }

  factory UpdateInfo.error({
    required String currentVersion,
    required String error,
  }) {
    return UpdateInfo(
      hasUpdate: false,
      currentVersion: currentVersion,
      latestVersion: currentVersion,
      releaseName: '',
      releaseBody: '',
      downloadUrl: '',
      error: error,
    );
  }
}
