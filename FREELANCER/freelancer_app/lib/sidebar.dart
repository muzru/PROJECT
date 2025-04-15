// widgets/sidebar_item.dart
import 'package:flutter/material.dart';

class SidebarItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool isSelected;
  final bool isExpanded;
  final VoidCallback onTap;

  const SidebarItem({
    super.key,
    required this.icon,
    required this.title,
    required this.isSelected,
    required this.isExpanded,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? const Color(0xFF2E6F40) : Colors.grey,
      ),
      title: isExpanded
          ? Text(
              title,
              style: TextStyle(
                color: isSelected ? const Color(0xFF2E6F40) : Colors.black,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            )
          : null,
      tileColor: isSelected ? Colors.grey.shade200 : Colors.transparent,
      onTap: onTap,
      contentPadding: EdgeInsets.symmetric(
        horizontal: isExpanded ? 16 : 0,
        vertical: 4,
      ),
      dense: !isExpanded,
    );
  }
}
