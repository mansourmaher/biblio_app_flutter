class Evenement {
  final String id;
  final String titre;
  final String description;
  final DateTime date;
  final String lieu;
  final int placesTotal;
  final List<String> inscrits;
  final String organisateurId;

  Evenement({
    required this.id,
    required this.titre,
    required this.description,
    required this.date,
    required this.lieu,
    required this.placesTotal,
    this.inscrits = const [],
    required this.organisateurId,
  });

  int get placesRestantes => placesTotal - inscrits.length;
  bool isInscrit(String uid) => inscrits.contains(uid);

  factory Evenement.fromMap(Map<String, dynamic> map, String id) {
    return Evenement(
      id: id,
      titre: map['titre'] ?? '',
      description: map['description'] ?? '',
      date: DateTime.parse(map['date']),
      lieu: map['lieu'] ?? '',
      placesTotal: map['placesTotal'] ?? 0,
      inscrits: List<String>.from(map['inscrits'] ?? []),
      organisateurId: map['organisateurId'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'titre': titre,
      'description': description,
      'date': date.toIso8601String(),
      'lieu': lieu,
      'placesTotal': placesTotal,
      'inscrits': inscrits,
      'organisateurId': organisateurId,
    };
  }
}
