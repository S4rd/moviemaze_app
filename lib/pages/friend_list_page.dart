// lib/pages/friend_list_page.dart
import 'package:flutter/material.dart';
import 'package:moviemaze_app/managers/friend_manager_firestore.dart';
import 'package:moviemaze_app/pages/friend_watchlist_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FriendListPage extends StatelessWidget {
  const FriendListPage({Key? key}) : super(key: key);

  void openFriendWatchlist(BuildContext context, String friendUid) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FriendWatchlistPage(friendUid: friendUid),
      ),
    );
  }

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("My Friends"),
        backgroundColor: Colors.black,
      ),
      body: StreamBuilder<List<String>>(
        stream: FriendManagerFirestore.getFriendsStream(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.red),
            );
          }

          final friendsUidList = snapshot.data!;
          if (friendsUidList.isEmpty) {
            return const Center(
              child: Text(
                "No friends yet.",
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          return ListView.builder(
            itemCount: friendsUidList.length,
            itemBuilder: (ctx, index) {
              final friendUid = friendsUidList[index];
              return FutureBuilder<String>(
                future: _fetchFriendNickname(friendUid),
                builder: (context, nicknameSnap) {
                  if (!nicknameSnap.hasData) {
                    return const ListTile(
                      title: Text("Loading...", style: TextStyle(color: Colors.white)),
                    );
                  }

                  final nickname = nicknameSnap.data!;
                  return Card(
                    color: Colors.grey[900],
                    child: ListTile(
                      title: Text("$nickname",
                          style: const TextStyle(color: Colors.white)),
                      subtitle: const Text(
                        "Tap to see watchlist",
                        style: TextStyle(color: Colors.white70),
                      ),
                      onTap: () => openFriendWatchlist(context, friendUid),
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
