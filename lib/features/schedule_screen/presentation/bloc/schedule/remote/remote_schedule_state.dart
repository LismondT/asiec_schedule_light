
import 'dart:async';

import 'package:asiec_schedule/core/domain/entity/day_entity.dart';

abstract class RemoteScheduleState {
  final StreamController<List<DayEntity>>? scheduleController;

  const RemoteScheduleState({this.scheduleController});
}

class RemoteScheduleLoading extends RemoteScheduleState {
  const RemoteScheduleLoading();
}

class RemoteScheduleError extends RemoteScheduleState {
  final String message;
  const RemoteScheduleError(this.message);
}

class RemoteScheduleDone extends RemoteScheduleState {
  const RemoteScheduleDone({super.scheduleController});
}

class RemoteScheduleWithoutId extends RemoteScheduleState {
  const RemoteScheduleWithoutId();
}