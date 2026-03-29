enum RoleMembre { visiteur, membre, admin }
enum StatutMembre { actif, suspendu, enAttente }

class Membre {
  final String uid;
  final String nom;
  final String email;
  final String telephone;
  final DateTime dateAdhesion;
  final List<String> genresPreferes;
  final int nbEmpruntsEnCours;
  final RoleMembre role;
  final StatutMembre statut;

  Membre({
    required this.uid,
    required this.nom,
    required this.email,
    this.telephone = '',
    required this.dateAdhesion,
    this.genresPreferes = const [],
    this.nbEmpruntsEnCours = 0,
    this.role = RoleMembre.membre,
    this.statut = StatutMembre.enAttente,
  });

  factory Membre.fromMap(Map<String, dynamic> map, String uid) {
    return Membre(
      uid: uid,
      nom: map['nom'] ?? '',
      email: map['email'] ?? '',
      telephone: map['telephone'] ?? '',
      dateAdhesion: DateTime.parse(map['dateAdhesion']),
      genresPreferes: List<String>.from(map['genresPreferes'] ?? []),
      nbEmpruntsEnCours: map['nbEmpruntsEnCours'] ?? 0,
      role: RoleMembre.values.firstWhere(
        (e) => e.name == map['role'],
        orElse: () => RoleMembre.membre,
      ),
      statut: StatutMembre.values.firstWhere(
        (e) => e.name == map['statut'],
        orElse: () => StatutMembre.enAttente,
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nom': nom,
      'email': email,
      'telephone': telephone,
      'dateAdhesion': dateAdhesion.toIso8601String(),
      'genresPreferes': genresPreferes,
      'nbEmpruntsEnCours': nbEmpruntsEnCours,
      'role': role.name,
      'statut': statut.name,
    };
  }
}