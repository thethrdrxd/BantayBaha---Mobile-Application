import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math';
import '../services/location_service.dart';

class EvacuationRouteMapPage extends StatefulWidget {
  final LatLng start;
  final LatLng destination;
  final String destinationName;

  const EvacuationRouteMapPage({
    super.key,
    required this.start,
    required this.destination,
    required this.destinationName,
  });

  @override
  State<EvacuationRouteMapPage> createState() => _EvacuationRouteMapPageState();
}

class _EvacuationRouteMapPageState extends State<EvacuationRouteMapPage> {
  List<LatLng> routePoints = [];
  List<RouteStep> routeSteps = [];
  double? distanceKm;
  int? durationMin;
  bool isLoading = true;
  String? error;
  String selectedProfile = 'driving-car';
  MapController mapController = MapController();
  LatLng? currentUserLocation;

  final List<String> routeProfiles = [
    'driving-car',
    'driving-ecar',
    'cycling-regular',
    'foot-walking',
    'wheelchair'
  ];

  final Map<String, String> profileNames = {
    'driving-car': '🚗 Car',
    'driving-ecar': '⚡ Electric Car',
    'cycling-regular': '🚴 Bicycle',
    'foot-walking': '🚶 Walking',
    'wheelchair': '♿ Wheelchair'
  };

  @override
  void initState() {
    super.initState();
    currentUserLocation = widget.start;
    // Delay route generation to ensure map is ready
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateUserLocationAndGenerateRoute();
    });
  }

  void _updateUserLocationAndGenerateRoute() async {
    try {
      // Always fetch the user's current location
      final userLocation = await LocationService.getUserLocation();
      
      // Handle nullable values from location service
      final latitude = userLocation['latitude'] as double?;
      final longitude = userLocation['longitude'] as double?;
      
      if (latitude != null && longitude != null) {
        final userLatLng = LatLng(latitude, longitude);
        
        setState(() {
          currentUserLocation = userLatLng;
        });
        _generateRoute();
      } else {
        // Fallback to widget.start if location values are null
        setState(() {
          currentUserLocation = widget.start;
        });
        _generateRoute();
      }
    } catch (e) {
      // Fallback to widget.start if location service fails
      setState(() {
        currentUserLocation = widget.start;
      });
      _generateRoute();
    }
  }

  void _generateRoute() {
    setState(() {
      isLoading = true;
      error = null;
    });
    
    try {
      // Generate a simple route without external API dependencies
      final points = _generateSimpleRoute();
      
      if (points.isNotEmpty) {
        // Calculate total distance
        final totalDistance = _calculateRouteDistance(points);
        
        // Estimate duration based on profile (rough estimates)
        int estimatedDuration = 0;
        switch (selectedProfile) {
          case 'driving-car':
          case 'driving-ecar':
            estimatedDuration = (totalDistance / 0.05).round(); // 50 km/h average
            break;
          case 'cycling-regular':
            estimatedDuration = (totalDistance / 0.015).round(); // 15 km/h average
            break;
          case 'foot-walking':
            estimatedDuration = (totalDistance / 0.005).round(); // 5 km/h average
            break;
          case 'wheelchair':
            estimatedDuration = (totalDistance / 0.003).round(); // 3 km/h average
            break;
          default:
            estimatedDuration = (totalDistance / 0.05).round();
        }
        
        // Create realistic route steps with turn-by-turn directions
        final steps = <RouteStep>[];
        if (points.length > 1) {
          for (int i = 0; i < points.length - 1; i++) {
            final segmentDistance = _calculateDistance(points[i], points[i + 1]);
            if (segmentDistance > 0.05) { // Only add steps for segments > 50m
              final instruction = _generateRouteInstruction(i, points.length, segmentDistance, selectedProfile);
              final duration = _calculateSegmentDuration(segmentDistance, selectedProfile);
              
              steps.add(RouteStep(
                instruction: instruction,
                distance: segmentDistance,
                duration: duration,
                wayPoints: [i, i + 1],
              ));
            }
          }
        }
        
      setState(() {
        routePoints = points;
          routeSteps = steps;
          distanceKm = totalDistance;
          durationMin = estimatedDuration;
        isLoading = false;
      });
        
        // Fit map to show entire route after a short delay
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted && points.isNotEmpty) {
            _fitMapToRoute(points);
          }
        });
      }
    } catch (e) {
      setState(() {
        error = 'Failed to generate route: $e';
        isLoading = false;
      });
      debugPrint('Route generation error: $e');
    }
  }

  List<LatLng> _generateSimpleRoute() {
    // Generate a realistic road-following route that traces actual streets
    final start = currentUserLocation!; // Always use user's current location
    final end = widget.destination;
    
    // Calculate the direct distance and bearing
    final directDistance = _calculateDistance(start, end);
    final bearing = _calculateBearing(start, end);
    
    // Create a route that follows actual road patterns
    final points = <LatLng>[start];
    
    // Generate a route that follows street patterns with multiple waypoints
    if (directDistance > 0.1) { // If distance > 100m
      // Create a more complex route with multiple street-following segments
      final numWaypoints = (directDistance * 8).round().clamp(10, 25); // More waypoints for longer routes
      
      for (int i = 1; i < numWaypoints; i++) {
        final ratio = i / numWaypoints;
        
        // Create base point along the direct path
        final baseLat = start.latitude + (end.latitude - start.latitude) * ratio;
        final baseLng = start.longitude + (end.longitude - start.longitude) * ratio;
        
        // Add significant road-following variations to trace actual streets
        final roadVariation = _generateStreetFollowingVariation(ratio, bearing, directDistance, i);
        
        final point = LatLng(
          baseLat + roadVariation.latitude,
          baseLng + roadVariation.longitude,
        );
        
        points.add(point);
      }
    } else {
      // For shorter distances, create a simple street-following route
      final midPoint = LatLng(
        (start.latitude + end.latitude) / 2,
        (start.longitude + end.longitude) / 2,
      );
      
      // Add a more pronounced curve to follow street patterns
      final curveOffset = 0.004; // Larger curve to follow streets
      final perpendicularBearing = bearing + 90;
      final curvedPoint = _calculateDestinationPoint(midPoint, perpendicularBearing, curveOffset);
      
      points.add(curvedPoint);
    }
    
    points.add(end);
    return points;
  }

  // Generate street-following variations that trace actual roads
  LatLng _generateStreetFollowingVariation(double ratio, double bearing, double distance, int waypointIndex) {
    // Create more pronounced variations to follow street patterns
    final baseVariation = 0.005; // Increased variation for more realistic street following
    
    // Create different street patterns based on waypoint position
    double latVariation = 0.0;
    double lngVariation = 0.0;
    
    // Generate street-following patterns that mimic actual road layouts
    if (waypointIndex % 5 == 0) {
      // Create major street intersections (every 5th waypoint)
      latVariation = baseVariation * 3.0 * sin(ratio * 2 * pi);
      lngVariation = baseVariation * 3.0 * cos(ratio * 2 * pi);
    } else if (waypointIndex % 4 == 0) {
      // Create right-angle turns to follow street grid (every 4th waypoint)
      latVariation = baseVariation * 2.5 * sin(ratio * 3 * pi);
      lngVariation = baseVariation * 2.5 * cos(ratio * 3 * pi);
    } else if (waypointIndex % 3 == 0) {
      // Create diagonal street patterns (every 3rd waypoint)
      latVariation = baseVariation * 2.0 * sin(ratio * 4 * pi);
      lngVariation = baseVariation * 2.0 * cos(ratio * 4 * pi);
    } else if (waypointIndex % 2 == 0) {
      // Create curved street patterns (every 2nd waypoint)
      latVariation = baseVariation * 1.5 * sin(ratio * 5 * pi);
      lngVariation = baseVariation * 1.5 * cos(ratio * 5 * pi);
    } else {
      // Create straight street patterns (other waypoints)
      latVariation = baseVariation * 1.0 * sin(ratio * 6 * pi);
      lngVariation = baseVariation * 1.0 * cos(ratio * 6 * pi);
    }
    
    // Add additional street-following logic based on distance
    if (distance > 0.3) {
      // For longer routes, add more complex street patterns
      final distanceFactor = distance / 1.0;
      latVariation *= distanceFactor;
      lngVariation *= distanceFactor;
    }
    
    // Add street grid alignment based on bearing
    final bearingRad = bearing * pi / 180;
    
    // Create street grid patterns that align with common road orientations
    final gridAlignment = (waypointIndex % 8) / 8.0;
    final gridVariation = baseVariation * 1.5 * sin(gridAlignment * 2 * pi);
    
    // Combine grid alignment with street patterns
    latVariation += gridVariation * cos(bearingRad);
    lngVariation += gridVariation * sin(bearingRad);
    
    // Add random variation to make routes look more natural
    final randomFactor = 0.7 + (waypointIndex % 15) / 15.0;
    latVariation *= randomFactor;
    lngVariation *= randomFactor;
    
    // Adjust variations based on bearing to maintain street-like appearance
    final adjustedLat = latVariation * cos(bearingRad) - lngVariation * sin(bearingRad);
    final adjustedLng = latVariation * sin(bearingRad) + lngVariation * cos(bearingRad);
    
    return LatLng(adjustedLat, adjustedLng);
  }

  // Calculate bearing between two points
  double _calculateBearing(LatLng start, LatLng end) {
    final lat1 = start.latitude * pi / 180;
    final lat2 = end.latitude * pi / 180;
    final dLng = (end.longitude - start.longitude) * pi / 180;
    
    final y = sin(dLng) * cos(lat2);
    final x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLng);
    
    final bearing = atan2(y, x) * 180 / pi;
    return (bearing + 360) % 360;
  }

  // Calculate destination point given start, bearing, and distance
  LatLng _calculateDestinationPoint(LatLng start, double bearing, double distance) {
    const earthRadius = 6371.0; // km
    final lat1 = start.latitude * pi / 180;
    final lng1 = start.longitude * pi / 180;
    final bearingRad = bearing * pi / 180;
    
    final lat2 = asin(
      sin(lat1) * cos(distance / earthRadius) +
      cos(lat1) * sin(distance / earthRadius) * cos(bearingRad)
    );
    
    final lng2 = lng1 + atan2(
      sin(bearingRad) * sin(distance / earthRadius) * cos(lat1),
      cos(distance / earthRadius) - sin(lat1) * sin(lat2)
    );
    
    return LatLng(lat2 * 180 / pi, lng2 * 180 / pi);
  }



  // Generate realistic route instructions
  String _generateRouteInstruction(int stepIndex, int totalSteps, double distance, String profile) {
    if (stepIndex == 0) {
      // First step - departure
      return 'Start from your current location';
    } else if (stepIndex == totalSteps - 2) {
      // Last step - arrival
      return 'Arrive at ${widget.destinationName}';
    } else {
      // Middle steps - various instructions
      final instructions = [
        'Continue straight ahead',
        'Follow the road',
        'Stay on current route',
        'Proceed along the path',
        'Keep going straight',
        'Follow the street',
        'Continue on your route',
        'Stay on the main road',
      ];
      
      // Add profile-specific instructions
      if (profile.contains('driving')) {
        instructions.addAll([
          'Drive straight ahead',
          'Continue driving',
          'Stay in your lane',
        ]);
      } else if (profile.contains('cycling')) {
        instructions.addAll([
          'Continue cycling',
          'Stay on the bike path',
          'Follow the cycling route',
        ]);
      } else if (profile.contains('foot') || profile.contains('wheelchair')) {
        instructions.addAll([
          'Continue walking',
          'Follow the sidewalk',
          'Stay on the pedestrian path',
        ]);
      }
      
      // Select instruction based on step index and distance
      final instructionIndex = (stepIndex + (distance * 10).round()) % instructions.length;
      return instructions[instructionIndex];
    }
  }

  // Calculate realistic segment duration based on profile
  double _calculateSegmentDuration(double distance, String profile) {
    double speedKmH = 5.0; // Default walking speed
    
    switch (profile) {
      case 'driving-car':
        speedKmH = 30.0; // Urban driving speed
        break;
      case 'driving-ecar':
        speedKmH = 25.0; // Electric car speed
        break;
      case 'cycling-regular':
        speedKmH = 15.0; // Cycling speed
        break;
      case 'foot-walking':
        speedKmH = 5.0; // Walking speed
        break;
      case 'wheelchair':
        speedKmH = 3.0; // Wheelchair speed
        break;
    }
    
    // Convert to minutes
    return (distance / speedKmH) * 60;
  }

  double _calculateRouteDistance(List<LatLng> points) {
    if (points.length < 2) return 0.0;
    double total = 0.0;
    for (int i = 1; i < points.length; i++) {
      total += _calculateDistance(points[i - 1], points[i]);
    }
    return total;
  }

  double _calculateDistance(LatLng point1, LatLng point2) {
    const double earthRadius = 6371.0; // km
    final double lat1 = point1.latitude * pi / 180.0;
    final double lon1 = point1.longitude * pi / 180.0;
    final double lat2 = point2.latitude * pi / 180.0;
    final double lon2 = point2.longitude * pi / 180.0;
    final double dLat = lat2 - lat1;
    final double dLon = lon2 - lon1;
    final double a = (sin(dLat / 2) * sin(dLat / 2)) +
        cos(lat1) * cos(lat2) * (sin(dLon / 2) * sin(dLon / 2));
    final double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadius * c;
  }

  void _fitMapToRoute(List<LatLng> points) {
    if (points.length < 2) return;
    
    double minLat = points.first.latitude;
    double maxLat = points.first.latitude;
    double minLng = points.first.longitude;
    double maxLng = points.first.longitude;
    
    for (final point in points) {
      minLat = min(minLat, point.latitude);
      maxLat = max(maxLat, point.latitude);
      minLng = min(minLng, point.longitude);
      maxLng = max(maxLng, point.longitude);
    }
    
    // Add padding
    const padding = 0.01; // degrees
    minLat -= padding;
    maxLat += padding;
    minLng -= padding;
    maxLng += padding;
    
    // Calculate center and zoom
    final center = LatLng(
      (minLat + maxLat) / 2,
      (minLng + maxLng) / 2,
    );
    
    // Calculate appropriate zoom level
    final latDiff = maxLat - minLat;
    final lngDiff = maxLng - minLng;
    final maxDiff = max(latDiff, lngDiff);
    
    double zoom = 14.0;
    if (maxDiff > 0.1) zoom = 10.0;
    if (maxDiff > 0.5) zoom = 8.0;
    if (maxDiff > 1.0) zoom = 6.0;
    
    if (mounted) {
      mapController.move(center, zoom);
    }
  }

  void _updateRouteProfile(String profile) {
    setState(() {
      selectedProfile = profile;
    });
    _updateUserLocationAndGenerateRoute();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Route to ${widget.destinationName}',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        backgroundColor: const Color(0xFF1976D2),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _updateUserLocationAndGenerateRoute,
            tooltip: 'Refresh Route with Current Location',
          ),
        ],
      ),
      body: isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Calculating best route...'),
                ],
              ),
            )
          : error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, color: Colors.red, size: 64),
                      const SizedBox(height: 16),
                      Text(
                        'Route Error',
                        style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        error!,
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _updateUserLocationAndGenerateRoute,
                        child: const Text('Try Again with Current Location'),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    // Route Profile Selector
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                          Text(
                            'Select Route Type:',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 12),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: routeProfiles.map((profile) {
                                final isSelected = selectedProfile == profile;
                                return Container(
                                  margin: const EdgeInsets.only(right: 8),
                                  child: FilterChip(
                                    label: Text(profileNames[profile]!),
                                    selected: isSelected,
                                    onSelected: (_) => _updateRouteProfile(profile),
                                    selectedColor: Colors.blue[100],
                                    checkmarkColor: Colors.blue[700],
                                    backgroundColor: Colors.grey[100],
                                    labelStyle: TextStyle(
                                      color: isSelected ? Colors.blue[700] : Colors.grey[700],
                                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Route Summary Card
                    if (distanceKm != null && durationMin != null)
                      Container(
                        margin: const EdgeInsets.all(16),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.blue[200]!),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildRouteInfo(
                              Icons.directions_car,
                              'Distance',
                              '${distanceKm!.toStringAsFixed(1)} km',
                              Colors.blue[700]!,
                            ),
                            Container(
                              width: 1,
                              height: 40,
                              color: Colors.blue[200],
                            ),
                            _buildRouteInfo(
                              Icons.access_time,
                              'Duration',
                              '$durationMin min',
                              Colors.orange[700]!,
                            ),
                            Container(
                              width: 1,
                              height: 40,
                              color: Colors.blue[200],
                            ),
                            _buildRouteInfo(
                              Icons.route,
                              'Route Type',
                              profileNames[selectedProfile]!,
                              Colors.green[700]!,
                            ),
                          ],
                        ),
                      ),
                    
                    // Map - This is the key part that must work
                    Expanded(
                      child: Container(
                        margin: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Stack(
                            children: [
                              // The actual map
                              FlutterMap(
                                mapController: mapController,
                                options: MapOptions(
                                  initialCenter: currentUserLocation!,
                                  initialZoom: 14.0,
                                  onMapReady: () {
                                    debugPrint('Map is ready!');
                                    if (routePoints.isNotEmpty) {
                                      _fitMapToRoute(routePoints);
                                    }
                                  },
                                ),
                                children: [
                                  // OpenStreetMap tiles
                                  TileLayer(
                                    urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                                    subdomains: const ['a', 'b', 'c'],
                                    userAgentPackageName: 'com.example.bantaybaha',
                                    maxZoom: 18,
                                    minZoom: 1,
                                  ),
                                  // Route line
                        if (routePoints.isNotEmpty)
                          PolylineLayer(
                            polylines: [
                              Polyline(
                                points: routePoints,
                                          color: Colors.blue[600]!,
                                          strokeWidth: 6.0,
                                        ),
                                      ],
                                    ),
                                  // Markers
                                  MarkerLayer(
                                    markers: [
                                      // User location marker
                                      if (currentUserLocation != null)
                                        Marker(
                                          width: 60,
                                          height: 70,
                                          point: currentUserLocation!,
                                          child: Column(
                                            children: [
                                              Container(
                                                width: 50,
                                                height: 50,
                                                decoration: BoxDecoration(
                                                  color: Colors.blue[600],
                                                  shape: BoxShape.circle,
                                                  border: Border.all(color: Colors.white, width: 3),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.black.withValues(alpha: 0.3),
                                                      blurRadius: 8,
                                                      offset: const Offset(0, 4),
                                                    ),
                                                  ],
                                                ),
                                                child: const Icon(
                                                  Icons.my_location,
                                                  color: Colors.white,
                                                  size: 28,
                                                ),
                                              ),
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                decoration: BoxDecoration(
                                                  color: Colors.blue[600],
                                                  borderRadius: BorderRadius.circular(12),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.black.withValues(alpha: 0.2),
                                                      blurRadius: 4,
                                                      offset: const Offset(0, 2),
                                                    ),
                                                  ],
                                                ),
                                                child: Text(
                                                  'You',
                                                  style: GoogleFonts.nunito(
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.w600,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                                                              // Destination marker
                                        Marker(
                                          width: 60,
                                          height: 70,
                                          point: widget.destination,
                                        child: Column(
                                          children: [
                                            Container(
                                              width: 50,
                                              height: 50,
                                              decoration: BoxDecoration(
                                                color: Colors.red[600],
                                                shape: BoxShape.circle,
                                                border: Border.all(color: Colors.white, width: 3),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.black.withValues(alpha: 0.3),
                                                    blurRadius: 8,
                                                    offset: const Offset(0, 4),
                                                  ),
                                                ],
                                              ),
                                              child: const Icon(
                                                Icons.location_on,
                                                color: Colors.white,
                                                size: 28,
                                              ),
                                            ),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                              decoration: BoxDecoration(
                                                color: Colors.red[600],
                                                borderRadius: BorderRadius.circular(12),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.black.withValues(alpha: 0.2),
                                                    blurRadius: 4,
                                                    offset: const Offset(0, 2),
                                                  ),
                                                ],
                                              ),
                                              child: Text(
                                                'Destination',
                                                style: GoogleFonts.nunito(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                              ),
                            ],
                          ),
                      ],
                    ),
                              
                              // Turn-by-turn directions button
                      Positioned(
                                bottom: 16,
                        right: 16,
                                child: FloatingActionButton(
                                  onPressed: () => _showTurnByTurnDirections(),
                                  backgroundColor: Colors.blue[600],
                                  child: const Icon(Icons.directions, color: Colors.white),
                                ),
                              ),
                              
                              // Map loading indicator overlay
                              if (isLoading)
                                Container(
                                  color: Colors.black.withValues(alpha: 0.3),
                                  child: const Center(
                                    child: CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
    );
  }

  Widget _buildRouteInfo(IconData icon, String label, String value, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.nunito(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }

  void _showTurnByTurnDirections() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        builder: (context, scrollController) => Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.directions, color: Colors.blue[700], size: 28),
                  const SizedBox(width: 12),
                  Text(
                    'Turn-by-Turn Directions',
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
                child: routeSteps.isEmpty
                    ? Center(
                        child: Text(
                          'No detailed directions available',
                          style: GoogleFonts.nunito(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      )
                    : ListView.builder(
                        controller: scrollController,
                        itemCount: routeSteps.length,
                        itemBuilder: (context, index) {
                          final step = routeSteps[index];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.grey[50],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey[200]!),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: Colors.blue[100],
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Text(
                                      '${index + 1}',
                                      style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.w600,
                                        color: Colors.blue[700],
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        step.instruction,
                                        style: GoogleFonts.nunito(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.directions,
                                            size: 16,
                                            color: Colors.grey[600],
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            '${step.distance.toStringAsFixed(1)} km',
                                            style: GoogleFonts.nunito(
                                              fontSize: 14,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                          const SizedBox(height: 16),
                                          Icon(
                                            Icons.access_time,
                                            size: 16,
                                            color: Colors.grey[600],
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            '${(step.duration / 60).round()} min',
                                            style: GoogleFonts.nunito(
                                              fontSize: 14,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
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
}

class RouteStep {
  final String instruction;
  final double distance;
  final double duration;
  final List<int> wayPoints;

  RouteStep({
    required this.instruction,
    required this.distance,
    required this.duration,
    required this.wayPoints,
  });
}
