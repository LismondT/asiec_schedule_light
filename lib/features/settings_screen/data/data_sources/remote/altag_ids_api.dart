import 'package:asiec_schedule/core/enums/schedule_request_type.dart';
import 'package:html/dom.dart';
import 'package:html/parser.dart';
import 'package:http/http.dart';

class AltagIdsApi {
  final Client _client;
  final String _groupsUrl = 'http://schedule.altag.ru:89/filter_grup.php';
  final String _teachersUrl = 'http://schedule.altag.ru:89/filter_prep.php';
  final String _classroomsUrl = 'http://schedule.altag.ru:89/filter_aud.php';

  static const Map<String, String> _headers = {
    "Accept-Language": "ru-RU,ru;q=0.9,en-US;q=0.8,en;q=0.7",
    "User-Agent": "AltagScheduleAndroidApp",
    "X-Requested-With": "XMLHttpRequest",
  };

  static const Map<String, String> _body = {
    'dostup': 'true',
  };


  const AltagIdsApi(this._client);


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
    Response response = await _client.post(
      Uri.parse(_groupsUrl),
      headers: _headers,
      body: _body
    );

    String body = response.body;
    
    return _parseIds(body);
  }


  Future<Map<String, String>> _getTeachersIds() async {
    Response response = await _client.post(
      Uri.parse(_teachersUrl),
      headers: _headers,
      body: _body
    );

    String body = response.body;

    return _parseIds(body);
  }


  Future<Map<String, String>> _getClassroomsIds() async {
    Response response = await _client.post(
      Uri.parse(_classroomsUrl),
      headers: _headers,
      body: _body
    );

    String body = response.body;

    return _parseIds(body);
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