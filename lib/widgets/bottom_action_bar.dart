import 'package:flutter/material.dart';

class BottomActionBar extends StatelessWidget {
  final VoidCallback onCalendarTap;
  final VoidCallback onRecordTap;
  final VoidCallback onSummarizeTap;
  final int currentIndex;

  const BottomActionBar({
    super.key,
    required this.onCalendarTap,
    required this.onRecordTap,
    required this.onSummarizeTap,
    this.currentIndex = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF2D4B3E),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildActionButton(
            icon: Icons.calendar_today,
            label: 'Calendar',
            isSelected: currentIndex == 0,
            onTap: onCalendarTap,
          ),
          _buildActionButton(
            icon: Icons.mic,
            label: 'Record',
            isSelected: currentIndex == 1,
            onTap: onRecordTap,
          ),
          _buildActionButton(
            icon: Icons.auto_awesome,
            label: 'Summarize',
            isSelected: currentIndex == 2,
            onTap: onSummarizeTap,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    const color = Colors.white;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
