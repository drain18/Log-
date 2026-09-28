import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:final_project/models/entry.dart';

class StorageService {
  static const String _entriesKey = 'journal_entries_v1';

  // Spike test method to verify SharedPreferences works
  static Future<bool> testStorage() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('spike_test', 'Hello Log! App');
    final val = prefs.getString('spike_test');
    return val == 'Hello Log! App';
  }

  static Future<List<Entry>> loadEntries() async {
    final prefs = await SharedPreferences.getInstance();
    final String? jsonString = prefs.getString(_entriesKey);
    if (jsonString == null) return [];
    
    try {
      final List<dynamic> decoded = jsonDecode(jsonString);
      return decoded.map((item) => Entry.fromJson(item)).toList();
    } catch (e) {
      return [];
    }
  }

  static Future<void> saveEntries(List<Entry> entries) async {
    final prefs = await SharedPreferences.getInstance();
    final String encoded = jsonEncode(entries.map((e) => e.toJson()).toList());
    await prefs.setString(_entriesKey, encoded);
  }

  static Future<void> addEntry(Entry entry) async {
    final entries = await loadEntries();
    entries.add(entry);
    await saveEntries(entries);
  }

  static Future<void> deleteEntry(String id) async {
    final entries = await loadEntries();
    entries.removeWhere((e) => e.id == id);
    await saveEntries(entries);
  }
}
