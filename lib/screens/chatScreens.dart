import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:saksi/components/chat.dart';

class Chatscreens extends StatefulWidget {
  const Chatscreens({super.key});

  @override
  State<Chatscreens> createState() => _ChatscreensState();
}

class _ChatscreensState extends State<Chatscreens> {
  String? username;
  String? email;
  int? status;

  // Load user data from SharedPreferences
  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      email = prefs.getString('email');
      status = prefs.getInt('userStatus');
    });
  }

  Future<List<QueryDocumentSnapshot>> readActiveAdmins() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection("users")
          .where("status", isEqualTo: 1) // Fetch only admins
          .get();
      return querySnapshot.docs;
    } catch (e) {
      print("Error: $e");
      return [];
    }
  }

  String generateChatRoomId(String user1, String user2) {
    if (user1.compareTo(user2) > 0) {
      return "$user1$user2";
    } else {
      return "$user2$user1";
    }
  }

  Future<void> createChatRoom(String adminName, String adminUid) async {
    try {
      if (email == null || status != 2) {
        print(email);
        throw Exception("User not logged in or not authorized");
      }

      String roomId = generateChatRoomId(email!, adminUid);

      DocumentReference chatRoomRef =
      FirebaseFirestore.instance.collection("chatRooms").doc(roomId);

      DocumentSnapshot chatRoomSnapshot = await chatRoomRef.get();

      if (!chatRoomSnapshot.exists) {
        await chatRoomRef.set({
          "roomId": roomId,
          "users": [email, adminUid],
          "userNames": [username, adminName],
          "createdAt": FieldValue.serverTimestamp(),
        });
      }

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Chat(
            roomId: roomId,
            adminName: adminName,
          ),
        ),
      );
    } catch (e) {
      print("Error creating chat room: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Pilih Admin"),
        centerTitle: true,
      ),
      body: FutureBuilder<List<QueryDocumentSnapshot>>(
        future: readActiveAdmins(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("Tidak ada admin tersedia"));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              var adminData = snapshot.data![index].data() as Map<String, dynamic>;
              String adminName = adminData['name'];
              String adminUid = adminData['email'];

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                elevation: 4.0,
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.blueAccent,
                    child: Text(
                      adminName[0].toUpperCase(),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  title: Text(adminName),
                  subtitle: Text(adminData['email']),
                  trailing: const Icon(Icons.chat, color: Colors.green),
                  onTap: () => createChatRoom(adminName, adminUid),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
