import 'package:asiec_schedule/core/domain/entity/day_entity.dart';
import 'package:asiec_schedule/core/domain/entity/lesson_entity.dart';
import 'package:asiec_schedule/features/schedule_screen/presentation/widgets/lesson_info_popup.dart';
import 'package:asiec_schedule/features/schedule_screen/presentation/widgets/lesson_tile.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Daytile extends StatelessWidget {
  final DayEntity day;

  const Daytile({super.key, required this.day});

  @override
  Widget build(BuildContext context) {
    String dateTitle = DateFormat('EEEE, d MMMM', 'ru_RU').format(day.date);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 20, top: 12, bottom: 12),
          child: Text(dateTitle,
              style: TextStyle(
                  color: Theme.of(context).colorScheme.outline, fontSize: 18)),
        ),
        ...day.lessons.map((lesson) {
          return Material(
            child: Ink(
              color: Theme.of(context).colorScheme.surfaceContainer,
              child: InkWell(
                  splashColor:
                      Theme.of(context).colorScheme.surfaceContainerHigh,
                  highlightColor:
                      Theme.of(context).colorScheme.surfaceContainerHighest,
                  onTap: () => _showLessonInfoDialog(context, lesson),
                  child: LessonTile(lesson: lesson)),
            ),
          );
        })
      ],
    );
  }

  void _showLessonInfoDialog(BuildContext context, LessonEntity lesson) {
    showModalBottomSheet(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(30))),

        context: context,
        builder: (context) => LessonInfoPopup(lesson));
  }
}
