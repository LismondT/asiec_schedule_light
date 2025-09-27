import 'package:asiec_schedule/core/domain/entity/lesson_entity.dart';
import 'package:asiec_schedule/core/presentation/widgets/app_bar_title.dart';
import 'package:asiec_schedule/features/timer_screen/presentation/cubit/lecture_timer_cubit.dart';
import 'package:asiec_schedule/features/timer_screen/presentation/cubit/lecture_timer_states.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LectureTimerScreen extends StatelessWidget {
  const LectureTimerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const AppBarTitle(title: 'Время'),
        centerTitle: true,
        backgroundColor: colorScheme.secondaryContainer,
        foregroundColor: colorScheme.onSecondaryContainer,
        elevation: 4,
      ),
      body: BlocBuilder<LectureTimerCubit, LectureTimerState>(
        builder: (context, state) {
          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: _buildContent(context, state),
          );
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, LectureTimerState state) {
    final colorScheme = Theme.of(context).colorScheme;

    if (state is LectureTimerInitState || state is LectureTimerLoadingState) {
      return Center(
        child: CircularProgressIndicator(color: colorScheme.primary),
      );
    }

    if (state is LectureTimerHolidaysState) {
      return _buildHolidaysState(context);
    }

    if (state is LectureTimerBeforeLessonsStartState) {
      return _buildBeforeLessonsState(context, state);
    }

    if (state is LectureTimerLessonState) {
      return _buildLessonState(context, state);
    }

    if (state is LectureTimerFreeTimeState) {
      return _buildFreeTimeState(context, state);
    }

    return Center(
      child: Text(
        'Неизвестное состояние',
        style: TextStyle(color: colorScheme.onSurface),
      ),
    );
  }

  Widget _buildHolidaysState(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.beach_access,
            size: 80,
            color: colorScheme.primary.withOpacity(0.7),
          ),
          const SizedBox(height: 20),
          Text(
            'Сегодня занятий нет!',
            style: textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Можно отдохнуть',
            style: textTheme.bodyLarge?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBeforeLessonsState(
      BuildContext context, LectureTimerBeforeLessonsStartState state) {
    final colorScheme = Theme.of(context).colorScheme;
    final lesson = state.lesson;
    final timeUntilStart = _calculateTimeUntilStart(lesson.startTime);

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatusCard(
              context: context,
              icon: Icons.access_time,
              title: 'До начала занятий',
              subtitle:
                  'Первая пара начнётся в ${_formatTime(lesson.startTime)}',
              color: colorScheme.primary,
            ),
            const SizedBox(height: 20),
            _buildTimeCard(
              context: context,
              time: timeUntilStart,
              label: 'До начала первой пары',
            ),
            const SizedBox(height: 20),
            _buildLessonInfoCard(context, lesson, isNext: true),
          ],
        ),
      ),
    );
  }

  Widget _buildLessonState(
      BuildContext context, LectureTimerLessonState state) {
    final colorScheme = Theme.of(context).colorScheme;
    final lesson = state.lesson;
    final breakDuration = state.freeTime;
    final timeUntilEnd = _calculateTimeUntilEnd(lesson.endTime);

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatusCard(
              context: context,
              icon: Icons.school,
              title: 'Идёт пара',
              subtitle:
                  '${lesson.number} пара • ${_formatTime(lesson.startTime)}-${_formatTime(lesson.endTime)}',
              color: colorScheme.secondary,
            ),
            const SizedBox(height: 20),
            _buildTimeCard(
              context: context,
              time: timeUntilEnd,
              label: 'До конца пары',
            ),
            const SizedBox(height: 20),
            if (breakDuration > Duration.zero)
              _buildBreakInfoCard(context, breakDuration),
            const SizedBox(height: 20),
            _buildLessonInfoCard(context, lesson),
          ],
        ),
      ),
    );
  }

  Widget _buildFreeTimeState(
      BuildContext context, LectureTimerFreeTimeState state) {
    final colorScheme = Theme.of(context).colorScheme;
    final breakDuration = state.duration;
    final nextLesson = state.nextLesson;
    final timeUntilNext = _calculateTimeUntilEnd(state.end);

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatusCard(
              context: context,
              icon: Icons.free_breakfast,
              title: 'Перемена',
              subtitle: '${_formatTime(state.start)}-${_formatTime(state.end)}',
              color: colorScheme.tertiary,
            ),
            const SizedBox(height: 20),
            _buildTimeCard(
              context: context,
              time: timeUntilNext,
              label: 'До начала следующей пары',
            ),
            const SizedBox(height: 20),
            _buildBreakInfoCard(context, breakDuration),
            if (nextLesson != null) ...[
              const SizedBox(height: 20),
              _buildLessonInfoCard(context, nextLesson, isNext: true),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: textTheme.bodyLarge?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeCard(
      {required BuildContext context,
      required Duration time,
      required String label}) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final hours = time.inHours;
    final minutes = time.inMinutes.remainder(60);
    final seconds = time.inSeconds.remainder(60);

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Text(
              label,
              style: textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w500,
                color: colorScheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
              style: textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onPrimaryContainer,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBreakInfoCard(BuildContext context, Duration duration) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(Icons.timer, color: colorScheme.tertiary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Длительность перемены',
                    style: textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  Text(
                    '${duration.inMinutes} минут',
                    style: textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.tertiary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLessonInfoCard(BuildContext context, LessonEntity lesson,
      {bool isNext = false}) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isNext ? 'Следующая пара' : 'Текущая пара',
              style: textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            _buildInfoRow(context, 'Предмет', lesson.name ?? 'Не указано'),
            _buildInfoRow(
                context, 'Аудитория', lesson.classroom ?? 'Не указано'),
            _buildInfoRow(
                context, 'Преподаватель', lesson.teacher ?? 'Не указано'),
            _buildInfoRow(context, 'Время',
                '${_formatTime(lesson.startTime)}-${_formatTime(lesson.endTime)}'),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w400,
                color: colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  Duration _calculateTimeUntilStart(TimeOfDay startTime) {
    final now = DateTime.now();
    final startDateTime = DateTime(
        now.year, now.month, now.day, startTime.hour, startTime.minute);
    return startDateTime.difference(now);
  }

  Duration _calculateTimeUntilEnd(TimeOfDay endTime) {
    final now = DateTime.now();
    final endDateTime =
        DateTime(now.year, now.month, now.day, endTime.hour, endTime.minute);
    return endDateTime.difference(now);
  }
}
