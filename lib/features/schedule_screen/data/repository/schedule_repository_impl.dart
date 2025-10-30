import 'package:asiec_schedule/core/domain/entity/schedule.dart';
import 'package:asiec_schedule/features/schedule_screen/data/data_sources/local/schedule_local_datasource.dart';
import 'package:asiec_schedule/features/schedule_screen/data/data_sources/remote/schedule_remote_datasource.dart';
import 'package:asiec_schedule/features/schedule_screen/domain/repository/schedule_repository.dart';

import '../../../../core/enums/schedule_request_type.dart';

class ScheduleRepositoryImpl extends ScheduleRepository {
  final ScheduleRemoteDatasource _remoteDatasource;
  final ScheduleLocalDatasource _localDatasource;

  ScheduleRepositoryImpl(this._remoteDatasource, this._localDatasource);

  @override
  Future<Schedule> getSchedule(
      DateTime start, int days, ScheduleRequestType type, String id) async {
    return await _remoteDatasource.getSchedule(start, days, type, id);
  }

  @override
  Future<Schedule> getLocalSchedule() async {
    return await _localDatasource.getSchedule();
  }

  @override
  Future<void> saveLocalSchedule(Schedule schedule) async {
    await _localDatasource.saveSchedule(schedule);
  }
}
