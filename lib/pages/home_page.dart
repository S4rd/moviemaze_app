// lib/pages/home_page.dart
import 'package:flutter/material.dart';
import 'package:moviemaze_app/services/api_service.dart';
import 'movie_detail_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ApiService apiService = ApiService();

  // For movies
  List<Map<String, dynamic>> popularMovies = [];
  // For series
  List<Map<String, dynamic>> popularSeries = [];

  // For searching (movies + series combined)
  List<Map<String, dynamic>> searchResults = [];
  bool isSearching = false;
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      final movies = await apiService.fetchPopularMovies();
      final series = await apiService.fetchPopularSeries();

      setState(() {
        popularMovies = movies;
        popularSeries = series;
      });

      debugPrint("[HomePage] Fetched ${movies.length} popular movies, "
          "${series.length} popular series.");
    } catch (e) {
      debugPrint("[HomePage] Error fetching data: $e");
    }
  }

  Future<void> handleSearch(String query) async {
    if (query.isEmpty) {
      setState(() {
        searchResults = [];
        isSearching = false;
      });
      return;
    }

    debugPrint("[HomePage] Searching for: $query");
    try {
      // 1) Search for movies
      final movieResults = await apiService.searchMovies(query);
      debugPrint("  -> movieResults.length = ${movieResults.length}");

      // 2) Search for TV series
      final seriesResults = await apiService.searchSeries(query);
      debugPrint("  -> seriesResults.length = ${seriesResults.length}");

      // 3) Combine them
      final combined = [...movieResults, ...seriesResults];
      debugPrint("  -> combined.length = ${combined.length}");

      setState(() {
        searchResults = combined;
        isSearching = true;
      });
    } catch (e) {
      debugPrint("[HomePage] handleSearch error: $e");
      setState(() {
        searchResults = [];
        isSearching = false;
      });
    }
  }

  void clearSearch() {
    debugPrint("[HomePage] Clearing search");
    searchController.clear();
    setState(() {
      searchResults = [];
      isSearching = false;
    });
  }

  void navigateToDetails(Map<String, dynamic> item) {
    final String mediaType = item["mediaType"] ?? "movie"; // 'movie' or 'tv'
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MovieDetailPage(
          mediaId: item["id"],
          mediaType: mediaType,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isSearchActive = isSearching && searchResults.isNotEmpty;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: TextField(
          controller: searchController,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: "Search movies or series...",
            hintStyle: TextStyle(color: Colors.white54),
            border: InputBorder.none,
          ),
          // If you want immediate search on every keystroke, keep this:
          onChanged: handleSearch,

          // If you only want to search after pressing "Enter":
          // onSubmitted: handleSearch,
        ),
        actions: [
          if (isSearching || searchController.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: clearSearch,
            ),
        ],
      ),
      body: isSearchActive
          ? buildSearchResults()
          : buildPopularSections(),
    );
  }

  Widget buildSearchResults() {
    return ListView.builder(
      itemCount: searchResults.length,
      itemBuilder: (context, index) {
        final item = searchResults[index];

        // If item['title'] doesn't exist (it's a TV show), fallback to item['name']
        final displayTitle = item['title'] ?? item['name'] ?? 'No title';
        final posterPath = item['poster_path'];
        final mediaType = item['mediaType'] ?? 'movie';

        return GestureDetector(
          onTap: () => navigateToDetails(item),
          child: Card(
            color: Colors.grey[900],
            child: ListTile(
              leading: posterPath != null
                  ? Image.network(
                "https://image.tmdb.org/t/p/w200$posterPath",
                width: 50,
                fit: BoxFit.cover,
              )
                  : const SizedBox(width: 50),
              title: Text(
                displayTitle,
                style: const TextStyle(color: Colors.white),
              ),
              subtitle: Text(
                mediaType.toUpperCase(),
                style: const TextStyle(color: Colors.white70),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget buildPopularSections() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Popular Movies
          const Padding(
            padding: EdgeInsets.all(12.0),
            child: Text(
              "Popular Movies",
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(
            height: 250,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: popularMovies.length,
              itemBuilder: (context, index) {
                final movie = popularMovies[index];
                final String title = movie["title"] ?? "No title";
                final String? posterPath = movie["poster_path"];

                return GestureDetector(
                  onTap: () => navigateToDetails({
                    ...movie,
                    'mediaType': 'movie',
                  }),
                  child: SizedBox(
                    width: 140,
                    child: Card(
                      color: Colors.grey[900],
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (posterPath != null)
                            Image.network(
                              "https://image.tmdb.org/t/p/w200$posterPath",
                              width: 140,
                              height: 180,
                              fit: BoxFit.cover,
                            )
                          else
                            Container(
                              width: 140,
                              height: 180,
                              color: Colors.grey,
                            ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              title,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Popular Series
          const Padding(
            padding: EdgeInsets.all(12.0),
            child: Text(
              "Popular Series",
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(
            height: 250,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: popularSeries.length,
              itemBuilder: (context, index) {
                final series = popularSeries[index];
                final String name = series["name"] ?? "No name";
                final String? posterPath = series["poster_path"];

                return GestureDetector(
                  onTap: () => navigateToDetails({
                    ...series,
                    'mediaType': 'tv',
                  }),
                  child: SizedBox(
                    width: 140,
                    child: Card(
                      color: Colors.grey[900],
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (posterPath != null)
                            Image.network(
                              "https://image.tmdb.org/t/p/w200$posterPath",
                              width: 140,
                              height: 180,
                              fit: BoxFit.cover,
                            )
                          else
                            Container(
                              width: 140,
                              height: 180,
                              color: Colors.grey,
                            ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
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
