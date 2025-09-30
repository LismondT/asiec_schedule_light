import 'package:asiec_schedule/core/domain/entity/lesson_entity.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class LessonInfoPopup extends StatelessWidget {
  final LessonEntity _lesson;

  const LessonInfoPopup(this._lesson, {super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(22, 22, 22, 30),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Заголовок и кнопка закрытия
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Информация о занятии',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 22
                ),
              ),
              IconButton(
                icon: Icon(Icons.close_rounded, color: colorScheme.onSurface),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Основной контент
          Flexible(
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildInfoCard(
                    context,
                    title: 'Основная информация',
                    children: [
                      _buildInfoRow(context, 'Название', _lesson.name ?? 'Не указано'),
                      _buildInfoRow(context, 'Группа', _lesson.group ?? 'Не указана'),
                      if (_lesson.subgroup > 0)
                        _buildInfoRow(context, 'Подгруппа', _lesson.subgroup.toString()),
                      _buildInfoRow(context, 'Преподаватель', _lesson.teacher ?? 'Не указан'),
                      _buildInfoRow(context, 'Аудитория', _lesson.classroom ?? 'Не указана'),
                    ],
                  ),

                  const SizedBox(height: 12),

                  _buildInfoCard(
                    context,
                    title: 'Время',
                    children: [
                      _buildInfoRow(context, 'Дата', DateFormat("dd MMMM yyyy", "Ru_ru").format(_lesson.date!)),
                      _buildInfoRow(context, 'Начало', _lesson.startTime.format(context)),
                      _buildInfoRow(context, 'Конец', _lesson.endTime.format(context)),
                      _buildInfoRow(context, 'Длительность', _lesson.duration().format(context)),
                    ],
                  ),

                  const SizedBox(height: 12),

                  if (_lesson.territory != null && _lesson.territory!.isNotEmpty)
                    _buildInfoCard(
                      context,
                      title: 'Локация',
                      children: [
                        _buildInfoRow(context, 'Расположение', _lesson.territory!),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context, {required String title, required List<Widget> children}) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: Theme.of(context).dividerColor,
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
              width: 114,
              child: Text('$label:',
                  style: const TextStyle(fontWeight: FontWeight.w500))),
          const SizedBox(width: 8),
          Expanded(
            child: Text(value, style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
          ),
        ],
      ),
    );
  }
}
