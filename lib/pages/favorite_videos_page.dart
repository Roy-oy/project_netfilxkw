import 'package:flutter/material.dart';
import 'package:project/models/movie_model.dart';
import 'package:project/pages/movie_detail_page.dart';
import 'package:project/providers/movie_get_discover_provider.dart';
import 'package:project/providers/movie_get_now_playing_provider.dart';
import 'package:project/providers/movie_get_top_rated_provider.dart';
import 'package:project/widget/item_movie_widget.dart';
import 'package:provider/provider.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';

class FavoriteVideosPage extends StatefulWidget {
  const FavoriteVideosPage({super.key});


  @override
  State<FavoriteVideosPage> createState() => _FavoriteVideosPageState();
}

class _FavoriteVideosPageState extends State<FavoriteVideosPage> {
  final PagingController<int, MovieModel> _pagingController = PagingController(
    firstPageKey: 1,
  );

  @override
  void initState() {
    super.initState();
    _pagingController.addPageRequestListener((pageKey) {
      context.read<MovieGetDiscoverProvider>().getDiscoverWithPaging(
            context,
            pagingController: _pagingController,
            page: pageKey,
          );
      context.read<MovieGetTopRatedProvider>().getTopRatedWithPaging(
                context,
                pagingController: _pagingController,
                page: pageKey,
              );
      context.read<MovieGetNowPlayingProvider>().getNowPlayingWithPaging(
                context,
                pagingController: _pagingController,
                page: pageKey,
              );
    });
  }

  Widget _buildGlassCard(Widget child) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: child,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      body: Stack(
        children: [
          // Background gradient circles
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFFf5c518).withOpacity(0.2),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -150,
            left: -150,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFFFF9000).withOpacity(0.2),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // Main content
          // Main content
          CustomScrollView(
            slivers: [
              // Custom AppBar
              SliverAppBar(
                expandedHeight: 120,
                pinned: true,
                backgroundColor: const Color(0xFF0D0D0D),
                flexibleSpace: FlexibleSpaceBar(
                  title: ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [Color(0xFFf5c518), Color(0xFFFF9000)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ).createShader(bounds),
                    child: Text(
                      'Favorite Videos',
                      style: GoogleFonts.righteous(
                        fontSize: 24,
                        color: Colors.white,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                  centerTitle: true,
                ),
                leading: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CircleAvatar(
                    backgroundColor: const Color(0xFF1F1F1F),
                    child: IconButton(
                      icon: const Icon(
                        Icons.arrow_back,
                        color: Color(0xFFf5c518),
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ),
              ),

              // Pagination Content
              PagedSliverList<int, MovieModel>(
                pagingController: _pagingController,
                builderDelegate: PagedChildBuilderDelegate<MovieModel>(
                  itemBuilder: (context, item, index) => Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 8.0,
                    ),
                    child: _buildGlassCard(
                      ItemMovieWidget(
                        movie: item,
                        heightBackdrop: 260,
                        widthBackdrop: double.infinity,
                        heightPoster: 140,
                        widthPoster: 80,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => MovieDetailPage(id: item.id),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  firstPageProgressIndicatorBuilder: (_) => Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        const Color(0xFFf5c518),
                      ),
                    ),
                  ),
                  newPageProgressIndicatorBuilder: (_) => Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          const Color(0xFFf5c518),
                        ),
                      ),
                    ),
                  ),
                  noItemsFoundIndicatorBuilder: (_) => Center(
                    child: Text(
                      'No favorite movies found.',
                      style: GoogleFonts.poppins(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }
}
