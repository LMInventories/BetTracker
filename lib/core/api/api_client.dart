import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiClient {
  static const _baseUrl = 'https://api-football-v1.p.rapidapi.com/v3';
  static const _host = 'api-football-v1.p.rapidapi.com';

  static Dio create(String apiKey) {
    final dio = Dio(
      BaseOptions(
        baseUrl: _baseUrl,
        headers: {
          'X-RapidAPI-Key': apiKey,
          'X-RapidAPI-Host': _host,
        },
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 15),
      ),
    );
    return dio;
  }

  static Future<String> getStoredKey() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('rapidapi_key') ?? '';
  }

  static Future<void> saveKey(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('rapidapi_key', key);
  }
}
