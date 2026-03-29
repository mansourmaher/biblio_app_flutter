import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/emprunt_controller.dart';
import '../../models/emprunt.dart';
import '../../utils/constants.dart';
import '../../utils/helpers.dart';

class EmpruntsScreen extends StatelessWidget {
  const EmpruntsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => EmpruntController(),
      child: const _EmpruntsView(),
    );
  }
}

class _EmpruntsView extends StatelessWidget {
  const _EmpruntsView();

  @override
  Widget build(BuildContext context) {
    final membre = context.watch<AuthController>().membre;
    final empruntController = context.watch<EmpruntController>();

    if (membre == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(24),
                ),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Mes Emprunts 📖',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Suivez vos livres empruntés',
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Borrows list
            Expanded(
              child: StreamBuilder<List<Emprunt>>(
                stream: empruntController.getEmpruntsEnCours(membre.uid),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final emprunts = snapshot.data ?? [];

                  if (emprunts.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.menu_book_outlined,
                            size: 80,
                            color: Colors.grey.shade300,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Aucun emprunt en cours',
                            style: TextStyle(
                              fontSize: 18,
                              color: AppColors.textLight,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Rendez-vous dans le catalogue\npour emprunter un livre!',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: AppColors.textLight),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: emprunts.length,
                    itemBuilder: (context, index) {
                      return _EmpruntCard(
                        emprunt: emprunts[index],
                        membreId: membre.uid,
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Emprunt Card ──────────────────────────────────────────
class _EmpruntCard extends StatelessWidget {
  final Emprunt emprunt;
  final String membreId;

  const _EmpruntCard({required this.emprunt, required this.membreId});

  static const List<Color> coverColors = [
    Color(0xFF1565C0),
    Color(0xFFEF6C00),
    Color(0xFF2E7D32),
    Color(0xFF6A1B9A),
    Color(0xFFC62828),
    Color(0xFF00838F),
  ];

  @override
  Widget build(BuildContext context) {
    final isLate = Helpers.estEnRetard(emprunt.dateRetourPrevue);
    final joursRestants = Helpers.joursRestants(emprunt.dateRetourPrevue);
    final color = coverColors[emprunt.livreTitre.length % coverColors.length];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isLate ? AppColors.error.withOpacity(0.3) : Colors.transparent,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Book cover
            Container(
              width: 56,
              height: 72,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.menu_book, color: Colors.white, size: 28),
            ),
            const SizedBox(width: 16),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    emprunt.livreTitre,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_today,
                        size: 12,
                        color: AppColors.textLight,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Emprunté le ${Helpers.formatDateSimple(emprunt.dateEmprunt)}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textLight,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  // Status badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color:
                          isLate
                              ? AppColors.error.withOpacity(0.1)
                              : joursRestants <= 3
                              ? AppColors.warning.withOpacity(0.1)
                              : AppColors.success.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      Helpers.statutEmpruntLabel(emprunt.dateRetourPrevue),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color:
                            isLate
                                ? AppColors.error
                                : joursRestants <= 3
                                ? AppColors.warning
                                : AppColors.success,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Return button
            Column(
              children: [
                ElevatedButton(
                  onPressed: () => _retourner(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text('Rendre', style: TextStyle(fontSize: 12)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _retourner(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('Rendre le livre'),
            content: Text('Confirmer le retour de "${emprunt.livreTitre}" ?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Annuler'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Confirmer'),
              ),
            ],
          ),
    );

    if (confirm == true && context.mounted) {
      await context.read<EmpruntController>().retournerLivre(
        empruntId: emprunt.id,
        livreId: emprunt.livreId,
        membreId: membreId,
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Livre rendu avec succès! ✅'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    }
  }
}
