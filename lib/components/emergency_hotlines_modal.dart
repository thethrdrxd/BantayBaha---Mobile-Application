import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

class EmergencyHotlinesSheet extends StatelessWidget {
  const EmergencyHotlinesSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
      decoration: const BoxDecoration(
        color: Color(0xFFF5F7FA),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.phone_in_talk, color: Color(0xFF1976D2), size: 28),
                    const SizedBox(width: 10),
                    Text(
                      'Emergency Hotlines',
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[900],
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.blueGrey, size: 26),
                  onPressed: () => Navigator.of(context).pop(),
                  tooltip: 'Close',
                ),
              ],
            ),
            const SizedBox(height: 10),
            Divider(thickness: 1.2, color: Colors.blue[100]),
            const SizedBox(height: 10),
            _hotlineSection(
              context,
              title: 'CBDRRMO (City of Bogo Disaster Risk Reduction)',
              icon: Icons.shield,
              color: Color(0xFF1976D2),
              numbers: [
                {'label': 'Landline', 'number': '(032) 342 0580'},
                {'label': 'Globe', 'number': '0945 685 2435'},
                {'label': 'Smart', 'number': '0919 920 4635'}
              ],
            ),
            const SizedBox(height: 18),
            Divider(thickness: 1, color: Colors.blue[50]),
            const SizedBox(height: 18),
            _hotlineSection(
              context,
              title: 'Command Center',
              icon: Icons.security,
              color: Color(0xFF388E3C),
              numbers: [
                {'label': '', 'number': '0995-614-6128'},
                {'label': '', 'number': '0961-780-3213'}
              ],
            ),
            const SizedBox(height: 18),
            Divider(thickness: 1, color: Colors.blue[50]),
            const SizedBox(height: 18),
            _hotlineSection(
              context,
              title: 'Police',
              icon: Icons.local_police,
              color: Color(0xFF1976D2),
              numbers: [
                {'label': '', 'number': '(032)-383-9628'},
                {'label': '', 'number': '0905-600-2028'},
                {'label': '', 'number': '0921-236-5637'}
              ],
            ),
            const SizedBox(height: 18),
            Divider(thickness: 1, color: Colors.blue[50]),
            const SizedBox(height: 18),
            _hotlineSection(
              context,
              title: 'Fire',
              icon: Icons.local_fire_department,
              color: Color(0xFFD32F2F),
              numbers: [
                {'label': '', 'number': '(032)-324-3501'},
                {'label': '', 'number': '0917-127-9158'},
                {'label': '', 'number': '0923-724-8662'}
              ],
            ),
            const SizedBox(height: 28),
            Center(
              child: Text(
                'City Government of Bogo',
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.blue[900],
                ),
              ),
            ),
            Center(
              child: Text(
                'www.cityofbogocebu.gov.ph',
                style: GoogleFonts.nunito(
                  fontSize: 13,
                  color: Colors.blueGrey,
                ),
              ),
            ),
            Center(
              child: Text(
                'facebook @lgubogo',
                style: GoogleFonts.nunito(
                  fontSize: 13,
                  color: Colors.blueGrey,
                ),
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _hotlineSection(BuildContext context, {required String title, required IconData icon, required Color color, required List<Map<String, String>> numbers}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.07),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.06),
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
                decoration: BoxDecoration(
                  color: color.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.all(8),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...numbers.map((num) => Padding(
                padding: const EdgeInsets.only(left: 4, bottom: 6),
                child: Row(
                  children: [
                    Icon(Icons.phone, color: color, size: 18),
                    const SizedBox(width: 8),
                    if (num['label'] != null && num['label']!.isNotEmpty)
                      Text(
                        '${num['label']}: ',
                        style: GoogleFonts.nunito(
                          fontSize: 15,
                          color: Colors.blueGrey[700],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    GestureDetector(
                      onTap: () async {
                        final phone = num['number']!.replaceAll(RegExp(r'[^0-9+]'), '');
                        final uri = 'tel:$phone';
                        if (await canLaunch(uri)) {
                          await launch(uri);
                        }
                      },
                      child: Text(
                        num['number']!,
                        style: GoogleFonts.nunito(
                          fontSize: 16,
                          color: color,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
} 