import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'evacuation_route_map.dart';
import 'package:latlong2/latlong.dart';

class EvacuationCentersSheet extends StatelessWidget {
  final List<Map<String, dynamic>> centers;
  final double? startLat;
  final double? startLng;
  const EvacuationCentersSheet({required this.centers, super.key, this.startLat, this.startLng});

  @override
  Widget build(BuildContext context) {
    if (centers.isEmpty) {
      return SizedBox(
        height: 180,
        child: Center(child: Text('No nearby evacuation centers found.', style: TextStyle(fontSize: 16))),
      );
    }
    final nearest = centers.isNotEmpty ? centers.first : null;
    final others = centers.length > 1 ? centers.sublist(1) : [];
    return SizedBox(
      height: 480,
      child: Column(
        children: [
          // Modal header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Nearby Evacuation Centers',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[900],
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  tooltip: 'Close',
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
          const Divider(height: 1, thickness: 1),
          // List of evacuation centers (scrollable)
          Expanded(
      child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        children: [
          if (nearest != null)
            _EvacuationCenterCard(
              center: nearest,
              isSuggested: true,
              startLat: startLat,
              startLng: startLng,
            ),
          ...others.map((c) => _EvacuationCenterCard(center: c, startLat: startLat, startLng: startLng)),
                if (others.isEmpty && nearest == null)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Center(
                      child: Text('No evacuation centers found.', style: GoogleFonts.poppins(fontSize: 15)),
                    ),
                  ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EvacuationCenterCard extends StatelessWidget {
  final Map<String, dynamic> center;
  final bool isSuggested;
  final double? startLat;
  final double? startLng;
  const _EvacuationCenterCard({required this.center, this.isSuggested = false, this.startLat, this.startLng});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isSuggested ? Colors.blue[50] : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isSuggested ? Colors.blue[200]! : Colors.grey[200]!, width: 1),
        boxShadow: [
          if (isSuggested)
            BoxShadow(
              color: Colors.blue.withOpacity(0.07),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.location_city, color: Colors.blue[700], size: 28),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        center['name'],
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[900],
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (isSuggested)
                      Container(
                        margin: const EdgeInsets.only(left: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.blue[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Suggested',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[800],
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  center['address'],
                  style: GoogleFonts.nunito(
                    fontSize: 14,
                    color: Colors.blueGrey[700],
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                if (center['distance'] != null)
                  Text(
                    'Distance: ${center['distance'].toStringAsFixed(2)} km',
                    style: GoogleFonts.nunito(
                      fontSize: 13,
                      color: Colors.blueGrey[600],
                    ),
                  ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.directions, color: Colors.blue[900]),
            tooltip: 'Get Directions',
            onPressed: () {
              if (startLat != null && startLng != null) {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => EvacuationRouteMapPage(
                      start: LatLng(startLat!, startLng!),
                      destination: LatLng(center['lat'], center['lng']),
                      destinationName: center['name'],
                    ),
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('No start location available.')),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}

// Add a checklist widget for precautions
class _PrecautionChecklist extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final items = [
      'Bring essential documents',
      'Pack food, water, and medicines',
      'Prepare flashlight and batteries',
      'Bring extra clothes and blankets',
      'Follow authorities’ instructions',
      'Secure your home before leaving',
      'Stay calm and help others if possible',
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items.map((item) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          children: [
            Icon(Icons.check_circle_outline, color: Colors.orange[700], size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                item,
                style: GoogleFonts.nunito(
                  fontSize: 14,
                  color: Colors.orange[900],
                ),
              ),
            ),
          ],
        ),
      )).toList(),
    );
  }
}

// Add a checklist widget for precautions
class PrecautionsSheet extends StatelessWidget {
  const PrecautionsSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 340,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Evacuation Precautions',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange[900],
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  tooltip: 'Close',
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
          const Divider(height: 1, thickness: 1),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.warning_amber_rounded, color: Colors.orange[800]),
                    const SizedBox(width: 8),
                    Text(
                      'What to Bring & Do',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange[900],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                _PrecautionChecklist(),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange[800],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      textStyle: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    icon: const Icon(Icons.arrow_forward_rounded),
                    label: const Text('View Evacuation Centers'),
                    onPressed: () => Navigator.of(context).pop(true),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ReminderSheet extends StatelessWidget {
  const ReminderSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 320,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Row(
              children: [
                Icon(Icons.warning_amber_rounded, color: Colors.orange[800], size: 32),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Before proceeding, please review these evacuation precautions:',
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.orange[900],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: _PrecautionChecklist(),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: 120,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange[800],
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('OK'),
            ),
          ),
        ],
      ),
    );
  }
} 