import 'package:flutter/material.dart';
import 'package:project/pages/movie_detail_page.dart';
import 'package:project/providers/movie_get_top_rated_provider.dart';
import 'package:project/widget/image_widget.dart';
import 'package:provider/provider.dart';

class MovieTopRatedComponent extends StatefulWidget {
  const MovieTopRatedComponent({super.key});

  @override
  State<MovieTopRatedComponent> createState() => _MovieTopRatedComponentState();
}

class _MovieTopRatedComponentState extends State<MovieTopRatedComponent> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MovieGetTopRatedProvider>().getTopRated(context);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Container(
        color: const Color(0xFF0D0D0D),
        child: SizedBox(
          height: 200,
          child: Consumer<MovieGetTopRatedProvider>(
            builder: (_, provider, __) {
              if (provider.isLoading) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16.0),
                  decoration: BoxDecoration(
                      color: const Color(0xFF0D0D0D),
                      borderRadius: BorderRadius.circular(12.0)),
                );
              }

              if (provider.movies.isNotEmpty) {
                return Container(
                  color: const Color(0xFF0D0D0D),
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (_, index) {
                      return ImageNetworkWidget(
                        imageSrc: provider.movies[index].posterPath,
                        height: 200,
                        width: 120,
                        radius: 12.0,
                        fit: BoxFit.cover,
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(
                            builder: (_) {
                              return MovieDetailPage(
                                  id: provider.movies[index].id);
                            },
                          ));
                        },
                      );
                    },
                    separatorBuilder: (_, __) => const SizedBox(
                      width: 8.0,
                    ),
                    itemCount: provider.movies.length,
                  ),
                );
              }

              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 16.0),
                decoration: BoxDecoration(
                  color: const Color(0xFF1F1F1F), // Update from Colors.black26
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: const Center(
                  child: Text(
                    'Not found top rated movies',
                    style: TextStyle(color: Colors.white70), // Add text color
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
