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

  @override
  void initState() {
    super.initState();
    _initializeChat();
  }

  Future<void> _initializeChat() async {
    await fetchMessages();
    listenForMessages();
  }

  Future<void> fetchMessages() async {
    try {
      final response = await supabase
          .from('tbl_chat')
          .select()
          .match({
            'fromfreelancer_id': widget.freelancerId,
            'toclient_id': widget.clientId,
          })
          .or(
            'fromclient_id.eq.${widget.clientId},tofreelancer_id.eq.${widget.freelancerId}',
          )
          .order('created_at', ascending: true);

      if (mounted) {
        setState(() {
          messages =
              response.map((msg) => Map<String, dynamic>.from(msg)).toList();
          isLoading = false;
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
                return (message['fromfreelancer_id'] == widget.freelancerId &&
                        message['toclient_id'] == widget.clientId) ||
                    (message['fromclient_id'] == widget.clientId &&
                        message['tofreelancer_id'] == widget.freelancerId);
              }).toList();

              for (var message in filteredMessages) {
                if (!messages
                    .any((msg) => msg['chat_id'] == message['chat_id'])) {
                  messages.add(Map<String, dynamic>.from(message));
                }
              }
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

  Future<void> sendMessage() async {
    final messageText = _messageController.text.trim();
    if (messageText.isEmpty) return;

    try {
      await supabase.from('tbl_chat').insert({
        'fromfreelancer_id': widget.freelancerId,
        'fromclient_id': null,
        'toclient_id': widget.clientId,
        'tofreelancer_id': null,
        'chat_content': messageText,
      });
      _messageController.clear();
    } catch (e) {
      print('Error sending message: $e');
      if (mounted) {
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
          'Chat with Client',
          style: GoogleFonts.poppins(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF2E7D32),
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : messages.isEmpty
                    ? const Center(child: Text('No messages yet'))
                    : ListView.builder(
                        reverse: false,
                        itemCount: messages.length,
                        itemBuilder: (context, index) {
                          final message = messages[index];
                          final isMe = message['fromfreelancer_id'] ==
                              widget.freelancerId;

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
