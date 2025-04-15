import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;

class ActivityItem extends StatelessWidget {
  final String title;
  final String description;
  final DateTime timestamp;
  final IconData icon;
  final Color iconColor;

  const ActivityItem({
    super.key,
    required this.title,
    required this.description,
    required this.timestamp,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: iconColor.withOpacity(0.1),
        child: Icon(icon, color: iconColor),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Text(description),
      trailing: Text(
        timeago.format(timestamp),
        style: TextStyle(
          color: Colors.grey.shade600,
          fontSize: 12,
        ),
      ),
    );
  }
}
