import 'package:asiec_schedule/core/domain/entity/day.dart';
import 'package:asiec_schedule/core/domain/entity/lesson.dart';
import 'package:asiec_schedule/core/domain/entity/schedule.dart';
import 'package:asiec_schedule/core/enums/schedule_request_type.dart';
import 'package:asiec_schedule/core/utils/extensions/lesson_extension.dart';
import 'package:asiec_schedule/features/schedule_screen/data/data_sources/remote/schedule_remote_datasource.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:html/parser.dart';
import 'package:intl/intl.dart';

class AsiecScheduleRemoteDatasource extends ScheduleRemoteDatasource {
  final String _baseUrl = "https://www.asiec.ru/ras/ras.php";
  final Dio _client;

  AsiecScheduleRemoteDatasource(this._client);

  @override
  Future<Schedule> getSchedule(
      DateTime start, int days, ScheduleRequestType type, String id) async {
    final responseDays = await _getScheduleBody(
        start, start.add(Duration(days: days)), type, id);
    final firstDate = responseDays.firstOrNull?.date ?? DateTime(1);
    final lastDate = responseDays.lastOrNull?.date ?? DateTime(1);
    final schedule =
        Schedule(days: responseDays, firstDate: firstDate, lastDate: lastDate);
    return schedule;
  }

  Future<List<Day>> _getScheduleBody(DateTime startDate, DateTime endDate,
      ScheduleRequestType type, String id) async {
    final response = await _client.post(_baseUrl,
        data: _getData(startDate, endDate, type, id),
        options: Options(contentType: Headers.formUrlEncodedContentType));

    String body = response.data;
    return parseSchedule(body);
  }

  Map<String, String> _getData(DateTime startDate, DateTime endDate,
      ScheduleRequestType type, String id) {
    return {
      'dostup': 'true',
      switch (type) {
        ScheduleRequestType.groups => 'gruppa',
        ScheduleRequestType.teachers => 'prepod',
        ScheduleRequestType.classrooms => 'auditoria',
      }: id,
      'calendar': DateFormat('yyyy-MM-dd').format(startDate),
      'calendar2': DateFormat('yyyy-MM-dd').format(endDate),
      'ras': switch (type) {
        ScheduleRequestType.groups => 'GRUP',
        ScheduleRequestType.teachers => 'PREP',
        ScheduleRequestType.classrooms => 'AUD',
      }
    };
  }

  List<Day> parseSchedule(String html) {
    final document = parse(html);
    final table = document.querySelector('.table-3');
    if (table == null) return [];

    final rows = table.querySelectorAll('tr');
    final List<Day> days = [];
    DateTime? currentDate;
    List<Lesson> currentLessons = [];

    for (final row in rows) {
      if (row.querySelector('.den') != null) {
        // Это строка с датой
        if (currentDate != null && currentLessons.isNotEmpty) {
          currentLessons =
              currentLessons.withUpdatedSubgroups().withAddedTags();

          days.add(Day(date: currentDate, lessons: currentLessons));
        }
        currentLessons = [];

        final dateText = row.text.trim();
        final dateRegex = RegExp(r'([а-яА-Я]+),\s(\d{2}\.\d{2}\.\d{4})');
        final match = dateRegex.firstMatch(dateText);
        if (match != null) {
          final dateStr = match.group(2);
          currentDate = DateFormat('dd.MM.yyyy').parse(dateStr!);
        }
      } else {
        // Это строка с парой
        if (currentDate == null) continue;

        final cells = row.querySelectorAll('td');
        if (cells.length < 6) continue;

        final numberText = cells[0].text.trim();
        final group = cells[1].text.trim();
        var name = cells[2].text.trim();
        final teacher = cells[3].text.trim();
        final territory = cells[4].text.trim();
        final classroom = cells[5].text.trim();

        // Парсим номер пары и время
        final numberMatch = RegExp(r'(\d+)').firstMatch(numberText);
        final number =
            numberMatch != null ? int.parse(numberMatch.group(1)!) : 0;

        final timeMatch = RegExp(r'(\d{1,2}:\d{2})\s*-\s*(\d{1,2}:\d{2})')
            .firstMatch(numberText);
        TimeOfDay? startTime;
        TimeOfDay? endTime;

        if (timeMatch != null) {
          startTime = _parseTime(timeMatch.group(1)!);
          endTime = _parseTime(timeMatch.group(2)!);
        }

        // Определяем подгруппу (если есть)
        int subgroup = 0;
        final subgroupMatch = RegExp(r'(\d+)\s*подгруппа').firstMatch(name);
        if (subgroupMatch != null) {
          subgroup = int.parse(subgroupMatch.group(1)!);
          name = name.replaceFirst(RegExp(r'[/\\] (\d+)\s*подгруппа'), '');
        }

        if (name.isNotEmpty && startTime != null && endTime != null) {
          currentLessons.add(Lesson(
            number: number,
            name: name,
            group: group,
            subgroup: subgroup,
            teacher: teacher.isNotEmpty ? teacher : 'Не указан',
            classroom: classroom.isNotEmpty && classroom != '"'
                ? classroom
                : 'не указана',
            territory: territory.isNotEmpty ? territory : 'не указан',
            startTime: startTime,
            endTime: endTime,
            date: currentDate,
          ));
        }
      }
    }

    // Добавляем последний день
    if (currentDate != null && currentLessons.isNotEmpty) {
      days.add(Day(date: currentDate, lessons: currentLessons));
    }

    return days;
  }

  TimeOfDay _parseTime(String timeStr) {
    final parts = timeStr.split(':');
    return TimeOfDay(
      hour: int.parse(parts[0]),
      minute: int.parse(parts[1]),
    );
  }
}
