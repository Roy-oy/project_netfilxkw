import 'package:flutter/material.dart';
import 'package:project/database/profile_databse.dart';
import 'package:project/models/movie_model.dart';
import 'package:project/pages/movie_detail_page.dart';
import 'package:project/providers/movie_get_discover_provider.dart';
import 'package:project/providers/movie_get_now_playing_provider.dart';
import 'package:project/providers/movie_get_top_rated_provider.dart';
import 'package:project/widget/item_movie_widget.dart';
import 'package:provider/provider.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';

enum TypeMovie { discover, topRated, nowPlaying, myVideos }

class MoviePaginationPage extends StatefulWidget {
  const MoviePaginationPage({super.key, required this.type});

  final TypeMovie type;

  @override
  State<MoviePaginationPage> createState() => _MoviePaginationPageState();
}

class _MoviePaginationPageState extends State<MoviePaginationPage> {
  final PagingController<int, MovieModel> _pagingController = PagingController(
    firstPageKey: 1,
  );

  @override
  void initState() {
    if (widget.type != TypeMovie.myVideos) {
      _pagingController.addPageRequestListener((pageKey) {
        switch (widget.type) {
          case TypeMovie.discover:
            context.read<MovieGetDiscoverProvider>().getDiscoverWithPaging(
                  context,
                  pagingController: _pagingController,
                  page: pageKey,
                );
            break;
          case TypeMovie.topRated:
            context.read<MovieGetTopRatedProvider>().getTopRatedWithPaging(
                  context,
                  pagingController: _pagingController,
                  page: pageKey,
                );
            break;
          case TypeMovie.nowPlaying:
            context.read<MovieGetNowPlayingProvider>().getNowPlayingWithPaging(
                  context,
                  pagingController: _pagingController,
                  page: pageKey,
                );
            break;
          case TypeMovie.myVideos:
            break;
        }
      });
    }
    super.initState();
  }

  Widget _buildMyVideosView() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: ProfileDatabse.instance
          .getUserVideos(FirebaseAuth.instance.currentUser?.email ?? ''),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No videos added yet'));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemCount: snapshot.data!.length,
          itemBuilder: (context, index) {
            final video = snapshot.data![index];
            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              child: InkWell(
                onTap: () async {
                  final url = Uri.parse(video['videoUrl']);
                  if (await canLaunchUrl(url)) {
                    await launchUrl(url);
                  }
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 200,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(4),
                        ),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.play_circle_outline,
                          size: 64,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            video['title'],
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Rating: ${video['rating'] ?? 'Not rated'}',
                            style: const TextStyle(
                              color: Colors.grey,
                            ),
                          ),
                          Text(
                            'Added by: ${video['userEmail']}',
                            style: const TextStyle(
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Builder(builder: (_) {
          switch (widget.type) {
            case TypeMovie.discover:
              return const Text('Discover Movies');
            case TypeMovie.topRated:
              return const Text('Top Rated Movies');
            case TypeMovie.nowPlaying:
              return const Text('Now Playing Movies');
            case TypeMovie.myVideos:
              return const Text('My Videos');
          }
        }),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.5,
      ),
      body: widget.type == TypeMovie.myVideos
          ? _buildMyVideosView()
          : PagedListView.separated(
              padding: const EdgeInsets.all(16.0),
              pagingController: _pagingController,
              builderDelegate: PagedChildBuilderDelegate<MovieModel>(
                itemBuilder: (context, item, index) => ItemMovieWidget(
                  movie: item,
                  heightBackdrop: 260,
                  widthBackdrop: double.infinity,
                  heightPoster: 140,
                  widthPoster: 80,
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(
                      builder: (_) {
                        return MovieDetailPage(id: item.id);
                      },
                    ));
                  },
                ),
              ),
              separatorBuilder: (context, index) => const SizedBox(height: 10),
            ),
    );
  }

  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }
}