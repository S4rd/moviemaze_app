// lib/pages/add_friend_page.dart
import 'package:flutter/material.dart';
import 'package:moviemaze_app/managers/friend_manager_firestore.dart';

class AddFriendPage extends StatefulWidget {
  const AddFriendPage({Key? key}) : super(key: key);

  @override
  State<AddFriendPage> createState() => _AddFriendPageState();
}

class _AddFriendPageState extends State<AddFriendPage> {
  final TextEditingController _nicknameController = TextEditingController();
  List<Map<String, dynamic>> searchResults = [];
  bool isSearching = false;

  Future<void> handleSearch() async {
    final query = _nicknameController.text.trim();
    if (query.isEmpty) {
      setState(() {
        searchResults = [];
      });
      return;
    }

    setState(() {
      isSearching = true;
    });

    final results = await FriendManagerFirestore.searchUserByNickname(query);
    setState(() {
      searchResults = results;
      isSearching = false;
    });
  }

  Future<void> sendFriendRequest(String targetUid) async {
    await FriendManagerFirestore.sendFriendRequest(targetUid);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Friend request sent!")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Add Friend"),
        backgroundColor: Colors.black,
      ),
      body: Column(
        children: [
          // Search field
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _nicknameController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Enter nickname to search",
                hintStyle: const TextStyle(color: Colors.white54),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search, color: Colors.white),
                  onPressed: handleSearch,
                ),
                enabledBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white54),
                ),
                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.red),
                ),
              ),
            ),
          ),
          if (isSearching) const CircularProgressIndicator(color: Colors.red),
          Expanded(
            child: ListView.builder(
              itemCount: searchResults.length,
              itemBuilder: (ctx, index) {
                final user = searchResults[index];
                final uid = user['uid'];
                final nickname = user['nickname'];

                return ListTile(
                  title: Text(nickname, style: const TextStyle(color: Colors.white)),
                  trailing: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    onPressed: () => sendFriendRequest(uid),
                    child: const Text("Add"),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
