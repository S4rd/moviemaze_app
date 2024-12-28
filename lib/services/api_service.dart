import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {

  final String apiKey = "315ea114bf4635a2938996f768997e05";
  final String baseUrl = "https://api.themoviedb.org/3";

  /// Fetches popular movies (page 1).
  Future<List<Map<String, dynamic>>> fetchPopularMovies() async {
    final url = Uri.parse("$baseUrl/movie/popular?api_key=$apiKey");
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List results = data["results"];
      return results.cast<Map<String, dynamic>>();
    } else {
      return [];
    }
  }

  /// Fetches popular TV series (page 1).
  Future<List<Map<String, dynamic>>> fetchPopularSeries() async {
    final url = Uri.parse("$baseUrl/tv/popular?api_key=$apiKey");
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List results = data["results"];
      return results.cast<Map<String, dynamic>>();
    } else {
      return [];
    }
  }

  /// Search for movies with a given query.
  /// (If you wish to also search TV, create a similar function or modify this one.)
  Future<List<Map<String, dynamic>>> searchMovies(String query) async {
    final url = Uri.parse("$baseUrl/search/movie?api_key=$apiKey&query=$query");
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List results = data["results"];
      return results.cast<Map<String, dynamic>>();
    } else {
      return [];
    }
  }

  /// Fetch details for a movie by ID.
  Future<Map<String, dynamic>?> fetchMovieDetails(int movieId) async {
    final url =
    Uri.parse("$baseUrl/movie/$movieId?api_key=$apiKey&language=en-US");
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      return null;
    }
  }

  /// Fetch details for a TV show by ID.
  Future<Map<String, dynamic>?> fetchSeriesDetails(int seriesId) async {
    final url =
    Uri.parse("$baseUrl/tv/$seriesId?api_key=$apiKey&language=en-US");
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      return null;
    }
  }

  /// Fetch reviews for a movie.
  Future<List<Map<String, dynamic>>> fetchMovieReviews(int movieId) async {
    final url = Uri.parse(
      "$baseUrl/movie/$movieId/reviews?api_key=$apiKey&language=en-US",
    );
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(data["results"]);
    } else {
      return [];
    }
  }

  /// Fetch reviews for a TV show.
  Future<List<Map<String, dynamic>>> fetchSeriesReviews(int seriesId) async {
    final url = Uri.parse(
      "$baseUrl/tv/$seriesId/reviews?api_key=$apiKey&language=en-US",
    );
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(data["results"]);
    } else {
      return [];
    }
  }

  /// Fetch the trailer (YouTube Key) for a movie.
  Future<String?> fetchMovieTrailerKey(int movieId) async {
    final url = Uri.parse(
      "$baseUrl/movie/$movieId/videos?api_key=$apiKey&language=en-US",
    );
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List results = data['results'];
      if (results.isNotEmpty) {
        // Usually the first or any named "Trailer" is the official trailer
        final video = results.first;
        return video['key']; // For YouTube
      }
    }
    return null;
  }

  /// Fetch the trailer (YouTube Key) for a TV show.
  Future<String?> fetchSeriesTrailerKey(int seriesId) async {
    final url = Uri.parse(
      "$baseUrl/tv/$seriesId/videos?api_key=$apiKey&language=en-US",
    );
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List results = data['results'];
      if (results.isNotEmpty) {
        final video = results.first;
        return video['key'];
      }
    }
    return null;
  }
}
