
import 'package:asiec_schedule/core/domain/entity/schedule_entity.dart';

sealed class ScheduleState {}

class ScheduleStateInit extends ScheduleState {}

class ScheduleStateLoading extends ScheduleState {}

class ScheduleStateLoaded extends ScheduleState {
  final ScheduleEntity data;
  ScheduleStateLoaded(this.data);
}

class ScheduleStateEmpty extends ScheduleState {}

class ScheduleStateIdUnselected extends ScheduleState {}

class ScheduleStateError extends ScheduleState {
  final String message;
  ScheduleStateError(this.message);
}
