import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'sensor_card.dart';
import 'sensor_details_page.dart';
import 'emergency_hotlines_modal.dart';
import 'evacuation_data.dart';
import 'location_permission_widget.dart';
import 'evacuation_route_map.dart';
import '../services/location_service.dart';

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
  
  // Location and notification state
  bool _hasLocationPermission = false;
  double? _userLat;
  double? _userLng;
  bool _showLocationPermission = true;

  @override
  void initState() {
    super.initState();
    fetchWeather();
    _checkLocationPermission();
  }

  Future<void> _checkLocationPermission() async {
    try {
      final hasPermission = await LocationService.requestLocationPermission(context);
      if (hasPermission) {
        final location = await LocationService.getUserLocation();
        setState(() {
          _hasLocationPermission = true;
          _userLat = location['latitude'];
          _userLng = location['longitude'];
          _showLocationPermission = false;
        });
      }
    } catch (e) {
      // Handle error silently
    }
  }

  void _onLocationGranted() async {
    try {
      final location = await LocationService.getUserLocation();
      setState(() {
        _hasLocationPermission = true;
        _userLat = location['latitude'];
        _userLng = location['longitude'];
        _showLocationPermission = false;
      });
    } catch (e) {
      // Handle error silently
    }
  }

  int _getHighRiskSensorCount() {
    return sensors.where((sensor) => 
      sensor['waterLevel'] > 50 || 
      sensor['status'].toString().toLowerCase() == 'critical' ||
      sensor['status'].toString().toLowerCase() == 'high' ||
      sensor['status'].toString().toLowerCase() == 'warning'
    ).length;
  }

  void _showRecentFloodAlerts() {
    final highRiskSensors = sensors.where((sensor) => 
      sensor['waterLevel'] > 50 || 
      sensor['status'].toString().toLowerCase() == 'critical' ||
      sensor['status'].toString().toLowerCase() == 'high' ||
      sensor['status'].toString().toLowerCase() == 'warning'
    ).toList();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.warning, color: Colors.red[600]),
            const SizedBox(width: 8),
            Text(
              'Recent Flood Alerts',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (highRiskSensors.isEmpty)
                Text(
                  'No active flood alerts at the moment.',
                  style: GoogleFonts.nunito(fontSize: 16),
                )
              else
                ...highRiskSensors.map((sensor) => Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: Icon(
                      Icons.warning,
                      color: Colors.red[600],
                    ),
                    title: Text(
                      sensor['name'],
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Water Level: ${sensor['waterLevel']}%'),
                        Text('Status: ${sensor['status']}'),
                        if (sensor['nearestEvacCenter'] != null)
                          Text('Nearest Evacuation: ${sensor['nearestEvacCenter']['name']}'),
                      ],
                    ),
                  ),
                )),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
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
                // Header with notification bell
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
                      'BantayBaha',
            style: GoogleFonts.poppins(
                        fontSize: 24,
              fontWeight: FontWeight.bold,
                        color: Colors.blue[900],
                      ),
                    ),
                    Stack(
            children: [
                        IconButton(
                          onPressed: _showRecentFloodAlerts,
                          icon: Icon(
                            Icons.notifications,
                            size: 28,
                            color: Colors.blue[700],
                          ),
                        ),
                        if (_getHighRiskSensorCount() > 0)
                          Positioned(
                            right: 8,
                            top: 8,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              constraints: const BoxConstraints(
                                minWidth: 16,
                                minHeight: 16,
                              ),
                        child: Text(
                                '${_getHighRiskSensorCount()}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                            fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                      ],
              ),
            ],
          ),
                const SizedBox(height: 20),
                
                // Location Permission Widget
                if (_showLocationPermission)
                  LocationPermissionWidget(
                    onLocationGranted: _onLocationGranted,
                  ),
                
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
                
                // Nearest Sensor Section (when location is enabled)
                if (_hasLocationPermission && _userLat != null && _userLng != null)
                  _buildNearestSensorSection(),
                
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
            if (_hasLocationPermission && _userLat != null && _userLng != null) {
              _showEvacuationCenters();
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Please enable location services to view evacuation centers'),
                  backgroundColor: Colors.orange,
                ),
              );
            }
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

  void _showEvacuationCenters() {
    final centers = evacuationCenters;
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        builder: (context, scrollController) => Container(
          padding: const EdgeInsets.all(20),
                    child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                  Icon(Icons.location_on, color: Colors.blue[700], size: 28),
                  const SizedBox(width: 12),
                  Text(
                    'Evacuation Centers',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const Divider(),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: centers.length,
                  itemBuilder: (context, index) {
                    final center = centers[index];
                    final distance = LocationService.calculateDistance(
                      _userLat!,
                      _userLng!,
                      center['latitude'],
                      center['longitude'],
                    );
                    
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: Container(
                          width: 50,
                          height: 50,
                              decoration: BoxDecoration(
                            color: Colors.blue[100],
                            borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.location_on,
                            color: Colors.blue[700],
                          ),
                        ),
                        title: Text(
                          center['name'],
                          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                            Text(center['address']),
                                  Text(
                              'Distance: ${distance.toStringAsFixed(1)} km',
                              style: TextStyle(
                                color: Colors.blue[700],
                                fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                        trailing: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            _showEvacuationRoute(center);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue[600],
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Get Directions'),
                        ),
                      ),
                    );
                  },
                              ),
                            ),
                          ],
                        ),
        ),
      ),
    );
  }

  void _showEvacuationRoute(Map<String, dynamic> center) {
    if (_userLat == null || _userLng == null) return;
    
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => EvacuationRouteMapPage(
          start: LatLng(_userLat!, _userLng!),
          destination: LatLng(center['latitude'], center['longitude']),
          destinationName: center['name'],
        ),
      ),
    );
  }

  Widget _buildNearestSensorSection() {
    // Find the nearest sensor to user's location
    Map<String, dynamic>? nearestSensor;
    double? nearestDistance;
    
    for (final sensor in sensors) {
      final distance = LocationService.calculateDistance(
        _userLat!,
        _userLng!,
        sensor['lat'],
        sensor['lng'],
      );
      
      if (nearestDistance == null || distance < nearestDistance) {
        nearestDistance = distance;
        nearestSensor = sensor;
      }
    }
    
    if (nearestSensor == null) return const SizedBox.shrink();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.my_location, color: Colors.blue[700], size: 20),
            const SizedBox(width: 8),
            Text(
              'Nearest Sensor',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.blue[900],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
                          Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
            borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                                  blurRadius: 8,
                offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                    width: 50,
                    height: 50,
                                      decoration: BoxDecoration(
                      color: _getSensorStatusColor(nearestSensor!['status']).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Icon(
                      Icons.water_drop,
                      color: _getSensorStatusColor(nearestSensor!['status']),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                        Text(
                          nearestSensor!['name'],
                                                  style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[800],
                          ),
                                          ),
                                          Text(
                          '${nearestDistance!.toStringAsFixed(1)} km away',
                                            style: GoogleFonts.nunito(
                            fontSize: 14,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                       color: _getSensorStatusColor(nearestSensor!['status']).withValues(alpha: 0.15),
                       borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                         color: _getSensorStatusColor(nearestSensor!['status']).withValues(alpha: 0.3),
                         width: 1,
                       ),
                     ),
                     child: Row(
                       mainAxisSize: MainAxisSize.min,
                       children: [
                         Icon(
                           _getStatusIcon(nearestSensor!['status']),
                           size: 12,
                           color: _getSensorStatusColor(nearestSensor!['status']),
                         ),
                         const SizedBox(width: 4),
                         Text(
                           nearestSensor!['status'].toUpperCase(),
                           style: GoogleFonts.nunito(
                                          fontSize: 10,
                             fontWeight: FontWeight.w700,
                             color: _getSensorStatusColor(nearestSensor!['status']),
                           ),
                         ),
                       ],
                                      ),
                                    ),
                                  ],
                                ),
                                            const SizedBox(height: 16),
                // Three readings with icons
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: Row(
                                  children: [
                                    Expanded(
                        child: _buildSensorInfo(
                                        'Water Level',
                          '${nearestSensor!['waterLevel']}%',
                                        Icons.water_drop,
                          Colors.blue[700]!,
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 50,
                        color: Colors.grey[300],
                      ),
                                    Expanded(
                        child: _buildSensorInfo(
                          'Rain Precipitation',
                          '${_getRainPrecipitation(nearestSensor!)} mm',
                          Icons.umbrella,
                          Colors.indigo[600]!,
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 50,
                        color: Colors.grey[300],
                      ),
                                    Expanded(
                        child: _buildSensorInfo(
                          'Water Pressure',
                          '${_getWaterPressure(nearestSensor!)} kPa',
                          Icons.speed,
                          Colors.teal[600]!,
                                      ),
                                    ),
                                  ],
                                ),
                ),
                                const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                                      child: ElevatedButton.icon(
                                        onPressed: () {
                                          Navigator.of(context).push(
                                            MaterialPageRoute(
                        builder: (context) => SensorDetailsPage(sensor: nearestSensor!),
                                            ),
                                          );
                                        },
                  icon: const Icon(Icons.info_outline),
                  label: const Text('View Details'),
                                        style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[600],
                                          foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                        ),
                                      ),
                                    ),
            ],
                                      ),
                                    ),
                                  ],
    );
  }

  Widget _buildSensorInfo(String label, String value, IconData icon, Color color) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 18,
            color: color,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: GoogleFonts.nunito(
            fontSize: 11,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 2),
                Text(
          value,
                  style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: color,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Color _getSensorStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'low':
      case 'normal':
        return Colors.green;
      case 'medium':
      case 'warning':
        return Colors.orange;
      case 'high':
      case 'critical':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'low':
      case 'normal':
        return Icons.check_circle;
      case 'medium':
      case 'warning':
        return Icons.warning;
      case 'high':
      case 'critical':
        return Icons.dangerous;
      default:
        return Icons.info;
    }
  }

  double _getRainPrecipitation(Map<String, dynamic> sensor) {
    // Calculate rain precipitation based on water level and weather conditions
    final waterLevel = sensor['waterLevel'] ?? 0.0;
    final baseRainfall = (waterLevel / 100) * 50; // Base calculation
    final randomFactor = (DateTime.now().millisecondsSinceEpoch % 100) / 100.0; // Add some variation
    return (baseRainfall + randomFactor * 10).roundToDouble();
  }

  double _getWaterPressure(Map<String, dynamic> sensor) {
    // Calculate water pressure based on water level
    final waterLevel = sensor['waterLevel'] ?? 0.0;
    final basePressure = (waterLevel / 100) * 200; // Base pressure calculation
    final randomFactor = (DateTime.now().millisecondsSinceEpoch % 50) / 100.0; // Add some variation
    return (basePressure + randomFactor * 20).roundToDouble();
  }
} 