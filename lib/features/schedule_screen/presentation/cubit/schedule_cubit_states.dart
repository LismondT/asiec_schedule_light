import 'package:asiec_schedule/core/domain/entity/schedule.dart';
import 'package:asiec_schedule/core/enums/schedule_request_type.dart';

sealed class ScheduleState {}

class ScheduleStateInit extends ScheduleState {}

class ScheduleStateLoading extends ScheduleState {}

class ScheduleStateLoaded extends ScheduleState {
  final Schedule data;
  final ScheduleRequestType type;
  final bool isLocalSchedule;

  ScheduleStateLoaded(this.data, this.type, {this.isLocalSchedule = false});
}

class ScheduleStateLoadedByDate extends ScheduleState {
  final Schedule data;
  final ScheduleRequestType type;

  ScheduleStateLoadedByDate(this.data, this.type);
}

class ScheduleStateEmpty extends ScheduleState {}

class ScheduleStateIdUnselected extends ScheduleState {}

class ScheduleStateError extends ScheduleState {
  final String message;

  ScheduleStateError(this.message);
}
