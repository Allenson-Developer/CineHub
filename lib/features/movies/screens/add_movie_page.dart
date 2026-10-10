import 'package:flutter/material.dart';

import '../services/movie_service.dart';

class AddMoviePage extends StatefulWidget {
  const AddMoviePage({super.key});

  @override
  State<AddMoviePage> createState() => _AddMoviePageState();
}

 class _AddMoviePageState extends State<AddMoviePage> {
  final _formKey = GlobalKey<FormState>();
  final MovieService _movieService = MovieService();
  String _imagenUrlPreview = '';

  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _yearController = TextEditingController();
  final _imageUrlController = TextEditingController();
  final _genreController = TextEditingController();
  final _starsController = TextEditingController();

  bool _guardando = false;

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

  Future<void> _guardarPelicula() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final year = int.parse(_yearController.text.trim());
    final stars = double.parse(_starsController.text.trim());

    final genres = _genreController.text
        .split(',')
        .map((genero) => genero.trim())
        .where((genero) => genero.isNotEmpty)
        .toList();

    setState(() {
      _guardando = true;
    });

    try {
      await _movieService.crearPelicula(
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
          content: Text('¡Película creada correctamente!'),
          backgroundColor: Colors.green,
        ),
      );

      // Regresamos al catálogo indicando que se creó una película.
      Navigator.pop(context, true);
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'No se pudo guardar la película. '
            'Comprueba los datos y la conexión.',
          ),
          backgroundColor: Colors.red,
        ),
      );

      debugPrint('Error al crear película: $error');
    } finally {
      if (mounted) {
        setState(() {
          _guardando = false;
        });
      }
    }
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
      return 'Ingresa una URL válida que comience con https://';
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agregar película'),
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
                size: 60,
                color: Color(0xFF6750A4),
              ),

              const SizedBox(height: 12),

              const Text(
                'Registrar nueva película',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
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
                    return 'Ingresa el título de la película';
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
                    return 'Ingresa una descripción';
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
                  final year = int.tryParse(valor?.trim() ?? '');

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
             hintText: 'https://...',
             prefixIcon: Icon(Icons.image),
             border: OutlineInputBorder(),
                ),
             onChanged: (valor) {
                setState(() {
              _imagenUrlPreview = valor.trim();
             });
             },
             validator: _validarUrl,
             ),

             if (_imagenUrlPreview.isNotEmpty) ...[
             const SizedBox(height: 12),

              Container(
              width: double.infinity,
              height: 200,
               decoration: BoxDecoration(
               color: Colors.grey.shade200,
               borderRadius: BorderRadius.circular(12),
              ),
                 clipBehavior: Clip.antiAlias,
                 child: Image.network(
                 _imagenUrlPreview,
                    fit: BoxFit.contain,
                   loadingBuilder: (context, child, loadingProgress) {
                   if (loadingProgress == null) {
                    return child;
               }

                return const Center(
                child: CircularProgressIndicator(),
               );
    },
      errorBuilder: (context, error, stackTrace) {
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.broken_image_outlined,
                  size: 40,
                  color: Colors.red,
                ),
                SizedBox(height: 8),
                Text(
                  'No se pudo cargar la imagen.',
                  textAlign: TextAlign.center,
                ),
                Text(
                  'Revisa la URL e inténtalo de nuevo.',
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    ),
  ),
],

              const SizedBox(height: 16),

              // Géneros separados por comas
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
                      .where((genero) => genero.trim().isNotEmpty)
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
                  hintText: 'Ejemplo: 4.5',
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

              // Botón para guardar
              ElevatedButton.icon(
                onPressed: _guardando ? null : _guardarPelicula,
                icon: _guardando
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.save),
                label: Text(
                  _guardando ? 'Guardando...' : 'Guardar película',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6750A4),
                  foregroundColor: Colors.white,
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