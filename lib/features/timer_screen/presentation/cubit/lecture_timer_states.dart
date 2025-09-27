import 'package:asiec_schedule/core/domain/entity/lesson_entity.dart';
import 'package:flutter/material.dart';

sealed class LectureTimerState {}

class LectureTimerInitState extends LectureTimerState {}

class LectureTimerLoadingState extends LectureTimerState {}

class LectureTimerLessonState extends LectureTimerState {
  final LessonEntity lesson;
  final Duration freeTime;

  LectureTimerLessonState(this.lesson, this.freeTime);
}

class LectureTimerFreeTimeState extends LectureTimerState {
  final LessonEntity? nextLesson;
  final TimeOfDay start;
  final TimeOfDay end;

  Duration get duration => Duration(
      hours: end.hour - start.hour, minutes: end.minute - start.minute);

  LectureTimerFreeTimeState(this.start, this.end, this.nextLesson);
}

class LectureTimerHolidaysState extends LectureTimerState {}

class LectureTimerBeforeLessonsStartState extends LectureTimerState {
  final LessonEntity lesson;

  LectureTimerBeforeLessonsStartState(this.lesson);
}
