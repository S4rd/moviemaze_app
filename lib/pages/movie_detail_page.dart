// lib/pages/movie_detail_page.dart
import 'package:flutter/material.dart';
import 'package:moviemaze_app/services/api_service.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:moviemaze_app/managers/watchlist_manager_firestore.dart';
import 'package:moviemaze_app/managers/rating_manager_firestore.dart';

class MovieDetailPage extends StatefulWidget {
  final int mediaId;      // can be movieId or seriesId
  final String mediaType; // "movie" or "tv"

  const MovieDetailPage({
    Key? key,
    required this.mediaId,
    required this.mediaType,
  }) : super(key: key);

  @override
  State<MovieDetailPage> createState() => _MovieDetailPageState();
}

class _MovieDetailPageState extends State<MovieDetailPage> {
  final ApiService apiService = ApiService();

  Map<String, dynamic>? details;
  List<Map<String, dynamic>> reviews = [];
  String? trailerKey;
  late YoutubePlayerController _youtubeController;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    try {
      if (widget.mediaType == "movie") {
        final movieDetails = await apiService.fetchMovieDetails(widget.mediaId);
        final fetchedReviews = await apiService.fetchMovieReviews(widget.mediaId);
        final tKey = await apiService.fetchMovieTrailerKey(widget.mediaId);

        setState(() {
          details = movieDetails;
          reviews = fetchedReviews;
          trailerKey = tKey;
          isLoading = false;
        });
      } else {
        final seriesDetails = await apiService.fetchSeriesDetails(widget.mediaId);
        final fetchedReviews = await apiService.fetchSeriesReviews(widget.mediaId);
        final tKey = await apiService.fetchSeriesTrailerKey(widget.mediaId);

        setState(() {
          details = seriesDetails;
          reviews = fetchedReviews;
          trailerKey = tKey;
          isLoading = false;
        });
      }

      if (trailerKey != null) {
        _youtubeController = YoutubePlayerController(
          initialVideoId: trailerKey!,
          flags: const YoutubePlayerFlags(autoPlay: false),
        );
      }
    } catch (e) {
      debugPrint("Error loading data: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    if (trailerKey != null) {
      _youtubeController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final String nameOrTitle = widget.mediaType == "movie"
        ? (details?["title"] ?? "No title")
        : (details?["name"] ?? "No name");

    final String dateOrAirDate = widget.mediaType == "movie"
        ? (details?["release_date"] ?? "N/A")
        : (details?["first_air_date"] ?? "N/A");

    final double apiRating = (details?["vote_average"] ?? 0).toDouble();
    final String overview = details?["overview"] ?? "No description";
    final posterPath = details?["poster_path"];
    final posterUrl = (posterPath != null)
        ? "https://image.tmdb.org/t/p/w400$posterPath"
        : null;

    final genres = details?["genres"] as List<dynamic>? ?? [];
    final genreNames = genres.map((g) => g["name"]).join(", ");

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(nameOrTitle),
        backgroundColor: Colors.black,
      ),
      body: isLoading
          ? const Center(
        child: CircularProgressIndicator(color: Colors.deepOrange),
      )
          : SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Poster
            if (posterUrl != null)
              Image.network(posterUrl, fit: BoxFit.cover),
            const SizedBox(height: 16),

            // Title & Date
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                "$nameOrTitle ($dateOrAirDate)",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            // IMDb rating
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                "IMDb: ${apiRating.toStringAsFixed(1)}",
                style: const TextStyle(
                  color: Colors.deepOrange,
                  fontSize: 16,
                ),
              ),
            ),

            // Genres
            if (genreNames.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  "Genres: $genreNames",
                  style: const TextStyle(color: Colors.white70),
                ),
              ),
            const SizedBox(height: 16),

            // Overview
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                overview,
                style: const TextStyle(color: Colors.white70),
              ),
            ),
            const SizedBox(height: 16),

            // Add to Watchlist
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ElevatedButton.icon(
                icon: const Icon(Icons.add),
                label: const Text("Add to Watchlist"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.black,
                  textStyle: const TextStyle(fontWeight: FontWeight.bold),
                ),
                onPressed: () async {
                  final item = {
                    'id': widget.mediaId,
                    'mediaType': widget.mediaType,
                    'title': nameOrTitle,
                    'poster_path': posterPath,
                  };
                  await WatchlistManagerFirestore.addToWatchlist(item);

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('$nameOrTitle added to watchlist'),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),

            // Rate This
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ElevatedButton.icon(
                icon: const Icon(Icons.star),
                label: const Text("Rate This"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.black,
                  textStyle: const TextStyle(fontWeight: FontWeight.bold),
                ),
                onPressed: () async {
                  final newRating = await showRatingDialog(
                    context,
                    mediaId: widget.mediaId,
                    mediaType: widget.mediaType,
                    title: nameOrTitle,
                    posterPath: posterPath,
                  );
                  if (newRating != null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("You rated it $newRating / 10"),
                      ),
                    );
                  }
                },
              ),
            ),
            const SizedBox(height: 16),

            // Trailer
            if (trailerKey != null) buildTrailerSection(),
            const SizedBox(height: 16),

            // Reviews
            buildReviewSection(),
          ],
        ),
      ),
    );
  }

  Widget buildTrailerSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            "Trailer",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 8),
        YoutubePlayerBuilder(
          player: YoutubePlayer(controller: _youtubeController),
          builder: (context, player) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: player,
            );
          },
        ),
      ],
    );
  }

  Widget buildReviewSection() {
    if (reviews.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Text(
          "No reviews found.",
          style: TextStyle(color: Colors.white70),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            "Reviews",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: reviews.length,
          itemBuilder: (context, index) {
            final review = reviews[index];
            final author = review["author"] ?? "Anonymous";
            final content = review["content"] ?? "";
            return ListTile(
              title: Text(
                author,
                style: const TextStyle(color: Colors.deepOrange),
              ),
              subtitle: Text(
                content,
                style: const TextStyle(color: Colors.white70),
              ),
            );
          },
        ),
      ],
    );
  }

  // Show a rating dialog, then call RatingManagerFirestore.setRating(...).
  Future<double?> showRatingDialog(
      BuildContext context, {
        required int mediaId,
        required String mediaType,
        required String title,
        required String? posterPath,
      }) async {
    double localRating = RatingManagerFirestore.getRating(mediaId) != 0
        ? RatingManagerFirestore.getRating(mediaId)
        : 5.0;

    return showDialog<double>(
      context: context,
      builder: (dialogCtx) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          title: Text("Rate $title", style: const TextStyle(color: Colors.white)),
          content: StatefulBuilder(
            builder: (ctx, setStateDialog) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "${localRating.toStringAsFixed(1)} / 10",
                    style: const TextStyle(color: Colors.white),
                  ),
                  Slider(
                    value: localRating,
                    min: 0,
                    max: 10,
                    divisions: 10,
                    label: localRating.toStringAsFixed(1),
                    activeColor: Colors.red,
                    onChanged: (val) {
                      setStateDialog(() {
                        localRating = val;
                      });
                    },
                  ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              child: const Text("CANCEL", style: TextStyle(color: Colors.white)),
              onPressed: () => Navigator.pop(dialogCtx, null),
            ),
            TextButton(
              child: const Text("OK", style: TextStyle(color: Colors.red)),
              onPressed: () {
                RatingManagerFirestore.setRating(
                  mediaId,
                  mediaType,
                  localRating,
                  title,
                  posterPath,
                );
                Navigator.pop(dialogCtx, localRating);
              },
            ),
          ],
        );
      },
    );
  }
}
