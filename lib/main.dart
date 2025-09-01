import 'package:flutter/material.dart';
import 'login_page.dart';
import 'components/home_page.dart';
// Removed missing screen imports

void main() {
  runApp(const BantayBahaApp());
}

class BantayBahaApp extends StatelessWidget {
  const BantayBahaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'BantayBaha',
      home: const LoginPage(),
      routes: {
        '/home': (_) => const HomePage(),
      },
    );
  }
}
