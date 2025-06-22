import 'dart:convert';
import 'package:http/http.dart' as http;
import '../weather model/weather_model.dart';
import '../forecast model/forecast_model.dart';

class WeatherService {
  static const String apiKey = '72688363f4ed0e72b351bb97207fb9f9'; // replace with your actual API key

  static Future<Weather> fetchWeather({required String city}) async {
    final url = Uri.parse('https://api.openweathermap.org/data/2.5/weather?q=$city&units=metric&appid=$apiKey');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return Weather.fromJson(json);
    } else {
      throw Exception('Failed to load weather data: ${response.statusCode}\n${response.body}');
    }
  }

  static Future<List<Forecast>> fetchForecast({required String city}) async {
    final url = Uri.parse('https://api.openweathermap.org/data/2.5/forecast?q=$city&units=metric&appid=$apiKey');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return Forecast.fromForecastJson(json);
    } else {
      throw Exception('Failed to load forecast: ${response.statusCode}\n${response.body}');
    }
  }

  static Future<Weather> fetchWeatherByLocation(double lat, double lon) async {
    final url = Uri.parse('https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lon&units=metric&appid=$apiKey');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return Weather.fromJson(json);
    } else {
      throw Exception('Failed to load weather by location: ${response.statusCode}\n${response.body}');
    }
  }

  static Future<List<Forecast>> fetchForecastByLocation(double lat, double lon) async {
    final url = Uri.parse('https://api.openweathermap.org/data/2.5/forecast?lat=$lat&lon=$lon&units=metric&appid=$apiKey');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return Forecast.fromForecastJson(json);
    } else {
      throw Exception('Failed to load forecast by location: ${response.statusCode}\n${response.body}');
    }
  }
}
