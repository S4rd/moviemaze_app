// lib/pages/friend_watchlist_page.dart

import 'package:flutter/material.dart';
import 'package:moviemaze_app/managers/friend_manager_firestore.dart';
import 'package:moviemaze_app/managers/watchlist_manager_firestore.dart';

class FriendWatchlistPage extends StatefulWidget {
  final String friendUid;

  const FriendWatchlistPage({Key? key, required this.friendUid})
      : super(key: key);

  @override
  State<FriendWatchlistPage> createState() => _FriendWatchlistPageState();
}

class _FriendWatchlistPageState extends State<FriendWatchlistPage> {
  bool isFriend = false;
  bool isLoading = true;
  List<Map<String, dynamic>> friendWatchlist = [];

  @override
  void initState() {
    super.initState();
    checkFriendStatus();
  }

  Future<void> checkFriendStatus() async {
    final friendStatus =
    await FriendManagerFirestore.isFriend(widget.friendUid);
    if (friendStatus) {
      // If we are friends, fetch the watchlist
      final watchlist = await WatchlistManagerFirestore.getUserWatchlistOnce(
        widget.friendUid,
      );
      setState(() {
        isFriend = true;
        friendWatchlist = watchlist;
        isLoading = false;
      });
    } else {
      // Not friend
      setState(() {
        isFriend = false;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Friend's Watchlist"),
        backgroundColor: Colors.black,
      ),
      body: isLoading
          ? const Center(
        child: CircularProgressIndicator(color: Colors.red),
      )
          : isFriend
      // If friend
          ? friendWatchlist.isEmpty
      // Watchlist is empty
          ? const Center(
        child: Text(
          "No items in your friend's watchlist.",
          style: TextStyle(color: Colors.white),
        ),
      )
      // Watchlist has items -> show them
          : ListView.builder(
        itemCount: friendWatchlist.length,
        itemBuilder: (ctx, index) {
          final item = friendWatchlist[index];
          final title = item['title'] ?? 'No title';
          final posterPath = item['poster_path'];
          final mediaType = item['mediaType'] ?? 'movie';

          return Card(
            color: Colors.grey[800],
            margin: const EdgeInsets.symmetric(vertical: 4.0),
            child: ListTile(
              leading: posterPath != null
                  ? Image.network(
                "https://image.tmdb.org/t/p/w200$posterPath",
                width: 50,
                fit: BoxFit.cover,
              )
                  : const SizedBox(width: 50),
              title: Text(
                title,
                style: const TextStyle(color: Colors.white),
              ),
              subtitle: Text(
                mediaType.toUpperCase(),
                style: const TextStyle(color: Colors.white70),
              ),
            ),
          );
        },
      )
      // If NOT friend
          : const Center(
        child: Text(
          "You are not friends with this user yet.",
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
