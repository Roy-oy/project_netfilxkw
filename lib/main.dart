import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:project/pages/movie_page.dart';
import 'package:project/providers/favorite_provider.dart';
import 'package:project/providers/movie_get_discover_provider.dart';
import 'package:project/providers/movie_get_now_playing_provider.dart';
import 'package:project/providers/movie_get_top_rated_provider.dart';
import 'package:project/providers/movie_serach_provider.dart';
import 'package:provider/provider.dart';
import 'package:project/injector.dart';
import 'package:project/Pages/login_page.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  setup(); // Inisialisasi dependency injection

  runApp(const App());
  FlutterNativeSplash.remove();
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => sl<MovieGetDiscoverProvider>(),
        ),
        ChangeNotifierProvider(
          create: (_) => sl<MovieGetTopRatedProvider>(),
        ),
        ChangeNotifierProvider(
          create: (_) => sl<MovieGetNowPlayingProvider>(),
        ),
        ChangeNotifierProvider(
          create: (_) => sl<MovieSearchProvider>(),
        ),
        ChangeNotifierProvider(
          create: (_) => FavoriteProvider(),
        ),
      ],
      child: MaterialApp(
        title: 'Movie DB',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: LoginPage(), // Mulai dari LoginPage
        routes: {
          '/movie_page': (context) => const MoviePage(), // Rute ke MoviePage
        },
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
