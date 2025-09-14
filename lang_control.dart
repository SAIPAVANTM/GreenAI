import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'apptrans.dart';

class LanguageController extends GetxController {
  static const String _languageKey = 'selected_language';
  final RxString currentLanguage = 'English'.obs;

  @override
  void onInit() {
    super.onInit();
    loadSavedLanguage();
  }

  // Load saved language from SharedPreferences
  Future<void> loadSavedLanguage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedLanguage = prefs.getString(_languageKey) ?? 'English';
      currentLanguage.value = savedLanguage;
      changeLanguage(savedLanguage);
    } catch (e) {
      print('Error loading saved language: $e');
      // Fallback to English if there's an error
      currentLanguage.value = 'English';
      changeLanguage('English');
    }
  }

  // Save language to SharedPreferences and update app locale
  Future<void> saveAndChangeLanguage(String language) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_languageKey, language);
      currentLanguage.value = language;
      changeLanguage(language);
    } catch (e) {
      print('Error saving language: $e');
      Get.snackbar(
        'Error',
        'Failed to save language preference',
        backgroundColor: Colors.red.withOpacity(0.7),
        colorText: Colors.white,
      );
    }
  }

  // Change app language using GetX
  void changeLanguage(String language) {
    final String? languageCode = AppTranslations.languageToCode[language];
    if (languageCode != null) {
      final parts = languageCode.split('_');
      final locale = Locale(parts, parts.length > 1 ? parts[21] : null);
      Get.updateLocale(locale);
    }
  }

  // Get current locale
  Locale getCurrentLocale() {
    final String? languageCode = AppTranslations.languageToCode[currentLanguage.value];
    if (languageCode != null) {
      final parts = languageCode.split('_');
      return Locale(parts, parts.length > 1 ? parts[21] : null);
    }
    return const Locale('en', 'US');
  }

  // Get list of available languages
  List<String> getAvailableLanguages() {
    return AppTranslations.languageToCode.keys.toList();
  }
}
