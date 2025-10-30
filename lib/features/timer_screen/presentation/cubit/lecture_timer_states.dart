import 'package:asiec_schedule/core/domain/entity/lesson.dart';
import 'package:asiec_schedule/core/enums/schedule_request_type.dart';
import 'package:flutter/material.dart';

sealed class LectureTimerState {}

class LectureTimerInitState extends LectureTimerState {}

class LectureTimerLoadingState extends LectureTimerState {}

class LectureTimerLessonState extends LectureTimerState {
  final ScheduleRequestType requestType;
  final Lesson lesson;
  final Duration freeTime;

  LectureTimerLessonState(this.lesson, this.freeTime,
      {this.requestType = ScheduleRequestType.groups});
}

class LectureTimerFreeTimeState extends LectureTimerState {
  final ScheduleRequestType requestType;
  final Lesson? nextLesson;
  final TimeOfDay start;
  final TimeOfDay end;

  Duration get duration => Duration(
      hours: end.hour - start.hour, minutes: end.minute - start.minute);

  LectureTimerFreeTimeState(this.start, this.end, this.nextLesson,
      {this.requestType = ScheduleRequestType.groups});
}

class LectureTimerHolidaysState extends LectureTimerState {}

class LectureTimerBeforeLessonsStartState extends LectureTimerState {
  final ScheduleRequestType requestType;
  final Lesson lesson;

  LectureTimerBeforeLessonsStartState(this.lesson,
      {this.requestType = ScheduleRequestType.groups});
}
