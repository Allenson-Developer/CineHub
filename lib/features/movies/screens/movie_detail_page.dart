import 'package:flutter/material.dart';

import '../models/movie.dart';
import 'edit_movie_page.dart';

class MovieDetailPage extends StatelessWidget {
  final Movie movie;

  const MovieDetailPage({
    super.key,
    required this.movie,
  });

  Future<void> _abrirEdicion(BuildContext context) async {
    final resultado = await Navigator.push<bool>(
      context,
      MaterialPageRoute<bool>(
        builder: (context) => EditMoviePage(
          movie: movie,
        ),
      ),
    );

    if (!context.mounted) return;

    // Si se actualizó o eliminó la película,
    // regresamos al catálogo para recargar los datos.
    if (resultado == true) {
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle de película'),
        backgroundColor: const Color(0xFF181A2B),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Portada
            SizedBox(
              width: double.infinity,
              height: 320,
              child: Image.network(
                movie.imageUrl,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return const Center(
                    child: Icon(
                      Icons.movie_outlined,
                      size: 80,
                      color: Colors.grey,
                    ),
                  );
                },
              ),
            ),

            // Información
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    movie.title,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 12),

                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_month,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 6),
                      Text('${movie.year}'),
                      const SizedBox(width: 20),
                      const Icon(
                        Icons.star,
                        color: Colors.amber,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${movie.stars.toStringAsFixed(1)} / 5',
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  const Text(
                    'Géneros',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: movie.genre.map((genero) {
                      return Chip(
                        label: Text(genero),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 24),

                  const Text(
                    'Sinopsis',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Text(
                    movie.description,
                    style: const TextStyle(
                      fontSize: 16,
                      height: 1.6,
                    ),
                  ),

                  const SizedBox(height: 28),

                  // Botón para editar
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _abrirEdicion(context),
                      icon: const Icon(Icons.edit),
                      label: const Text('Editar película'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6750A4),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          vertical: 16,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Botón para volver
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('Volver al catálogo'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}