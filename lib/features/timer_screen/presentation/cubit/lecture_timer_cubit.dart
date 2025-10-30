import 'dart:async';

import 'package:asiec_schedule/core/domain/entity/lesson.dart';
import 'package:asiec_schedule/features/timer_screen/domain/use_cases/get_current_day.dart';
import 'package:asiec_schedule/features/timer_screen/presentation/cubit/lecture_timer_states.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';

class LectureTimerCubit extends Cubit<LectureTimerState> {
  final GetCurrentDay _getCurrentDay;
  Timer? _timer;

  LectureTimerCubit(this._getCurrentDay) : super(LectureTimerInitState());

  void startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _checkCurrentTime();
    });
    _checkCurrentTime();
  }

  void stopTimer() async {
    _timer?.cancel();
    _timer = null;
  }

  void _checkCurrentTime() async {
    final now = DateTime.now();
    final currentTime = TimeOfDay.fromDateTime(now);

    final todaySchedule = await _getCurrentDay();

    if (todaySchedule == null) {
      emit(LectureTimerHolidaysState());
      return;
    }

    final firstLesson = todaySchedule.lessons.first;
    if (now.isBefore(_getDateTimeFromTimeOfDay(firstLesson.startTime, now))) {
      emit(LectureTimerBeforeLessonsStartState(firstLesson));
      return;
    }

    final lastLesson = todaySchedule.lessons.last;
    if (now.isAfter(_getDateTimeFromTimeOfDay(lastLesson.endTime, now))) {
      // ToDo: after lessons state
      emit(LectureTimerHolidaysState());
      return;
    }

    Lesson? currentLesson;
    for (final lesson in todaySchedule.lessons) {
      final lessonStart = _getDateTimeFromTimeOfDay(lesson.startTime, now);
      final lessonEnd = _getDateTimeFromTimeOfDay(lesson.endTime, now);

      if (now.isAfter(lessonStart) && now.isBefore(lessonEnd)) {
        currentLesson = lesson;
        break;
      }
    }

    if (currentLesson != null) {
      // Мы на уроке
      final lessonEnd = _getDateTimeFromTimeOfDay(currentLesson.endTime, now);
      final nextLesson = _findNextLesson(todaySchedule.lessons, currentLesson);

      if (nextLesson != null) {
        // Если есть следующий урок, вычисляем длительность перемены
        final nextLessonStart =
            _getDateTimeFromTimeOfDay(nextLesson.startTime, now);
        final breakDuration = nextLessonStart.difference(lessonEnd);
        emit(LectureTimerLessonState(currentLesson, breakDuration));
      } else {
        // Если это последний урок, перемены нет
        emit(LectureTimerLessonState(currentLesson, Duration.zero));
      }
    } else {
      // Мы в перерыве между уроками
      _findFreeTimePeriod(todaySchedule.lessons, currentTime, now);
    }
  }

  Lesson? _findNextLesson(
      List<Lesson> lessons, Lesson currentLesson) {
    final currentIndex = lessons.indexOf(currentLesson);
    if (currentIndex != -1 && currentIndex < lessons.length - 1) {
      return lessons[currentIndex + 1];
    }
    return null;
  }

  void _findFreeTimePeriod(
      List<Lesson> lessons, TimeOfDay currentTime, DateTime now) {
    Lesson? nextLesson;
    TimeOfDay freeTimeStart = currentTime;
    TimeOfDay freeTimeEnd = currentTime;

    for (int i = 0; i < lessons.length - 1; i++) {
      final currentLesson = lessons[i];
      final nextLessonCandidate = lessons[i + 1];

      final currentEnd = _getDateTimeFromTimeOfDay(currentLesson.endTime, now);
      final nextStart =
          _getDateTimeFromTimeOfDay(nextLessonCandidate.startTime, now);

      if (now.isAfter(currentEnd) && now.isBefore(nextStart)) {
        freeTimeStart = currentLesson.endTime;
        freeTimeEnd = nextLessonCandidate.startTime;
        nextLesson = nextLessonCandidate;
        break;
      }
    }

    emit(LectureTimerFreeTimeState(freeTimeStart, freeTimeEnd, nextLesson));
  }

  DateTime _getDateTimeFromTimeOfDay(TimeOfDay timeOfDay, DateTime date) {
    return DateTime(
        date.year, date.month, date.day, timeOfDay.hour, timeOfDay.minute);
  }

  @override
  Future<void> close() {
    stopTimer();
    return super.close();
  }
}
