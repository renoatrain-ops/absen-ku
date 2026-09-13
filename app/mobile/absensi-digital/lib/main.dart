// Flutter main entry
import 'package:flutter/material.dart';
import 'pages/home_page.dart';

void main() {
  runApp(const AbsensiApp());
}

class AbsensiApp extends StatelessWidget {
  const AbsensiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Absensi Digital',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xff197c8c),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xfff3f8f8),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xffd9eff0),
          foregroundColor: Color(0xff123e46),
          elevation: 0,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(0, 48),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
        ),
      ),
      home: const HomePage(),
    );
  }
}
