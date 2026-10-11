import 'package:flutter/material.dart';
import 'package:final_project/models/entry.dart';
import 'package:final_project/services/storage_service.dart';
import 'package:final_project/services/summary_service.dart';
import 'package:final_project/widgets/primary_button.dart';
import 'package:final_project/widgets/bottom_action_bar.dart';

class EntryDetailScreen extends StatefulWidget {
  final Entry entry;
  const EntryDetailScreen({super.key, required this.entry});

  @override
  State<EntryDetailScreen> createState() => _EntryDetailScreenState();
}

class _EntryDetailScreenState extends State<EntryDetailScreen> {
  late Entry _currentEntry;
  late TextEditingController _textController;
  bool _isEditing = false;
  bool _isGenerating = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _currentEntry = widget.entry;
    _textController = TextEditingController(text: _currentEntry.text);
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    final newText = _textController.text.trim();
    if (newText.isEmpty) return;
    final updated = _currentEntry.copyWith(text: newText);
    await StorageService.updateEntry(updated);
    if (!mounted) return;
    setState(() {
      _currentEntry = updated;
      _isEditing = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Entry updated successfully.')),
    );
  }

  Future<void> _summarizeEntry() async {
    setState(() {
      _isGenerating = true;
      _errorMessage = null;
    });
    try {
      final summary = await SummaryService.summarize(_currentEntry.text);
      final updated = _currentEntry.copyWith(summary: summary);
      await StorageService.updateEntry(updated);
      if (!mounted) return;
      setState(() {
        _currentEntry = updated;
        _isGenerating = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
        _isGenerating = false;
      });
    }
  }

  Future<void> _deleteEntry() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFFF9F7F2),
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
      await StorageService.deleteEntry(_currentEntry.id);
      if (!mounted) return;
      Navigator.pop(context, true);
    }
  }
  @override
  Widget build(BuildContext context) {
    final dateStr = '${_currentEntry.date.month}/${_currentEntry.date.day}/${_currentEntry.date.year}';

    return Scaffold(
      backgroundColor: const Color(0xFFF9F7F2),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF9F7F2),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF2D4B3E)),
          onPressed: () => Navigator.pop(context, true),
        ),
        title: Text(
          'Entry for $dateStr',
          style: const TextStyle(color: Color(0xFF2D4B3E), fontSize: 20, fontWeight: FontWeight.bold),
        ),
        actions: [
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit, color: Color(0xFF2D4B3E)),
              onPressed: () => setState(() => _isEditing = true),
              tooltip: 'Edit',
            ),
          IconButton(
            icon: const Icon(Icons.delete, color: Color(0xFFDC2626)),
            onPressed: _deleteEntry,
            tooltip: 'Delete',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Journal Text',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF2D4B3E)),
            ),
            const SizedBox(height: 8),
            if (_isEditing) ...[
              TextField(
                controller: _textController,
                maxLines: 8,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        _textController.text = _currentEntry.text;
                        setState(() => _isEditing = false);
                      },
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: PrimaryButton(
                      label: 'Save',
                      icon: Icons.check,
                      onPressed: _saveChanges,
                    ),
                  ),
                ],
              ),
            ] else ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                child: Text(_currentEntry.text, style: const TextStyle(fontSize: 16, height: 1.5)),
              ),
            ],
            const SizedBox(height: 24),
            if (_currentEntry.summary != null) ...[
              const Text(
                'AI Summary',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF8DAA91)),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF8DAA91).withValues(alpha: 0.3)),
                ),
                child: Text(_currentEntry.summary!, style: const TextStyle(fontSize: 15, fontStyle: FontStyle.italic, height: 1.4)),
              ),
              const SizedBox(height: 24),
            ],
            if (_currentEntry.summary == null && !_isEditing) ...[
              PrimaryButton(
                label: _isGenerating ? 'Summarizing...' : 'Summarize with AI',
                icon: Icons.auto_awesome,
                onPressed: _isGenerating ? () {} : _summarizeEntry,
              ),
              const SizedBox(height: 16),
            ],
            if (_isGenerating) ...[
              const Center(child: CircularProgressIndicator(color: Color(0xFF2D4B3E))),
              const SizedBox(height: 16),
            ],
            if (_errorMessage != null) ...[
              Text(_errorMessage!, style: const TextStyle(color: Color(0xFFDC2626), fontSize: 14), textAlign: TextAlign.center),
              const SizedBox(height: 16),
            ],
          ],
        ),
      ),
      bottomNavigationBar: BottomActionBar(
        currentIndex: 0,
        onCalendarTap: () => Navigator.pop(context, true),
        onRecordTap: () {},
        onSummarizeTap: () {
          if (_currentEntry.summary == null && !_isGenerating) {
            _summarizeEntry();
          }
        },
      ),
    );
  }
}

