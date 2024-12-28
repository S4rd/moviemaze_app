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

  // For searching (movies only, in this example)
  List<Map<String, dynamic>> searchResults = [];
  bool isSearching = false;
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    // Fetch both popular movies and popular series
    final movies = await apiService.fetchPopularMovies();
    final series = await apiService.fetchPopularSeries();
    setState(() {
      popularMovies = movies;
      popularSeries = series;
    });
  }

  Future<void> handleSearch(String query) async {
    if (query.isEmpty) {
      setState(() {
        searchResults = [];
        isSearching = false;
      });
      return;
    }
    final results = await apiService.searchMovies(query);
    setState(() {
      searchResults = results;
      isSearching = true;
    });
  }

  void clearSearch() {
    searchController.clear();
    setState(() {
      searchResults = [];
      isSearching = false;
    });
  }

  void navigateToDetails(Map<String, dynamic> item, String mediaType) {
    // item["id"] and the mediaType ("movie" or "tv") are sent to the detail page
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
    // If user is searching, we only show search results (movies).
    // If not, show both popular movies & series sections.
    final List<Map<String, dynamic>> displayList =
    isSearching ? searchResults : popularMovies;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: TextField(
          controller: searchController,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: "Search movies...",
            hintStyle: TextStyle(color: Colors.white54),
            border: InputBorder.none,
          ),
          onChanged: handleSearch,
        ),
        actions: [
          if (isSearching)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: clearSearch,
            ),
        ],
        backgroundColor: Colors.black,
      ),
      body: isSearching
          ? // When searching, just show vertical list of movie results.
      ListView.builder(
        itemCount: displayList.length,
        itemBuilder: (context, index) {
          final movie = displayList[index];
          final String title = movie["title"] ?? "No title";
          final String? posterPath = movie["poster_path"];

          return GestureDetector(
            onTap: () => navigateToDetails(movie, "movie"),
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
                  title,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
          );
        },
      )
          : // Show popular movies + popular series in a scrollable Column
      SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Popular Movies Section ---
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
              height: 250, // height for the horizontal list
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: popularMovies.length,
                itemBuilder: (context, index) {
                  final movie = popularMovies[index];
                  final String title = movie["title"] ?? "No title";
                  final String? posterPath = movie["poster_path"];
                  return GestureDetector(
                    onTap: () => navigateToDetails(movie, "movie"),
                    child: SizedBox(
                      width: 140,
                      child: Card(
                        color: Colors.grey[900],
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            posterPath != null
                                ? Image.network(
                              "https://image.tmdb.org/t/p/w200$posterPath",
                              width: 140,
                              height: 180,
                              fit: BoxFit.cover,
                            )
                                : Container(
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

            // --- Popular Series Section ---
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
                    onTap: () => navigateToDetails(series, "tv"),
                    child: SizedBox(
                      width: 140,
                      child: Card(
                        color: Colors.grey[900],
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            posterPath != null
                                ? Image.network(
                              "https://image.tmdb.org/t/p/w200$posterPath",
                              width: 140,
                              height: 180,
                              fit: BoxFit.cover,
                            )
                                : Container(
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
      ),
    );
  }
}
