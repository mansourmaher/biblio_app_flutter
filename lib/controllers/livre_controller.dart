import 'package:flutter/material.dart';
import '../models/livre.dart';
import '../services/firestore_service.dart';

class LivreController extends ChangeNotifier {
  final FirestoreService _service = FirestoreService();

  List<Livre> _livres = [];
  List<Livre> _filteredLivres = [];
  bool _loading = false;
  String _searchQuery = '';
  String _selectedGenre = 'Tous';

  List<Livre> get livres => _filteredLivres;
  bool get loading => _loading;
  String get searchQuery => _searchQuery;
  String get selectedGenre => _selectedGenre;

  // All genres
  static const List<String> genres = [
    'Tous', 'Roman', 'Science-Fiction', 'Policier',
    'Histoire', 'Biographie', 'Jeunesse', 'Poésie', 'Autre',
  ];

  // Listen to books stream
  Stream<List<Livre>> get livresStream => _service.getLivres();

  void updateLivres(List<Livre> livres) {
    _livres = livres;
    _applyFilters();
  }

  void search(String query) {
    _searchQuery = query;
    _applyFilters();
  }

  void filterByGenre(String genre) {
    _selectedGenre = genre;
    _applyFilters();
    notifyListeners();
  }

  void _applyFilters() {
    var result = List<Livre>.from(_livres);

    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      result = result
          .where((l) =>
              l.titre.toLowerCase().contains(q) ||
              l.auteur.toLowerCase().contains(q) ||
              l.genre.toLowerCase().contains(q))
          .toList();
    }

    if (_selectedGenre != 'Tous') {
      result = result.where((l) => l.genre == _selectedGenre).toList();
    }

    _filteredLivres = result;
    notifyListeners();
  }

  Future<void> addLivre(Livre livre) async {
    _loading = true;
    notifyListeners();
    await _service.addLivre(livre);
    _loading = false;
    notifyListeners();
  }

  Future<void> deleteLivre(String id) async {
    await _service.deleteLivre(id);
  }

  Future<String?> emprunterLivre({
    required String membreId,
    required Livre livre,
  }) async {
    return await _service.emprunterLivre(
      membreId: membreId,
      livre: livre,
    );
  }
}