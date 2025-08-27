import 'dart:math';

final List<Map<String, dynamic>> evacuationCenters = [
  {
    'name': 'Bogo Central School',
    'lat': 11.0480,
    'lng': 124.0070,
    'address': 'Bogo City, Cebu'
  },
  {
    'name': 'Don Pedro Barangay Hall',
    'lat': 11.0620,
    'lng': 123.9720,
    'address': 'Don Pedro, Bogo City'
  },
  {
    'name': 'Taytayan Barangay Hall',
    'lat': 11.0530,
    'lng': 123.9880,
    'address': 'Taytayan, Bogo City'
  },
];

double calculateDistance(lat1, lon1, lat2, lon2) {
  const earthRadius = 6371; // km
  final dLat = (lat2 - lat1) * pi / 180;
  final dLon = (lon2 - lon1) * pi / 180;
  final a = sin(dLat / 2) * sin(dLat / 2) +
      cos(lat1 * pi / 180) * cos(lat2 * pi / 180) *
      sin(dLon / 2) * sin(dLon / 2);
  final c = 2 * atan2(sqrt(a), sqrt(1 - a));
  return earthRadius * c;
}

List<Map<String, dynamic>> buildSensorsWithNearestEvac() {
  final List<Map<String, dynamic>> sensors = [
    {
      'name': 'Mcdo Bogo City',
      'lat': 11.048697476519239,
      'lng': 124.00429859595907,
      'waterLevel': 1.2,
      'status': 'MEDIUM',
      'waterPressure': 1.8,
      'rainPrecipitation': 3.2,
    },
    {
      'name': 'Barangay Don Pedro',
      'lat': 11.062539469238237,
      'lng': 123.9721444370959,
      'waterLevel': 0.8,
      'status': 'LOW',
      'waterPressure': 1.1,
      'rainPrecipitation': 1.0,
    },
    {
      'name': 'Barangay Taytayan',
      'lat': 11.051972756946592,
      'lng': 123.98698540415546,
      'waterLevel': 2.1,
      'status': 'HIGH',
      'waterPressure': 2.5,
      'rainPrecipitation': 5.7,
    },
  ];
  for (final sensor in sensors) {
    Map<String, dynamic>? nearest;
    double minDist = double.infinity;
    for (final evac in evacuationCenters) {
      final dist = calculateDistance(sensor['lat'], sensor['lng'], evac['lat'], evac['lng']);
      if (dist < minDist) {
        minDist = dist;
        nearest = evac;
      }
    }
    sensor['nearestEvac'] = nearest;
    sensor['nearestEvacDist'] = minDist;
  }
  return sensors;
}

List<Map<String, dynamic>> getNearbyEvacCenters(double sensorLat, double sensorLng, double radiusKm) {
  final List<Map<String, dynamic>> result = [];
  for (final center in evacuationCenters) {
    final dist = calculateDistance(sensorLat, sensorLng, center['lat'], center['lng']);
    if (dist <= radiusKm) {
      final c = Map<String, dynamic>.from(center);
      c['distance'] = dist;
      result.add(c);
    }
  }
  // Sort by distance
  result.sort((a, b) => (a['distance'] as double).compareTo(b['distance'] as double));
  return result;
} 