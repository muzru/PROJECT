import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Chat extends StatefulWidget {
  final String freelancerId;
  final String clientId;

  const Chat({
    super.key,
    required this.freelancerId,
    required this.clientId,
  });

  @override
  State<Chat> createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  final SupabaseClient supabase = Supabase.instance.client;
  final TextEditingController _messageController = TextEditingController();
  List<Map<String, dynamic>> messages = [];
  bool isLoading = true;
  Timer? _timer;
  DateTime? _lastMessageTime;

  @override
  void initState() {
    super.initState();
    _initializeChat();
  }

  @override
  void dispose() {
    _timer?.cancel(); // Cancel the timer when the widget is disposed
    super.dispose();
  }

  Future<void> _initializeChat() async {
    await fetchMessages();
    listenForMessages();
    _startPeriodicCheck(); // Start the periodic check
  }

  Future<void> fetchMessages() async {
    try {
      final response = await supabase
          .from('tbl_chat')
          .select()
          .match({
            'fromclient_id': widget.clientId,
            'tofreelancer_id': widget.freelancerId,
          })
          .or(
            'fromfreelancer_id.eq.${widget.freelancerId},toclient_id.eq.${widget.clientId}',
          )
          .order('created_at', ascending: true); // Add execute to get the data

      if (mounted) {
        setState(() {
          // Access response.data and cast it
          messages = (response as List<dynamic>?)
                  ?.map((msg) => Map<String, dynamic>.from(msg))
                  .toList() ??
              [];
          isLoading = false;
          _lastMessageTime = messages.isNotEmpty
              ? DateTime.parse(messages.last['created_at'])
              : null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
        print('Error fetching messages: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load messages: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void listenForMessages() {
    supabase
        .from('tbl_chat')
        .stream(primaryKey: ['chat_id'])
        .order('created_at', ascending: true)
        .listen((snapshot) {
          print('🔄 New snapshot received: $snapshot');
          if (mounted) {
            setState(() {
              final filteredMessages = snapshot.where((message) {
                return (message['fromclient_id'] == widget.clientId &&
                        message['tofreelancer_id'] == widget.freelancerId) ||
                    (message['fromfreelancer_id'] == widget.freelancerId &&
                        message['toclient_id'] == widget.clientId);
              }).toList();

              // Update messages with new or modified entries
              for (var message in filteredMessages) {
                final existingIndex = messages
                    .indexWhere((msg) => msg['chat_id'] == message['chat_id']);
                if (existingIndex == -1) {
                  messages.add(Map<String, dynamic>.from(message));
                } else {
                  messages[existingIndex] = Map<String, dynamic>.from(message);
                }
              }
              // Sort messages by created_at
              messages.sort((a, b) => DateTime.parse(a['created_at'])
                  .compareTo(DateTime.parse(b['created_at'])));
              _lastMessageTime = messages.isNotEmpty
                  ? DateTime.parse(messages.last['created_at'])
                  : null;
            });
          }
        })
        .onError((error) {
          print('Stream error: $error');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Stream error: $error'),
                backgroundColor: Colors.red,
              ),
            );
          }
        });
  }

  void _startPeriodicCheck() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      await _checkForNewMessages();
    });
  }

  Future<void> _checkForNewMessages() async {
    try {
      final response = await supabase
          .from('tbl_chat')
          .select()
          .match({
            'fromclient_id': widget.clientId,
            'tofreelancer_id': widget.freelancerId,
          })
          .or(
            'fromfreelancer_id.eq.${widget.freelancerId},toclient_id.eq.${widget.clientId}',
          )
          .gte(
              'created_at',
              _lastMessageTime?.toIso8601String() ??
                  DateTime(1970).toIso8601String())
          .order('created_at', ascending: true);
      ; // Add execute to get the data

      final newMessages = (response as List<dynamic>?)
              ?.map((msg) => Map<String, dynamic>.from(msg))
              .toList() ??
          [];

      if (newMessages.isNotEmpty && mounted) {
        setState(() {
          // Filter for messages from the opposite side
          final oppositeMessages = newMessages.where((message) {
            return (message['fromclient_id'] != widget.clientId &&
                    message['tofreelancer_id'] == widget.freelancerId) ||
                (message['fromfreelancer_id'] != widget.freelancerId &&
                    message['toclient_id'] == widget.clientId);
          }).toList();

          if (oppositeMessages.isNotEmpty) {
            messages.addAll(oppositeMessages);
            messages.sort((a, b) => DateTime.parse(a['created_at'])
                .compareTo(DateTime.parse(b['created_at'])));
            _lastMessageTime = DateTime.parse(messages.last['created_at']);
            // Optionally show a notification or scroll to the new message
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('New message from the other side!'),
                backgroundColor: Colors.green,
              ),
            );
          }
        });
      }
    } catch (e) {
      print('Error checking for new messages: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error checking messages: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> sendMessage() async {
    final messageText = _messageController.text.trim();
    if (messageText.isEmpty) return;

    try {
      // Optimistically add the message to the UI
      final newMessage = {
        'fromclient_id': widget.clientId,
        'toclient_id': null,
        'tofreelancer_id': widget.freelancerId,
        'fromfreelancer_id': null,
        'chat_content': messageText,
        'created_at': DateTime.now().toIso8601String(),
        'chat_id': -1, // Temporary placeholder
      };
      setState(() {
        messages.add(newMessage);
        messages.sort((a, b) => DateTime.parse(a['created_at'])
            .compareTo(DateTime.parse(b['created_at'])));
      });

      // Send the message to Supabase
      final response = await supabase.from('tbl_chat').insert({
        'fromclient_id': widget.clientId,
        'toclient_id': null,
        'tofreelancer_id': widget.freelancerId,
        'fromfreelancer_id': null,
        'chat_content': messageText,
      }).select();

      if (mounted) {
        setState(() {
          // Replace the temporary message with the server response
          final sentMessage =
              (response as List<dynamic>)[0] as Map<String, dynamic>;
          final index = messages.indexWhere((msg) => msg['chat_id'] == -1);
          if (index != -1) {
            messages[index] = sentMessage;
          }
        });
      }

      _messageController.clear();
    } catch (e) {
      print('Error sending message: $e');
      if (mounted) {
        setState(() {
          // Remove the optimistic message on failure
          messages.removeWhere((msg) => msg['chat_id'] == -1);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send message: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 2,
        title: Text(
          'Chat with Freelancer',
          style: GoogleFonts.poppins(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF2E7D32),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.blue),
            onPressed: fetchMessages, // Manual reload
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : messages.isEmpty
                    ? const Center(child: Text('No messages yet'))
                    : ListView.builder(
                        // Removed reverse: true to display from top to bottom
                        itemCount: messages.length,
                        itemBuilder: (context, index) {
                          final message = messages[index];
                          final isMe =
                              message['fromclient_id'] == widget.clientId;

                          return Align(
                            alignment: isMe
                                ? Alignment.centerRight
                                : Alignment.centerLeft,
                            child: Container(
                              margin: const EdgeInsets.symmetric(
                                  vertical: 5, horizontal: 10),
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color:
                                    isMe ? Colors.blueAccent : Colors.grey[300],
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                message['chat_content'] ?? '',
                                style: TextStyle(
                                    color: isMe ? Colors.white : Colors.black),
                              ),
                            ),
                          );
                        },
                      ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: "Type a message...",
                      border: const OutlineInputBorder(),
                      hintStyle: GoogleFonts.poppins(),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.blue),
                  onPressed: sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
