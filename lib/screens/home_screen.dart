import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:final_project/models/entry.dart';
import 'package:final_project/services/storage_service.dart';
import 'package:final_project/widgets/primary_button.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  List<Entry> _allEntries = [];

  @override
  void initState() {
    super.initState();
    _loadEntries();
  }

  Future<void> _loadEntries() async {
    final entries = await StorageService.loadEntries();
    if (!mounted) return;
    setState(() {
      _allEntries = entries;
    });
  }

  int _calculateStreak() {
    if (_allEntries.isEmpty) return 0;
    
    final Set<String> entryDates = _allEntries
        .map((e) => "${e.date.year}-${e.date.month.toString().padLeft(2, '0')}-${e.date.day.toString().padLeft(2, '0')}")
        .toSet();

    DateTime checkDate = DateTime.now();
    String checkStr = "${checkDate.year}-${checkDate.month.toString().padLeft(2, '0')}-${checkDate.day.toString().padLeft(2, '0')}";

    if (!entryDates.contains(checkStr)) {
      checkDate = checkDate.subtract(const Duration(days: 1));
      checkStr = "${checkDate.year}-${checkDate.month.toString().padLeft(2, '0')}-${checkDate.day.toString().padLeft(2, '0')}";
      if (!entryDates.contains(checkStr)) {
        return 0;
      }
    }

    int streak = 0;
    while (true) {
      if (entryDates.contains(checkStr)) {
        streak++;
        checkDate = checkDate.subtract(const Duration(days: 1));
        checkStr = "${checkDate.year}-${checkDate.month.toString().padLeft(2, '0')}-${checkDate.day.toString().padLeft(2, '0')}";
      } else {
        break;
      }
    }
    return streak;
  }

  List<Entry> _getEntriesForDay(DateTime day) {
    return _allEntries.where((e) {
      return e.date.year == day.year &&
          e.date.month == day.month &&
          e.date.day == day.day;
    }).toList();
  }

  void _showAddEntryModal() {
    final TextEditingController textController = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFFF9F7F2),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 24,
          right: 24,
          top: 24,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'New Journal Entry',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D4B3E),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: textController,
                maxLines: 5,
                decoration: InputDecoration(
                  hintText: 'What is on your mind today? (Or record voice...)',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              PrimaryButton(
                label: 'Save Entry',
                icon: Icons.check,
                onPressed: () async {
                  if (textController.text.trim().isEmpty) return;
                  final nav = Navigator.of(context);
                  final newEntry = Entry(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    date: _selectedDay,
                    text: textController.text.trim(),
                    summary: 'Auto-summary: ${textController.text.trim().split(' ').take(5).join(' ')}...',
                  );
                  await StorageService.addEntry(newEntry);
                  if (!mounted) return;
                  nav.pop();
                  _loadEntries();
                },
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  void _showEntryDetail(Entry entry) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFFF9F7F2),
        title: Text(
          'Entry for ${entry.date.month}/${entry.date.day}/${entry.date.year}',
          style: const TextStyle(color: Color(0xFF2D4B3E)),
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Journal Text:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 8),
              Text(entry.text, style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 16),
              if (entry.summary != null) ...[
                const Text(
                  'AI Summary:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF8DAA91)),
                ),
                const SizedBox(height: 8),
                Text(entry.summary!, style: const TextStyle(fontStyle: FontStyle.italic)),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: const Color(0xFFDC2626)),
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Delete Entry?'),
                  content: const Text('Are you sure you want to delete this journal entry?'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                    TextButton(
                      style: TextButton.styleFrom(foregroundColor: const Color(0xFFDC2626)),
                      onPressed: () => Navigator.pop(ctx, true),
                      child: const Text('Delete'),
                    ),
                  ],
                ),
              );

              if (confirm == true) {
                final targetId = entry.id;
                await StorageService.deleteEntry(targetId);
                if (!context.mounted) return;
                Navigator.pop(context);
                _loadEntries();
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    final selectedEntries = _getEntriesForDay(_selectedDay);
    final streak = _calculateStreak();

    return Scaffold(
      backgroundColor: const Color(0xFFF9F7F2),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF9F7F2),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Log!',
          style: TextStyle(
            color: Color(0xFF2D4B3E),
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2D4B3E),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.local_fire_department, color: Color(0xFF8DAA91), size: 32),
                        const SizedBox(width: 12),
                        Text(
                          '$streak Day Streak!',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TableCalendar(
                        firstDay: DateTime.utc(2023, 1, 1),
                        lastDay: DateTime.utc(2030, 12, 31),
                        focusedDay: _focusedDay,
                        selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                        onDaySelected: (selectedDay, focusedDay) {
                          setState(() {
                            _selectedDay = selectedDay;
                            _focusedDay = focusedDay;
                          });
                        },
                        eventLoader: _getEntriesForDay,
                        calendarStyle: const CalendarStyle(
                          todayDecoration: BoxDecoration(
                            color: Color(0xFF8DAA91),
                            shape: BoxShape.circle,
                          ),
                          selectedDecoration: BoxDecoration(
                            color: Color(0xFF2D4B3E),
                            shape: BoxShape.circle,
                          ),
                          markerDecoration: BoxDecoration(
                            color: Color(0xFF2D4B3E),
                            shape: BoxShape.circle,
                          ),
                        ),
                        headerStyle: const HeaderStyle(
                          formatButtonVisible: false,
                          titleCentered: true,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Entries for ${_selectedDay.month}/${_selectedDay.day}/${_selectedDay.year}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2D4B3E),
                        ),
                      ),
                      TextButton.icon(
                        onPressed: _showAddEntryModal,
                        icon: const Icon(Icons.add, color: Color(0xFF2D4B3E)),
                        label: const Text('Add Entry', style: TextStyle(color: Color(0xFF2D4B3E))),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: selectedEntries.isEmpty
                        ? Center(
                            child: Text(
                              'No entries for this date.',
                              style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
                            ),
                          )
                        : ListView.builder(
                            itemCount: selectedEntries.length,
                            itemBuilder: (context, index) {
                              final entry = selectedEntries[index];
                              return Card(
                                margin: const EdgeInsets.only(bottom: 8),
                                elevation: 0,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                child: ListTile(
                                  title: Text(
                                    entry.text,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontWeight: FontWeight.w500),
                                  ),
                                  subtitle: entry.summary != null
                                      ? Text(
                                          entry.summary!,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(fontSize: 12, color: Color(0xFF8DAA91)),
                                        )
                                      : null,
                                  trailing: const Icon(Icons.chevron_right),
                                  onTap: () => _showEntryDetail(entry),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF2D4B3E),
        foregroundColor: Colors.white,
        onPressed: _showAddEntryModal,
        child: const Icon(Icons.mic),
      ),
    );
  }
}

