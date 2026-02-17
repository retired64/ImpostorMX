/*
 * Impostor MX - Juego de fiesta libre y gratuito
 * Copyright (C) 2026 Retired64 
 */

import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Importamos los diccionarios que acabamos de crear
import '../lang/es.dart';
import '../lang/en.dart';
import '../lang/pt.dart';

class LanguageProvider extends ChangeNotifier {
  static const String _prefsKey = 'user_language';

  // Idioma por defecto al iniciar (antes de detectar)
  String _currentLanguage = 'es';

  // Getter para obtener el código del idioma actual ('es', 'en', 'pt')
  String get currentLanguage => _currentLanguage;

  // Mapa maestro que conecta el código del idioma con su diccionario
  final Map<String, Map<String, String>> _dictionaries = {
    'es': es,
    'en': en,
    'pt': pt,
  };

  // Mapa para los castigos por defecto según el idioma
  final Map<String, List<String>> _defaultPunishments = {
    'es': defaultPunishmentsEs,
    'en': defaultPunishmentsEn,
    'pt': defaultPunishmentsPt,
  };

  LanguageProvider() {
    _loadSavedLanguage();
  }

  /// 1. CARGA INICIAL: Lee las preferencias o detecta el idioma del celular
  Future<void> _loadSavedLanguage() async {
    final prefs = await SharedPreferences.getInstance();

    if (prefs.containsKey(_prefsKey)) {
      // Si el usuario ya había elegido un idioma antes, lo respetamos
      _currentLanguage = prefs.getString(_prefsKey)!;
    } else {
      // Si es la primera vez que abre la app, detectamos el idioma del sistema
      final String sysLang = ui.PlatformDispatcher.instance.locale.languageCode;

      // Si soportamos su idioma nativo, lo usamos. Si no, fallback a inglés.
      if (_dictionaries.containsKey(sysLang)) {
        _currentLanguage = sysLang;
      } else {
        _currentLanguage = 'en';
      }
    }
    notifyListeners();
  }

  /// 2. CAMBIO MANUAL: Permite al usuario cambiar el idioma desde Ajustes
  Future<void> setLanguage(String langCode) async {
    if (_dictionaries.containsKey(langCode) && _currentLanguage != langCode) {
      _currentLanguage = langCode;

      // Guardamos la decisión para la próxima vez
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefsKey, langCode);

      notifyListeners();
    }
  }

  /// 3. TRADUCTOR: Busca la clave en el diccionario actual y devuelve el texto
  String translate(String key) {
    // Si la clave no existe por algún error, devuelve la misma clave para que te des cuenta
    return _dictionaries[_currentLanguage]?[key] ?? key;
  }

  /// 4. CASTIGOS: Devuelve la lista de castigos en el idioma correcto
  List<String> getDefaultPunishments() {
    return _defaultPunishments[_currentLanguage] ?? defaultPunishmentsEs;
  }
}
