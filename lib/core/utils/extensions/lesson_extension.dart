import 'package:asiec_schedule/core/domain/entity/lesson.dart';

import '../../domain/entity/subgroup_data.dart';

extension LessonsListExtension on List<Lesson> {
  /// Проходим по занятиям. Если занятия 2х подгрупп проходят в одно время,
  /// то добавляем subgroupData, и убираем повторение
  List<Lesson> withUpdatedSubgroups() {
    final List<Lesson> result = [];
    final Map<String, List<Lesson>> lessonsByKey = {};

    // Группируем занятия по ключу (дата + номер + время + название + группа)
    for (final lesson in this) {
      final key =
          '${lesson.date?.toIso8601String()}_${lesson.number}_${lesson.startTime.hour}:${lesson.startTime.minute}_${lesson.endTime.hour}:${lesson.endTime.minute}_${lesson.name}_${lesson.group}';

      if (!lessonsByKey.containsKey(key)) {
        lessonsByKey[key] = [];
      }
      lessonsByKey[key]!.add(lesson);
    }

    // Обрабатываем каждую группу занятий
    for (final entry in lessonsByKey.entries) {
      final lessons = entry.value;

      if (lessons.length == 2) {
        // Если два занятия - проверяем, что это подгруппы
        final lesson1 = lessons[0];
        final lesson2 = lessons[1];

        // Проверяем, что это действительно подгруппы (разные номера подгрупп)
        if (lesson1.subgroup != 0 &&
            lesson2.subgroup != 0 &&
            lesson1.subgroup != lesson2.subgroup) {
          // Создаем основное занятие с subgroupData
          final mainLesson = lesson1.copyWith(
            subgroup: 0, // основное занятие без подгруппы
            subgroupData: SubgroupData(
              subgroup: lesson2.subgroup,
              teacher: lesson2.teacher,
              classroom: lesson2.classroom,
              territory: lesson2.territory,
            ),
          );

          result.add(mainLesson);
        } else {
          // Если это не подгруппы, добавляем оба занятия
          result.addAll(lessons);
        }
      } else {
        // Если не ровно два занятия - добавляем все как есть
        result.addAll(lessons);
      }
    }

    // Сортируем по номеру занятия для consistency
    result.sort((a, b) => a.number.compareTo(b.number));

    return result;
  }

  List<Lesson> withAddedTags() {
    final Map<String, String> nameToTag = {
      '(самостоятельная нагрузка)': 'сам. нагр.',
      '(дистанционная работа)': 'дист. раб.',
      '(курсовое проектирование)': 'курс. проек.',
      '(практика)': 'пр',
      '(лекция)': 'лек',
      '(лабораторная работа)': 'лаб. раб.',
      '(семинар)': 'сем',
    };

    return map((lesson) {
      if (lesson.name == null) return lesson;

      String cleanedName = lesson.name!;
      final List<String> foundTags = [];

      // Ищем теги и удаляем их из названия
      for (final entry in nameToTag.entries) {
        if (cleanedName.toLowerCase().contains(entry.key)) {
          foundTags.add(entry.value);
          // Удаляем тег из названия, используя регулярное выражение для игнорирования регистра
          cleanedName = cleanedName.replaceAll(RegExp(entry.key, caseSensitive: false), '');
        }
      }

      // Очищаем название от лишних пробелов и запятых
      cleanedName = cleanedName
          .replaceAll(RegExp(r'\s*,\s*,'), ',') // Убираем двойные запятые
          .replaceAll(RegExp(r'^\s*,\s*'), '') // Убираем запятую в начале
          .replaceAll(RegExp(r'\s*,\s*$'), '') // Убираем запятую в конце
          .trim();

      // Если нашли теги, возвращаем урок с обновленным названием и тегами
      if (foundTags.isNotEmpty) {
        return lesson.copyWith(
          name: cleanedName,
          tags: foundTags,
        );
      }

      return lesson;
    }).toList();
  }
}

extension LessonExtension on Lesson {
  String fullName() {
    final Map<String, String> tagToName = {
      'сам. нагр.': '(самостоятельная нагрузка)',
      'дист. раб.': '(дистанционная работа)',
      'курс. проек.': '(курсовое проектирование)',
      'пр': '(практика)',
      'лек': '(лекция)',
      'лаб. раб.': '(лабораторная работа)',
      'сем': '(семинар)',
    };

    if (name == null) return '';

    // Если нет тегов, возвращаем просто название
    if (tags.isEmpty) {
      return name!;
    }

    // Создаем список полных названий тегов
    final fullTags = tags.map((tag) => tagToName[tag] ?? tag).toList();

    // Комбинируем название и теги
    return '${name!} ${fullTags.join(' ')}'.trim();
  }
}
