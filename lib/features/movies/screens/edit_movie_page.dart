import 'package:flutter/material.dart';

import '../models/movie.dart';
import '../services/movie_service.dart';

class EditMoviePage extends StatefulWidget {
  final Movie movie;

  const EditMoviePage({
    super.key,
    required this.movie,
  });

  @override
  State<EditMoviePage> createState() => _EditMoviePageState();
}

class _EditMoviePageState extends State<EditMoviePage> {
  final _formKey = GlobalKey<FormState>();
  final MovieService _movieService = MovieService();

  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _yearController;
  late final TextEditingController _imageUrlController;
  late final TextEditingController _genreController;
  late final TextEditingController _starsController;

  bool _procesando = false;

  @override
  void initState() {
    super.initState();

    // Cargar los datos actuales de la película.
    final pelicula = widget.movie;

    _titleController = TextEditingController(
      text: pelicula.title,
    );

    _descriptionController = TextEditingController(
      text: pelicula.description,
    );

    _yearController = TextEditingController(
      text: pelicula.year.toString(),
    );

    _imageUrlController = TextEditingController(
      text: pelicula.imageUrl,
    );

    _genreController = TextEditingController(
      text: pelicula.genre.join(', '),
    );

    _starsController = TextEditingController(
      text: pelicula.stars.toString(),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _yearController.dispose();
    _imageUrlController.dispose();
    _genreController.dispose();
    _starsController.dispose();

    super.dispose();
  }

  String? _validarUrl(String? valor) {
    if (valor == null || valor.trim().isEmpty) {
      return 'Ingresa la URL de la portada';
    }

    final uri = Uri.tryParse(valor.trim());

    if (uri == null ||
        !uri.hasScheme ||
        (uri.scheme != 'http' && uri.scheme != 'https') ||
        uri.host.isEmpty) {
      return 'Ingresa una URL válida';
    }

    return null;
  }

  // Actualizar los datos de la película.
  Future<void> _actualizarPelicula() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final year = int.parse(_yearController.text.trim());

    final stars = double.parse(
      _starsController.text.trim().replaceAll(',', '.'),
    );

    final genres = _genreController.text
        .split(',')
        .map((genero) => genero.trim())
        .where((genero) => genero.isNotEmpty)
        .toList();

    setState(() {
      _procesando = true;
    });

    try {
      await _movieService.actualizarPelicula(
        id: widget.movie.id,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        year: year,
        imageUrl: _imageUrlController.text.trim(),
        genre: genres,
        stars: stars,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('¡Película actualizada correctamente!'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context, true);
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'No se pudo actualizar la película.',
          ),
          backgroundColor: Colors.red,
        ),
      );

      debugPrint('Error al actualizar película: $error');
    } finally {
      if (mounted) {
        setState(() {
          _procesando = false;
        });
      }
    }
  }

  // Solicitar confirmación antes de eliminar.
  Future<void> _confirmarEliminacion() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Eliminar película'),
          content: Text(
            '¿Estás seguro de que deseas eliminar '
            '"${widget.movie.title}"? Esta acción no se puede deshacer.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text(
                'Eliminar',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );

    if (confirmar != true || !mounted) {
      return;
    }

    setState(() {
      _procesando = true;
    });

    try {
      await _movieService.eliminarPelicula(widget.movie.id);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('¡Película eliminada correctamente!'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context, true);
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'No se pudo eliminar la película.',
          ),
          backgroundColor: Colors.red,
        ),
      );

      debugPrint('Error al eliminar película: $error');
    } finally {
      if (mounted) {
        setState(() {
          _procesando = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar película'),
        backgroundColor: const Color(0xFF181A2B),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(
             Icons.movie_creation_outlined,
             size: 55,
             color: Color(0xFF6750A4),
             ),

              const SizedBox(height: 12),

              Text(
                'Editar ${widget.movie.title}',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 24),

              // Título
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Título',
                  prefixIcon: Icon(Icons.movie),
                  border: OutlineInputBorder(),
                ),
                validator: (valor) {
                  if (valor == null || valor.trim().isEmpty) {
                    return 'Ingresa el título';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Descripción
              TextFormField(
                controller: _descriptionController,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Descripción',
                  alignLabelWithHint: true,
                  prefixIcon: Icon(Icons.description),
                  border: OutlineInputBorder(),
                ),
                validator: (valor) {
                  if (valor == null || valor.trim().isEmpty) {
                    return 'Ingresa la descripción';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Año
              TextFormField(
                controller: _yearController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Año de lanzamiento',
                  prefixIcon: Icon(Icons.calendar_month),
                  border: OutlineInputBorder(),
                ),
                validator: (valor) {
                  final year = int.tryParse(
                    valor?.trim() ?? '',
                  );

                  if (year == null ||
                      year < 1888 ||
                      year > DateTime.now().year + 5) {
                    return 'Ingresa un año válido';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 16),

              // URL de la portada
              TextFormField(
                controller: _imageUrlController,
                keyboardType: TextInputType.url,
                decoration: const InputDecoration(
                  labelText: 'URL de la portada',
                  prefixIcon: Icon(Icons.image),
                  border: OutlineInputBorder(),
                ),
                validator: _validarUrl,
              ),

              const SizedBox(height: 16),

              // Géneros
              TextFormField(
                controller: _genreController,
                decoration: const InputDecoration(
                  labelText: 'Géneros',
                  hintText: 'Drama, Acción, Aventura',
                  prefixIcon: Icon(Icons.category),
                  border: OutlineInputBorder(),
                ),
                validator: (valor) {
                  final genres = (valor ?? '')
                      .split(',')
                      .where(
                        (genero) => genero.trim().isNotEmpty,
                      )
                      .toList();

                  if (genres.isEmpty) {
                    return 'Ingresa al menos un género';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Calificación
              TextFormField(
                controller: _starsController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Calificación (0 a 5)',
                  prefixIcon: Icon(
                    Icons.star,
                    color: Colors.amber,
                  ),
                  border: OutlineInputBorder(),
                ),
                validator: (valor) {
                  final stars = double.tryParse(
                    (valor ?? '').trim().replaceAll(',', '.'),
                  );

                  if (stars == null || stars < 0 || stars > 5) {
                    return 'La calificación debe estar entre 0 y 5';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 24),

              // Botón actualizar
              ElevatedButton.icon(
                onPressed: _procesando
                    ? null
                    : _actualizarPelicula,
                icon: const Icon(Icons.save),
                label: Text(
                  _procesando
                      ? 'Procesando...'
                      : 'Actualizar película',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6750A4),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),

              const SizedBox(height: 12),

              // Botón eliminar
              OutlinedButton.icon(
                onPressed: _procesando
                    ? null
                    : _confirmarEliminacion,
                icon: const Icon(Icons.delete_outline),
                label: const Text('Eliminar película'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}