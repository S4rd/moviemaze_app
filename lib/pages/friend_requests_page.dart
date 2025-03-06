import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:moviemaze_app/managers/friend_manager_firestore.dart';

class FriendRequestsPage extends StatelessWidget {
  const FriendRequestsPage({Key? key}) : super(key: key);

  Future<String> _fetchFriendNickname(String friendUid) async {
    final docSnap = await FirebaseFirestore.instance
        .collection('users')
        .doc(friendUid)
        .get();
    if (docSnap.exists) {
      return docSnap.data()?['nickname'] ?? "No Nickname";
    }
    return "Unknown User";
  }

  Future<void> acceptRequest(String senderUid) async {
    await FriendManagerFirestore.acceptFriendRequest(senderUid);
  }

  Future<void> rejectRequest(String senderUid) async {
    await FriendManagerFirestore.rejectFriendRequest(senderUid);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Incoming Friend Requests"),
        backgroundColor: Colors.black,
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: FriendManagerFirestore.getIncomingRequestsStream(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.red),
            );
          }

          final requests = snapshot.data!;
          if (requests.isEmpty) {
            return const Center(
              child: Text(
                "No incoming requests.",
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          return ListView.builder(
            itemCount: requests.length,
            itemBuilder: (ctx, index) {
              final request = requests[index];
              final senderUid = request['senderUid'];

              return FutureBuilder<String>(
                future: _fetchFriendNickname(senderUid),
                builder: (context, nicknameSnapshot) {
                  if (!nicknameSnapshot.hasData) {
                    return const ListTile(
                      title: Text(
                        "Loading...",
                        style: TextStyle(color: Colors.white),
                      ),
                    );
                  }

                  final nickname = nicknameSnapshot.data!;
                  return Card(
                    color: Colors.grey[900],
                    child: ListTile(
                      title: Text(
                        "From: $nickname",
                        style: const TextStyle(color: Colors.white),
                      ),
                      subtitle: const Text(
                        "Friend request is pending",
                        style: TextStyle(color: Colors.white70),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.check, color: Colors.green),
                            onPressed: () => acceptRequest(senderUid),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.red),
                            onPressed: () => rejectRequest(senderUid),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
