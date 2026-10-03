import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:final_project/models/entry.dart';
import 'package:final_project/services/storage_service.dart';

class RecorderScreen extends StatefulWidget {
  const RecorderScreen({super.key});

  @override
  State<RecorderScreen> createState() => _RecorderScreenState();
}

class _RecorderScreenState extends State<RecorderScreen> {
  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _transcript = '';

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _startListening();
  }

  void _startListening() async {
    bool available = await _speech.initialize(
      onStatus: (val) => debugPrint('onStatus: $val'),
      onError: (val) => debugPrint('onError: $val'),
    );
    if (available) {
      setState(() => _isListening = true);
      _speech.listen(
        onResult: (val) => setState(() {
          _transcript = val.recognizedWords;
        }),
      );
    } else {
      setState(() => _isListening = false);
      debugPrint('Speech recognition not available');
    }
  }

  void _stopListening() async {
    await _speech.stop();
    setState(() => _isListening = false);
  }

  void _saveEntry() async {
    if (_transcript.trim().isEmpty) {
      Navigator.pop(context);
      return;
    }
    final entry = Entry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      date: DateTime.now(),
      text: _transcript,
      summary: null,
    );
    await StorageService.addEntry(entry);
    if (!mounted) return;
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Voice Recorder'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            _stopListening();
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _isListening ? Icons.mic : Icons.mic_none,
              size: 80,
              color: const Color(0xFF2D4B3E),
            ),
            const SizedBox(height: 24),
            Text(
              _isListening ? 'Listening... Speak your journal entry.' : 'Recording stopped.',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D4B3E),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: SingleChildScrollView(
                  child: Text(
                    _transcript.isEmpty ? 'Your speech will appear here...' : _transcript,
                    style: TextStyle(
                      fontSize: 16,
                      color: _transcript.isEmpty ? Colors.grey : const Color(0xFF2D4B3E),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: const BorderSide(color: Color(0xFFDC2626)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () {
                      _stopListening();
                      Navigator.pop(context);
                    },
                    child: const Text('Discard', style: TextStyle(color: Color(0xFFDC2626))),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2D4B3E),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    onPressed: () {
                      _stopListening();
                      _saveEntry();
                    },
                    child: const Text('Save Entry'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
