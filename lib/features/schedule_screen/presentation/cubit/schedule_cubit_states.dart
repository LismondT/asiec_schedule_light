import 'package:asiec_schedule/core/domain/entity/schedule_entity.dart';
import 'package:asiec_schedule/core/enums/schedule_request_type.dart';

sealed class ScheduleState {}

class ScheduleStateInit extends ScheduleState {}

class ScheduleStateLoading extends ScheduleState {}

class ScheduleStateLoaded extends ScheduleState {
  final ScheduleEntity data;
  final ScheduleRequestType type;
  final bool isLocalSchedule;

  ScheduleStateLoaded(this.data, this.type, {this.isLocalSchedule = false});
}

class ScheduleStateEmpty extends ScheduleState {}

class ScheduleStateIdUnselected extends ScheduleState {}

class ScheduleStateError extends ScheduleState {
  final String message;

  ScheduleStateError(this.message);
}
