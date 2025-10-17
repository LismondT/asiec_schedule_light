import 'package:asiec_schedule/core/domain/entity/lesson_entity.dart';
import 'package:asiec_schedule/core/enums/schedule_request_type.dart';
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
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const AppBarTitle(title: 'Расписание'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 4,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                colorScheme.primary.withOpacity(0.1),
                colorScheme.secondary.withOpacity(0.05),
              ],
            ),
          ),
        ),
      ),
      body: BlocBuilder<LectureTimerCubit, LectureTimerState>(
        builder: (context, state) {
          return _buildEnhancedContent(context, state);
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, LectureTimerState state) {
    final colorScheme = Theme.of(context).colorScheme;

    if (state is LectureTimerInitState || state is LectureTimerLoadingState) {
      return _buildLoadingState(context);
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

    return _buildErrorState(context);
  }

  Widget _buildEnhancedContent(BuildContext context, LectureTimerState state) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 700),
      switchInCurve: Curves.easeInOutCubic,
      switchOutCurve: Curves.easeInOutCubic,
      transitionBuilder: (Widget child, Animation<double> animation) {
        return FadeTransition(
          opacity: Tween<double>(
            begin: 0.0,
            end: 1.0,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.easeInOut,
          )),
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.0, 0.1),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeInOut,
            )),
            child: child,
          ),
        );
      },
      child: _buildContent(context, state),
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 80,
            height: 80,
            child: Stack(
              children: [
                Center(
                  child: SizedBox(
                    width: 60,
                    height: 60,
                    child: CircularProgressIndicator(
                      strokeWidth: 4,
                      valueColor: AlwaysStoppedAnimation(colorScheme.primary),
                    ),
                  ),
                ),
                Center(
                  child: Icon(
                    Icons.schedule,
                    size: 30,
                    color: colorScheme.primary.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Загружаем расписание...',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: colorScheme.onSurface.withOpacity(0.7),
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildHolidaysState(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  colorScheme.primary.withOpacity(0.1),
                  colorScheme.tertiary.withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: colorScheme.primary.withOpacity(0.2),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.beach_access_rounded,
                    size: 60,
                    color: colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Выходной!',
                  style: textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Сегодня занятий нет, можно отдохнуть',
                  textAlign: TextAlign.center,
                  style: textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _buildTipCard(
            context,
            icon: Icons.celebration_rounded,
            title: 'Идеальное время',
            subtitle: 'Для самообразования и отдыха',
            color: colorScheme.tertiary,
          ),
        ],
      ),
    );
  }

  Widget _buildBeforeLessonsState(
      BuildContext context, LectureTimerBeforeLessonsStartState state) {
    final lesson = state.lesson;
    final timeUntilStart = _calculateTimeUntilStart(lesson.startTime);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          _buildStatusHeader(
            context: context,
            icon: Icons.coffee_rounded,
            title: 'До начала занятий',
            subtitle: 'Первая пара начнётся в ${_formatTime(lesson.startTime)}',
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 32),
          _buildAnimatedTimerCard(
            context: context,
            time: timeUntilStart,
            label: 'До начала первой пары',
            gradient: LinearGradient(
              colors: [
                Theme.of(context).colorScheme.primaryContainer,
                Theme.of(context).colorScheme.primaryContainer.withOpacity(0.8),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _buildLessonPreviewCard(context, lesson,
              requestType: state.requestType, isNext: true),
        ],
      ),
    );
  }

  Widget _buildLessonState(
      BuildContext context, LectureTimerLessonState state) {
    final lesson = state.lesson;
    final breakDuration = state.freeTime;
    final timeUntilEnd = _calculateTimeUntilEnd(lesson.endTime);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          _buildStatusHeader(
            context: context,
            icon: Icons.school_rounded,
            title: 'Идёт пара',
            subtitle:
                '${lesson.number} пара • ${_formatTime(lesson.startTime)}-${_formatTime(lesson.endTime)}',
            color: Theme.of(context).colorScheme.secondary,
          ),
          const SizedBox(height: 32),
          _buildAnimatedTimerCard(
            context: context,
            time: timeUntilEnd,
            label: 'До конца пары',
            gradient: LinearGradient(
              colors: [
                Theme.of(context).colorScheme.secondaryContainer,
                Theme.of(context)
                    .colorScheme
                    .secondaryContainer
                    .withOpacity(0.8),
              ],
            ),
          ),
          if (breakDuration > Duration.zero) ...[
            const SizedBox(height: 24),
            _buildBreakPreviewCard(context, breakDuration),
          ],
          const SizedBox(height: 24),
          _buildLessonPreviewCard(context, lesson,
              requestType: state.requestType),
        ],
      ),
    );
  }

  Widget _buildFreeTimeState(
      BuildContext context, LectureTimerFreeTimeState state) {
    final breakDuration = state.duration;
    final nextLesson = state.nextLesson;
    final timeUntilNext = _calculateTimeUntilEnd(state.end);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          _buildStatusHeader(
            context: context,
            icon: Icons.free_breakfast_rounded,
            title: 'Перемена',
            subtitle: '${_formatTime(state.start)}-${_formatTime(state.end)}',
            color: Theme.of(context).colorScheme.tertiary,
          ),
          const SizedBox(height: 32),
          _buildAnimatedTimerCard(
            context: context,
            time: timeUntilNext,
            label: 'До начала следующей пары',
            gradient: LinearGradient(
              colors: [
                Theme.of(context).colorScheme.tertiaryContainer,
                Theme.of(context)
                    .colorScheme
                    .tertiaryContainer
                    .withOpacity(0.8),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _buildBreakPreviewCard(context, breakDuration),
          if (nextLesson != null) ...[
            const SizedBox(height: 24),
            _buildLessonPreviewCard(context, nextLesson,
                requestType: state.requestType, isNext: true),
          ],
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline_rounded,
            size: 64,
            color: colorScheme.error,
          ),
          const SizedBox(height: 16),
          Text(
            'Что-то пошло не так',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: colorScheme.onSurface,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Попробуйте обновить страницу',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusHeader({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withOpacity(0.15),
            color.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 28, color: color),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedTimerCard({
    required BuildContext context,
    required Duration time,
    required String label,
    required Gradient gradient,
  }) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    final hours = time.inHours;
    final minutes = time.inMinutes.remainder(60);
    final seconds = time.inSeconds.remainder(60);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.2),
            blurRadius: 25,
            offset: const Offset(0, 12),
            spreadRadius: 1,
          ),
          BoxShadow(
            color: colorScheme.primary.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          // Заголовок с анимацией появления
          AnimatedScale(
            duration: const Duration(milliseconds: 600),
            scale: 1.0,
            curve: Curves.elasticOut,
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.onPrimaryContainer,
                letterSpacing: 0.5,
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Основной таймер с анимацией
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildAnimatedTimeUnit(
                context,
                value: hours.toString().padLeft(2, '0'),
                unit: 'часов',
                isPulsing: hours > 0,
              ),
              _buildAnimatedTimeSeparator(context),
              _buildAnimatedTimeUnit(
                context,
                value: minutes.toString().padLeft(2, '0'),
                unit: 'минут',
                isPulsing: hours == 0 && minutes > 0,
              ),
              _buildAnimatedTimeSeparator(context),
              _buildAnimatedTimeUnit(
                context,
                value: seconds.toString().padLeft(2, '0'),
                unit: 'секунд',
                isPulsing: hours == 0 && minutes == 0,
              ),
            ],
          ),

          // Прогресс бар (только для урока или перемены)
          if (time.inMinutes < 60) ...[
            const SizedBox(height: 20),
            _buildProgressBar(context, time),
          ],
        ],
      ),
    );
  }

  Widget _buildAnimatedTimeUnit(
    BuildContext context, {
    required String value,
    required String unit,
    required bool isPulsing,
  }) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        // Анимированный контейнер для цифр
        AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            gradient: isPulsing
                ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      colorScheme.onPrimaryContainer.withOpacity(0.15),
                      colorScheme.onPrimaryContainer.withOpacity(0.25),
                    ],
                  )
                : null,
            color: isPulsing
                ? null
                : colorScheme.onPrimaryContainer.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isPulsing
                  ? colorScheme.onPrimaryContainer.withOpacity(0.3)
                  : Colors.transparent,
              width: isPulsing ? 2 : 0,
            ),
            boxShadow: isPulsing
                ? [
                    BoxShadow(
                      color: colorScheme.onPrimaryContainer.withOpacity(0.2),
                      blurRadius: 10,
                      spreadRadius: 1,
                    ),
                  ]
                : null,
          ),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 500),
            transitionBuilder: (Widget child, Animation<double> animation) {
              return ScaleTransition(
                scale: animation,
                child: FadeTransition(
                  opacity: animation,
                  child: child,
                ),
              );
            },
            child: Text(
              value,
              key: ValueKey(value), // Важно для анимации смены цифр
              style: textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onPrimaryContainer,
                fontFeatures: const [FontFeature.tabularFigures()],
                fontSize: isPulsing ? 28 : 24,
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),

        // Подпись с анимацией
        AnimatedOpacity(
          duration: const Duration(milliseconds: 300),
          opacity: isPulsing ? 1.0 : 0.7,
          child: Text(
            unit,
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.onPrimaryContainer.withOpacity(0.8),
              fontWeight: isPulsing ? FontWeight.w600 : FontWeight.w500,
              fontSize: isPulsing ? 12 : 11,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAnimatedTimeSeparator(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      child: TweenAnimationBuilder(
        duration: const Duration(milliseconds: 1000),
        tween: Tween<double>(begin: 0, end: 1),
        builder: (context, double value, child) {
          return Opacity(
            opacity: 0.5 + 0.5 * value,
            child: Transform.translate(
              offset: Offset(0, 2 * (1 - value)),
              child: child,
            ),
          );
        },
        child: Text(
          ':',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
        ),
      ),
    );
  }

  Widget _buildProgressBar(BuildContext context, Duration time) {
    final colorScheme = Theme.of(context).colorScheme;
    final totalMinutes = 60; // Максимальная длительность для прогресс бара
    final currentMinutes = time.inMinutes.clamp(0, totalMinutes);
    final progress = 1.0 - (currentMinutes / totalMinutes);

    return Column(
      children: [
        // Текст прогресса
        AnimatedOpacity(
          duration: const Duration(milliseconds: 300),
          opacity: progress > 0.1 ? 1.0 : 0.0,
          child: Text(
            '${(progress * 100).round()}%',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colorScheme.onPrimaryContainer.withOpacity(0.8),
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
        const SizedBox(height: 8),

        // Анимированный прогресс бар
        Container(
          height: 6,
          decoration: BoxDecoration(
            color: colorScheme.onPrimaryContainer.withOpacity(0.1),
            borderRadius: BorderRadius.circular(3),
          ),
          child: AnimatedFractionallySizedBox(
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeOutCubic,
            alignment: Alignment.centerLeft,
            widthFactor: progress,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    colorScheme.onPrimaryContainer,
                    colorScheme.onPrimaryContainer.withOpacity(0.8),
                  ],
                ),
                borderRadius: BorderRadius.circular(3),
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.onPrimaryContainer.withOpacity(0.3),
                    blurRadius: 4,
                    spreadRadius: 1,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBreakPreviewCard(BuildContext context, Duration duration) {
    final colorScheme = Theme.of(context).colorScheme;

    return _buildInfoCard(
      context,
      icon: Icons.timer_rounded,
      iconColor: colorScheme.tertiary,
      title: 'Длительность перемены',
      value: '${duration.inMinutes} ${_getMinutesText(duration.inMinutes)}',
      valueColor: colorScheme.tertiary,
    );
  }

  Widget _buildLessonPreviewCard(
    BuildContext context,
    LessonEntity lesson, {
    required ScheduleRequestType requestType,
    bool isNext = false,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colorScheme.outline.withOpacity(0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isNext ? Icons.next_plan_rounded : Icons.play_lesson_rounded,
                  size: 20,
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                isNext ? 'Следующая пара' : 'Текущая пара',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Универсальные поля для всех типов
          _buildDetailRow(
            context,
            icon: Icons.menu_book_rounded,
            label: 'Предмет',
            value: lesson.name ?? 'Не указано',
          ),
          _buildDetailRow(
            context,
            icon: Icons.schedule_rounded,
            label: 'Время',
            value:
                '${_formatTime(lesson.startTime)}-${_formatTime(lesson.endTime)}',
          ),

          // Динамические поля в зависимости от типа расписания
          if (requestType == ScheduleRequestType.groups) ...[
            _buildDetailRow(
              context,
              icon: Icons.person_rounded,
              label: 'Преподаватель',
              value: lesson.teacher ?? 'Не указано',
            ),
            _buildDetailRow(
              context,
              icon: Icons.room_rounded,
              label: 'Аудитория',
              value: lesson.classroom ?? 'Не указано',
            ),
            if (lesson.territory?.isNotEmpty == true)
              _buildDetailRow(
                context,
                icon: Icons.location_on_rounded,
                label: 'Корпус',
                value: lesson.territory!,
              ),
          ] else if (requestType == ScheduleRequestType.teachers) ...[
            _buildDetailRow(
              context,
              icon: Icons.groups_rounded,
              label: 'Группа',
              value: lesson.group ?? 'Не указано',
            ),
            _buildDetailRow(
              context,
              icon: Icons.room_rounded,
              label: 'Аудитория',
              value: lesson.classroom ?? 'Не указано',
            ),
            if (lesson.subgroup != 0)
              _buildDetailRow(
                context,
                icon: Icons.account_tree_rounded,
                label: 'Подгруппа',
                value: lesson.subgroup.toString(),
              ),
            if (lesson.territory?.isNotEmpty == true)
              _buildDetailRow(
                context,
                icon: Icons.location_on_rounded,
                label: 'Корпус',
                value: lesson.territory!,
              ),
          ] else if (requestType == ScheduleRequestType.classrooms) ...[
            _buildDetailRow(
              context,
              icon: Icons.groups_rounded,
              label: 'Группа',
              value: lesson.group ?? 'Не указано',
            ),
            _buildDetailRow(
              context,
              icon: Icons.person_rounded,
              label: 'Преподаватель',
              value: lesson.teacher ?? 'Не указано',
            ),
            if (lesson.subgroup != 0)
              _buildDetailRow(
                context,
                icon: Icons.account_tree_rounded,
                label: 'Подгруппа',
                value: lesson.subgroup.toString(),
              ),
            if (lesson.territory?.isNotEmpty == true)
              _buildDetailRow(
                context,
                icon: Icons.location_on_rounded,
                label: 'Корпус',
                value: lesson.territory!,
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildTipCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, size: 24, color: color),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                ),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
    required Color valueColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 20, color: iconColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: valueColor,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 18,
            color: colorScheme.onSurfaceVariant.withOpacity(0.6),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.w400,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getMinutesText(int minutes) {
    if (minutes % 10 == 1 && minutes % 100 != 11) return 'минута';
    if (minutes % 10 >= 2 &&
        minutes % 10 <= 4 &&
        (minutes % 100 < 10 || minutes % 100 >= 20)) {
      return 'минуты';
    }
    return 'минут';
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
