// lib/pages/profile_page.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'movie_detail_page.dart';
import 'rated_items_page.dart';
import 'package:moviemaze_app/managers/watchlist_manager_firestore.dart';
import 'package:moviemaze_app/managers/rating_manager_firestore.dart';

// NEW imports:
import 'package:moviemaze_app/pages/add_friend_page.dart';
import 'package:moviemaze_app/pages/friend_requests_page.dart';
import 'package:moviemaze_app/pages/friend_list_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String _nickname = "Loading...";

  @override
  void initState() {
    super.initState();
    _loadNickname();
  }

  Future<void> _loadNickname() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final docSnap = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    if (docSnap.exists) {
      setState(() {
        _nickname = docSnap.data()?['nickname'] ?? "No Nickname";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        // Leading icon can remain the same if you want
        leading: IconButton(
          icon: const Icon(Icons.person_outline),
          onPressed: () {},
        ),
        // Instead of "Şamil", we use _nickname
        title: Text(
          _nickname,
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // The row with the 'Ratings' card remains the same...
            Row(
              children: [
                // Ratings Card
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      // Navigate to the RatedItemsPage
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const RatedItemsPage()),
                      );
                    },
                    child: Card(
                      color: Colors.grey[850],
                      margin: const EdgeInsets.only(right: 8.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: SizedBox(
                        height: 120,
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: ValueListenableBuilder<
                              List<Map<String, dynamic>>>(
                            valueListenable:
                            RatingManagerFirestore.ratingsNotifier,
                            builder: (context, ratedItems, _) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Rate a show or a movie',
                                    style:
                                    TextStyle(color: Colors.red, fontSize: 14),
                                  ),
                                  const Spacer(),
                                  Text(
                                    'Ratings\n${ratedItems.length}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Buttons row for Add Friend, Friend Requests, My Friends
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const AddFriendPage()),
                      );
                    },
                    child: const Text("Add Friend"),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const FriendRequestsPage()),
                      );
                    },
                    child: const Text("Friend Requests"),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const FriendListPage()),
                      );
                    },
                    child: const Text("My Friends"),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),
            const Text(
              'Your Watchlist',
              style: TextStyle(
                color: Colors.red,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            ValueListenableBuilder<List<Map<String, dynamic>>>(
              valueListenable: WatchlistManagerFirestore.watchlistNotifier,
              builder: (context, watchlistItems, _) {
                if (watchlistItems.isEmpty) {
                  return const Text(
                    'No items in your watchlist yet.',
                    style: TextStyle(color: Colors.white, fontSize: 14),
                  );
                }
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: watchlistItems.length,
                  itemBuilder: (context, index) {
                    final item = watchlistItems[index];
                    final title = item['title'] ?? 'No title';
                    final posterPath = item['poster_path'];
                    final mediaType = item['mediaType'] ?? 'movie';
                    final userRating =
                    RatingManagerFirestore.getRating(item['id']);

                    return Card(
                      color: Colors.grey[800],
                      margin: const EdgeInsets.symmetric(vertical: 4.0),
                      child: ListTile(
                        onTap: () {
                          // Navigate to detail
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MovieDetailPage(
                                mediaId: item['id'],
                                mediaType: mediaType,
                              ),
                            ),
                          );
                        },
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
                          "${mediaType.toUpperCase()} • Rating: ${userRating.toStringAsFixed(1)} / 10",
                          style: const TextStyle(color: Colors.white70),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            WatchlistManagerFirestore.removeFromWatchlist(
                                item['id']);
                          },
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
