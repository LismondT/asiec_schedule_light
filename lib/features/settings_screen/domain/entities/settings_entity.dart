
import 'package:asiec_schedule/core/enums/schedule_request_type.dart';
import 'package:flutter/material.dart';

class SettingsEntity {
  final bool isDarkMode;
  final Color shemeColor;
  final ScheduleRequestType requestType;
  final String requestId;
  
  SettingsEntity({
    required this.isDarkMode,
    required this.shemeColor,
    required this.requestType,
    required this.requestId
  });
}