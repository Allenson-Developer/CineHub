import 'package:flutter/material.dart';
import 'features/movies/screens/movie_list_page.dart';

void main() {
  runApp(const PeliculasApp());
}

class PeliculasApp extends StatelessWidget {
  const PeliculasApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'CineHub',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6750A4),
        ),
        scaffoldBackgroundColor: const Color(0xFFF5F5FA),
      ),
      home: const MovieListPage(),
    );
  }
}