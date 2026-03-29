import 'package:flutter/material.dart';

// ── App Colors ──────────────────────────────────────────
class AppColors {
  static const primary = Color(0xFF1565C0); // deep blue
  static const secondary = Color(0xFFF9A825); // warm yellow
  static const accent = Color(0xFFEF6C00); // orange
  static const background = Color(0xFFF5F5F5);
  static const card = Color(0xFFFFFFFF);
  static const textDark = Color(0xFF212121);
  static const textLight = Color(0xFF757575);
  static const success = Color(0xFF2E7D32);
  static const error = Color(0xFFC62828);
  static const warning = Color(0xFFF9A825);
}

// ── App Text Styles ──────────────────────────────────────
class AppText {
  static const String appName = 'Bibliothèque';
  static const String tagline = 'Votre bibliothèque de quartier';
}

// ── Borrow Duration ──────────────────────────────────────
class AppConfig {
  static const int dureeEmpruntJours = 14; // 2 weeks
  static const int maxEmpruntsParMembre = 3;
  static const int dureeReservationJours = 3;
}

// ── Firestore Collection Names ───────────────────────────
class Collections {
  static const String livres = 'livres';
  static const String membres = 'membres';
  static const String emprunts = 'emprunts';
  static const String evenements = 'evenements';
  static const String messages = 'messages';
}
