import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:project/injector.dart';
import 'package:project/providers/movie_get_detail_provider.dart';
import 'package:project/providers/movie_get_videos_provider.dart';
import 'package:project/widget/image_widget.dart';
import 'package:project/widget/webview_widget.dart';
import 'package:project/widget/youtube_player_widget.dart';
import 'package:provider/provider.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'dart:ui';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:project/providers/favorite_provider.dart';

class MovieDetailPage extends StatefulWidget {
  const MovieDetailPage({super.key, required this.id});

  final int id;

  @override
  State<MovieDetailPage> createState() => _MovieDetailPageState();
}

class _MovieDetailPageState extends State<MovieDetailPage> {
  bool isFavorite = false;

  void toggleFavorite() {
    setState(() {
      isFavorite = !isFavorite;
    });
  }

  void _launchYouTube(String videoId) async {
    final url = Uri.parse('https://www.youtube.com/watch?v=$videoId');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) =>
              sl<MovieGetDetailProvider>()..getDetail(context, id: widget.id),
        ),
        ChangeNotifierProvider(
          create: (_) =>
              sl<MovieGetVideosProvider>()..getVideos(context, id: widget.id),
        ),
      ],
      builder: (_, __) => Scaffold(
        backgroundColor: const Color(0xFF121212),
        body: Stack(
          children: [
            Consumer<MovieGetDetailProvider>(
              builder: (_, provider, __) {
                if (provider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (provider.movie == null) {
                  return const Center(child: Text('Movie not found'));
                }

                final movie = provider.movie!;

                return CustomScrollView(
                  slivers: [
                    _buildAppBar(context, movie),
                    _buildVideoSection(),
                    _buildOverviewSection(movie),
                    _buildDetailsSection(movie),
                    _buildMetadataSection(movie),
                    SliverPadding(padding: EdgeInsets.only(bottom: 20)),
                  ],
                );
              },
            ),
            Positioned(
              bottom: 16,
              right: 16,
              child: Consumer<MovieGetDetailProvider>(
                builder: (_, movieProvider, __) => Consumer<FavoriteProvider>(
                  builder: (context, favoriteProvider, child) {
                    final isFavorite = movieProvider.movie != null &&
                        favoriteProvider.isFavorite(movieProvider.movie!.id);
                    return FloatingActionButton(
                      onPressed: () {
                        if (movieProvider.movie != null) {
                          favoriteProvider.toggleFavorite(movieProvider.movie!);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                isFavorite
                                    ? 'Removed from favorites'
                                    : 'Added to favorites',
                              ),
                              backgroundColor:
                                  isFavorite ? Colors.red : Colors.green,
                              duration: const Duration(seconds: 1),
                            ),
                          );
                        }
                      },
                      backgroundColor: const Color(0xFFf5c518),
                      child: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: Colors.black,
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, movie) {
    return SliverAppBar(
      expandedHeight:
          MediaQuery.of(context).size.height * 0.6, // Dynamic height
      pinned: true,
      stretch: true, // Enable stretching
      backgroundColor: Colors.transparent,
      leading: IconButton(
        icon: Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.black26,
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.arrow_back_ios_new, color: Color(0xFFf5c518)),
        ),
        onPressed: () => Navigator.pop(context),
      ),
      flexibleSpace: FlexibleSpaceBar(
        stretchModes: const [
          StretchMode.zoomBackground,
          StretchMode.blurBackground,
        ],
        background: Stack(
          fit: StackFit.expand,
          children: [
            Hero(
              tag: 'movie-${movie.id}',
              child: ImageNetworkWidget(
                imageSrc: movie.backdropPath.isNotEmpty
                    ? movie.backdropPath
                    : movie.posterPath,
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.3),
                      Colors.black.withOpacity(0.5),
                    ],
                    stops: const [0.3, 0.7, 1.0],
                  ),
                ),
              ),
            ),
            Positioned(
              left: 16,
              right: 16,
              bottom: 16,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    movie.title,
                    style: GoogleFonts.poppins(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      height: 1.2,
                      shadows: [
                        Shadow(
                          color: Colors.black,
                          offset: Offset(0, 1),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                  ),
                  if (movie.tagline.isNotEmpty) ...[
                    SizedBox(height: 8),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Color(0xFFf5c518),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        movie.tagline,
                        style: GoogleFonts.poppins(
                          color: Colors.black87,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoSection() {
    return SliverToBoxAdapter(
      child: Consumer<MovieGetVideosProvider>(
        builder: (_, provider, __) {
          final videos = provider.videos;
          if (videos == null || videos.results.isEmpty) {
            return const SizedBox.shrink();
          }

          final trailers = videos.results
              .where((video) => video.type.toLowerCase() == 'trailer')
              .toList();

          if (trailers.isEmpty) return const SizedBox.shrink();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
                child: Text(
                  'Trailers & Videos',
                  style: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              SizedBox(
                height: 220,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  itemCount: trailers.length,
                  itemBuilder: (context, index) {
                    final video = trailers[index];
                    return GestureDetector(
                      onTap: () => _launchYouTube(video.key),
                      child: Container(
                        width: 300,
                        margin: EdgeInsets.only(right: 16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 8,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              ImageNetworkWidget(
                                imageSrc: YoutubePlayer.getThumbnail(
                                  videoId: video.key,
                                  quality: ThumbnailQuality.high,
                                ),
                                fit: BoxFit.cover,
                                type: TypeSrcImg.external,
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.transparent,
                                      Colors.black.withOpacity(0.7),
                                    ],
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                  ),
                                ),
                              ),
                              Center(
                                child: Container(
                                  padding: EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Color(0xFFf5c518),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.play_arrow,
                                    color: Colors.black,
                                    size: 32,
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: 12,
                                left: 12,
                                right: 12,
                                child: Text(
                                  video.name,
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
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
          );
        },
      ),
    );
  }

  Widget _buildOverviewSection(movie) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Overview',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              movie.overview,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 16,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailsSection(movie) {
    final formatter = NumberFormat.currency(symbol: '\$');

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow(
              'Release Date',
              DateFormat.yMMMMd().format(movie.releaseDate),
            ),
            _buildDetailRow(
              'Runtime',
              '${movie.runtime} minutes',
            ),
            if (movie.budget > 0)
              _buildDetailRow(
                'Budget',
                formatter.format(movie.budget),
              ),
            if (movie.revenue > 0)
              _buildDetailRow(
                'Revenue',
                formatter.format(movie.revenue),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetadataSection(movie) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (movie.genres.isNotEmpty) ...[
              Row(
                children: [
                  Container(
                    width: 3,
                    height: 24,
                    decoration: BoxDecoration(
                      color: Color(0xFFf5c518),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Genres',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: movie.genres.map<Widget>((genre) {
                  return Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Color(0xFFf5c518),
                          Color(0xFFFF9000),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Color(0xFFf5c518).withOpacity(0.3),
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      genre.name,
                      style: GoogleFonts.poppins(
                        color: Colors.black87,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            value,
            style: const TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }
}
