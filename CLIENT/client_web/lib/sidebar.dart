// sidebar.dart
import 'package:flutter/material.dart';

class SidebarItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool isSelected;
  final bool isExpanded;
  final VoidCallback onTap;
  final int? badgeCount;

  const SidebarItem({
    super.key,
    required this.icon,
    required this.title,
    required this.isSelected,
    required this.isExpanded,
    required this.onTap,
    this.badgeCount,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? Colors.white : Colors.grey[600],
      ),
      title: isExpanded
          ? Text(
              title,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey[600],
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            )
          : null,
      trailing: badgeCount != null && badgeCount! > 0 && isExpanded
          ? CircleAvatar(
              radius: 10,
              backgroundColor: Colors.red,
              child: Text(
                badgeCount.toString(),
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            )
          : null,
      tileColor: isSelected ? Colors.blue : null,
      onTap: onTap,
    );
  }
}
