import 'package:client_web/proposal.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ClientNotificationsPage extends StatefulWidget {
  const ClientNotificationsPage({super.key});

  @override
  State<ClientNotificationsPage> createState() =>
      _ClientNotificationsPageState();
}

class _ClientNotificationsPageState extends State<ClientNotificationsPage> {
  final supabase = Supabase.instance.client;

  List<Map<String, dynamic>> notifications = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchNotifications();
  }

  Future<void> fetchNotifications() async {
    final response = await supabase
        .from('tbl_workrequest')
        .select('workrequest_id, created_at, work_id, freelancer_id, is_read')
        .order('created_at', ascending: false);

    final data = response;

    List<Map<String, dynamic>> tempList = [];

    for (var item in data) {
      final freelancer = await supabase
          .from('tbl_freelancer')
          .select('freelancer_name')
          .eq('freelancer_id', item['freelancer_id'])
          .maybeSingle();

      final work = await supabase
          .from('tbl_work')
          .select('work_name')
          .eq('work_id', item['work_id'])
          .maybeSingle();

      tempList.add({
        "id": item['workrequest_id'],
        "title": freelancer?['freelancer_name'] ?? "Unknown Freelancer",
        "message": "Work Request: ${work?['work_name'] ?? 'Unknown Work'}",
        "time": _formatTimeAgo(item['created_at']),
        "isRead": item['is_read'] ?? false,
      });
    }

    setState(() {
      notifications = tempList;
      isLoading = false;
    });
  }

  String _formatTimeAgo(String createdAt) {
    final createdTime = DateTime.parse(createdAt);
    final now = DateTime.now();
    final diff = now.difference(createdTime);

    if (diff.inMinutes < 60) {
      return "${diff.inMinutes}m ago";
    } else if (diff.inHours < 24) {
      return "${diff.inHours}h ago";
    } else {
      return "${diff.inDays}d ago";
    }
  }

  void markAsRead(int index) async {
    final workRequestId = notifications[index]["id"];

    // Update in Supabase
    await supabase
        .from('tbl_workrequest')
        .update({'is_read': true}).eq('workrequest_id', workRequestId);

    // Update local state
    setState(() {
      notifications[index]["isRead"] = true;
    });

    // Navigate to Proposal Page
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProposalsPage(),
      ),
    );
  }

  void deleteNotification(int index) {
    setState(() {
      notifications.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Client Notifications"),
        backgroundColor: const Color(0xFF2E6F40),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            onPressed: () {
              setState(() {
                notifications.clear();
              });
            },
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : notifications.isEmpty
              ? const Center(
                  child: Text(
                    "No new notifications",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                )
              : ListView.builder(
                  itemCount: notifications.length,
                  itemBuilder: (context, index) {
                    final notification = notifications[index];
                    return Dismissible(
                      key: Key(notification["id"].toString()),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        color: Colors.red,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      onDismissed: (direction) => deleteNotification(index),
                      child: Card(
                        color: notification["isRead"]
                            ? Colors.white
                            : Colors.green.shade100,
                        child: ListTile(
                          title: Text(notification["title"],
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text(notification["message"]),
                          trailing: Text(notification["time"],
                              style: TextStyle(color: Colors.grey.shade600)),
                          onTap: () => markAsRead(index),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
