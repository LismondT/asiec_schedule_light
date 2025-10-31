import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart';

enum AppFlavor { asiec, altag }

class FlavorConfig {
  final AppFlavor flavor;
  final String name;
  late final String version;
  late final String buildNumber;
  late final Map<String, dynamic> _config;

  static FlavorConfig? _instance;

  FlavorConfig._internal({required this.flavor, required this.name});

  factory FlavorConfig({required AppFlavor flavor, required String name}) {
    _instance ??= FlavorConfig._internal(flavor: flavor, name: name);
    return _instance!;
  }

  Future<void> initialize() async {
    final packageInfo = await PackageInfo.fromPlatform();
    version = packageInfo.version;
    buildNumber = packageInfo.buildNumber;

    final String configString =
        await rootBundle.loadString('assets/config.json');
    _config = jsonDecode(configString);
  }

  static FlavorConfig get instance {
    return _instance!;
  }

  String get metricaApi => _config['metrica_api_key'];

  bool get isAsiec => flavor == AppFlavor.asiec;

  bool get isAltag => flavor == AppFlavor.altag;

  String get displayVersion => 'v$version (build $buildNumber)';
}
