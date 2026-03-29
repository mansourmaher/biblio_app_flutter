enum StatutEmprunt { enCours, retourne, enRetard, reserve }

class Emprunt {
  final String id;
  final String membreId;
  final String livreId;
  final String livreTitre;
  final DateTime dateEmprunt;
  final DateTime dateRetourPrevue;
  DateTime? dateRetourEffective;
  final StatutEmprunt statut;

  Emprunt({
    required this.id,
    required this.membreId,
    required this.livreId,
    required this.livreTitre,
    required this.dateEmprunt,
    required this.dateRetourPrevue,
    this.dateRetourEffective,
    this.statut = StatutEmprunt.enCours,
  });

  factory Emprunt.fromMap(Map<String, dynamic> map, String id) {
    return Emprunt(
      id: id,
      membreId: map['membreId'] ?? '',
      livreId: map['livreId'] ?? '',
      livreTitre: map['livreTitre'] ?? '',
      dateEmprunt: DateTime.parse(map['dateEmprunt']),
      dateRetourPrevue: DateTime.parse(map['dateRetourPrevue']),
      dateRetourEffective: map['dateRetourEffective'] != null
          ? DateTime.parse(map['dateRetourEffective'])
          : null,
      statut: StatutEmprunt.values.firstWhere(
        (e) => e.name == map['statut'],
        orElse: () => StatutEmprunt.enCours,
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'membreId': membreId,
      'livreId': livreId,
      'livreTitre': livreTitre,
      'dateEmprunt': dateEmprunt.toIso8601String(),
      'dateRetourPrevue': dateRetourPrevue.toIso8601String(),
      'dateRetourEffective': dateRetourEffective?.toIso8601String(),
      'statut': statut.name,
    };
  }
}