import 'package:device_preview/device_preview.dart';
import 'package:flutter/material.dart';
import 'package:final_project/screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  runApp(
    DevicePreview(
      enabled: true,
      builder: (context) => const LogApp(),
    ),
  );
}

class LogApp extends StatelessWidget {
  const LogApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Log!',
      debugShowCheckedModeBanner: false,
      locale: DevicePreview.locale(context),
      builder: DevicePreview.appBuilder,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2D4B3E),
          primary: const Color(0xFF2D4B3E),
          secondary: const Color(0xFF8DAA91),
          surface: const Color(0xFFF9F7F2),
        ),
        scaffoldBackgroundColor: const Color(0xFFF9F7F2),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFF9F7F2),
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            color: Color(0xFF2D4B3E),
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}

