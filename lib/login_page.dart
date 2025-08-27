import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    const Color cardBlue = Color(0xFFEAF4FB);
    const Color accentBlue = Color(0xFF1976D2);
    const Color buttonBlue = Color(0xFF1976D2);
    const Color white = Colors.white;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final height = constraints.maxHeight;
          return Stack(
            alignment: Alignment.topCenter,
            children: [
              // Blue-to-white gradient background
              Container(
                height: height * 0.6,
                width: double.infinity,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFF4A90E2), Color(0xFFB3D1F7), Colors.white],
                  ),
                ),
              ),
              // Wave/flood effect behind rescuer (move higher)
              Positioned(
                top: height * 0.36,
                left: 0,
                right: 0,
                child: SizedBox(
                  height: height * 0.18,
                  width: double.infinity,
                  child: CustomPaint(
                    painter: _WavePainter(),
                  ),
                ),
              ),
              // Large rescuer image behind the card, overlapping
              Positioned(
                top: height * 0.13,
                left: 0,
                right: 0,
                child: IgnorePointer(
                  child: Center(
                    child: FractionallySizedBox(
                      widthFactor: 0.85,
                      child: Image.asset(
                        'assets/rescuer.png',
                        height: height * 0.48,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
              ),
              // Main content (logo, card)
              Column(
                children: [
                  SizedBox(height: height * 0.05),
                  // Prominent logo
                  Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    
                 
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF1976D2).withOpacity(0.18),
                          blurRadius: 32,
                          spreadRadius: 2,
                          offset: const Offset(0, 12),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: height * 0.04),
                  // Lowered white card with rounded top corners
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      margin: EdgeInsets.only(top: height * 0.39),
                      padding: const EdgeInsets.fromLTRB(20, 48, 20, 20),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(36),
                          topRight: Radius.circular(36),
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Title
                          Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                  text: 'Welcome to\n',
                                  style: GoogleFonts.poppins(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.black87,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                TextSpan(
                                  text: 'BantayBaha',
                                  style: GoogleFonts.poppins(
                                    fontSize: 40,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF1976D2),
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 18),
                          // Description
                          Text(
                            'Your trusted companion for flood monitoring and safety in Bogo City.\nStay informed and stay safe.',
                            style: GoogleFonts.nunito(
                              fontSize: 15,
                              color: Colors.black54,
                              height: 1.5,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          // Large circular button (nudged up)
                          SizedBox(
                            width: 64,
                            height: 64,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                shape: const CircleBorder(),
                                backgroundColor: const Color(0xFF1976D2),
                                elevation: 6,
                                padding: EdgeInsets.zero,
                              ),
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(builder: (context) => const PhoneInputPage()),
                                );
                              },
                              child: Align(
                                alignment: Alignment(0, -0.1), // Centered, nudged slightly up
                                child: Icon(Icons.arrow_forward, color: Colors.white, size: 35),
                              ),
                            ),
                          ),
                          Text(
                            'Supported by the City Government of Bogo',
                            style: GoogleFonts.nunito(
                              fontSize: 12,
                              color: Colors.black54,
                              height: 6,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

// Custom painter for the wave/flood effect
class _WavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF1565C0).withOpacity(0.95)
      ..style = PaintingStyle.fill;

    // Smooth, single-crest wave
    final path = Path();
    path.moveTo(0, size.height * 0.30);
    path.quadraticBezierTo(size.width * 0.25, size.height * 0.10, size.width * 0.5, size.height * 0.30);
    path.quadraticBezierTo(size.width * 0.75, size.height * 0.50, size.width, size.height * 0.30);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    canvas.drawPath(path, paint);

    // More prominent light blue highlight
    final highlight = Paint()
      ..color = const Color(0xFFB3D1F7).withOpacity(0.95)
      ..style = PaintingStyle.fill;
    final highlightPath = Path();
    highlightPath.moveTo(0, size.height * 0.45);
    highlightPath.quadraticBezierTo(size.width * 0.25, size.height * 0.25, size.width * 0.5, size.height * 0.45);
    highlightPath.quadraticBezierTo(size.width * 0.75, size.height * 0.65, size.width, size.height * 0.45);
    highlightPath.lineTo(size.width, size.height);
    highlightPath.lineTo(0, size.height);
    highlightPath.close();
    canvas.drawPath(highlightPath, highlight);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// New PhoneInputPage component
class PhoneInputPage extends StatefulWidget {
  const PhoneInputPage({super.key});

  @override
  State<PhoneInputPage> createState() => _PhoneInputPageState();
}

class _PhoneInputPageState extends State<PhoneInputPage> {
  final TextEditingController phoneController = TextEditingController();
  bool isLoading = false;

  void startDummyAuth() {
    setState(() => isLoading = true);
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() => isLoading = false);
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => OtpVerificationPage(
            phone: phoneController.text.trim(),
          ),
        ),
      );
    });
  }
//SA PAG INPUT SA NUMBER NI NA PAGE!!!!!!!!!!!!!
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE3F0FF),
      body: Center(
        child: Container(
          width: 350,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(32),
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFB3D1F7), Colors.white],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.blue.withOpacity(0.10),
                blurRadius: 32,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Phone icon in a circle with shadow
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.13),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Center(
                  child: Icon(Icons.phone, color: Color(0xFF1976D2), size: 38),
                ),
              ),
              const SizedBox(height: 28),
              // Title
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: 'Hello, ',
                      style: GoogleFonts.poppins(
                        fontSize: 26,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    TextSpan(
                      text: 'Bogohanon!',
                      style: GoogleFonts.poppins(
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1976D2),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "Let's sign you in",
                style: GoogleFonts.nunito(
                  fontSize: 15,
                  color: Colors.black54,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 28),
              // Phone number input
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.07),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: TextField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  style: GoogleFonts.nunito(fontSize: 16),
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                    border: InputBorder.none,
                    hintText: 'Phone number',
                    hintStyle: GoogleFonts.nunito(color: Colors.grey[400]),
                  ),
                ),
              ),
              const SizedBox(height: 22),
              // Continue button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1976D2),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 6,
                    textStyle: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onPressed: isLoading ? null : startDummyAuth,
                  child: isLoading
                      ? const CircularProgressIndicator()
                      : const Text('Continue'),
                ),
              ),
              const SizedBox(height: 18),
              // Create account link
             
            ],
          ),
        ),
      ),
    );
  }
}

 //SA AUTHENTICATION NI NA PAGE!!!!!!!!!!!!!!!!!!!!!//
class OtpVerificationPage extends StatefulWidget {
  final String phone;
  const OtpVerificationPage({required this.phone, super.key});

  @override
  State<OtpVerificationPage> createState() => _OtpVerificationPageState();
}

class _OtpVerificationPageState extends State<OtpVerificationPage> {
  final TextEditingController codeController = TextEditingController();
  bool isVerifying = false;

  void verifyCode() {
    setState(() => isVerifying = true);
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() => isVerifying = false);
      if (codeController.text.trim() == '123456') {
        Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid code!')),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE3F0FF),
      body: Center(
        child: Container(
          width: 350,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFB3D1F7), Colors.white],
            ),
        boxShadow: [
          BoxShadow(
                color: Colors.blue.withOpacity(0.10),
                blurRadius: 32,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Phone icon in a circle with shadow
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
          BoxShadow(
                      color: Colors.blue.withOpacity(0.13),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Center(
                  child: Icon(Icons.lock, color: Color(0xFF1976D2), size: 38),
                ),
              ),

             
              const SizedBox(height: 28),
              // Title
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: 'Verify your number',
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Enter the code sent to your phone.',
                style: GoogleFonts.nunito(
                  fontSize: 15,
                  color: Colors.black54,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 28),
              // OTP input
              Container(
                decoration: BoxDecoration(
            color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.07),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: TextField(
                  controller: codeController,
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.nunito(fontSize: 18, letterSpacing: 8),
                  decoration: InputDecoration(
                    counterText: '',
                    hintText: 'Enter code',
                    hintStyle: GoogleFonts.nunito(color: Colors.grey[400]),
                  ),
                ),
              ),
              const SizedBox(height: 22),
              // Verify button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1976D2),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 6,
                    textStyle: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onPressed: isVerifying ? null : verifyCode,
                  child: isVerifying
                      ? const CircularProgressIndicator()
                      : const Text('Verify'),
                ),
          ),
        ],
      ),
        ),
      ),
    );
  }
}
  