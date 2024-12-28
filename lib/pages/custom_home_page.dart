import 'package:flutter/material.dart';

class CustomHomePage extends StatelessWidget {
  const CustomHomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Örnek veri (poster URLs)
    final featuredMovies = [
      {
        "title": "Joker Lister",
        "imageUrl": "https://via.placeholder.com/100x150?text=Joker+Lister",
      },
      {
        "title": "Smile",
        "imageUrl": "https://via.placeholder.com/100x150?text=Smile",
      },
      {
        "title": "Terrifier 2",
        "imageUrl": "https://via.placeholder.com/100x150?text=Terrifier+2",
      },
      {
        "title": "Another Movie",
        "imageUrl": "https://via.placeholder.com/100x150?text=Another+One",
      },
    ];

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Üst kısım: Arka planda bir görsel, önünde play butonu, başlık vb.
              Stack(
                children: [
                  // Arka plan görseli
                  Container(
                    height: 200,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: NetworkImage(
                          "https://via.placeholder.com/400x200?text=Emilia+Perez+Poster",
                        ),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  // Üstte yarı saydam bir katman (gerekirse)
                  Container(
                    height: 200,
                    color: Colors.black.withOpacity(0.3),
                  ),
                  // İçerik: Oynatma butonu ve başlık
                  Positioned(
                    bottom: 20,
                    left: 20,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Oynatma butonu (ikonlu bir buton)
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            shape: CircleBorder(),
                            padding: EdgeInsets.all(10),
                          ),
                          onPressed: () {},
                          child: Icon(Icons.play_arrow, color: Colors.white),
                        ),
                        SizedBox(width: 10),
                        // Başlık ve alt metin
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Emilia Pérez",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              "Watch the Official Trailer",
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              SizedBox(height: 20),

              // Arama Alanı
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: TextField(
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: "Search for shows, movies",
                    hintStyle: TextStyle(color: Colors.white54),
                    filled: true,
                    fillColor: Colors.grey[900],
                    prefixIcon: Icon(Icons.search, color: Colors.white54),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white70),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),

              SizedBox(height: 20),

              // "Featured today" başlığı
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  "Featured today",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              SizedBox(height: 10),

              // Yatay Liste
              SizedBox(
                height: 200,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: featuredMovies.length,
                  itemBuilder: (context, index) {
                    final movie = featuredMovies[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Poster
                          Container(
                            width: 100,
                            height: 150,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              image: DecorationImage(
                                image: NetworkImage(movie["imageUrl"]!),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          SizedBox(height: 5),
                          // Başlık
                          SizedBox(
                            width: 100,
                            child: Text(
                              movie["title"]!,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              // Ek alanlar eklemek isterseniz buraya ekleyebilirsiniz.
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
