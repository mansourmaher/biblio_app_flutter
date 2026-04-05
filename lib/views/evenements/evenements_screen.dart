import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/auth_controller.dart';
import '../../models/evenement.dart';
import '../../models/membre.dart';
import '../../services/firestore_service.dart';
import '../../utils/constants.dart';
import '../../utils/helpers.dart';

class EvenementsScreen extends StatelessWidget {
  const EvenementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final membre = context.watch<AuthController>().membre;
    final service = FirestoreService();
    final isAdmin = membre?.role == RoleMembre.admin;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
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
                    'Événements 🎭',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Activités culturelles de la bibliothèque',
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),

            // Events list
            Expanded(
              child: StreamBuilder<List<Evenement>>(
                stream: service.getEvenements(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final evenements = snapshot.data ?? [];

                  if (evenements.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.event_outlined,
                            size: 80,
                            color: Colors.grey.shade300,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Aucun événement prévu',
                            style: TextStyle(
                              fontSize: 18,
                              color: AppColors.textLight,
                            ),
                          ),
                          const SizedBox(height: 8),
                          if (isAdmin)
                            ElevatedButton.icon(
                              onPressed:
                                  () => _showAddEvenement(
                                    context,
                                    service,
                                    membre!.uid,
                                  ),
                              icon: const Icon(Icons.add),
                              label: const Text('Créer un événement'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                              ),
                            ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: evenements.length,
                    itemBuilder: (context, index) {
                      return _EvenementCard(
                        evenement: evenements[index],
                        membreId: membre?.uid ?? '',
                        isAdmin: isAdmin,
                        service: service,
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton:
          isAdmin
              ? FloatingActionButton.extended(
                onPressed:
                    () => _showAddEvenement(context, service, membre!.uid),
                backgroundColor: AppColors.primary,
                icon: const Icon(Icons.add, color: Colors.white),
                label: const Text(
                  'Événement',
                  style: TextStyle(color: Colors.white),
                ),
              )
              : null,
    );
  }

  void _showAddEvenement(
    BuildContext context,
    FirestoreService service,
    String organisateurId,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder:
          (_) => _AddEvenementSheet(
            service: service,
            organisateurId: organisateurId,
          ),
    );
  }
}

// ── Evenement Card ────────────────────────────────────────
class _EvenementCard extends StatelessWidget {
  final Evenement evenement;
  final String membreId;
  final bool isAdmin;
  final FirestoreService service;

  const _EvenementCard({
    required this.evenement,
    required this.membreId,
    required this.isAdmin,
    required this.service,
  });

  static const List<Color> cardColors = [
    AppColors.primary,
    AppColors.secondary,
  ];

  @override
  Widget build(BuildContext context) {
    final isPast = evenement.date.isBefore(DateTime.now());
    final isInscrit = evenement.isInscrit(membreId);
    final isFull = evenement.placesRestantes <= 0;
    final color = cardColors[evenement.titre.length % cardColors.length];

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Color banner
          Container(
            height: 80,
            decoration: BoxDecoration(
              color: isPast ? Colors.grey : color,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            ),
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.event, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        evenement.titre,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        Helpers.formatDateSimple(evenement.date),
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isPast)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'PASSÉ',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Details
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Location & places
                Row(
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      size: 16,
                      color: AppColors.textLight,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      evenement.lieu,
                      style: const TextStyle(
                        color: AppColors.textLight,
                        fontSize: 13,
                      ),
                    ),
                    const Spacer(),
                    Icon(
                      Icons.people_outline,
                      size: 16,
                      color: isFull ? AppColors.error : AppColors.textLight,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${evenement.inscrits.length}/${evenement.placesTotal} places',
                      style: TextStyle(
                        color: isFull ? AppColors.error : AppColors.textLight,
                        fontSize: 13,
                        fontWeight:
                            isFull ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Description
                Text(
                  evenement.description,
                  style: const TextStyle(
                    color: AppColors.textDark,
                    fontSize: 13,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),

                // Action buttons
                Row(
                  children: [
                    if (!isPast && membreId.isNotEmpty)
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed:
                              isFull && !isInscrit
                                  ? null
                                  : () => _toggleInscription(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                isInscrit ? Colors.red.shade400 : color,
                            foregroundColor: Colors.white,
                            disabledBackgroundColor: Colors.grey.shade300,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          icon: Icon(
                            isInscrit
                                ? Icons.cancel_outlined
                                : Icons.check_circle_outline,
                          ),
                          label: Text(
                            isInscrit
                                ? 'Se désinscrire'
                                : isFull
                                ? 'Complet'
                                : 'S\'inscrire',
                          ),
                        ),
                      ),
                    if (isAdmin) ...[
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: () => _confirmDelete(context),
                        icon: const Icon(
                          Icons.delete_outline,
                          color: AppColors.error,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _toggleInscription(BuildContext context) async {
    if (evenement.isInscrit(membreId)) {
      await service.desinscrireEvenement(
        evenementId: evenement.id,
        membreId: membreId,
      );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Désinscription effectuée'),
            backgroundColor: AppColors.warning,
          ),
        );
      }
    } else {
      await service.inscrireEvenement(
        evenementId: evenement.id,
        membreId: membreId,
      );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Inscription confirmée! 🎉'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    }
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('Supprimer l\'événement'),
            content: Text('Supprimer "${evenement.titre}" ?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Annuler'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.error,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Supprimer'),
              ),
            ],
          ),
    );

    if (confirm == true) {
      await service.deleteEvenement(evenement.id);
    }
  }
}

// ── Add Evenement Sheet ───────────────────────────────────
class _AddEvenementSheet extends StatefulWidget {
  final FirestoreService service;
  final String organisateurId;

  const _AddEvenementSheet({
    required this.service,
    required this.organisateurId,
  });

  @override
  State<_AddEvenementSheet> createState() => _AddEvenementSheetState();
}

class _AddEvenementSheetState extends State<_AddEvenementSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titreController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _lieuController = TextEditingController();
  final _placesController = TextEditingController(text: '20');
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 7));
  bool _loading = false;

  @override
  void dispose() {
    _titreController.dispose();
    _descriptionController.dispose();
    _lieuController.dispose();
    _placesController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null) setState(() => _selectedDate = date);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    final evenement = Evenement(
      id: '',
      titre: _titreController.text.trim(),
      description: _descriptionController.text.trim(),
      date: _selectedDate,
      lieu: _lieuController.text.trim(),
      placesTotal: int.tryParse(_placesController.text) ?? 20,
      organisateurId: widget.organisateurId,
    );

    await widget.service.addEvenement(evenement);

    setState(() => _loading = false);

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Événement créé! 🎉'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 24,
        right: 24,
        top: 24,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Nouvel Événement',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),

              TextFormField(
                controller: _titreController,
                decoration: const InputDecoration(
                  labelText: 'Titre *',
                  prefixIcon: Icon(Icons.title),
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v?.isEmpty == true ? 'Titre requis' : null,
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _descriptionController,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Description *',
                  prefixIcon: Icon(Icons.description_outlined),
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                validator:
                    (v) => v?.isEmpty == true ? 'Description requise' : null,
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _lieuController,
                decoration: const InputDecoration(
                  labelText: 'Lieu *',
                  prefixIcon: Icon(Icons.location_on_outlined),
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v?.isEmpty == true ? 'Lieu requis' : null,
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _placesController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Places',
                        prefixIcon: Icon(Icons.people_outline),
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: _pickDate,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade400),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.calendar_today,
                              size: 18,
                              color: AppColors.textLight,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              Helpers.formatDateSimple(_selectedDate),
                              style: const TextStyle(fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _loading ? null : _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child:
                      _loading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                            'Créer l\'événement',
                            style: TextStyle(fontSize: 16),
                          ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
