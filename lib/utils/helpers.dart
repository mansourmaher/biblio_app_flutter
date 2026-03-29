import 'package:intl/intl.dart';

class Helpers {
  // Format date → "12 janvier 2025"
  static String formatDate(DateTime date) {
    try {
      return DateFormat('d MMMM yyyy', 'fr_FR').format(date);
    } catch (_) {
      return DateFormat('dd/MM/yyyy').format(date);
    }
  }

  // Format date short → "12/01/2025"
  static String formatDateShort(DateTime date) {
    try {
      return DateFormat('dd/MM/yyyy').format(date);
    } catch (_) {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  // Days remaining before return
  static int joursRestants(DateTime dateRetour) {
    return dateRetour.difference(DateTime.now()).inDays;
  }

  // Is borrow late?
  static bool estEnRetard(DateTime dateRetour) {
    return DateTime.now().isAfter(dateRetour);
  }

  // Return status label
  static String statutEmpruntLabel(DateTime dateRetour) {
    final jours = joursRestants(dateRetour);
    if (jours < 0) return 'En retard de ${jours.abs()} jours';
    if (jours == 0) return 'À rendre aujourd\'hui';
    if (jours <= 3) return 'Dans $jours jours ⚠️';
    return 'Dans $jours jours';
  }

  // Simple date without locale
  static String formatDateSimple(DateTime date) {
    const months = [
      'Jan',
      'Fév',
      'Mar',
      'Avr',
      'Mai',
      'Jun',
      'Jul',
      'Aoû',
      'Sep',
      'Oct',
      'Nov',
      'Déc',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}
