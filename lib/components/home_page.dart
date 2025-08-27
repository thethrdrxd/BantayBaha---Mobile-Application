import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'sensor_card.dart';
import 'sensor_details_page.dart';
import 'emergency_hotlines_modal.dart';
import 'evacuation_data.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<Map<String, dynamic>> sensors = buildSensorsWithNearestEvac();

  Map<String, dynamic>? weather;
  bool isLoadingWeather = true;
  String? weatherError;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    fetchWeather();
  }

  Future<void> fetchWeather() async {
    setState(() {
      isLoadingWeather = true;
      weatherError = null;
    });
    try {
      // Bogo City coordinates
      final lat = 11.0519;
      final lon = 124.0043;
      final apiKey = '7046252d1a0e5abf363e005e7c706aff';
      final url = 'https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lon&appid=$apiKey&units=metric';
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          weather = {
            'temperature': data['main']['temp'].round(),
            'condition': data['weather'][0]['main'],
            'humidity': data['main']['humidity'],
            'rainfall': data['rain'] != null ? (data['rain']['1h'] ?? 0) : 0,
            'icon': _mapWeatherToIcon(data['weather'][0]['main']),
          };
          isLoadingWeather = false;
        });
      } else {
        print('Weather API error: status ${response.statusCode}');
        print('Response body: ${response.body}');
        setState(() {
          weatherError = 'Failed to fetch weather.';
          isLoadingWeather = false;
        });
      }
    } catch (e) {
      print('Weather fetch exception: $e');
      setState(() {
        weatherError = 'Error: $e';
        isLoadingWeather = false;
      });
    }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE3F0FF),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Weather Forecast Section
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEAF4FB),
                    borderRadius: BorderRadius.circular(28),
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFFEAF4FB), Color(0xFFFFFFFF)],
                    ),
                    boxShadow: [
                      // Outer shadow
                      BoxShadow(
                        color: Colors.blueGrey.withOpacity(0.10),
                        blurRadius: 24,
                        offset: const Offset(8, 8),
                      ),
                      // Inner shadow (simulated)
                      BoxShadow(
                        color: Colors.white.withOpacity(0.8),
                        blurRadius: 8,
                        offset: const Offset(-6, -6),
                        spreadRadius: -4,
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.location_on, color: Color(0xFF1976D2), size: 20),
                          SizedBox(width: 6),
                          Text(
                            'Bogo City, Cebu, Philippines',
                            style: GoogleFonts.poppins(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Colors.blue[900],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      isLoadingWeather
                          ? Center(child: CircularProgressIndicator())
                          : weatherError != null
                              ? Text(weatherError!, style: TextStyle(color: Colors.red))
                              : Row(
                                  children: [
                                    Icon(weather!['icon'], size: 48, color: Colors.blue[700]),
                                    const SizedBox(width: 18),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '${weather!['temperature']}°C',
                                          style: GoogleFonts.poppins(
                                            fontSize: 32,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.blue[900],
                                          ),
                                        ),
                                        Text(
                                          weather!['condition'],
                                          style: GoogleFonts.nunito(
                                            fontSize: 18,
                                            color: Colors.blue[700],
                                          ),
                                        ),
                                        Text(
                                          'Humidity: ${weather!['humidity']}%  |  Rainfall: ${weather!['rainfall']}mm',
                                          style: GoogleFonts.nunito(
                                            fontSize: 14,
                                            color: Colors.grey[700],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),
                Text(
                  'Recent Flood Alerts',
                  style: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[900],
                  ),
                ),
                const SizedBox(height: 12),
                // Sensor Cards
                ...sensors.map((sensor) => SensorCard(
                  sensor: sensor,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => SensorDetailsPage(sensor: sensor),
                      ),
                    );
                  },
                )),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
          if (index == 1) {
            // Evacuation Centers
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Evacuation Centers tapped!')),
            );
          } else if (index == 2) {
            // Emergency Hotline
            showModalBottomSheet(
              context: context,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              isScrollControlled: true,
              builder: (context) => const EmergencyHotlinesSheet(),
            );
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.location_on),
            label: 'Evacuation',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.phone_in_talk),
            label: 'Hotline',
          ),
        ],
        selectedItemColor: Color(0xFF1976D2),
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        elevation: 12,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
} 