import 'package:asiec_schedule/core/domain/entity/schedule.dart';
import 'package:asiec_schedule/core/enums/schedule_request_type.dart';
import 'package:asiec_schedule/features/schedule_screen/presentation/cubit/schedule_cubit.dart';
import 'package:asiec_schedule/features/schedule_screen/presentation/cubit/schedule_cubit_states.dart';
import 'package:asiec_schedule/features/schedule_screen/presentation/widgets/day_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../widgets/bouncing_icon.dart';

class ScheduleScreen extends StatelessWidget {
  const ScheduleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: CustomScrollView(
        slivers: [
          // Красивый AppBar с градиентом
          SliverAppBar(
            backgroundColor: Colors.transparent,
            foregroundColor: colorScheme.onSurface,
            floating: true,
            snap: true,
            elevation: 0,
            scrolledUnderElevation: 8,
            flexibleSpace: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    colorScheme.primaryContainer.withOpacity(0.8),
                    colorScheme.secondaryContainer.withOpacity(0.6),
                  ],
                ),
              ),
            ),
            title: BlocBuilder<ScheduleCubit, ScheduleState>(
              builder: (context, state) {
                final isBackup =
                    state is ScheduleStateLoaded && state.isLocalSchedule;
                final isDateSelected = state is ScheduleStateLoadedByDate;

                return AnimatedSwitcher(
                  duration: const Duration(milliseconds: 500),
                  transitionBuilder: (child, animation) {
                    return FadeTransition(
                      opacity: CurvedAnimation(
                        parent: animation,
                        curve: Curves.easeOutCubic,
                      ),
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0, 0.3),
                          end: Offset.zero,
                        ).animate(CurvedAnimation(
                          parent: animation,
                          curve: Curves.easeOutBack,
                        )),
                        child: child,
                      ),
                    );
                  },
                  child: Row(
                    key: ValueKey('$isBackup$isDateSelected'),
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      if (isBackup) ...[
                        PulsingIcon(
                          icon: Icons.warning_amber_rounded,
                          color: colorScheme.error,
                        ),
                        const SizedBox(width: 8),
                      ],
                      if (isDateSelected) ...[
                        PulsingIcon(
                          icon: Icons.calendar_month_rounded,
                          color: colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                      ],
                      Expanded(
                        child: Text(
                          _getAppBarTitle(state),
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: colorScheme.onPrimaryContainer,
                            letterSpacing: -0.5,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            actions: [
              // Кнопка возврата к обычному расписанию
              BlocBuilder<ScheduleCubit, ScheduleState>(
                builder: (context, state) {
                  if (state is ScheduleStateLoadedByDate) {
                    return IconButton(
                      onPressed: () =>
                          context.read<ScheduleCubit>().loadDefaultSchedule(),
                      icon: _buildAnimatedIcon(
                        Icons.close_rounded,
                        colorScheme.onPrimaryContainer,
                      ),
                      tooltip: 'Вернуться к обычному расписанию',
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
              // Кнопка выбора даты
              BlocBuilder<ScheduleCubit, ScheduleState>(
                builder: (context, state) {
                  if (state is ScheduleStateLoadedByDate ||
                      state is ScheduleStateLoaded) {
                    if (state is ScheduleStateLoaded && state.isLocalSchedule) {
                      return const SizedBox.shrink();
                    }
                    return IconButton(
                      onPressed: () => _showDatePicker(context),
                      icon: _buildAnimatedIcon(
                        Icons.calendar_today_rounded,
                        colorScheme.onPrimaryContainer,
                      ),
                      tooltip: 'Выбрать дату',
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
              // Кнопка обновления
              BlocBuilder<ScheduleCubit, ScheduleState>(
                builder: (context, state) {
                  if (state is! ScheduleStateLoadedByDate &&
                      state is! ScheduleStateIdUnselected) {
                    return IconButton(
                      onPressed: () =>
                          context.read<ScheduleCubit>().loadDefaultSchedule(),
                      icon: _buildAnimatedIcon(
                        Icons.refresh_rounded,
                        colorScheme.onPrimaryContainer,
                      ),
                      tooltip: 'Обновить',
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ],
          ),

          // Body с улучшенными анимациями
          BlocBuilder<ScheduleCubit, ScheduleState>(
            builder: (context, state) {
              return _buildStateContent(context, state);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStateContent(BuildContext context, ScheduleState state) {
    switch (state) {
      case ScheduleStateInit():
      case ScheduleStateLoading():
        return _buildEnhancedLoadingBody(context);
      case ScheduleStateLoaded():
        return _buildDoneBody(state.data, state.type);
      case ScheduleStateLoadedByDate():
        return _buildDoneBody(state.data, state.type);
      case ScheduleStateEmpty():
        return _buildEnhancedEmptyScreen(context);
      case ScheduleStateIdUnselected():
        return _buildEnhancedWithoutIdScreen(context);
      case ScheduleStateError():
        return _buildEnhancedErrorBody(context, state.message);
    }
  }

  Widget _buildAnimatedIcon(IconData icon, Color color) {
    return TweenAnimationBuilder(
      duration: const Duration(milliseconds: 300),
      tween: Tween<double>(begin: 0.0, end: 1.0),
      builder: (context, double value, child) {
        return Opacity(
          opacity: value,
          child: Transform.scale(
            scale: 0.8 + 0.2 * value,
            child: Icon(icon, color: color),
          ),
        );
      },
    );
  }

  Future<void> _showDatePicker(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).colorScheme.primary,
              onPrimary: Theme.of(context).colorScheme.onPrimary,
              surface: Theme.of(context).colorScheme.surface,
              onSurface: Theme.of(context).colorScheme.onSurface,
            ),
            dialogBackgroundColor: Theme.of(context).colorScheme.surface,
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      context.read<ScheduleCubit>().loadSchedule(picked);
    }
  }

  Widget _buildEnhancedErrorBody(BuildContext context, String error) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return SliverToBoxAdapter(
      child: Container(
        height: 500,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Анимированная иконка ошибки
                TweenAnimationBuilder(
                  duration: const Duration(milliseconds: 800),
                  tween: Tween<double>(begin: 0.0, end: 1.0),
                  builder: (context, double value, child) {
                    return Transform.scale(
                      scale: 0.5 + 0.5 * value,
                      child: Opacity(
                        opacity: value,
                        child: child,
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: colorScheme.errorContainer,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: colorScheme.error.withOpacity(0.3),
                          blurRadius: 15,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.error_outline_rounded,
                      size: 48,
                      color: colorScheme.onErrorContainer,
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Текст с анимацией появления
                AnimatedOpacity(
                  duration: const Duration(milliseconds: 600),
                  opacity: 1.0,
                  child: Column(
                    children: [
                      Text(
                        'Что-то пошло не так',
                        style: textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        error,
                        style: textTheme.bodyLarge?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          height: 1.4,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Анимированная кнопка
                TweenAnimationBuilder(
                  duration: const Duration(milliseconds: 1000),
                  tween: Tween<double>(begin: 0.0, end: 1.0),
                  builder: (context, double value, child) {
                    return Opacity(
                      opacity: value,
                      child: Transform.translate(
                        offset: Offset(0, 20 * (1 - value)),
                        child: child,
                      ),
                    );
                  },
                  child: FilledButton(
                    onPressed: () =>
                        context.read<ScheduleCubit>().loadDefaultSchedule(),
                    style: FilledButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      foregroundColor: colorScheme.onPrimary,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 32, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text('Попробовать снова'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEnhancedLoadingBody(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SliverToBoxAdapter(
      child: SizedBox(
        height: 500,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Основная анимированная иконка загрузки
                SizedBox(
                  width: 120,
                  height: 120,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Внешнее пульсирующее кольцо
                      PulsingContainer(
                        duration: const Duration(milliseconds: 2000),
                        child: Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: colorScheme.primary.withOpacity(0.3),
                              width: 3,
                            ),
                          ),
                        ),
                      ),

                      // Вращающееся кольцо прогресса
                      SizedBox(
                        width: 80,
                        height: 80,
                        child: CircularProgressIndicator(
                          strokeWidth: 4,
                          valueColor: AlwaysStoppedAnimation(
                            colorScheme.primary,
                          ),
                          backgroundColor: colorScheme.primary.withOpacity(0.2),
                        ),
                      ),

                      // Центральная иконка с пульсацией
                      PulsingIcon(
                        icon: Icons.schedule_rounded,
                        color: colorScheme.onPrimaryContainer,
                        size: 32,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),

                // Анимированный текст
                Column(
                  children: [
                    TweenAnimationBuilder(
                      duration: const Duration(milliseconds: 800),
                      tween: Tween<double>(begin: 0.0, end: 1.0),
                      builder: (context, double value, child) {
                        return Opacity(
                          opacity: value,
                          child: Transform.translate(
                            offset: Offset(0, 10 * (1 - value)),
                            child: child,
                          ),
                        );
                      },
                      child: Text(
                        'Загружаем расписание',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: colorScheme.onSurface,
                            ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Пульсирующие точки
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        PulsingDot(delay: 0, color: colorScheme.primary),
                        const SizedBox(width: 8),
                        PulsingDot(delay: 200, color: colorScheme.primary),
                        const SizedBox(width: 8),
                        PulsingDot(delay: 400, color: colorScheme.primary),
                      ],
                    ),
                  ],
                ),

                // Skeleton загрузки дней
                const SizedBox(height: 40),
                _buildLoadingSkeleton(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingSkeleton(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: List.generate(3, (index) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: TweenAnimationBuilder(
            duration: Duration(milliseconds: 600 + index * 200),
            tween: Tween<double>(begin: 0.0, end: 1.0),
            builder: (context, double value, child) {
              return Opacity(
                opacity: value,
                child: Transform.translate(
                  offset: Offset(20 * (1 - value), 0),
                  child: child,
                ),
              );
            },
            child: Container(
              height: 100,
              decoration: BoxDecoration(
                color: colorScheme.surfaceVariant.withOpacity(0.5),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.shadow.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    // Skeleton для даты
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: colorScheme.onSurfaceVariant.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Skeleton для контента
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: double.infinity,
                            height: 16,
                            decoration: BoxDecoration(
                              color:
                                  colorScheme.onSurfaceVariant.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            width: 120,
                            height: 12,
                            decoration: BoxDecoration(
                              color:
                                  colorScheme.onSurfaceVariant.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildDoneBody(Schedule schedule, ScheduleRequestType type) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) => AnimatedDayTile(
          day: schedule.days[index],
          type: type,
          index: index,
        ),
        childCount: schedule.days.length,
      ),
    );
  }

  Widget _buildEnhancedWithoutIdScreen(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SliverToBoxAdapter(
      child: SizedBox(
        height: 500,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TweenAnimationBuilder(
                  duration: const Duration(milliseconds: 800),
                  tween: Tween<double>(begin: 0.0, end: 1.0),
                  builder: (context, double value, child) {
                    return Transform.scale(
                      scale: 0.8 + 0.2 * value,
                      child: Opacity(
                        opacity: value,
                        child: child,
                      ),
                    );
                  },
                  child: Icon(
                    Icons.settings_rounded,
                    size: 80,
                    color: colorScheme.primary.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 24),
                AnimatedOpacity(
                  duration: const Duration(milliseconds: 600),
                  opacity: 1.0,
                  child: Column(
                    children: [
                      Text(
                        'Выберите группу',
                        style:
                            Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.onSurface,
                                ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Перейдите в настройки, чтобы выбрать группу, преподавателя или аудиторию',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                              height: 1.4,
                            ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEnhancedEmptyScreen(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return SliverToBoxAdapter(
      child: SizedBox(
        height: 500,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Анимированная иконка праздника
                TweenAnimationBuilder(
                  duration: const Duration(milliseconds: 1000),
                  tween: Tween<double>(begin: 0.0, end: 1.0),
                  builder: (context, double value, child) {
                    return Transform.scale(
                      scale: 0.7 + 0.3 * value,
                      child: Opacity(
                        opacity: value,
                        child: child,
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          colorScheme.primary.withOpacity(0.1),
                          colorScheme.tertiary.withOpacity(0.1),
                        ],
                      ),
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
                      Icons.celebration_rounded,
                      size: 64,
                      color: colorScheme.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Текст с анимацией
                AnimatedOpacity(
                  duration: const Duration(milliseconds: 800),
                  opacity: 1.0,
                  child: Column(
                    children: [
                      Text(
                        'Ура! Свободные дни!',
                        style: textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Похоже, занятий не найдено.\nМожно отдохнуть или заняться чем-то полезным!',
                        style: textTheme.bodyLarge?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Или возможны временные проблемы с сайтом расписания',
                        style: textTheme.bodyMedium?.copyWith(
                          color: colorScheme.outline,
                          fontStyle: FontStyle.italic,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Анимированные иконки
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    BouncingIcon(icon: Icons.coffee_rounded, delay: 0),
                    const SizedBox(width: 20),
                    BouncingIcon(icon: Icons.book_rounded, delay: 200),
                    const SizedBox(width: 20),
                    BouncingIcon(
                        icon: Icons.sports_esports_rounded, delay: 400),
                  ],
                ),
                const SizedBox(height: 32),

                // Анимированная кнопка
                TweenAnimationBuilder(
                  duration: const Duration(milliseconds: 1200),
                  tween: Tween<double>(begin: 0.0, end: 1.0),
                  builder: (context, double value, child) {
                    return Opacity(
                      opacity: value,
                      child: Transform.translate(
                        offset: Offset(0, 30 * (1 - value)),
                        child: child,
                      ),
                    );
                  },
                  child: FilledButton(
                    onPressed: () =>
                        context.read<ScheduleCubit>().loadDefaultSchedule(),
                    style: FilledButton.styleFrom(
                      backgroundColor: colorScheme.primaryContainer,
                      foregroundColor: colorScheme.onPrimaryContainer,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 32, vertical: 16),
                    ),
                    child: const Text('Обновить расписание'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getAppBarTitle(ScheduleState state) {
    if (state is ScheduleStateLoaded && state.isLocalSchedule) {
      return 'Расписание (резерв)';
    }
    if (state is ScheduleStateLoadedByDate) {
      return 'Расписание по дате';
    }
    return 'Расписание';
  }
}

// Анимированная версия DayTile для плавного появления
class AnimatedDayTile extends StatelessWidget {
  final dynamic day;
  final ScheduleRequestType type;
  final int index;

  const AnimatedDayTile({
    super.key,
    required this.day,
    required this.type,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder(
      duration: Duration(milliseconds: 400 + index * 100),
      tween: Tween<double>(begin: 0.0, end: 1.0),
      curve: Curves.easeOutCubic,
      builder: (context, double value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: child,
          ),
        );
      },
      child: DayTile(day: day, type: type),
    );
  }
}

// Пульсирующая иконка
class PulsingIcon extends StatefulWidget {
  final IconData icon;
  final Color color;
  final double size;

  const PulsingIcon({
    super.key,
    required this.icon,
    required this.color,
    this.size = 20,
  });

  @override
  State<PulsingIcon> createState() => _PulsingIconState();
}

class _PulsingIconState extends State<PulsingIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0.8, end: 1.2).animate(_controller);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.scale(
          scale: _animation.value,
          child: Icon(
            widget.icon,
            size: widget.size,
            color: widget.color,
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

// Пульсирующий контейнер
class PulsingContainer extends StatefulWidget {
  final Widget child;
  final Duration duration;

  const PulsingContainer({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 1500),
  });

  @override
  State<PulsingContainer> createState() => _PulsingContainerState();
}

class _PulsingContainerState extends State<PulsingContainer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0.9, end: 1.1).animate(_controller);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.scale(
          scale: _animation.value,
          child: widget.child,
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

// Пульсирующая точка
class PulsingDot extends StatefulWidget {
  final int delay;
  final Color color;

  const PulsingDot({
    super.key,
    required this.delay,
    required this.color,
  });

  @override
  State<PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<PulsingDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    if (widget.delay > 0) {
      Future.delayed(Duration(milliseconds: widget.delay), () {
        if (mounted) _controller.repeat(reverse: true);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Opacity(
          opacity: _animation.value,
          child: Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: widget.color,
              shape: BoxShape.circle,
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
