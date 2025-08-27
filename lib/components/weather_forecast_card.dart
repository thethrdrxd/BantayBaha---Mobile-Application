import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

class WeatherForecastCard extends StatefulWidget {
  final double lat;
  final double lon;
  final String apiKey;
  const WeatherForecastCard({required this.lat, required this.lon, required this.apiKey, super.key});

  @override
  State<WeatherForecastCard> createState() => _WeatherForecastCardState();
}

class _WeatherForecastCardState extends State<WeatherForecastCard> {
  bool expanded = false;
  bool loading = true;
  String? error;
  Map<String, dynamic>? current;
  List<dynamic>? daily;

  @override
  void initState() {
    super.initState();
    fetchForecast();
  }

  Future<void> fetchForecast() async {
    setState(() {
      loading = true;
      error = null;
    });
    try {
      final url = 'https://api.openweathermap.org/data/2.5/onecall?lat=${widget.lat}&lon=${widget.lon}&exclude=minutely,hourly,alerts&units=metric&appid=${widget.apiKey}';
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          current = data['current'];
          daily = data['daily'];
          loading = false;
        });
      } else {
        setState(() {
          error = 'Failed to fetch weather.';
          loading = false;
        });
      }
    } catch (e) {
      setState(() {
        error = 'Error: $e';
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {
          setState(() {
            expanded = !expanded;
            print('WeatherForecastCard tapped. Expanded: $expanded');
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.blue.withOpacity(0.08),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: loading
              ? (() { print('WeatherForecastCard: loading'); return Center(child: CircularProgressIndicator()); })()
              : error != null
                  ? (() { print('WeatherForecastCard: error $error'); return Text(error!, style: TextStyle(color: Colors.red)); })()
                  : (() { print('WeatherForecastCard: showing data, expanded=$expanded'); return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(_mapWeatherToIcon(current!['weather'][0]['main']), size: 48, color: Colors.blue[700]),
                          const SizedBox(width: 18),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${current!['temp'].round()}°C',
                                style: GoogleFonts.poppins(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue[900],
                                ),
                              ),
                              Text(
                                current!['weather'][0]['main'],
                                style: GoogleFonts.nunito(
                                  fontSize: 18,
                                  color: Colors.blue[700],
                                ),
                              ),
                              Text(
                                'Humidity: ${current!['humidity']}%  |  Rainfall: ${current!['rain'] ?? 0}mm',
                                style: GoogleFonts.nunito(
                                  fontSize: 14,
                                  color: Colors.grey[700],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      if (expanded && daily != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 18),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('7-Day Forecast', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue[900])),
                              const SizedBox(height: 8),
                              ...List.generate(7, (i) {
                                final day = daily![i];
                                final date = DateTime.fromMillisecondsSinceEpoch(day['dt'] * 1000);
                                final minTemp = day['temp']['min'].round();
                                final maxTemp = day['temp']['max'].round();
                                final icon = day['weather'][0]['icon'];
                                final main = day['weather'][0]['main'];
                                return Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 4),
                                  child: Row(
                                    children: [
                                      SizedBox(
                                        width: 80,
                                        child: Text(
                                          _weekday(date),
                                          style: GoogleFonts.nunito(fontSize: 15, color: Colors.blue[900]),
                                        ),
                                      ),
                                      Image.network('https://openweathermap.org/img/wn/$icon@2x.png', width: 32, height: 32),
                                      const SizedBox(width: 8),
                                      Text('$minTemp° / $maxTemp°', style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600)),
                                      const SizedBox(width: 8),
                                      Text(main, style: GoogleFonts.nunito(fontSize: 14, color: Colors.blueGrey[700])),
                                    ],
                                  ),
                                );
                              }),
                            ],
                          ),
                        ),
                    ],
                   ); })(),
        ),
      ),
    );
  }

  IconData _mapWeatherToIcon(String condition) {
    switch (condition.toLowerCase()) {
      case 'clear':
        return Icons.wb_sunny;
      case 'clouds':
        return Icons.cloud;
      case 'rain':
        return Icons.umbrella;
      case 'thunderstorm':
        return Icons.flash_on;
      case 'drizzle':
        return Icons.grain;
      case 'snow':
        return Icons.ac_unit;
      default:
        return Icons.cloud;
    }
  }

  String _weekday(DateTime date) {
    const days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    return days[date.weekday % 7];
  }
} 