import 'package:flutter/material.dart';

import '../models/movie.dart';
import '../services/movie_service.dart';
import '../widgets/movie_card.dart';
import 'add_movie_page.dart';
import 'movie_detail_page.dart';

class MovieListPage extends StatefulWidget {
  const MovieListPage({super.key});

  @override
  State<MovieListPage> createState() => _MovieListPageState();
}

class _MovieListPageState extends State<MovieListPage> {
  final MovieService _movieService = MovieService();

  final TextEditingController _busquedaController =
      TextEditingController();

  final TextEditingController _filtroController =
      TextEditingController();

  late Future<List<Movie>> _peliculasFuture;

  String _busqueda = '';
  String _tipoFiltro = 'Todos';

  @override
  void initState() {
    super.initState();
    _cargarPeliculas();
  }

  // Cargar todas las películas desde la API.
  void _cargarPeliculas() {
    _peliculasFuture = _movieService.obtenerPeliculas();
  }

  void _mostrarMensaje(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensaje)),
    );
  }

  // Limpiar la búsqueda y los filtros.
  void _limpiarFiltrosYRecargar() {
    _busquedaController.clear();
    _filtroController.clear();

    setState(() {
      _busqueda = '';
      _tipoFiltro = 'Todos';
      _cargarPeliculas();
    });
  }

  // Abrir el formulario para agregar una película.
  Future<void> _abrirFormularioAgregar() async {
    final resultado = await Navigator.push<bool>(
      context,
      MaterialPageRoute<bool>(
        builder: (context) => const AddMoviePage(),
      ),
    );

    if (!mounted) return;

    if (resultado == true) {
      _limpiarFiltrosYRecargar();
    }
  }

  // Aplicar el filtro seleccionado mediante la API.
  void _aplicarFiltro() {
    final valor = _filtroController.text.trim();

    if (_tipoFiltro == 'Todos') {
      _limpiarFiltrosYRecargar();
      return;
    }

    if (valor.isEmpty) {
      _mostrarMensaje('Ingresa un valor para filtrar.');
      return;
    }

    late Future<List<Movie>> consulta;

    if (_tipoFiltro == 'Género') {
      consulta = _movieService.obtenerPorGenero(valor);
    } else if (_tipoFiltro == 'Año') {
      final anio = int.tryParse(valor);

      if (anio == null || anio < 1888 ||
          anio > DateTime.now().year + 5) {
        _mostrarMensaje('Ingresa un año válido.');
        return;
      }

      consulta = _movieService.obtenerPorAnio(anio);
    } else if (_tipoFiltro == 'Calificación') {
      final estrellas = double.tryParse(
        valor.replaceAll(',', '.'),
      );

      if (estrellas == null ||
          estrellas < 0 ||
          estrellas > 5) {
        _mostrarMensaje(
          'La calificación debe estar entre 0 y 5.',
        );
        return;
      }

      consulta =
          _movieService.obtenerPorCalificacion(estrellas);
    } else {
      consulta = _movieService.obtenerPeliculas();
    }

    // La búsqueda por título comienza desde cero
    // para mostrar los resultados del filtro seleccionado.
    _busquedaController.clear();

    setState(() {
      _busqueda = '';
      _peliculasFuture = consulta;
    });
  }

  @override
  void dispose() {
    _busquedaController.dispose();
    _filtroController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'CineHub',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF181A2B),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _abrirFormularioAgregar,
            icon: const Icon(Icons.add),
            tooltip: 'Agregar película',
          ),
          IconButton(
            onPressed: _limpiarFiltrosYRecargar,
            icon: const Icon(Icons.refresh),
            tooltip: 'Mostrar todas las películas',
          ),
        ],
      ),

      body: FutureBuilder<List<Movie>>(
        future: _peliculasFuture,
        builder: (context, snapshot) {
          // 1. Estado de carga.
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Cargando películas...'),
                ],
              ),
            );
          }

          // 2. Estado de error.
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.cloud_off,
                      size: 55,
                      color: Colors.grey,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'No pudimos cargar las películas.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 17),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Comprueba tu conexión e inténtalo de nuevo.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _limpiarFiltrosYRecargar,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Intentar de nuevo'),
                    ),
                  ],
                ),
              ),
            );
          }

          // 3. Obtener los resultados, incluso si la lista está vacía.
          final peliculas = snapshot.data ?? <Movie>[];

          // 4. Buscar por título entre los resultados recibidos.
          final peliculasFiltradas = peliculas.where((pelicula) {
            return pelicula.title
                .toLowerCase()
                .contains(_busqueda.trim().toLowerCase());
          }).toList();

          // 5. Mostrar buscador, filtros y catálogo.
          return Column(
            children: [
              // Búsqueda por título.
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  16, 16, 16, 8,
                ),
                child: TextField(
                  controller: _busquedaController,
                  onChanged: (valor) {
                    setState(() {
                      _busqueda = valor;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Buscar película...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _busqueda.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            tooltip: 'Limpiar búsqueda',
                            onPressed: () {
                              _busquedaController.clear();
                              setState(() {
                                _busqueda = '';
                              });
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),

              // Controles de filtrado.
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  16, 4, 16, 8,
                ),
                child: Column(
                  children: [
                    DropdownButtonFormField<String>(
                   initialValue: _tipoFiltro,
                   decoration: const InputDecoration(
                   labelText: 'Filtrar películas por',
                   prefixIcon: Icon(Icons.filter_list),
                    border: OutlineInputBorder(),
                   ),
                      items: const [
                        DropdownMenuItem(
                          value: 'Todos',
                          child: Text('Todas las películas'),
                        ),
                        DropdownMenuItem(
                          value: 'Género',
                          child: Text('Género'),
                        ),
                        DropdownMenuItem(
                          value: 'Año',
                          child: Text('Año de lanzamiento'),
                        ),
                        DropdownMenuItem(
                          value: 'Calificación',
                          child: Text('Calificación'),
                        ),
                      ],
                      onChanged: (valor) {
                        if (valor == null) return;

                        setState(() {
                          _tipoFiltro = valor;

                          if (valor == 'Todos') {
                            _filtroController.clear();
                          }
                        });
                      },
                    ),

                    const SizedBox(height: 8),

                    TextField(
                      controller: _filtroController,
                      enabled: _tipoFiltro != 'Todos',
                      keyboardType:
                          _tipoFiltro == 'Año' ||
                                  _tipoFiltro == 'Calificación'
                              ? const TextInputType.numberWithOptions(
                                  decimal: true,
                                )
                              : TextInputType.text,
                      decoration: InputDecoration(
                        labelText: _tipoFiltro == 'Género'
                            ? 'Género'
                            : _tipoFiltro == 'Año'
                                ? 'Año'
                                : _tipoFiltro == 'Calificación'
                                    ? 'Calificación entre 0 y 5'
                                    : 'Selecciona un filtro',
                        hintText: _tipoFiltro == 'Género'
                            ? 'Ejemplo: Drama'
                            : _tipoFiltro == 'Año'
                                ? 'Ejemplo: 1994'
                                : _tipoFiltro == 'Calificación'
                                    ? 'Ejemplo: 5'
                                    : null,
                        prefixIcon: Icon(
                          _tipoFiltro == 'Género'
                              ? Icons.category
                              : _tipoFiltro == 'Año'
                                  ? Icons.calendar_month
                                  : _tipoFiltro == 'Calificación'
                                      ? Icons.star
                                      : Icons.filter_alt,
                        ),
                        border: const OutlineInputBorder(),
                      ),
                      onSubmitted: (_) => _aplicarFiltro(),
                    ),

                    const SizedBox(height: 10),

                    Wrap(
                      spacing: 10,
                      runSpacing: 8,
                      alignment: WrapAlignment.center,
                      children: [
                        ElevatedButton.icon(
                          onPressed: _aplicarFiltro,
                          icon: const Icon(Icons.search),
                          label: const Text('Aplicar filtro'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color(0xFF6750A4),
                            foregroundColor: Colors.white,
                          ),
                        ),
                        OutlinedButton.icon(
                          onPressed: _limpiarFiltrosYRecargar,
                          icon: const Icon(Icons.clear),
                          label: const Text('Limpiar filtros'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const Divider(height: 1),

              // Resultados.
              Expanded(
                child: peliculasFiltradas.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Text(
                            _busqueda.trim().isNotEmpty
                                ? 'No se encontraron películas con ese título.'
                                : _tipoFiltro != 'Todos'
                                    ? 'No se encontraron películas con ese filtro.'
                                    : 'No hay películas disponibles.',
                            textAlign: TextAlign.center,
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(
                          vertical: 12,
                        ),
                        itemCount: peliculasFiltradas.length,
                        itemBuilder: (context, index) {
                          final pelicula =
                              peliculasFiltradas[index];

                          return MovieCard(
                            key: ValueKey(pelicula.id),
                            movie: pelicula,
                            onTap: () async {
                              final resultado =
                                  await Navigator.push<bool>(
                                context,
                                MaterialPageRoute<bool>(
                                  builder: (context) =>
                                      MovieDetailPage(
                                    movie: pelicula,
                                  ),
                                ),
                              );

                              if (!mounted) return;

                              if (resultado == true) {
                                _limpiarFiltrosYRecargar();
                              }
                            },
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
}