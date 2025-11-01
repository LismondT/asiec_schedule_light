import 'package:asiec_schedule/core/domain/entity/lesson.dart';
import 'package:asiec_schedule/core/utils/extensions/lesson_extension.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class LessonInfoBottomSheet extends StatelessWidget {
  final Lesson _lesson;

  const LessonInfoBottomSheet(this._lesson, {super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header with drag indicator
          Container(
            width: 60,
            height: 4,
            margin: const EdgeInsets.only(top: 12, bottom: 16),
            decoration: BoxDecoration(
              color: colorScheme.onSurface.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Title and close
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: 24,
                  decoration: BoxDecoration(
                    color: colorScheme.primary,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Информация о занятии',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close, color: colorScheme.onSurface.withOpacity(0.6)),
                  onPressed: () => Navigator.pop(context),
                  splashRadius: 20,
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Lesson title
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _lesson.fullName()!,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.primary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                  // Info sections
                  _buildSection(
                    context,
                    title: 'Основное',
                    icon: Icons.school_rounded,
                    children: [
                      _buildInfoRow(context, 'Группа', _lesson.group ?? '—'),
                      if (_lesson.subgroup > 0)
                        _buildInfoRow(context, 'Подгруппа', _lesson.subgroup.toString()),
                      _buildInfoRow(context, 'Аудитория', _lesson.classroom ?? '—'),
                    ],
                  ),

                  const SizedBox(height: 24),

                  _buildSection(
                    context,
                    title: 'Время',
                    icon: Icons.schedule_rounded,
                    children: [
                      _buildInfoRow(context, 'Дата',
                          DateFormat("EEEE, d MMMM", "Ru_ru").format(_lesson.date!)),
                      _buildInfoRow(context, 'Время',
                          '${_lesson.startTime.format(context)} - ${_lesson.endTime.format(context)}'),
                      _buildInfoRow(context, 'Длительность', _lesson.duration().format(context)),
                    ],
                  ),

                  const SizedBox(height: 24),

                  if (_lesson.teacher != null && _lesson.teacher!.isNotEmpty)
                    _buildSection(
                      context,
                      title: 'Преподаватель',
                      icon: Icons.person_rounded,
                      children: [
                        _buildInfoRow(context, '', _lesson.teacher!, isMain: true),
                      ],
                    ),

                  if (_lesson.territory != null && _lesson.territory!.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    _buildSection(
                      context,
                      title: 'Местоположение',
                      icon: Icons.location_on_rounded,
                      children: [
                        _buildInfoRow(context, '', _lesson.territory!, isMain: true),
                      ],
                    ),
                  ],

                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(
      BuildContext context, {
        required String title,
        required IconData icon,
        required List<Widget> children,
      }) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: 18,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...children,
      ],
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value, {bool isMain = false}) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (label.isNotEmpty) ...[
            SizedBox(
              width: 100,
              child: Text(
                label,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: isMain ? FontWeight.w500 : FontWeight.w400,
                color: isMain ? theme.colorScheme.primary : theme.colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}