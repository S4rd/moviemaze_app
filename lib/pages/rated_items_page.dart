// lib/pages/rated_items_page.dart
import 'package:flutter/material.dart';
import 'package:moviemaze_app/managers/rating_manager_firestore.dart';

class RatedItemsPage extends StatelessWidget {
  const RatedItemsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          "My Rated Items",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: ValueListenableBuilder<List<Map<String, dynamic>>>(
        valueListenable: RatingManagerFirestore.ratingsNotifier,
        builder: (context, ratedItems, _) {
          if (ratedItems.isEmpty) {
            return const Center(
              child: Text(
                "No rated items yet.",
                style: TextStyle(color: Colors.white),
              ),
            );
          }
          return ListView.builder(
            itemCount: ratedItems.length,
            itemBuilder: (context, index) {
              final item = ratedItems[index];
              final title = item['title'] ?? 'No title';
              final posterPath = item['poster_path'];
              final mediaType = item['mediaType'] ?? 'movie';
              final userRating = (item['rating'] ?? 0.0).toStringAsFixed(1);

              return Card(
                color: Colors.grey[800],
                margin: const EdgeInsets.all(8.0),
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
                    "${mediaType.toUpperCase()} • Rating: $userRating / 10",
                    style: const TextStyle(color: Colors.white70),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
