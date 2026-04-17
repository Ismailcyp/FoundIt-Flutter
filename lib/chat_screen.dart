import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatScreen extends StatefulWidget {
  final String otherUserId; // Changed from sellerId so it works for both!
  final String itemTitle;

  const ChatScreen({super.key, required this.otherUserId, required this.itemTitle});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _msgController = TextEditingController();
  final String currentUserId = FirebaseAuth.instance.currentUser!.uid;
  late String chatRoomId;

  // App Colors
  final Color _bgColor = const Color.fromARGB(255, 38, 2, 58);
  final Color _cardColor = const Color(0xFF1B1B28);
  final Color _primaryPurple = const Color(0xFF6E56FF);

  @override
  void initState() {
    super.initState();
    // Create a unique, consistent room ID for these two users
    chatRoomId = getChatRoomId(currentUserId, widget.otherUserId);
  }

  String getChatRoomId(String user1, String user2) {
    if (user1.compareTo(user2) > 0) {
      return "${user1}_$user2";
    } else {
      return "${user2}_$user1";
    }
  }

  void _sendMessage() async {
    if (_msgController.text.trim().isEmpty) return;

    final String messageText = _msgController.text.trim();
    _msgController.clear(); 

    final messageData = {
      "senderId": currentUserId,
      "receiverId": widget.otherUserId,
      "message": messageText,
      "timestamp": FieldValue.serverTimestamp(),
    };

    // 1. Add message
    await FirebaseFirestore.instance
        .collection('chats')
        .doc(chatRoomId)
        .collection('messages')
        .add(messageData);

    // 2. Update the main chat document for the Inbox
    await FirebaseFirestore.instance.collection('chats').doc(chatRoomId).set({
      "users": [currentUserId, widget.otherUserId],
      "lastMessage": messageText,
      "lastUpdated": FieldValue.serverTimestamp(),
      "itemTitle": widget.itemTitle,
    }, SetOptions(merge: true));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      appBar: AppBar(
        backgroundColor: _cardColor,
        elevation: 0,
        // --- NEW: FETCH OTHER USER'S DATA ---
        title: FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance.collection('users').doc(widget.otherUserId).get(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Text("Loading...", style: TextStyle(fontSize: 16));
            }

            // Extract data safely
            var userData = snapshot.data?.data() as Map<String, dynamic>?;
            String name = userData?['name'] ?? 'Unknown User';
            String phone = userData?['phone'] ?? 'No phone number';

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 2),
                Text(
                  '$phone  •  ${widget.itemTitle}', 
                  style: const TextStyle(fontSize: 12, color: Colors.white70, fontWeight: FontWeight.normal)
                ),
              ],
            );
          },
        ),
      ),
      body: Column(
        children: [
          // 1. The Chat Messages Stream
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('chats')
                  .doc(chatRoomId)
                  .collection('messages')
                  .orderBy('timestamp', descending: true) 
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator(color: _primaryPurple));
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text("Send a message to start the chat!", style: TextStyle(color: Colors.white54)),
                  );
                }

                return ListView.builder(
                  reverse: true, 
                  padding: const EdgeInsets.all(16),
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    var message = snapshot.data!.docs[index].data() as Map<String, dynamic>;
                    bool isMe = message['senderId'] == currentUserId;
                    return _buildMessageBubble(message['message'], isMe);
                  },
                );
              },
            ),
          ),

          // 2. The Input Area
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(color: _cardColor),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _msgController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: "Type a message...",
                        hintStyle: const TextStyle(color: Colors.white54),
                        filled: true,
                        fillColor: _bgColor,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: _sendMessage,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: _primaryPurple, shape: BoxShape.circle),
                      child: const Icon(Icons.send, color: Colors.white, size: 20),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(String text, bool isMe) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isMe ? _primaryPurple : _bgColor,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: isMe ? const Radius.circular(16) : const Radius.circular(0),
            bottomRight: isMe ? const Radius.circular(0) : const Radius.circular(16),
          ),
          border: isMe ? null : Border.all(color: Colors.white12),
        ),
        child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 15)),
      ),
    );
  }
}