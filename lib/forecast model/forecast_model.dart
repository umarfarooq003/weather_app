class Forecast {
  final String day;
  final String icon;
  final double temp;

  Forecast({
    required this.day,
    required this.icon,
    required this.temp,
  });

  /// Factory constructor to create a single Forecast object from JSON
  factory Forecast.fromJson(Map<String, dynamic> json) {
    final dateTime = DateTime.fromMillisecondsSinceEpoch(json['dt'] * 1000);
    final dayName = _getWeekday(dateTime.weekday);

    return Forecast(
      day: dayName,
      icon: json['weather'][0]['icon'],
      temp: (json['main']['temp'] as num).toDouble(),
    );
  }

  /// Static method to parse the full forecast JSON response into a list
  static List<Forecast> fromForecastJson(Map<String, dynamic> json) {
    final List list = json['list'];
    final List<Forecast> dailyForecasts = [];

    // OpenWeatherMap gives data every 3 hours, so we take one every 8 (24h) to get daily
    for (int i = 0; i < list.length; i += 8) {
      final item = list[i];
      final forecast = Forecast.fromJson(item);
      dailyForecasts.add(forecast);
    }

    return dailyForecasts;
  }

  /// Helper to get weekday name from int
  static String _getWeekday(int weekday) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[(weekday - 1) % 7];
  }
}
