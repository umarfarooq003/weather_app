class Weather {
  final String cityName;
  final double temp, windSpeed, humidity, pressure;
  final String description, icon;

  Weather({
    required this.cityName,
    required this.temp,
    required this.windSpeed,
    required this.humidity,
    required this.pressure,
    required this.description,
    required this.icon,
  });

  factory Weather.fromJson(Map<String, dynamic> json) {
    return Weather(
      cityName: json['name'],
      temp: (json['main']['temp'] as num).toDouble(),
      windSpeed: (json['wind']['speed'] as num).toDouble(),
      humidity: (json['main']['humidity'] as num).toDouble(),
      pressure: (json['main']['pressure'] as num).toDouble(),
      description: json['weather'][0]['main'],
      icon: json['weather'][0]['icon'],
    );
  }
}
