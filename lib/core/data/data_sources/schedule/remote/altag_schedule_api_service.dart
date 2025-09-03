
import 'package:asiec_schedule/core/data/data_sources/schedule/remote/schedule_api_service.dart';
import 'package:asiec_schedule/core/domain/entity/lesson_entity.dart';
import 'package:asiec_schedule/core/enums/schedule_request_type.dart';
import 'package:asiec_schedule/core/utils/altag/altag_schedule_time_service.dart';
import 'package:flutter/material.dart';
import 'package:html/dom.dart';
import 'package:http/http.dart';
import 'package:html/parser.dart';
import 'package:intl/intl.dart';

import 'package:asiec_schedule/core/domain/entity/day_entity.dart';


class AltagScheduleApiService extends ScheduleApiService {
  final String _baseUrl = 'http://schedule.altag.ru:89/ras.php';
  final Client _client;
  final AltagScheduleTimeService _scheduleTime;

  AltagScheduleApiService(this._client, this._scheduleTime);

  @override
  Stream<DayEntity> getSchedule(DateTime start, int days, ScheduleRequestType type, String id) async* {
    int nullDayCount = 0;

    for (int i = 0; i < days; i++) {
      DateTime day = start.add(Duration(days: i));

      if (day.weekday == DateTime.sunday) {
        continue;
      }

      DayEntity? dayEntity = await _getDay(day, type, id);

      if (dayEntity == null) {
        if(nullDayCount > 3) {
          break;
        }
        nullDayCount++;
        continue;
      }
      
      yield dayEntity;

      await Future.delayed(Duration(milliseconds: 125));
    }
  }

  Future<DayEntity?> _getDay(DateTime date, ScheduleRequestType type, String id) async {
    final Response response = await _client.post(
      Uri.parse(_baseUrl),
      headers: {
        "Accept-Language": "ru-RU,ru;q=0.9,en-US;q=0.8,en;q=0.7",
        "User-Agent": "AltagScheduleAndroidApp",
        "X-Requested-With": "XMLHttpRequest",
      },
      body: _getData(date, type, id)
    );

    String body = response.body;
    return _parseBody(body, date);
  }

  Map<String, String> _getData(DateTime date, ScheduleRequestType type, String id) {
    return {
      'dostup': 'true',
      'gruppa': id,
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
      String numberStr = dayElement.querySelector('.time')?.text.split(':')[1].trim() ?? '0';
      String group = dayElement.querySelector('.group')?.text.split(':')[1].trim() ?? '';
      String name = dayElement.querySelector('.lesson')?.text.trim() ?? '';
      String teacher = dayElement.querySelector('.teacher')?.text.trim() ?? '';
      String territory = dayElement.querySelector('.territory')?.text.trim() ?? '';
      String classroom = dayElement.querySelector('.classroom')?.text.split(':')[1].trim() ?? '';

      int number = int.parse(numberStr);
      LessonTime? time = _scheduleTime.getLessonTime(date.weekday, number);

      lessons.add(LessonEntity(
        number: number,
        name: name,
        group: group,
        subgroup: 0, //ToDo: Доделать логику подгрупп
        teacher: teacher,
        classroom: classroom,
        territory: territory,
        startTime: time?.startTime ?? TimeOfDay(hour: 0, minute: 0),
        endTime: time?.endTime ?? TimeOfDay(hour: 0, minute: 0),
        date: date)
      );
    }

    if (lessons.isEmpty) {
      return null;
    }

    return DayEntity(date: date, lessons: lessons);
  }
}