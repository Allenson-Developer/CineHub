import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../../core/constants/api_constants.dart';
import '../models/movie.dart';

class MovieService {
  Future<List<Movie>> obtenerPeliculas() async {
    final url = Uri.parse(ApiConstants.baseUrl);

    final response = await http
        .get(url)
        .timeout(const Duration(seconds: 15));

    if (response.statusCode != 200) {
      throw Exception(
        'Error al obtener las películas: ${response.statusCode}',
      );
    }

    final datos = jsonDecode(response.body);

    if (datos is! List) {
      throw const FormatException(
        'La respuesta de la API no es una lista de películas.',
      );
    }

    return datos.map((pelicula) {
      if (pelicula is! Map) {
        throw const FormatException(
          'Los datos de una película no son válidos.',
        );
      }

      return Movie.fromJson(
        Map<String, dynamic>.from(pelicula),
      );
    }).toList();
  }

   Future<void> crearPelicula({
   required String title,
   required String description,
   required int year,
   required String imageUrl,
   required List<String> genre,
    required double stars,
 }) async {
  final url = Uri.parse(
    '${ApiConstants.baseUrl}/movie',
  );

  final response = await http
      .post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'title': title,
          'description': description,
          'year': year,
          'image_url': imageUrl,
          'genre': genre,
          'stars': stars,
        }),
      )
      .timeout(const Duration(seconds: 15));

  if (response.statusCode < 200 ||
      response.statusCode >= 300) {
    throw Exception(
      'No se pudo crear la película. '
      'Código HTTP: ${response.statusCode}',
    );
  }
 }
 Future<void> actualizarPelicula({
  required int id,
  required String title,
  required String description,
  required int year,
  required String imageUrl,
  required List<String> genre,
  required double stars,
}) async {
  final url = Uri.parse(
    '${ApiConstants.baseUrl}/movie/$id',
  );

  final response = await http
      .put(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'id': id,
          'title': title,
          'description': description,
          'year': year,
          'image_url': imageUrl,
          'genre': genre,
          'stars': stars,
        }),
      )
      .timeout(const Duration(seconds: 15));

  if (response.statusCode < 200 ||
      response.statusCode >= 300) {
    throw Exception(
      'No se pudo actualizar la película. '
      'Código HTTP: ${response.statusCode}',
    );
  }
}

// Eliminar una película existente.
Future<void> eliminarPelicula(int id) async {
  final url = Uri.parse(
    '${ApiConstants.baseUrl}/movie/$id',
  );

  final response = await http
      .delete(url)
      .timeout(const Duration(seconds: 15));

  if (response.statusCode < 200 ||
      response.statusCode >= 300) {
    throw Exception(
      'No se pudo eliminar la película. '
      'Código HTTP: ${response.statusCode}',
    );
  }
}

// Buscar películas por género.
Future<List<Movie>> obtenerPorGenero(String genero) {
  final generoCodificado = Uri.encodeComponent(genero.trim());

  return _obtenerPeliculasFiltradas(
    '/genre/$generoCodificado',
  );
}

// Buscar películas por año.
Future<List<Movie>> obtenerPorAnio(int year) {
  return _obtenerPeliculasFiltradas(
    '/year/$year',
  );
}

// Buscar películas por calificación.
Future<List<Movie>> obtenerPorCalificacion(double stars) {
  final calificacion = stars == stars.roundToDouble()
      ? stars.toInt().toString()
      : stars.toString();

  return _obtenerPeliculasFiltradas(
    '/stars/$calificacion',
  );
}

// Método privado que realiza la consulta y convierte el JSON.
Future<List<Movie>> _obtenerPeliculasFiltradas(
  String ruta,
) async {
  final url = Uri.parse(
    '${ApiConstants.baseUrl}$ruta',
  );

  final response = await http
      .get(url)
      .timeout(const Duration(seconds: 15));

  // La API utiliza 404 cuando no encuentra coincidencias.
  if (response.statusCode == 404) {
    return [];
  }

  if (response.statusCode != 200) {
    throw Exception(
      'Error al consultar películas. '
      'Código HTTP: ${response.statusCode}',
    );
  }

  final datos = jsonDecode(response.body);

  if (datos is! List) {
    throw const FormatException(
      'La respuesta no contiene una lista de películas.',
    );
  }

  return datos.map((pelicula) {
    if (pelicula is! Map) {
      throw const FormatException(
        'Los datos de una película no son válidos.',
      );
    }

    return Movie.fromJson(
      Map<String, dynamic>.from(pelicula),
    );
  }).toList();
}
 
}