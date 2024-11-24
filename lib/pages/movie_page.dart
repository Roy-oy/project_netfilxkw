import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:project/components/movie_discover_component.dart';
import 'package:project/components/movie_now_playing_component.dart';
import 'package:project/components/movie_top_rated_component.dart';
import 'package:project/components/my_videos_component.dart';
import 'package:project/pages/movie_search_page.dart';
import 'package:project/pages/login_page.dart';
import 'package:project/pages/profile_page.dart';
import 'movie_pagination_page.dart';

class MoviePage extends StatelessWidget {
  const MoviePage({super.key});

  void _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
      context, 
      MaterialPageRoute(
        builder: (context) => const LoginPage()
      )
    );
  }

  void _navigateToProfile(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ProfilePage(), 
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            title: Row(
              mainAxisSize: MainAxisSize.max, 
              mainAxisAlignment: MainAxisAlignment.start, 
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: CircleAvatar(
                    backgroundColor: Colors.transparent,
                    child: Image.asset('assets/images/logo.png',),
                  ),
                ),
              ],
            ),
            actions: [
              IconButton(
                onPressed: () => showSearch(
                  context: context,
                  delegate: MovieSearchPage(),
                ),
                icon: const Icon(Icons.search),
              ),
              IconButton(
                icon: CircleAvatar(
                  backgroundColor: Colors.blue,
                  child: Text(
                    user?.email?.substring(0, 1).toUpperCase() ?? 'U',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                onPressed: () => _navigateToProfile(context), 
              ),
              const SizedBox(width: 8),
            ],
            floating: true,
            snap: true,
            centerTitle: true,
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
          ),
          _WidgetTitle(
            title: 'My Videos',
          onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const MoviePaginationPage(
                    type: TypeMovie.myVideos,
                  ),
                ),
              );
            },
          ),
          const MyVideosComponent(),
          _WidgetTitle(
            title: 'Discover Movies',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const MoviePaginationPage(
                    type: TypeMovie.discover,
                  ),
                ),
              );
            },
          ),
          const MovieDiscoverComponent(),
          _WidgetTitle(
            title: 'Top Rated Movies',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const MoviePaginationPage(
                    type: TypeMovie.topRated,
                  ),
                ),
              );
            },
          ),
          const MovieTopRatedComponent(),
          _WidgetTitle(
            title: 'Now Playing Movies',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const MoviePaginationPage(
                    type: TypeMovie.nowPlaying,
                  ),
                ),
              );
            },
          ),
          const MovieNowPlayingComponent(),
          const SliverToBoxAdapter(
            child: SizedBox(height: 16),
          ),
        ],
      ),
    );
  }
}

class _WidgetTitle extends SliverToBoxAdapter {
  final String title;
  final void Function() onPressed;

  const _WidgetTitle({required this.title, required this.onPressed});

  @override
  Widget? get child => Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18.0,
              ),
            ),
            OutlinedButton(
              onPressed: onPressed,
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.black,
                shape: const StadiumBorder(),
                side: const BorderSide(
                  color: Colors.black54,
                ),
              ),
              child: const Text('See All'),
            )
          ],
        ),
      );
}