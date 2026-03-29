import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/membre.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Current user
  User? get currentUser => _auth.currentUser;

  // Auth state stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Register
  Future<String?> register({
    required String nom,
    required String email,
    required String password,
    String telephone = '',
  }) async {
    try {
      final result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final membre = Membre(
        uid: result.user!.uid,
        nom: nom,
        email: email,
        telephone: telephone,
        dateAdhesion: DateTime.now(),
        role: RoleMembre.membre,
        statut: StatutMembre.actif,
      );

      await _db
          .collection('membres')
          .doc(result.user!.uid)
          .set(membre.toMap());

      return null; // null = success
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'email-already-in-use':
          return 'Cet email est déjà utilisé';
        case 'weak-password':
          return 'Mot de passe trop faible';
        case 'invalid-email':
          return 'Email invalide';
        default:
          return 'Erreur: ${e.message}';
      }
    }
  }

  // Login
  Future<String?> login({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return null; // null = success
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          return 'Aucun compte avec cet email';
        case 'wrong-password':
          return 'Mot de passe incorrect';
        case 'invalid-email':
          return 'Email invalide';
        case 'invalid-credential':
          return 'Email ou mot de passe incorrect';
        default:
          return 'Erreur: ${e.message}';
      }
    }
  }

  // Logout
  Future<void> logout() async {
    await _auth.signOut();
  }

  // Get membre data
  Future<Membre?> getMembre(String uid) async {
    final doc = await _db.collection('membres').doc(uid).get();
    if (doc.exists) {
      return Membre.fromMap(doc.data()!, doc.id);
    }
    return null;
  }
}