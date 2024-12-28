import 'package:flutter/material.dart';
import 'package:moviemaze_app/services/api_service.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class MovieDetailPage extends StatefulWidget {
  final int mediaId;       // can be movieId or seriesId
  final String mediaType;  // "movie" or "tv"

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
      // If it's a TV series
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
    // For a movie, we usually have "title" and "release_date"
    // For a TV series, we have "name" and "first_air_date"
    final String nameOrTitle = widget.mediaType == "movie"
        ? (details?["title"] ?? "No title")
        : (details?["name"] ?? "No name");

    final String dateOrAirDate = widget.mediaType == "movie"
        ? (details?["release_date"] ?? "N/A")
        : (details?["first_air_date"] ?? "N/A");

    // This is the "vote_average"
    final double rating = (details?["vote_average"] ?? 0).toDouble();

    final String overview = details?["overview"] ?? "No description";
    final posterPath = details?["poster_path"];
    final posterUrl = posterPath != null
        ? "https://image.tmdb.org/t/p/w400$posterPath"
        : null;

    // For both movie and TV series, "genres" is typically a list of objects with "name"
    final genres = details?["genres"] as List<dynamic>? ?? [];
    final genreNames = genres.map((g) => g["name"]).join(", ");

    return Scaffold(
      appBar: AppBar(
        title: Text(nameOrTitle),
        backgroundColor: Colors.black,
      ),
      backgroundColor: Colors.black,
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

            // Rating
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                "IMDb: ${rating.toStringAsFixed(1)}",
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

            // Overview / Description
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                overview,
                style: const TextStyle(color: Colors.white70),
              ),
            ),
            const SizedBox(height: 16),

            // Trailer Section
            if (trailerKey != null) buildTrailerSection(),
            const SizedBox(height: 16),

            // Reviews Section
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
}
