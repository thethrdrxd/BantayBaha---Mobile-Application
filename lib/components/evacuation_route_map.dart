import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:open_route_service/open_route_service.dart';
import 'dart:math';

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
  double? distanceKm;
  double? durationMin;
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    fetchRoute();
  }

  Future<void> fetchRoute() async {
    setState(() {
      isLoading = true;
      error = null;
    });
    try {
      // Use your actual OpenRouteService API key directly here
      const apiKey = 'eyJvcmciOiI1YjNjZTM1OTc4NTExMTAwMDFjZjYyNDgiLCJpZCI6IjAwMzJkMDg1OTY5MDRjYmI5ODhhZWM3MGQzYWIwZTRkIiwiaCI6Im11cm11cjY0In0=';
      final OpenRouteService client = OpenRouteService(apiKey: apiKey);
      final List<ORSCoordinate> routeCoordinates = await client.directionsRouteCoordsGet(
        startCoordinate: ORSCoordinate(latitude: widget.start.latitude, longitude: widget.start.longitude),
        endCoordinate: ORSCoordinate(latitude: widget.destination.latitude, longitude: widget.destination.longitude),
      );
      final points = routeCoordinates.map((c) => LatLng(c.latitude, c.longitude)).toList();
      setState(() {
        routePoints = points;
        distanceKm = calculateDistance(points);
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = 'Failed to fetch route: $e';
        isLoading = false;
      });
    }
  } 

  double? calculateDistance(List<LatLng> points) {
    if (points.length < 2) return null;
    double total = 0.0;
    const earthRadius = 6371.0; // km
    for (int i = 1; i < points.length; i++) {
      final lat1 = points[i - 1].latitude * 3.141592653589793 / 180.0;
      final lon1 = points[i - 1].longitude * 3.141592653589793 / 180.0;
      final lat2 = points[i].latitude * 3.141592653589793 / 180.0;
      final lon2 = points[i].longitude * 3.141592653589793 / 180.0;
      final dLat = lat2 - lat1;
      final dLon = lon2 - lon1;
      final a = (sin(dLat / 2) * sin(dLat / 2)) +
          cos(lat1) * cos(lat2) * (sin(dLon / 2) * sin(dLon / 2));
      final c = 2 * atan2(sqrt(a), sqrt(1 - a));
      total += earthRadius * c;
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Evacuation Route to ${widget.destinationName}'),
        backgroundColor: const Color(0xFF1976D2),
        foregroundColor: Colors.white,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : error != null
              ? Center(child: Text(error!, style: const TextStyle(color: Colors.red)))
              : Stack(
                  children: [
                    FlutterMap(
                      options: MapOptions(
                        initialCenter: LatLng(
                          (widget.start.latitude + widget.destination.latitude) / 2,
                          (widget.start.longitude + widget.destination.longitude) / 2,
                        ),
                        initialZoom: 14.0,
                      ),
                      children: [
                        TileLayer(
                          urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                          subdomains: const ['a', 'b', 'c'],
                          userAgentPackageName: 'com.example.bantaybaha',
                        ),
                        MarkerLayer(
                          markers: [
                            Marker(
                              width: 40,
                              height: 40,
                              point: widget.start,
                              child: const Icon(Icons.person_pin_circle, color: Colors.blue, size: 36),
                            ),
                            Marker(
                              width: 40,
                              height: 40,
                              point: widget.destination,
                              child: const Icon(Icons.location_on, color: Colors.red, size: 36),
                            ),
                          ],
                        ),
                        if (routePoints.isNotEmpty)
                          PolylineLayer(
                            polylines: [
                              Polyline(
                                points: routePoints,
                                color: Colors.blueAccent,
                                strokeWidth: 5.0,
                              ),
                            ],
                          ),
                      ],
                    ),
                    if (distanceKm != null)
                      Positioned(
                        top: 16,
                        left: 16,
                        right: 16,
                        child: Card(
                          color: Colors.white.withOpacity(0.9),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 6,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 18),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.directions, color: Colors.blue[700]),
                                const SizedBox(width: 10),
                                Text(
                                  'Distance: ${distanceKm!.toStringAsFixed(2)} km',
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
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
} 