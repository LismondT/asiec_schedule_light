
import 'dart:async';
import 'package:asiec_schedule/core/presentation/widgets/app_bar_title.dart';
import 'package:asiec_schedule/features/schedule_screen/presentation/bloc/schedule/remote/remote_schedule_events.dart';
import 'package:asiec_schedule/injection_container.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';

import 'package:asiec_schedule/features/schedule_screen/presentation/bloc/schedule/remote/remote_schedule_bloc.dart';
import 'package:asiec_schedule/features/schedule_screen/presentation/bloc/schedule/remote/remote_schedule_state.dart';
import 'package:asiec_schedule/features/schedule_screen/presentation/widgets/day_tile.dart';
import 'package:asiec_schedule/core/domain/entity/day_entity.dart';

class ScheduleScreen extends StatelessWidget {
  const ScheduleScreen({super.key});
  
  @override
  Widget build(BuildContext context) {
    return BlocProvider<RemoteScheduleBloc>(
      create: (context) => sl()..add(InitializeScheduleEvent()),
      child: Scaffold(
        body: CustomScrollView(
          slivers: [
            //AppBar
            SliverAppBar(
              backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
              floating: true,
              title: AppBarTitle(title: 'Расписание')
            ),

            //Body
            BlocBuilder<RemoteScheduleBloc, RemoteScheduleState>(
              builder: (_, state) {
                //Loading
                if (state is RemoteScheduleLoading) {
                  return SliverToBoxAdapter(child: _buildLoadingBody());
                }
            
                if (state is RemoteScheduleWithoutId) {
                  return _buildWithoutIdScreen();
                }
                
                //Done
                if (state is RemoteScheduleDone) {
                  return _buildDoneBody(state.scheduleController);
                }


                return SliverToBoxAdapter(child: const SizedBox());
              }
            ),
          ]
        ),
      ),
    );
  }

  Widget _buildLoadingBody() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24.0),
        child: CircularProgressIndicator(),
      )
    );
  }

  Widget _buildDoneBody(StreamController<List<DayEntity>>? scheduleController) {
    return StreamBuilder<List<DayEntity>>(
      stream: scheduleController?.stream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SliverToBoxAdapter(
            child: Center(
              child: Padding(
                padding: EdgeInsets.all(24.0),
                child: CircularProgressIndicator(),
              )
            )
          );
        }

        if (snapshot.hasError) {
          return SliverToBoxAdapter(
            child: Center(child: Text('Ошибка загрузки данных')),
          );
        }


        final days = snapshot.data ?? [];
        
        if (days.isEmpty) {
          return SliverToBoxAdapter(
            child: Center(child: Text('Нет доступных данных')),
          );
        }

        return SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) => Daytile(day: days[index]),
            childCount: days.length,
          ),
        );
      }
    );
  }

  Widget _buildWithoutIdScreen() {
    return SliverToBoxAdapter(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: const Text('Выберите группу в настройках',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),  
          ),
        ),
      )
    );
  }
}