import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:final_project/models/entry.dart';
import 'package:final_project/services/storage_service.dart';
import 'package:final_project/services/summary_service.dart';
import 'package:final_project/widgets/primary_button.dart';
import 'package:final_project/widgets/bottom_action_bar.dart';
import 'package:final_project/screens/recorder_screen.dart';

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

  Map<String, int> _calculateStreaks() {
    if (_allEntries.isEmpty) return {'current': 0, 'longest': 0};

    final Set<String> entryDates = _allEntries
        .map((e) => "${e.date.year}-${e.date.month.toString().padLeft(2, '0')}-${e.date.day.toString().padLeft(2, '0')}")
        .toSet();

    int currentStreak = 0;
    DateTime tempDate = DateTime.now();
    String tempStr = "${tempDate.year}-${tempDate.month.toString().padLeft(2, '0')}-${tempDate.day.toString().padLeft(2, '0')}";
    
    if (!entryDates.contains(tempStr)) {
      tempDate = tempDate.subtract(const Duration(days: 1));
      tempStr = "${tempDate.year}-${tempDate.month.toString().padLeft(2, '0')}-${tempDate.day.toString().padLeft(2, '0')}";
    }

    while (true) {
      if (entryDates.contains(tempStr)) {
        currentStreak++;
        tempDate = tempDate.subtract(const Duration(days: 1));
        tempStr = "${tempDate.year}-${tempDate.month.toString().padLeft(2, '0')}-${tempDate.day.toString().padLeft(2, '0')}";
      } else {
        break;
      }
    }

    List<DateTime> sortedDates = _allEntries
        .map((e) => DateTime(e.date.year, e.date.month, e.date.day))
        .toSet()
        .toList();
    sortedDates.sort();

    int longestStreak = 0;
    int runningStreak = 0;
    DateTime? prevDate;

    for (var date in sortedDates) {
      if (prevDate == null) {
        runningStreak = 1;
      } else {
        final diff = date.difference(prevDate).inDays;
        if (diff == 1) {
          runningStreak++;
        } else if (diff > 1) {
          runningStreak = 1;
        }
      }
      prevDate = date;
      if (runningStreak > longestStreak) {
        longestStreak = runningStreak;
      }
    }

    return {'current': currentStreak, 'longest': longestStreak};
  }

  String _getMonthName(int month) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[month - 1];
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
    bool isGenerating = false;
    String? currentSummary = entry.summary;
    String? errorMessage;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
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
                  if (currentSummary != null) ...[
                    const Text(
                      'AI Summary:',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF8DAA91)),
                    ),
                    const SizedBox(height: 8),
                    Text(currentSummary ?? '', style: const TextStyle(fontStyle: FontStyle.italic)),
                  ],
                  if (errorMessage != null) ...[
                    const SizedBox(height: 8),
                    Text(errorMessage ?? '', style: const TextStyle(color: Color(0xFFDC2626), fontSize: 12)),
                  ],
                  if (isGenerating) ...[
                    const SizedBox(height: 12),
                    const Center(child: CircularProgressIndicator(color: Color(0xFF2D4B3E))),
                  ],
                ],
              ),
            ),
            actions: [
              if (currentSummary == null && !isGenerating)
                TextButton(
                  onPressed: () async {
                    setDialogState(() {
                      isGenerating = true;
                      errorMessage = null;
                    });
                    try {
                      final summary = await SummaryService.summarize(entry.text);
                      final updatedEntry = entry.copyWith(summary: summary);
                      
                      final entries = await StorageService.loadEntries();
                      final index = entries.indexWhere((e) => e.id == entry.id);
                      if (index != -1) {
                        entries[index] = updatedEntry;
                        await StorageService.saveEntries(entries);
                      }
                      
                      setDialogState(() {
                        currentSummary = summary;
                        isGenerating = false;
                      });
                      _loadEntries();
                    } catch (e) {
                      setDialogState(() {
                        errorMessage = e.toString().replaceFirst('Exception: ', '');
                        isGenerating = false;
                      });
                    }
                  },
                  child: const Text('Summarize with AI'),
                ),
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
          );
        },
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    final selectedEntries = _getEntriesForDay(_selectedDay);
    final streaks = _calculateStreaks();
    final currentStreak = streaks['current'] ?? 0;
    final longestStreak = streaks['longest'] ?? 0;

    return Scaffold(
      backgroundColor: const Color(0xFFF9F7F2),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF9F7F2),
        elevation: 0,
        titleSpacing: 20.0,
        centerTitle: false,
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
                  Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF9F7F2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text('Current', style: TextStyle(fontSize: 12, color: Colors.grey)),
                                      const SizedBox(height: 4),
                                      Text('$currentStreak Days', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF2D4B3E))),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF9F7F2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text('Longest', style: TextStyle(fontSize: 12, color: Colors.grey)),
                                      const SizedBox(height: 4),
                                      Text('$longestStreak Days', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF2D4B3E))),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${_getMonthName(_focusedDay.month)} ${_focusedDay.year}',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2D4B3E),
                                ),
                              ),
                              Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.chevron_left, color: Color(0xFF2D4B3E)),
                                    onPressed: () {
                                      setState(() {
                                        _focusedDay = DateTime(_focusedDay.year, _focusedDay.month - 1, 1);
                                      });
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.chevron_right, color: Color(0xFF2D4B3E)),
                                    onPressed: () {
                                      setState(() {
                                        _focusedDay = DateTime(_focusedDay.year, _focusedDay.month + 1, 1);
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          TableCalendar(
                            headerVisible: false,
                            daysOfWeekHeight: 32,
                            daysOfWeekStyle: const DaysOfWeekStyle(
                              weekdayStyle: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF2D4B3E)),
                              weekendStyle: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF2D4B3E)),
                            ),
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
                              leftChevronVisible: false,
                              rightChevronVisible: false,
                            ),
                          ),
                        ],
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
      bottomNavigationBar: BottomActionBar(
        currentIndex: 0,
        onCalendarTap: () {},
        onRecordTap: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const RecorderScreen()),
          );
          if (result == true) {
            _loadEntries();
          }
        },
        onSummarizeTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Select an entry to summarize.')),
          );
        },
      ),
    );
  }
}