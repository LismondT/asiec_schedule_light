import 'package:asiec_schedule/core/domain/entity/schedule_entity.dart';
import 'package:asiec_schedule/features/schedule_screen/presentation/cubit/schedule_cubit.dart';
import 'package:asiec_schedule/features/schedule_screen/presentation/cubit/schedule_cubit_states.dart';
import 'package:asiec_schedule/features/schedule_screen/presentation/widgets/day_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ScheduleScreen extends StatelessWidget {
  const ScheduleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(slivers: [
        //AppBar
        SliverAppBar(
          backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
          floating: true,
          title: BlocBuilder<ScheduleCubit, ScheduleState>(
              builder: (context, state) {
            final isBackup =
                state is ScheduleStateLoaded && state.isLocalSchedule;
            return AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (child, animation) {
                return FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                            begin: const Offset(0, 0.5), end: Offset.zero)
                        .animate(CurvedAnimation(
                            parent: animation, curve: Curves.easeOut)),
                    child: child,
                  ),
                );
              },
              child: Row(
                key: ValueKey(isBackup),
                mainAxisSize: MainAxisSize.max,
                children: [
                  if (isBackup) ...[
                    Icon(
                      Icons.warning_amber,
                      size: 20,
                      color: Theme.of(context).colorScheme.onSecondaryContainer,
                    ),
                    const SizedBox(width: 6)
                  ],
                  Text(
                    isBackup ? 'Расписание (резерв)' : 'Расписание',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSecondaryContainer,
                    ),
                  ),
                ],
              ),
            );
          }),
          actions: [
            IconButton(
                onPressed: () =>
                    context.read<ScheduleCubit>().loadDefaultSchedule(),
                icon: Icon(Icons.refresh))
          ],
        ),

        //Body
        BlocBuilder<ScheduleCubit, ScheduleState>(builder: (context, state) {
          switch (state) {
            case ScheduleStateInit():
            case ScheduleStateLoading():
              return _buildLoadingBody();
            case ScheduleStateLoaded():
              return _buildDoneBody(state.data);
            case ScheduleStateEmpty():
              return _buildEmptyScreen(context);
            case ScheduleStateIdUnselected():
              return _buildWithoutIdScreen();
            case ScheduleStateError():
              return _buildErrorBody(context, state.message);
          }
        }),
      ]),
    );
  }

  Widget _buildErrorBody(BuildContext context, String error) {
    return SliverToBoxAdapter(
      child: Container(
        height: 400, // Фиксированная высота для ошибки
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline_rounded,
                  size: 64,
                  color: Theme.of(context).colorScheme.error,
                ),
                const SizedBox(height: 20),
                Text(
                  'Произошла ошибка',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  error,
                  style: TextStyle(
                    fontSize: 16,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                FilledButton.tonal(
                  onPressed: () =>
                      context.read<ScheduleCubit>().loadDefaultSchedule(),
                  style: FilledButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  ),
                  child: const Text('Попробовать снова'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingBody() {
    return const SliverToBoxAdapter(
      child: Center(
          child: Padding(
        padding: EdgeInsets.all(24.0),
        child: CircularProgressIndicator(),
      )),
    );
  }

  Widget _buildDoneBody(ScheduleEntity schedule) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) => Daytile(day: schedule.days[index]),
        childCount: schedule.days.length,
      ),
    );
  }

  Widget _buildWithoutIdScreen() {
    return const SliverToBoxAdapter(
        child: Center(
      child: Padding(
        padding: EdgeInsets.all(24.0),
        child: Text(
          'Выберите группу в настройках',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    ));
  }

  Widget _buildEmptyScreen(BuildContext context) {
    return SliverToBoxAdapter(
      child: Container(
        height: 400,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Анимированная иконка или эмодзи
                Icon(
                  Icons.celebration_rounded,
                  size: 80,
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.8),
                ),
                const SizedBox(height: 24),

                // Заголовок
                Text(
                  'Ура! Свободные дни!',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                    height: 1.3,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 16),

                // Описание
                Text(
                  'Похоже, занятий не найдено.\nМожно отдохнуть или заняться чем-то полезным!',
                  style: TextStyle(
                    fontSize: 16,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 8),

                // Дополнительная информация
                Text(
                  'Или возможны временные проблемы с сайтом расписания',
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).colorScheme.outline,
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 32),

                // Декоративные элементы
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildDecorIcon(context, Icons.coffee_rounded),
                    const SizedBox(width: 16),
                    _buildDecorIcon(context, Icons.book_rounded),
                    const SizedBox(width: 16),
                    _buildDecorIcon(context, Icons.sports_esports_rounded),
                  ],
                ),

                const SizedBox(height: 24),

                // Кнопка обновления
                FilledButton.tonal(
                  onPressed: () =>
                      context.read<ScheduleCubit>().loadDefaultSchedule(),
                  style: FilledButton.styleFrom(
                    backgroundColor:
                        Theme.of(context).colorScheme.primaryContainer,
                    foregroundColor:
                        Theme.of(context).colorScheme.onPrimaryContainer,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                  ),
                  child: const Text('Обновить расписание'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

// Вспомогательный метод для декоративных иконок
  Widget _buildDecorIcon(BuildContext context, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
        shape: BoxShape.circle,
      ),
      child: Icon(
        icon,
        size: 20,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );
  }

  String _getAppBarTitle(ScheduleState state) {
    if (state is ScheduleStateLoaded && state.isLocalSchedule) {
      return 'Расписание (резерв)';
    }
    return 'Расписание';
  }
}
