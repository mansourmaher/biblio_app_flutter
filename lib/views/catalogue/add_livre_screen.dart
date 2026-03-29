import 'package:flutter/material.dart';
import '../../models/livre.dart';
import '../../services/firestore_service.dart';
import '../../controllers/livre_controller.dart';
import '../../utils/constants.dart';
import '../../utils/validators.dart';

class AddLivreScreen extends StatefulWidget {
  const AddLivreScreen({super.key});

  @override
  State<AddLivreScreen> createState() => _AddLivreScreenState();
}

class _AddLivreScreenState extends State<AddLivreScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titreController = TextEditingController();
  final _auteurController = TextEditingController();
  final _isbnController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _service = FirestoreService();
  String _selectedGenre = 'Roman';
  bool _loading = false;

  @override
  void dispose() {
    _titreController.dispose();
    _auteurController.dispose();
    _isbnController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _addLivre() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    try {
      final livre = Livre(
        id: '',
        titre: _titreController.text.trim(),
        auteur: _auteurController.text.trim(),
        genre: _selectedGenre,
        isbn: _isbnController.text.trim(),
        description: _descriptionController.text.trim(),
        dateAjout: DateTime.now(),
      );

      await _service.addLivre(livre);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Livre ajouté avec succès! 📚'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Ajouter un livre'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Cover preview
              Container(
                width: double.infinity,
                height: 120,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                ),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.menu_book, size: 48, color: AppColors.primary),
                    SizedBox(height: 8),
                    Text(
                      'Nouveau livre',
                      style: TextStyle(color: AppColors.primary),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Titre
              TextFormField(
                controller: _titreController,
                decoration: const InputDecoration(
                  labelText: 'Titre *',
                  prefixIcon: Icon(Icons.title),
                  border: OutlineInputBorder(),
                ),
                validator: (v) => Validators.required(v, 'Titre'),
              ),
              const SizedBox(height: 16),

              // Auteur
              TextFormField(
                controller: _auteurController,
                decoration: const InputDecoration(
                  labelText: 'Auteur *',
                  prefixIcon: Icon(Icons.person_outlined),
                  border: OutlineInputBorder(),
                ),
                validator: (v) => Validators.required(v, 'Auteur'),
              ),
              const SizedBox(height: 16),

              // Genre dropdown
              DropdownButtonFormField<String>(
                value: _selectedGenre,
                decoration: const InputDecoration(
                  labelText: 'Genre *',
                  prefixIcon: Icon(Icons.category_outlined),
                  border: OutlineInputBorder(),
                ),
                items:
                    LivreController.genres
                        .where((g) => g != 'Tous')
                        .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                        .toList(),
                onChanged: (v) => setState(() => _selectedGenre = v!),
              ),
              const SizedBox(height: 16),

              // ISBN
              TextFormField(
                controller: _isbnController,
                decoration: const InputDecoration(
                  labelText: 'ISBN',
                  prefixIcon: Icon(Icons.qr_code),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              // Description
              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  prefixIcon: Icon(Icons.description_outlined),
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 32),

              // Submit
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton.icon(
                  onPressed: _loading ? null : _addLivre,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  icon:
                      _loading
                          ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                          : const Icon(Icons.add),
                  label: Text(
                    _loading ? 'Ajout en cours...' : 'Ajouter le livre',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
