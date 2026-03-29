class Validators {
  // Email
  static String? email(String? value) {
    if (value == null || value.isEmpty) return 'Email requis';
    final regex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!regex.hasMatch(value)) return 'Email invalide';
    return null;
  }

  // Password
  static String? password(String? value) {
    if (value == null || value.isEmpty) return 'Mot de passe requis';
    if (value.length < 6) return 'Minimum 6 caractères';
    return null;
  }

  // Name
  static String? nom(String? value) {
    if (value == null || value.isEmpty) return 'Nom requis';
    if (value.length < 2) return 'Nom trop court';
    return null;
  }

  // Phone
  static String? telephone(String? value) {
    if (value == null || value.isEmpty) return null; // optional
    final regex = RegExp(r'^\+?[\d\s-]{8,}$');
    if (!regex.hasMatch(value)) return 'Numéro invalide';
    return null;
  }

  // Required field (generic)
  static String? required(String? value, String fieldName) {
    if (value == null || value.isEmpty) return '$fieldName requis';
    return null;
  }
}
