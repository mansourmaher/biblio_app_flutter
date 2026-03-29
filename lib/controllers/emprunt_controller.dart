import 'package:flutter/material.dart';
import '../models/emprunt.dart';
import '../services/firestore_service.dart';

class EmpruntController extends ChangeNotifier {
  final FirestoreService _service = FirestoreService();

  Stream<List<Emprunt>> getEmpruntsEnCours(String membreId) {
    return _service.getEmpruntsEnCours(membreId);
  }

  Future<void> retournerLivre({
    required String empruntId,
    required String livreId,
    required String membreId,
  }) async {
    await _service.retournerLivre(
      empruntId: empruntId,
      livreId: livreId,
      membreId: membreId,
    );
    notifyListeners();
  }
}
