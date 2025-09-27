
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';

void main() async {
  final client = Dio();
  (client.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
      (HttpClient client) {
    client.badCertificateCallback =
        (X509Certificate cert, String host, int port) => true;
    return client;
  };


  final response = await client.post(
    "https://www.asiec.ru/ras/ras.php",
    data: {
      'dostup': true,
      'gruppa': '3afb102a-1ea1-11ed-abe0-00155d879809%0A',
      'calendar': '2025-04-09',
      'calendar2': '2025-04-09',
      'ras': 'GRUP'
    },
    options: Options(
      headers: {
        "Accept-Language": "ru-RU,ru;q=0.9,en-US;q=0.8,en;q=0.7",
        "User-Agent": "AsiecScheduleAndroidApp",
      },
      contentType: Headers.formUrlEncodedContentType
    )
  );

  print(response.data);
}