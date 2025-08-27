import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../components/evacuation_data.dart';
import '../components/evacuation_centers_modal.dart';

class SensorDetailsPage extends StatelessWidget {
  final Map<String, dynamic> sensor;
  const SensorDetailsPage({required this.sensor, super.key});

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    switch (sensor['status']) {
      case 'HIGH':
        statusColor = Colors.redAccent;
        break;
      case 'MEDIUM':
        statusColor = Colors.orangeAccent;
        break;
      case 'LOW':
      default:
        statusColor = Colors.green;
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(sensor['name'], style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF1976D2),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      backgroundColor: const Color(0xFFE3F0FF),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Sensor status card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 24),
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
                        color: statusColor.withOpacity(0.10),
                        blurRadius: 24,
                        offset: Offset(8, 8),
                      ),
                      // Inner shadow (simulated)
                      BoxShadow(
                        color: Colors.white.withOpacity(0.8),
                        blurRadius: 8,
                        offset: Offset(-6, -6),
                        spreadRadius: -4,
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(
                        sensor['status'] == 'HIGH'
                            ? Icons.warning
                            : sensor['status'] == 'MEDIUM'
                                ? Icons.water_drop
                                : Icons.sensors,
                        color: statusColor,
                        size: 48,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        sensor['name'],
                        style: GoogleFonts.poppins(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[900],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          sensor['status'],
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: statusColor,
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      _buildDetailRow(
                        icon: Icons.location_on,
                        label: 'Coordinates',
                        value: '${sensor['lat']}, ${sensor['lng']}',
                      ),
                      const SizedBox(height: 14),
                      _buildDetailRow(
                        icon: Icons.water,
                        label: 'Water Level',
                        value: '${sensor['waterLevel']} m',
                        valueColor: statusColor,
                      ),
                      const SizedBox(height: 14),
                      _buildDetailRow(
                        icon: Icons.speed,
                        label: 'Water Pressure',
                        value: '${sensor['waterPressure']} kPa',
                      ),
                      const SizedBox(height: 14),
                      _buildDetailRow(
                        icon: Icons.grain,
                        label: 'Rain Precipitation',
                        value: '${sensor['rainPrecipitation']} mm',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 36),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1976D2),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 8,
                      textStyle: GoogleFonts.poppins(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    icon: const Icon(Icons.location_searching, size: 24),
                    onPressed: () async {
                      final nearby = getNearbyEvacCenters(sensor['lat'], sensor['lng'], 2.0); // Only show centers within 2km
                      final reminder = await showModalBottomSheet<bool>(
                        context: context,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                        ),
                        builder: (context) => const ReminderSheet(),
                      );
                      if (reminder == true) {
                        showModalBottomSheet(
                          context: context,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                          ),
                          isScrollControlled: true,
                        builder: (context) => EvacuationCentersSheet(
                          centers: nearby,
                          startLat: sensor['lat'],
                          startLng: sensor['lng'],
                        ),
                      );
                      }
                    },
                    label: const Text('View Near Evacuation Area'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow({required IconData icon, required String label, required String value, Color? valueColor}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFE3F0FF),
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.all(8),
          child: Icon(icon, color: Colors.blue[700], size: 22),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.blue[900],
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: GoogleFonts.nunito(
                  fontSize: 15,
                  color: valueColor ?? Colors.black87,
                  fontWeight: FontWeight.w600,
                ),
                softWrap: true,
                overflow: TextOverflow.visible,
              ),
            ],
          ),
        ),
      ],
    );
  }
} 