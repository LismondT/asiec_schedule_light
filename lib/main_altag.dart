import 'package:asiec_schedule/app.dart';
import 'package:asiec_schedule/core/config/flavor_config.dart';
import 'package:asiec_schedule/injection_container.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  FlavorConfig(flavor: AppFlavor.altag, name: "Altag Schedule");

  await initializeDependencies();

  runApp(const MyApp());
}
