import 'package:asiec_schedule/core/config/flavor_config.dart';
import 'package:asiec_schedule/core/domain/entity/lesson.dart';
import 'package:asiec_schedule/core/enums/schedule_request_type.dart';
import 'package:flutter/material.dart';

class LessonTile extends StatelessWidget {
  final Lesson lesson;
  final ScheduleRequestType type;
  final bool shrinkLessonName;

  const LessonTile({
    super.key,
    required this.lesson,
    required this.type,
    this.shrinkLessonName = true,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isSubgroup = lesson.subgroup > 0;
    final subgroupColor = lesson.subgroup == 1
        ? colorScheme.secondaryContainer
        : colorScheme.tertiaryContainer;

    return Row(
      children: [
        SizedBox(
          // decoration: BoxDecoration(
          //   border: BorderDirectional(
          //     end: BorderSide(
          //       // color: isSubgroup ? subgroupColor : colorScheme.primary,
          //       // width: isSubgroup ? 2 : 1,
          //     ),
          //   ),
          // ),
          width: 58,
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Column(
                  children: [
                    Text(
                      lesson.startTime.format(context),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      lesson.endTime.format(context),
                      style: TextStyle(
                        color: colorScheme.outline,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Lesson Info
        Flexible(
          child: Container(
            decoration: BoxDecoration(
              border: BorderDirectional(
                start: BorderSide(
                  color: isSubgroup ? subgroupColor : colorScheme.primary,
                  width: isSubgroup ? 2 : 1,
                )
              )
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Первая строка: подгруппа, теги и начало названия
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Подгруппа
                      if (isSubgroup)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          margin: const EdgeInsets.only(right: 6, top: 1),
                          decoration: BoxDecoration(
                            color: subgroupColor,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'Гр. ${lesson.subgroup}',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onPrimaryContainer,
                            ),
                          ),
                        ),

                      // Теги
                      ...lesson.tags.map((tag) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 1),
                          margin: const EdgeInsets.only(right: 6, bottom: 0),
                          decoration: BoxDecoration(
                            color: colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color: colorScheme.primary.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            tag,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: colorScheme.onPrimaryContainer,
                            ),
                          ),
                        );
                      }),

                      // Начало названия занятия (только то, что помещается в первую строку)
                      if (shrinkLessonName)
                        Flexible(
                          child: Text(
                            lesson.name ?? "",
                            style: const TextStyle(fontWeight: FontWeight.bold),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        )
                      else
                        Flexible(
                          child: _FirstLineLessonName(
                            lessonName: lesson.name ?? "",
                            hasTagsOrSubgroup: isSubgroup || lesson.tags.isNotEmpty,
                          ),
                        ),
                    ],
                  ),

                  // Вторая и последующие строки названия (только при shrinkLessonName = false)
                  if (!shrinkLessonName && lesson.name != null && lesson.name!.isNotEmpty)
                    _RemainingLessonName(
                      lessonName: lesson.name ?? "",
                      hasTagsOrSubgroup: isSubgroup || lesson.tags.isNotEmpty,
                    ),

                  // Дополнительная информация
                  const SizedBox(height: 4),
                  Text(
                    _getSecondaryInfo(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: colorScheme.outline,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _getSecondaryInfo() {
    final forGroupStr = 'Ауд. ${lesson.classroom}, ${lesson.territory}';

    String groupInfo = lesson.group ?? '???';
    if (FlavorConfig.instance.isAltag) {
      if (lesson.subgroup == 1) {
        groupInfo = groupInfo.replaceFirst(' п. 1', '');
      } else if (lesson.subgroup == 2) {
        groupInfo = groupInfo.replaceFirst(' п. 2', '');
      }
    }
    final forTeacherStr =
        'Гр. $groupInfo, Ауд. ${lesson.classroom}, ${lesson.territory}';
    final forAuditoryStr = 'Гр. $groupInfo, Пр. ${lesson.teacher}';
    return switch (type) {
      ScheduleRequestType.groups => forGroupStr,
      ScheduleRequestType.teachers => forTeacherStr,
      ScheduleRequestType.classrooms => forAuditoryStr,
    };
  }
}

// Виджет для первой строки названия (с тегами)
class _FirstLineLessonName extends StatelessWidget {
  final String lessonName;
  final bool hasTagsOrSubgroup;

  const _FirstLineLessonName({
    required this.lessonName,
    required this.hasTagsOrSubgroup,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (!hasTagsOrSubgroup) {
          // Если нет тегов/подгруппы - просто показываем полное название
          return Text(
            lessonName,
            style: const TextStyle(fontWeight: FontWeight.bold),
          );
        }

        // Находим, сколько текста помещается в первую строку
        final firstLineText = _getFirstLineText(lessonName, constraints.maxWidth, context);

        // Если весь текст поместился в первую строку
        if (firstLineText.length >= lessonName.length) {
          return Text(
            lessonName,
            style: const TextStyle(fontWeight: FontWeight.bold),
          );
        }

        // Показываем только начало текста в первой строке
        return Text(
          firstLineText,
          style: const TextStyle(fontWeight: FontWeight.bold),
        );
      },
    );
  }

  String _getFirstLineText(String text, double maxWidth, BuildContext context) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: '',
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      maxLines: 1,
      textDirection: TextDirection.ltr,
    );

    String currentText = '';
    for (int i = 0; i < text.length; i++) {
      final testText = currentText + text[i];
      textPainter.text = TextSpan(
        text: testText,
        style: const TextStyle(fontWeight: FontWeight.bold),
      );
      textPainter.layout(maxWidth: maxWidth);

      if (textPainter.didExceedMaxLines) {
        break;
      }
      currentText = testText;
    }

    // Обрезаем до последнего пробела, чтобы не обрывать слова
    final lastSpaceIndex = currentText.lastIndexOf(' ');
    if (lastSpaceIndex > 0) {
      return currentText.substring(0, lastSpaceIndex);
    }

    return currentText;
  }
}

// Виджет для оставшейся части названия (без тегов)
class _RemainingLessonName extends StatelessWidget {
  final String lessonName;
  final bool hasTagsOrSubgroup;

  const _RemainingLessonName({
    required this.lessonName,
    required this.hasTagsOrSubgroup,
  });

  @override
  Widget build(BuildContext context) {
    if (!hasTagsOrSubgroup) {
      return const SizedBox.shrink(); // Не показываем, если нет тегов/подгруппы
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        // Находим текст для первой строки
        final firstLineText = _getFirstLineText(lessonName, constraints.maxWidth, context);

        // Если весь текст поместился в первую строку, не показываем вторую
        if (firstLineText.length >= lessonName.length) {
          return const SizedBox.shrink();
        }

        // Оставшийся текст (без части, которая уже показана в первой строке)
        final remainingText = lessonName.substring(firstLineText.length).trim();

        if (remainingText.isEmpty) {
          return const SizedBox.shrink();
        }

        return Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Text(
            remainingText,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        );
      },
    );
  }

  String _getFirstLineText(String text, double maxWidth, BuildContext context) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: '',
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      maxLines: 1,
      textDirection: TextDirection.ltr,
    );

    String currentText = '';
    for (int i = 0; i < text.length; i++) {
      final testText = currentText + text[i];
      textPainter.text = TextSpan(
        text: testText,
        style: const TextStyle(fontWeight: FontWeight.bold),
      );
      textPainter.layout(maxWidth: maxWidth);

      if (textPainter.didExceedMaxLines) {
        break;
      }
      currentText = testText;
    }

    // Обрезаем до последнего пробела, чтобы не обрывать слова
    final lastSpaceIndex = currentText.lastIndexOf(' ');
    if (lastSpaceIndex > 0) {
      return currentText.substring(0, lastSpaceIndex);
    }

    return currentText;
  }
}