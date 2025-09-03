
import 'package:dio/dio.dart';
import 'package:html/dom.dart';
import 'package:html/parser.dart';

import '../../../../../core/enums/schedule_request_type.dart';

class AsiecIdsApi {
  final Dio _client;
  final String _groupsUrl = 'https://www.asiec.ru/ras/filter_grup.php';
  final String _teachersUrl = 'https://www.asiec.ru/ras/filter_prep.php';
  final String _classroomsUrl = 'https://www.asiec.ru/ras/filter_aud.php';

  static const Map<String, String> _headers = {
    "Accept-Language": "ru-RU,ru;q=0.9,en-US;q=0.8,en;q=0.7",
    "User-Agent": "AsiecScheduleAndroidApp",
    "X-Requested-With": "XMLHttpRequest",
  };

  static const Map<String, String> _body = {
    'dostup': 'true',
  };


  const AsiecIdsApi(this._client);


  Future<Map<ScheduleRequestType, Map<String, String>>> getIds() async {
    Map<ScheduleRequestType, Map<String, String>> allIds = {};
    final groupIds = await _getGroupsIds();
    final teachersIds = await _getTeachersIds();
    final classroomsIds = await _getClassroomsIds();

    allIds[ScheduleRequestType.groups] = groupIds;
    allIds[ScheduleRequestType.teachers] = teachersIds;
    allIds[ScheduleRequestType.classrooms] = classroomsIds;

    return allIds;
  }


  Future<Map<String, String>> _getGroupsIds() async {
    final response = await _client.post(
        _groupsUrl,
        data: _body,
        options: Options(
          headers: _headers,
          contentType: Headers.formUrlEncodedContentType
        )
    );

    return _parseIds(response.data);
  }


  Future<Map<String, String>> _getTeachersIds() async {
    final response = await _client.post(
        _teachersUrl,
        data: _body,
        options: Options(
            headers: _headers,
            contentType: Headers.formUrlEncodedContentType
        )
    );

    return _parseIds(response.data);
  }


  Future<Map<String, String>> _getClassroomsIds() async {
    final response = await _client.post(
        _classroomsUrl,
        data: _body,
        options: Options(
            headers: _headers,
            contentType: Headers.formUrlEncodedContentType
        )
    );

    return _parseIds(response.data);
  }


  Map<String, String> _parseIds(String body) {
    Map<String, String> ids = {};
    Document document = parse(body);
    final List<Element> options = document.getElementsByTagName('option');


    for (final Element option in options) {
      String key = option.text.trim();
      final String value = option.attributes['value'] ?? '';

      if (key == '') {
        continue;
      }

      if (ids.containsKey(key)) {
        key += ' (2)';
      }

      ids[key] = value;
    }

    return ids;
  }
}