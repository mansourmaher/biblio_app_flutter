class Livre {
  final String id;
  final String titre;
  final String auteur;
  final String genre;
  final String isbn;
  final String description;
  final String couvertureUrl;
  final bool disponible;
  final double note;
  final int nombreAvis;
  final DateTime dateAjout;

  Livre({
    required this.id,
    required this.titre,
    required this.auteur,
    required this.genre,
    required this.isbn,
    this.description = '',
    this.couvertureUrl = '',
    this.disponible = true,
    this.note = 0.0,
    this.nombreAvis = 0,
    required this.dateAjout,
  });

  // Convert Firestore data → Livre object
  factory Livre.fromMap(Map<String, dynamic> map, String id) {
    return Livre(
      id: id,
      titre: map['titre'] ?? '',
      auteur: map['auteur'] ?? '',
      genre: map['genre'] ?? '',
      isbn: map['isbn'] ?? '',
      description: map['description'] ?? '',
      couvertureUrl: map['couvertureUrl'] ?? '',
      disponible: map['disponible'] ?? true,
      note: (map['note'] ?? 0.0).toDouble(),
      nombreAvis: map['nombreAvis'] ?? 0,
      dateAjout: DateTime.parse(map['dateAjout']),
    );
  }

  // Convert Livre object → Firestore data
  Map<String, dynamic> toMap() {
    return {
      'titre': titre,
      'auteur': auteur,
      'genre': genre,
      'isbn': isbn,
      'description': description,
      'couvertureUrl': couvertureUrl,
      'disponible': disponible,
      'note': note,
      'nombreAvis': nombreAvis,
      'dateAjout': dateAjout.toIso8601String(),
    };
  }
}