import 'package:asiec_schedule/core/domain/entity/schedule_entity.dart';
import 'package:asiec_schedule/features/schedule_screen/data/data_sources/remote/schedule_remote_datasource.dart';
import 'package:asiec_schedule/features/schedule_screen/domain/repository/schedule_repository.dart';

import '../../../../core/enums/schedule_request_type.dart';

class ScheduleRepositoryImpl extends ScheduleRepository {
  final ScheduleRemoteDatasource _remoteDatasource;

  ScheduleRepositoryImpl(this._remoteDatasource);

  @override
  Future<ScheduleEntity> getSchedule(
      DateTime start, int days, ScheduleRequestType type, String id) async {
    return await _remoteDatasource.getSchedule(start, days, type, id);
  }
}
