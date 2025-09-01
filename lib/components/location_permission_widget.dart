import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/location_service.dart';

class LocationPermissionWidget extends StatefulWidget {
  final VoidCallback? onLocationGranted;

  const LocationPermissionWidget({
    super.key,
    this.onLocationGranted,
  });

  @override
  State<LocationPermissionWidget> createState() => _LocationPermissionWidgetState();
}

class _LocationPermissionWidgetState extends State<LocationPermissionWidget> {
  bool _isRequesting = false;

  Future<void> _requestLocationPermission() async {
    setState(() {
      _isRequesting = true;
    });

    try {
      final hasPermission = await LocationService.requestLocationPermission(context);
      
      if (hasPermission && widget.onLocationGranted != null) {
        widget.onLocationGranted!();
      }
    } catch (e) {
      // Handle error silently
    } finally {
      setState(() {
        _isRequesting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Column(
        children: [
          Icon(
            Icons.location_on,
            size: 48,
            color: Colors.blue[700],
          ),
          const SizedBox(height: 16),
          Text(
            'Enable Location Services',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.blue[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'To provide accurate evacuation routes and nearby alerts, we need access to your location.',
            style: GoogleFonts.nunito(
              fontSize: 14,
              color: Colors.grey[700],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isRequesting ? null : _requestLocationPermission,
              icon: _isRequesting
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.location_on),
              label: Text(
                _isRequesting ? 'Requesting...' : 'Enable Location',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
              ),
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
    );
  }
}
