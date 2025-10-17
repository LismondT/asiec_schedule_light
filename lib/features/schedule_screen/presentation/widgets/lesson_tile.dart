import 'package:asiec_schedule/core/domain/entity/lesson_entity.dart';
import 'package:asiec_schedule/core/enums/schedule_request_type.dart';
import 'package:asiec_schedule/injection_container.dart';
import 'package:flutter/material.dart';

class LessonTile extends StatelessWidget {
  final LessonEntity lesson;
  final ScheduleRequestType type;

  const LessonTile({super.key, required this.lesson, required this.type});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isSubgroup = lesson.subgroup > 0;
    final subgroupColor = lesson.subgroup == 1
        ? colorScheme.secondaryContainer
        : colorScheme.tertiaryContainer;

    return Row(
      children: [
        Container(
          decoration: BoxDecoration(
            border: BorderDirectional(
              end: BorderSide(
                color: isSubgroup ? subgroupColor : colorScheme.primary,
                width: isSubgroup ? 2 : 1,
              ),
            ),
          ),
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
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (isSubgroup)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        margin: const EdgeInsets.only(right: 6),
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
                    Flexible(
                      child: Text(
                        lesson.name ?? "",
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
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
      ],
    );
  }

  String _getSecondaryInfo() {
    final forGroupStr = 'Ауд. ${lesson.classroom}, ${lesson.territory}';

    String groupInfo = lesson.group ?? '???';
    if (isAltag) {
      if (lesson.subgroup == 1) {
        groupInfo = groupInfo.replaceFirst(' п. 1', '');
      } else if (lesson.subgroup == 2) {
        groupInfo = groupInfo.replaceFirst(' п. 2', '');
      }
    }
    final forTeacherStr = 'Гр. $groupInfo, Ауд. ${lesson.classroom}, ${lesson.territory}';
    final forAuditoryStr = 'Гр. $groupInfo, Пр. ${lesson.teacher}';
    return switch(type) {
      ScheduleRequestType.groups => forGroupStr,
      ScheduleRequestType.teachers => forTeacherStr,
      ScheduleRequestType.classrooms => forAuditoryStr,
    };
  }
}