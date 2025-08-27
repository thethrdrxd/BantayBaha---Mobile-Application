import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SensorCard extends StatelessWidget {
  final Map<String, dynamic> sensor;
  final VoidCallback onTap;
  const SensorCard({required this.sensor, required this.onTap, super.key});

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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: const Color(0xFFEAF4FB),
          borderRadius: BorderRadius.circular(22),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFEAF4FB), Color(0xFFFFFFFF)],
          ),
          boxShadow: [
            // Outer shadow
            BoxShadow(
              color: Colors.blueGrey.withOpacity(0.10),
              blurRadius: 18,
              offset: Offset(8, 8),
            ),
            // Inner shadow (simulated)
            BoxShadow(
              color: Colors.white.withOpacity(0.8),
              blurRadius: 6,
              offset: Offset(-6, -6),
              spreadRadius: -4,
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(
              sensor['status'] == 'HIGH'
                  ? Icons.warning
                  : sensor['status'] == 'MEDIUM'
                      ? Icons.water_drop
                      : Icons.sensors,
              color: statusColor,
              size: 32,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    sensor['name'],
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.blue[900],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Water Level: ${sensor['waterLevel']}m',
                    style: GoogleFonts.nunito(
                      fontSize: 15,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                sensor['status'],
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: statusColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 