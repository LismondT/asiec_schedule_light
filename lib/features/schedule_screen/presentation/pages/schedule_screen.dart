import 'package:asiec_schedule/core/domain/entity/schedule_entity.dart';
import 'package:asiec_schedule/core/presentation/widgets/app_bar_title.dart';
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
          title: AppBarTitle(title: 'Расписание'),
          actions: [
            IconButton(
                onPressed: () =>
                    context.read<ScheduleCubit>().loadDefaultSchedule(),
                icon: Icon(Icons.refresh))
          ],
        ),

        //Body
        BlocBuilder<ScheduleCubit, ScheduleState>(builder: (_, state) {
          switch (state) {
            case ScheduleStateInit():
            case ScheduleStateLoading():
              return _buildLoadingBody();
            case ScheduleStateLoaded():
              return _buildDoneBody(state.data);
            case ScheduleStateEmpty():
              return _buildEmptyScreen();
            case ScheduleStateIdUnselected():
              return _buildWithoutIdScreen();
            case ScheduleStateError():
              // TODO: Handle this case.
              throw UnimplementedError();
          }
        }),
      ]),
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

  Widget _buildEmptyScreen() {
    return const SliverToBoxAdapter(
      child: Center(
          child: Text(
              'Занятия не найдены! Дни свободны!... Или проблемы с сайтом расписания -_-')),
    );
  }
}
