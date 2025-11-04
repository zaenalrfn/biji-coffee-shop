import 'package:flutter/material.dart';

class ViewToggle extends StatelessWidget {
  final bool isListView;
  final Function(bool) onToggle;

  const ViewToggle({
    super.key,
    required this.isListView,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 28),
      height: 48,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F3F3),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildToggleButton(
              label: 'List View',
              isSelected: isListView,
              onTap: () => onToggle(true),
            ),
          ),
          Expanded(
            child: _buildToggleButton(
              label: 'Map View',
              isSelected: !isListView,
              onTap: () => onToggle(false),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleButton({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 12,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 15,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              color: isSelected 
                  ? const Color(0xFF1A1A1A) 
                  : const Color(0xFF8B8B8B),
              letterSpacing: 0.2,
            ),
          ),
        ),
      ),
    );
  }
}