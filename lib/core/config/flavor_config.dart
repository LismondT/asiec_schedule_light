

import 'package:package_info_plus/package_info_plus.dart';

enum AppFlavor { asiec, altag }

class FlavorConfig {
  final AppFlavor flavor;
  final String name;
  late String version;
  late String buildNumber;

  static FlavorConfig? _instance;

  FlavorConfig._internal({required this.flavor, required this.name});

  factory FlavorConfig({required AppFlavor flavor, required String name}) {
    _instance ??= FlavorConfig._internal(flavor: flavor, name: name);
    return _instance!;
  }

  Future<void> initializeVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    version = packageInfo.version;
    buildNumber = packageInfo.buildNumber;
  }

  static FlavorConfig get instance {
    return _instance!;
  }

  bool get isAsiec => flavor == AppFlavor.asiec;

  bool get isAltag => flavor == AppFlavor.altag;

  String get displayVersion => 'v$version (build $buildNumber';
}
