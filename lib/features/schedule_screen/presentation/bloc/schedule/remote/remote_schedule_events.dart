
import 'package:asiec_schedule/core/enums/schedule_request_type.dart';

abstract class RemoteScheduleEvent {
  const RemoteScheduleEvent();
}

class InitializeScheduleEvent extends RemoteScheduleEvent {
  const InitializeScheduleEvent();
}

class GetDefaultScheduleEvent extends RemoteScheduleEvent {
  const GetDefaultScheduleEvent();
}

class RequestDataSchangedEvent extends RemoteScheduleEvent {
  final ScheduleRequestType requestType;
  final String requestId;

  RequestDataSchangedEvent({
    required this.requestType,
    required this.requestId,
  });
}