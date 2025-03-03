import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:saksi/services/firestore_services.dart';

class Chat extends StatefulWidget {
  final String roomId;
  final String adminName;

  const Chat({super.key, required this.roomId, required this.adminName});

  @override
  State<Chat> createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  final TextEditingController _messageController = TextEditingController();
  final DatabaseService _dbService = DatabaseService();

  Future<List<QueryDocumentSnapshot>> _readMessages() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection("chatRooms")
          .doc(widget.roomId)
          .collection("messages")
          .orderBy("time", descending: true)
          .get();
      return querySnapshot.docs;
    } catch (e) {
      print("Error fetching messages: $e");
      return [];
    }
  }

  Future<void> _sendMessage(String message) async {
    try {
      if (message.isNotEmpty) {
        await FirebaseFirestore.instance
            .collection("chatRooms")
            .doc(widget.roomId)
            .collection("messages")
            .add({
          "message": message,
          "sender": widget.adminName,
          "time": FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      print("Error sending message: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Chat with ${widget.adminName}"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            // Chat messages list
            Expanded(
              child: FutureBuilder<List<QueryDocumentSnapshot>>(
                future: _readMessages(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('No messages available'));
                  }
                  return ListView.builder(
                    reverse: true, // Start from the latest message
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      var chatData = snapshot.data![index].data() as Map<String, dynamic>;
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.blueAccent,
                            child: const Icon(Icons.person, color: Colors.white),
                          ),
                          title: Text(chatData['message']),
                          subtitle: Text(
                            chatData['time'] != null
                                ? DateFormat('dd/MM/yyyy HH:mm').format(
                              (chatData['time'] as Timestamp).toDate(),
                            )
                                : 'No timestamp',
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            const Divider(height: 1, color: Colors.grey),
            // Message input and send button
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        labelText: 'Type a message...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () async {
                      String message = _messageController.text.trim();
                      if (message.isNotEmpty) {
                        await _sendMessage(message);
                        _messageController.clear();
                        setState(() {}); // Reload chat messages
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(16.0),
                      shape: const CircleBorder(),
                    ),
                    child: const Icon(Icons.send, color: Colors.white),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
