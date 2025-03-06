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

  Future<String?> fetchMovieTrailerKey(int movieId) async {
    final url = Uri.parse(
      "$baseUrl/movie/$movieId/videos?api_key=$apiKey&language=en-US",
    );
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final List results = data['results'] ?? [];

      // 1) Try to find a video with type="Trailer" and site="YouTube"
      final trailer = results.firstWhere(
            (video) =>
        (video['type'] == 'Trailer') &&
            (video['site'] == 'YouTube'),
        orElse: () => null,
      );

      if (trailer != null) {
        return trailer['key'] as String?;
      }

      // 2) If no actual "Trailer", fallback to "Teaser"
      final teaser = results.firstWhere(
            (video) =>
        (video['type'] == 'Teaser') &&
            (video['site'] == 'YouTube'),
        orElse: () => null,
      );

      if (teaser != null) {
        return teaser['key'] as String?;
      }

      // 3) Optionally, fallback to any video
      // final anyVideo = results.isNotEmpty ? results.first : null;
      // if (anyVideo != null) {
      //   return anyVideo['key'];
      // }

      // 4) Otherwise, no suitable trailer found
      return null;
    }
    return null;
  }

  Future<String?> fetchSeriesTrailerKey(int seriesId) async {
    final url = Uri.parse(
      "$baseUrl/tv/$seriesId/videos?api_key=$apiKey&language=en-US",
    );
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final List results = data['results'] ?? [];

      // 1) Look for official YouTube trailer
      final trailer = results.firstWhere(
            (video) =>
        (video['type'] == 'Trailer') &&
            (video['site'] == 'YouTube'),
        orElse: () => null,
      );
      if (trailer != null) {
        return trailer['key'] as String?;
      }

      // 2) If none, fallback to a Teaser
      final teaser = results.firstWhere(
            (video) =>
        (video['type'] == 'Teaser') &&
            (video['site'] == 'YouTube'),
        orElse: () => null,
      );
      if (teaser != null) {
        return teaser['key'] as String?;
      }

      // 3) Otherwise, no trailer found
      return null;
    }
    return null;
  }

  Future<List<Map<String, dynamic>>> searchMovies(String query) async {
    final url = Uri.parse("$baseUrl/search/movie?api_key=$apiKey&query=$query&language=en-US");
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final List rawResults = data["results"] ?? [];

      // 1) Convert each item to Map<String, dynamic>
      final List<Map<String, dynamic>> results = rawResults.map((r) {
        // Force-convert dynamic map to Map<String, dynamic>
        return Map<String, dynamic>.from(r);
      }).toList();

      // 2) Insert 'mediaType': 'movie' on each
      for (var item in results) {
        item['mediaType'] = 'movie';
      }

      // 3) Return final list
      return results;
    } else {
      return [];
    }
  }


  Future<List<Map<String, dynamic>>> searchSeries(String query) async {
    final url = Uri.parse("$baseUrl/search/tv?api_key=$apiKey&query=$query&language=en-US");
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final List rawResults = data["results"] ?? [];

      final List<Map<String, dynamic>> results = rawResults.map((r) {
        return Map<String, dynamic>.from(r);
      }).toList();

      for (var item in results) {
        item['mediaType'] = 'tv';
      }

      return results;
    } else {
      return [];
    }
  }
}
