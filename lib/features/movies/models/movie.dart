class Movie {
  final int id;
  final String title;
  final String description;
  final int year;
  final String imageUrl;
  final List<String> genre;
  final double stars;

  Movie({
    required this.id,
    required this.title,
    required this.description,
    required this.year,
    required this.imageUrl,
    required this.genre,
    required this.stars,
  });

  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      year: json['year'],
      imageUrl: json['image_url'],
      genre: List<String>.from(json['genre']),
      stars: (json['stars'] as num).toDouble(),
    );
  }
}