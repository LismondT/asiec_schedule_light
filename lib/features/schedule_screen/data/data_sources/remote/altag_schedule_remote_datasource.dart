import 'package:asiec_schedule/core/domain/entity/day_entity.dart';
import 'package:asiec_schedule/core/domain/entity/lesson_entity.dart';
import 'package:asiec_schedule/core/domain/entity/schedule_entity.dart';
import 'package:asiec_schedule/core/enums/schedule_request_type.dart';
import 'package:asiec_schedule/core/utils/altag/altag_schedule_time_service.dart';
import 'package:asiec_schedule/features/schedule_screen/data/data_sources/remote/schedule_remote_datasource.dart';
import 'package:flutter/material.dart';
import 'package:html/dom.dart';
import 'package:html/parser.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';

class AltagScheduleRemoteDatasource extends ScheduleRemoteDatasource {
  final String _baseUrl = 'https://schedule.altag.ru/ras.php';
  final Client _client;
  final AltagScheduleTimeService _scheduleTime;

  AltagScheduleRemoteDatasource(this._client, this._scheduleTime);

  @override
  Future<ScheduleEntity> getSchedule(
      DateTime start, int days, ScheduleRequestType type, String id) async {
    int nullDayCount = 0;

    final List<DayEntity> scheduleDays = [];

    for (int i = 0; i < days; i++) {
      DateTime day = start.add(Duration(days: i));

      if (day.weekday == DateTime.sunday) {
        continue;
      }

      DayEntity? dayEntity = await _getDay(day, type, id);

      if (dayEntity == null) {
        if (nullDayCount > 3) {
          break;
        }
        nullDayCount++;
        continue;
      }

      scheduleDays.add(dayEntity);

      await Future.delayed(Duration(milliseconds: 125));
    }

    final firstDate = scheduleDays.firstOrNull?.date ?? DateTime(1);
    final lastDate = scheduleDays.lastOrNull?.date ?? DateTime(1);
    final schedule = ScheduleEntity(
        firstDate: firstDate, lastDate: lastDate, days: scheduleDays);
    return schedule;
  }

  Future<DayEntity?> _getDay(
      DateTime date, ScheduleRequestType type, String id) async {
    final Response response = await _client.post(Uri.parse(_baseUrl),
        headers: {
          "Accept-Language": "ru-RU,ru;q=0.9,en-US;q=0.8,en;q=0.7",
          "User-Agent": "AltagScheduleAndroidApp",
          "X-Requested-With": "XMLHttpRequest",
        },
        body: _getData(date, type, id));

    String body = response.body;
    return _parseBody(body, date);
  }

  Map<String, String> _getData(
      DateTime date, ScheduleRequestType type, String id) {
    String idField;
    switch (type) {
      case ScheduleRequestType.groups:
        idField = 'gruppa';
        break;
      case ScheduleRequestType.teachers:
        idField = 'prepod';
        break;
      case ScheduleRequestType.classrooms:
        idField = 'auditoria';
    }

    return {
      'dostup': 'true',
      idField: id,
      'calendar': DateFormat('yyyy-MM-dd').format(date),
      'ras': switch (type) {
        ScheduleRequestType.groups => 'GRUP',
        ScheduleRequestType.teachers => 'PREP',
        ScheduleRequestType.classrooms => 'AUD',
      }
    };
  }

  DayEntity? _parseBody(String body, DateTime date) {
    final Document document = parse(body);
    final dayElements = document.querySelectorAll('.table-body_item');

    List<LessonEntity> lessons = [];

    for (final dayElement in dayElements) {
      String numberStr =
          dayElement.querySelector('.time')?.text.split(':')[1].trim() ?? '0';
      String group =
          dayElement.querySelector('.group')?.text.split(':')[1].trim() ?? '';
      String name = dayElement.querySelector('.lesson')?.text.trim() ?? '';
      String teacher = dayElement.querySelector('.teacher')?.text.trim() ?? '';
      String territory =
          dayElement.querySelector('.territory')?.text.trim() ?? '';
      String classroom =
          dayElement.querySelector('.classroom')?.text.split(':')[1].trim() ??
              '';

      int number = int.parse(numberStr);
      LessonTime? time = _scheduleTime.getLessonTime(date.weekday, number);

      int subgroup = 0;
      if (group.contains("п. 1")) {
        subgroup = 1;
      } else if (group.contains("п. 2")) {
        subgroup = 2;
      }

      lessons.add(LessonEntity(
          number: number,
          name: name,
          group: group,
          subgroup: subgroup,
          teacher: teacher,
          classroom: classroom,
          territory: territory,
          startTime: time?.startTime ?? TimeOfDay(hour: 0, minute: 0),
          endTime: time?.endTime ?? TimeOfDay(hour: 0, minute: 0),
          date: date));
    }

    if (lessons.isEmpty) {
      return null;
    }

    //_addTimeToClassHour(lessons);

    return DayEntity(date: date, lessons: lessons);
  }

  void _addTimeToClassHour(List<LessonEntity> lessons) {
    for (int i = 0; i < lessons.length; i++) {
      final lesson = lessons[i];

      if (lesson.name?.startsWith('Классный час') ?? false) {
        LessonEntity? nextLesson;
        for (int j = i + 1; j < lessons.length; j++) {
          if (lessons[j].number > lesson.number) {
            nextLesson = lessons[j];
            break;
          }
        }

        if (nextLesson != null) {
          final nextStartTime = nextLesson.startTime;
          TimeOfDay newStartTime;
          TimeOfDay newEndTime;

          if (nextStartTime.hour == 8 && nextStartTime.minute == 50) {
            newStartTime = const TimeOfDay(hour: 8, minute: 0);
            newEndTime = const TimeOfDay(hour: 8, minute: 45);
          } else if (nextStartTime.hour == 14 && nextStartTime.minute == 50) {
            newStartTime = const TimeOfDay(hour: 13, minute: 55);
            newEndTime = const TimeOfDay(hour: 14, minute: 40);
          } else {
            continue;
          }

          final updatedLesson = LessonEntity(
            number: lesson.number,
            name: lesson.name,
            group: lesson.group,
            subgroup: lesson.subgroup,
            teacher: lesson.teacher,
            classroom: lesson.classroom,
            territory: lesson.territory,
            startTime: newStartTime,
            endTime: newEndTime,
            date: lesson.date,
          );

          lessons[i] = updatedLesson;
        }
      }
    }
  }
}
