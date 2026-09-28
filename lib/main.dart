import 'package:device_preview/device_preview.dart';
import 'package:flutter/material.dart';
import 'package:final_project/services/storage_service.dart';
import 'package:final_project/models/entry.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Run our Phase 0 Storage Spike
  final spikeSuccess = await StorageService.testStorage();
  debugPrint('--- Phase 0 Storage Spike Result: $spikeSuccess ---');

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
          seedColor: const Color(0xFF4A3780),
          primary: const Color(0xFF4A3780),
          secondary: const Color(0xFF7E69AB),
          surface: const Color(0xFFF8F7FC),
        ),
        scaffoldBackgroundColor: const Color(0xFFF8F7FC),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFF8F7FC),
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            color: Color(0xFF2D2545),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      home: const SpikeHomeScreen(),
    );
  }
}

class SpikeHomeScreen extends StatefulWidget {
  const SpikeHomeScreen({super.key});

  @override
  State<SpikeHomeScreen> createState() => _SpikeHomeScreenState();
}

class _SpikeHomeScreenState extends State<SpikeHomeScreen> {
  String _statusMessage = 'Storage Spike Initialized Successfully!';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Log! - Phase 0 Spike'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.check_circle_outline,
                size: 80,
                color: Color(0xFF4A3780),
              ),
              const SizedBox(height: 16),
              Text(
                _statusMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2D2545),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4A3780),
                  foregroundColor: Colors.white,
                ),
                onPressed: () async {
                  final entry = Entry(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    date: DateTime.now(),
                    text: 'This is a test journal entry from Phase 0 spike.',
                    summary: 'Test entry summary.',
                  );
                  await StorageService.addEntry(entry);
                  final loaded = await StorageService.loadEntries();
                  setState(() {
                    _statusMessage = 'Saved & Loaded ${loaded.length} entries successfully!';
                  });
                },
                child: const Text('Test Save & Load Entry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
