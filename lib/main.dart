import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:lottie/lottie.dart';
import 'weather model/weather_model.dart';
import 'weather service/weather_service.dart';

void main() {
  runApp(const WeatherApp());
}

class WeatherApp extends StatefulWidget {
  const WeatherApp({Key? key}) : super(key: key);

  @override
  State<WeatherApp> createState() => _WeatherAppState();
}

class _WeatherAppState extends State<WeatherApp> {
  bool darkMode = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Weather App',
      theme: darkMode ? ThemeData.dark() : ThemeData.light(),
      home: WeatherHomePage(
        darkMode: darkMode,
        onThemeChanged: (val) {
          setState(() {
            darkMode = val;
          });
        },
      ),
    );
  }
}

class WeatherHomePage extends StatefulWidget {
  final bool darkMode;
  final Function(bool) onThemeChanged;

  const WeatherHomePage({
    Key? key,
    required this.darkMode,
    required this.onThemeChanged,
  }) : super(key: key);

  @override
  State<WeatherHomePage> createState() => _WeatherHomePageState();
}

class _WeatherHomePageState extends State<WeatherHomePage> {
  Future<Weather>? _weatherFuture;
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadByLocation();
  }

  void _loadByLocation() async {
    try {
      Position pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
      );
      setState(() {
        _weatherFuture =
            WeatherService.fetchWeatherByLocation(pos.latitude, pos.longitude);
      });
    } catch (e) {
      debugPrint("Location error: $e");
    }
  }

  void _search(String city) {
    if (city.isEmpty) return;
    setState(() {
      _weatherFuture = WeatherService.fetchWeather(city: city);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_weatherFuture == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return FutureBuilder<Weather>(
      future: _weatherFuture,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        } else if (snap.hasError) {
          return Scaffold(body: Center(child: Text("Error: ${snap.error}")));
        }

        final w = snap.data!;
        return _buildContent(w);
      },
    );
  }

  Widget _buildContent(Weather w) {
    Color bgStart, bgEnd;
    String anim;
    if (w.description.contains("Rain")) {
      bgStart = Colors.blueGrey.shade700;
      bgEnd = Colors.grey.shade900;
      anim = "assets/animations/rainy.json";
    } else if (w.description.contains("Cloud")) {
      bgStart = Colors.grey.shade600;
      bgEnd = Colors.grey.shade900;
      anim = "assets/animations/cloudy.json";
    } else {
      bgStart = Colors.blue.shade700;
      bgEnd = Colors.blue.shade300;
      anim = "assets/animations/sunny.json";
    }

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async => _loadByLocation(),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [bgStart, bgEnd],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverAppBar(
                backgroundColor: Colors.transparent,
                expandedHeight: 150,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(w.cityName),
                ),
                actions: [
                  IconButton(
                    icon: Icon(widget.darkMode
                        ? Icons.wb_sunny
                        : Icons.nightlight_round),
                    onPressed: () =>
                        widget.onThemeChanged(!widget.darkMode),
                  ),
                ],
              ),
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: TextField(
                        controller: _controller,
                        decoration: InputDecoration(
                          hintText: "Search city",
                          fillColor: Colors.white24,
                          filled: true,
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.search),
                            onPressed: () => _search(_controller.text.trim()),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: SizedBox(
                        height: 180,
                        child: Lottie.asset(anim, fit: BoxFit.contain),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 24),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white24),
                      ),
                      child: Column(
                        children: [
                          Text("${w.temp.toStringAsFixed(1)}°C",
                              style: const TextStyle(
                                  fontSize: 48, fontWeight: FontWeight.bold)),
                          Text(w.description,
                              style: const TextStyle(fontSize: 24)),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildInfo(Icons.air, "${w.windSpeed} m/s"),
                              _buildInfo(Icons.opacity, "${w.humidity}%"),
                              _buildInfo(Icons.compress, "${w.pressure} hPa"),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Column _buildInfo(IconData icon, String val) {
    return Column(
      children: [
        Icon(icon, size: 30, color: Colors.white),
        const SizedBox(height: 4),
        Text(val, style: const TextStyle(color: Colors.white)),
      ],
    );
  }
}
