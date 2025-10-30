import 'package:flutter/material.dart';

import '../../../../core/config/flavor_config.dart';
import '../../../../core/domain/entity/lesson.dart';
import '../../../../core/enums/schedule_request_type.dart';

class LessonWithSubgroupTile extends StatelessWidget {
  final Lesson lesson;
  final ScheduleRequestType type;

  const LessonWithSubgroupTile(
      {super.key, required this.lesson, required this.type});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final subgroupData = lesson.subgroupData!;

    return Row(
      children: [
        Container(
          decoration: BoxDecoration(
            border: BorderDirectional(
              end: BorderSide(
                color: colorScheme.primary,
                width: 2,
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
                // Main lesson info
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      margin: const EdgeInsets.only(right: 6),
                      decoration: BoxDecoration(
                        color: colorScheme.secondaryContainer,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'Подгруппы',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSecondaryContainer,
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

                // Subgroup 1 info
                _buildSubgroupInfo(
                  context,
                  subgroupNumber: lesson.subgroup,
                  teacher: lesson.teacher,
                  classroom: lesson.classroom,
                  territory: lesson.territory,
                  color: colorScheme.secondaryContainer,
                ),

                const SizedBox(height: 4),

                // Subgroup 2 info
                _buildSubgroupInfo(
                  context,
                  subgroupNumber: subgroupData.subgroup,
                  teacher: subgroupData.teacher,
                  classroom: subgroupData.classroom,
                  territory: subgroupData.territory,
                  color: colorScheme.tertiaryContainer,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubgroupInfo(
    BuildContext context, {
    required int subgroupNumber,
    required String? teacher,
    required String? classroom,
    required String? territory,
    required Color color,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          margin: const EdgeInsets.only(right: 6),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            'Гр. $subgroupNumber',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSecondaryContainer,
            ),
          ),
        ),
        Flexible(
          child: Text(
            _getSubgroupSecondaryInfo(
              subgroupNumber,
              teacher: teacher,
              classroom: classroom,
              territory: territory,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: colorScheme.outline,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  String _getSubgroupSecondaryInfo(
    int subgroupNumber, {
    required String? teacher,
    required String? classroom,
    required String? territory,
  }) {
    final groupInfo = _getGroupInfo(subgroupNumber);

    final forGroupStr =
        'Ауд. ${classroom ?? 'не указана'}, ${territory ?? 'не указан'}';
    final forTeacherStr =
        'Гр. $groupInfo, Ауд. ${classroom ?? 'не указана'}, ${territory ?? 'не указан'}';
    final forAuditoryStr = 'Гр. $groupInfo, Пр. ${teacher ?? 'Не указан'}';

    return switch (type) {
      ScheduleRequestType.groups => forGroupStr,
      ScheduleRequestType.teachers => forTeacherStr,
      ScheduleRequestType.classrooms => forAuditoryStr,
    };
  }

  String _getGroupInfo(int subgroupNumber) {
    String groupInfo = lesson.group ?? '???';
    if (FlavorConfig.instance.isAltag) {
      // Убираем обозначения подгрупп для ALTAG
      groupInfo = groupInfo.replaceAll(' п. $subgroupNumber', '');
    }
    return groupInfo;
  }
}
