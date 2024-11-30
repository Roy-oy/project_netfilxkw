import 'package:flutter/material.dart';
import 'package:project/providers/movie_serach_provider.dart';
import 'package:project/widget/image_widget.dart';
import 'package:provider/provider.dart';

import 'movie_detail_page.dart';

class MovieSearchPage extends SearchDelegate {
  @override
  String? get searchFieldLabel => "Search Movies";

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        onPressed: () => query = "",
        icon: const Icon(Icons.clear),
      ),
    ];
  }

  @override
  ThemeData appBarTheme(BuildContext context) {
    return ThemeData(
      appBarTheme: const AppBarTheme(
        foregroundColor: Colors.white,
        backgroundColor: Color(0xFF1F1F1F),
        elevation: 0,
      ),
      inputDecorationTheme: const InputDecorationTheme(
        hintStyle: TextStyle(color: Colors.white70),
      ),
      textTheme: const TextTheme(
        titleLarge: TextStyle(color: Colors.white),
      ),
    );
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      onPressed: () => close(context, null),
      icon: const Icon(
        Icons.arrow_back,
        color: Colors.white,
      ),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (query.isNotEmpty) {
        context.read<MovieSearchProvider>().search(context, query: query);
      }
    });

    return Consumer<MovieSearchProvider>(
      builder: (_, provider, __) {
        if (query.isEmpty) {
          return const Center(
              child: Text("Search Movies",
                  style: TextStyle(color: Colors.white70)));
        }

        if (provider.isLoading) {
          return const Center(
              child: CircularProgressIndicator(color: Color(0xFFf5c518)));
        }

        if (provider.movies.isEmpty) {
          return const Center(
              child: Text("Movies Not Found",
                  style: TextStyle(color: Colors.white70)));
        }

        return Container(
          color: const Color(0xFF121212),
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemBuilder: (_, index) {
              final movie = provider.movies[index];
              return Card(
                color: const Color(0xFF1F1F1F),
                elevation: 0,
                child: Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          ImageNetworkWidget(
                            imageSrc: movie.posterPath,
                            height: 120,
                            width: 80,
                            radius: 10,
                            fit: BoxFit.cover,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  movie.title,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  movie.overview,
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Positioned.fill(
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            close(context, null);
                            Navigator.push(context, MaterialPageRoute(
                              builder: (_) {
                                return MovieDetailPage(id: movie.id);
                              },
                            ));
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemCount: provider.movies.length,
          ),
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return const SizedBox();
  }
}
