import 'package:flutter/material.dart';
import 'package:html/dom.dart';
import 'package:html/parser.dart';
import 'package:http/http.dart';

class LessonTime {
  final String number;
  final TimeOfDay startTime;
  final TimeOfDay endTime;

  LessonTime(
    this.number,
    this.startTime,
    this.endTime
  );
}


class AltagScheduleTimeService {
  final Client _client;
  final String _url = 'https://altag.ru/student/schedule/call_schedule';

  final List<List<LessonTime>> _lessonTimes = [[], [], []];

  bool _isInitialized = false;

  bool get isInitialized => _isInitialized; 

  AltagScheduleTimeService(this._client);

  Future<void> initialize() async {
    Response response = await _client.post(
      Uri.parse(_url),
      headers: {},
    );

    String body = response.body;
    _parseBody(body);

    _isInitialized = true;
  }

  void _parseBody(String body) {
    Document document = parse(body);
    final rows = document.querySelectorAll('#table tbody tr');

    for (final row in rows) {
      final cells = row.querySelectorAll('td, th');

      if (cells.isEmpty) {
        continue;
      }

      if (cells.length > 1 && cells[0].innerHtml.contains('пара')) {
        String lessonName = cells[0].innerHtml;
        
        for (int i = 1; i <= 3; i++) {
          String time = cells[i].innerHtml;
          final times = _parseTime(time);

          if (times == null) {
            continue;
          }

          LessonTime lessonTime = LessonTime(lessonName, times.start, times.end);
          _lessonTimes[i-1].add(lessonTime);
        }
      }
    }
  }

  ({TimeOfDay start, TimeOfDay end})? _parseTime(String time) {
    List<String> times = time.split(' - ');
    if (times.length == 2) {
      List<String> startTimeParts = times[0].split(':');
      List<String> endTimeParts = times[1].split(':');

      TimeOfDay startTime = TimeOfDay(hour: int.parse(startTimeParts[0]), minute: int.parse(startTimeParts[1]));
      TimeOfDay endTime = TimeOfDay(hour: int.parse(endTimeParts[0]), minute: int.parse(endTimeParts[1]));

      return (start: startTime, end: endTime);
    }

    return null;
  }

  //weekday - день недели, от 0 (понедельник) до 7 (воскресенье)
  //lessonIndex - номер пары, где 0 (первый классный час), последний (второй классный час)
  LessonTime? getLessonTime(int weekday, int lessonNumber) {
    //Классный час
    if (lessonNumber == 0) {
      return null;
    }

    int listIndex = 0;
    final int lessonIndex = lessonNumber - 1; 

    if (weekday > 1 && weekday <= 5) {
      listIndex = 1;
    }
    else if (weekday == 6) {
      listIndex = 2;
    }

    if (lessonIndex < _lessonTimes[listIndex].length) {
      return _lessonTimes[listIndex][lessonIndex];
    }

    return null;
  }
}