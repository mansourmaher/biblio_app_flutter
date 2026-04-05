import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/livre.dart';
import '../models/membre.dart';
import '../models/emprunt.dart';
import '../models/message.dart';
import '../utils/constants.dart';
import '../models/evenement.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ── LIVRES ────────────────────────────────────────────────

  // Get all books stream
  Stream<List<Livre>> getLivres() {
    return _db
        .collection(Collections.livres)
        .orderBy('dateAjout', descending: true)
        .snapshots()
        .map(
          (snap) =>
              snap.docs
                  .map((doc) => Livre.fromMap(doc.data(), doc.id))
                  .toList(),
        );
  }

  // Search books
  Future<List<Livre>> searchLivres(String query) async {
    final snap = await _db.collection(Collections.livres).get();
    final all =
        snap.docs.map((doc) => Livre.fromMap(doc.data(), doc.id)).toList();
    final q = query.toLowerCase();
    return all
        .where(
          (l) =>
              l.titre.toLowerCase().contains(q) ||
              l.auteur.toLowerCase().contains(q) ||
              l.genre.toLowerCase().contains(q) ||
              l.isbn.contains(q),
        )
        .toList();
  }

  // Get books by genre
  Stream<List<Livre>> getLivresByGenre(String genre) {
    return _db
        .collection(Collections.livres)
        .where('genre', isEqualTo: genre)
        .snapshots()
        .map(
          (snap) =>
              snap.docs
                  .map((doc) => Livre.fromMap(doc.data(), doc.id))
                  .toList(),
        );
  }

  // Add book (admin)
  Future<void> addLivre(Livre livre) async {
    await _db.collection(Collections.livres).add(livre.toMap());
  }

  // Update book (admin)
  Future<void> updateLivre(Livre livre) async {
    await _db
        .collection(Collections.livres)
        .doc(livre.id)
        .update(livre.toMap());
  }

  // Delete book (admin)
  Future<void> deleteLivre(String id) async {
    await _db.collection(Collections.livres).doc(id).delete();
  }

  // ── EMPRUNTS ──────────────────────────────────────────────

  // Borrow a book
  Future<String?> emprunterLivre({
    required String membreId,
    required Livre livre,
  }) async {
    if (!livre.disponible) return 'Ce livre n\'est pas disponible';

    final batch = _db.batch();

    // Create emprunt
    final empruntRef = _db.collection(Collections.emprunts).doc();
    final emprunt = Emprunt(
      id: empruntRef.id,
      membreId: membreId,
      livreId: livre.id,
      livreTitre: livre.titre,
      dateEmprunt: DateTime.now(),
      dateRetourPrevue: DateTime.now().add(
        const Duration(days: AppConfig.dureeEmpruntJours),
      ),
    );
    batch.set(empruntRef, emprunt.toMap());

    // Update book availability
    batch.update(_db.collection(Collections.livres).doc(livre.id), {
      'disponible': false,
    });

    // Update member borrow count
    batch.update(_db.collection(Collections.membres).doc(membreId), {
      'nbEmpruntsEnCours': FieldValue.increment(1),
    });

    await batch.commit();
    return null;
  }

  // Return a book
  Future<void> retournerLivre({
    required String empruntId,
    required String livreId,
    required String membreId,
  }) async {
    final batch = _db.batch();

    batch.update(_db.collection(Collections.emprunts).doc(empruntId), {
      'statut': 'retourne',
      'dateRetourEffective': DateTime.now().toIso8601String(),
    });

    batch.update(_db.collection(Collections.livres).doc(livreId), {
      'disponible': true,
    });

    batch.update(_db.collection(Collections.membres).doc(membreId), {
      'nbEmpruntsEnCours': FieldValue.increment(-1),
    });

    await batch.commit();
  }

  // Get member's active borrows
  Stream<List<Emprunt>> getEmpruntsEnCours(String membreId) {
    return _db
        .collection(Collections.emprunts)
        .where('membreId', isEqualTo: membreId)
        .where('statut', isEqualTo: 'enCours')
        .snapshots()
        .map(
          (snap) =>
              snap.docs
                  .map((doc) => Emprunt.fromMap(doc.data(), doc.id))
                  .toList(),
        );
  }

  // Get all emprunts (admin)
  Stream<List<Emprunt>> getAllEmprunts() {
    return _db
        .collection(Collections.emprunts)
        .orderBy('dateEmprunt', descending: true)
        .snapshots()
        .map(
          (snap) =>
              snap.docs
                  .map((doc) => Emprunt.fromMap(doc.data(), doc.id))
                  .toList(),
        );
  }

  // ── MEMBRES ───────────────────────────────────────────────

  // Get all members (admin)
  Stream<List<Membre>> getAllMembres() {
    return _db
        .collection(Collections.membres)
        .snapshots()
        .map(
          (snap) =>
              snap.docs
                  .map((doc) => Membre.fromMap(doc.data(), doc.id))
                  .toList(),
        );
  }

  // ── EVENEMENTS ────────────────────────────────────────────

  Stream<List<Evenement>> getEvenements() {
    return _db
        .collection(Collections.evenements)
        .orderBy('date')
        .snapshots()
        .map(
          (snap) =>
              snap.docs
                  .map((doc) => Evenement.fromMap(doc.data(), doc.id))
                  .toList(),
        );
  }

  Future<void> addEvenement(Evenement evenement) async {
    await _db.collection(Collections.evenements).add(evenement.toMap());
  }

  Future<void> inscrireEvenement({
    required String evenementId,
    required String membreId,
  }) async {
    await _db.collection(Collections.evenements).doc(evenementId).update({
      'inscrits': FieldValue.arrayUnion([membreId]),
    });
  }

  Future<void> desinscrireEvenement({
    required String evenementId,
    required String membreId,
  }) async {
    await _db.collection(Collections.evenements).doc(evenementId).update({
      'inscrits': FieldValue.arrayRemove([membreId]),
    });
  }

  Future<void> deleteEvenement(String id) async {
    await _db.collection(Collections.evenements).doc(id).delete();
  }

  // ── MESSAGES ──────────────────────────────────────────────

  // Get community messages (forum)
  Stream<List<Message>> getMessages(String conversationId) {
    return _db
        .collection(Collections.messages)
        .where('conversationId', isEqualTo: conversationId)
        .orderBy('dateEnvoi', descending: false)
        .snapshots()
        .map(
          (snap) =>
              snap.docs
                  .map((doc) => Message.fromMap(doc.data(), doc.id))
                  .toList(),
        );
  }

  // Send message
  Future<void> sendMessage(Message message) async {
    await _db.collection(Collections.messages).add({
      'senderId': message.senderId,
      'senderNom': message.senderNom,
      'contenu': message.contenu,
      'dateEnvoi': DateTime.now().toIso8601String(),
      'conversationId': message.conversationId,
    });
  }

  // Delete message
  Future<void> deleteMessage(String id) async {
    await _db.collection(Collections.messages).doc(id).delete();
  }
}
