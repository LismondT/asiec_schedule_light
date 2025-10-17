class GitHubReleaseModel {
  final String tagName;
  final String name;
  final String body;
  final List<GitHubAssetModel> assets;

  GitHubReleaseModel({
    required this.tagName,
    required this.name,
    required this.body,
    required this.assets,
  });

  factory GitHubReleaseModel.fromJson(Map<String, dynamic> json) {
    return GitHubReleaseModel(
      tagName: json['tag_name'],
      name: json['name'],
      body: json['body'],
      assets: (json['assets'] as List)
          .map((asset) => GitHubAssetModel.fromJson(asset))
          .toList(),
    );
  }
}

class GitHubAssetModel {
  final String name;
  final String browserDownloadUrl;
  final int size;

  GitHubAssetModel({
    required this.name,
    required this.browserDownloadUrl,
    required this.size,
  });

  factory GitHubAssetModel.fromJson(Map<String, dynamic> json) {
    return GitHubAssetModel(
      name: json['name'],
      browserDownloadUrl: json['browser_download_url'],
      size: json['size'] ?? 0,
    );
  }
}
