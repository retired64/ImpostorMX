/*
 * Impostor MX - Juego de fiesta libre y gratuito
 * Copyright (C) 2026 Retired64 
 *
 * Este programa es software libre: puedes redistribuirlo y/o modificarlo
 * bajo los términos de la Licencia Pública General GNU publicada por
 * la Free Software Foundation, ya sea la versión 3 de la Licencia, o
 * (a tu elección) cualquier versión posterior.
 *
 * Este programa se distribuye con la esperanza de que sea útil,
 * pero SIN NINGUNA GARANTÍA; sin siquiera la garantía implícita de
 * COMERCIABILIDAD o APTITUD PARA UN PROPÓSITO PARTICULAR. Consulta la
 * Licencia Pública General GNU para más detalles.
 *
 * Deberías haber recibido una copia de la Licencia Pública General GNU
 * junto con este programa. Si no es así, consulta <https://www.gnu.org/licenses/>.
 */

import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vibration/vibration.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import '../config/constants.dart';
import '../words.dart';
import '../lang/es.dart';

class Player {
  String id;
  String name;
  String pin;
  bool isLocked;
  String role;
  Player({
    required this.id,
    this.name = '',
    this.pin = '',
    this.isLocked = false,
    this.role = 'civilian',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'pin': pin,
      'isLocked': isLocked,
    };
  }

  factory Player.fromMap(Map<String, dynamic> map) {
    return Player(
      id: map['id'],
      name: map['name'] ?? '',
      pin: map['pin'] ?? '',
      isLocked: map['isLocked'] ?? false,
    );
  }
}

enum GameStatus { setup, playing, finished }

class GameProvider with ChangeNotifier {
  String currentLang = 'es';
  List<String> punishments = [];
  List<Category> _customCategories = [];

  List<Category> get allCategories => [
    ...getGameCategories(currentLang),
    ..._customCategories,
  ];

  List<Player> players = [];

  // --- SELECCIÓN MÚLTIPLE DE CATEGORÍAS ---
  List<Category> selectedCategories = [];

  String get selectedCategoriesName {
    if (selectedCategories.isEmpty) return "";
    if (selectedCategories.length == 1) return selectedCategories.first.name;
    return "MIX (${selectedCategories.length})";
  }

  String secretWord = '';

  // --- EL CORAZÓN DEL CAOS (Global Random) ---
  // Se instancia UNA SOLA VEZ al abrir la app para asegurar entropía pura
  // en cada partida, evitando que se repitan los roles numéricos.
  final Random _random = Random();

  int impostorCount = 1;
  int initialTimeSeconds = GameConstants.defaultTimeSeconds;
  int currentTurnIndex = 0;

  Timer? _timer;
  int remainingSeconds = 0;
  bool isTimerRunning = false;
  GameStatus status = GameStatus.setup;

  late AudioPlayer _audioPlayer;
  final AudioPlayer _effectPlayer = AudioPlayer();
  bool _isPlayingAudio = false;

  GameProvider() {
    _audioPlayer = AudioPlayer();
    _effectPlayer.setSource(AssetSource('sounds/tictac.mp3'));

    _initGame();
    _loadCustomCategories();
    _loadPunishments();
  }

  Future<void> _initGame() async {
    final prefs = await SharedPreferences.getInstance();
    final String? storedPlayers = prefs.getString('saved_players');
    
    if (storedPlayers != null) {
      try {
        final List<dynamic> decoded = jsonDecode(storedPlayers);
        players = decoded.map((p) => Player.fromMap(p)).toList();
        notifyListeners();
        return;
      } catch (e) {
        debugPrint("Error loading players: $e");
      }
    }
    
    // Eğer kayıtlı oyuncu yoksa 4 tane boş oluştur
    for (int i = 0; i < 4; i++) {
      _addEmptyPlayer(shouldNotify: false);
    }
    notifyListeners();
  }

  Future<void> _savePlayers() async {
    final prefs = await SharedPreferences.getInstance();
    final String encoded = jsonEncode(players.map((p) => p.toMap()).toList());
    await prefs.setString('saved_players', encoded);
  }

  Future<void> _loadCustomCategories() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(GameConstants.prefsCustomCategories);
    if (stored != null) {
      try {
        final List<dynamic> decoded = jsonDecode(stored);
        _customCategories = decoded
            .map((item) => Category.fromMap(item))
            .toList();
        notifyListeners();
      } catch (e) {
        debugPrint("Error load: $e");
      }
    }
  }

  Future<void> saveCustomCategory(Category cat, {bool isEdit = false}) async {
    if (isEdit) {
      final idx = _customCategories.indexWhere((c) => c.id == cat.id);
      if (idx != -1) _customCategories[idx] = cat;
    } else {
      _customCategories.add(cat);
    }
    await _persistCategories();
    notifyListeners();
  }

  Future<void> deleteCustomCategory(String id) async {
    _customCategories.removeWhere((c) => c.id == id);
    selectedCategories.removeWhere((c) => c.id == id);
    await _persistCategories();
    notifyListeners();
  }

  Future<void> _persistCategories() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(
      _customCategories.map((c) => c.toMap()).toList(),
    );
    await prefs.setString(GameConstants.prefsCustomCategories, encoded);
  }

  Future<void> _loadPunishments() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getStringList(GameConstants.prefsPunishments);
    if (stored != null && stored.isNotEmpty) {
      punishments = stored;
    } else {
      punishments = List.from(defaultPunishmentsEs);
    }
    notifyListeners();
  }

  Future<void> addPunishment(String text) async {
    punishments.add(text);
    await _savePunishments();
    notifyListeners();
  }

  Future<void> removePunishment(int index) async {
    if (punishments.length > 1) {
      punishments.removeAt(index);
      await _savePunishments();
      notifyListeners();
    }
  }

  Future<void> resetPunishments(List<String> defaultLangPunishments) async {
    punishments = List.from(defaultLangPunishments);
    await _savePunishments();
    notifyListeners();
  }

  Future<void> _savePunishments() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(GameConstants.prefsPunishments, punishments);
  }

  Future<void> playAlarm() async {
    try {
      if (_isPlayingAudio) await _audioPlayer.stop();
      _isPlayingAudio = true;
      await _audioPlayer.play(AssetSource('sounds/$currentLang/alarm.mp3'));
    } catch (_) {
      _isPlayingAudio = false;
    }
  }

  Future<void> _playTick() async {
    try {
      if (_effectPlayer.state == PlayerState.playing) {
        await _effectPlayer.stop();
      }
      await _effectPlayer.play(AssetSource('sounds/tictac.mp3'), volume: 1.0);
    } catch (_) {}
  }

  void stopAudio() {
    try {
      _audioPlayer.stop();
      _effectPlayer.stop();
    } catch (_) {}
    _isPlayingAudio = false;
  }

  void _hapticLight() => Vibration.vibrate(duration: 10);

  void _addEmptyPlayer({bool shouldNotify = true}) {
    players.add(
      Player(
        id:
            DateTime.now().microsecondsSinceEpoch.toString() +
            _random.nextInt(999).toString(),
      ),
    );
    if (shouldNotify) notifyListeners();
  }

  void addPlayer() {
    _addEmptyPlayer();
    _hapticLight();
    _savePlayers(); // Kaydet
  }

  void removePlayer(String id) {
    players.removeWhere((p) => p.id == id);
    Vibration.vibrate(pattern: GameConstants.hapticTap);
    notifyListeners();
    _savePlayers(); // Kaydet
  }

  void updatePlayer(String id, {String? name, String? pin}) {
    final idx = players.indexWhere((p) => p.id == id);
    if (idx != -1) {
      if (name != null) players[idx].name = name;
      if (pin != null) players[idx].pin = pin;
      // Burada notifyListeners çağırmıyoruz genelde TextField performansı için
      // Ama kaydetmemiz lazım. Yazarken her harfte kaydetmek yerine, focus bittiğinde kaydetmek daha iyi
      // ama şimdilik garantici olup kaydedelim.
      _savePlayers(); 
    }
  }

  bool lockPlayer(String id) {
    final idx = players.indexWhere((p) => p.id == id);
    if (idx == -1) return false;
    final p = players[idx];
    if (p.name.trim().isNotEmpty &&
        p.pin.length == 4 &&
        RegExp(r'^[0-9]+$').hasMatch(p.pin)) {
      players[idx].isLocked = true;
      Vibration.vibrate(pattern: GameConstants.hapticSuccess);
      notifyListeners();
      _savePlayers(); // Kaydet
      return true;
    }
    Vibration.vibrate(pattern: GameConstants.hapticError);
    return false;
  }

  void unlockPlayer(String id) {
    final idx = players.indexWhere((p) => p.id == id);
    if (idx != -1) {
      players[idx].isLocked = false;
      // PIN'i sıfırlama özelliğini kaldırdık çünkü artık kaydetmek istiyoruz
      _hapticLight();
      notifyListeners();
      _savePlayers(); // Kaydet
    }
  }

  void toggleCategory(Category cat) {
    final index = selectedCategories.indexWhere((c) => c.id == cat.id);
    if (index != -1) {
      selectedCategories.removeAt(index);
    } else {
      selectedCategories.add(cat);
    }
    _hapticLight();
    notifyListeners();
  }

  void adjustImpostors(int delta) {
    int max = (players.where((p) => p.isLocked).length / 2).floor();
    if (max < 1) max = 1;

    int newVal = impostorCount + delta;
    if (newVal >= 1 && newVal <= max) {
      impostorCount = newVal;
      _hapticLight();
      notifyListeners();
    }
  }

  void adjustTime(int delta) {
    int newVal = initialTimeSeconds + delta;
    if (newVal >= 60) {
      initialTimeSeconds = newVal;
      _hapticLight();
      notifyListeners();
    }
  }

  // --- GAMEPLAY Y ALGORITMO CAOS ---
  void startGame() {
    if (selectedCategories.isEmpty) return;

    final lockedPlayers = players.where((p) => p.isLocked).toList();
    if (lockedPlayers.length < GameConstants.minPlayers) return;

    stopAudio();
    _timer?.cancel();
    isTimerRunning = false;

    // 1. Limpieza total de roles (todos regresan a civiles)
    for (var p in players) {
      p.role = 'civilian';
    }

    // 2. Extraer TODAS las palabras de las categorías seleccionadas
    List<String> combinedWords = [];
    for (var cat in selectedCategories) {
      combinedWords.addAll(cat.words);
    }

    // Elegimos la palabra secreta usando la semilla global
    secretWord = combinedWords[_random.nextInt(combinedWords.length)];

    // 3. Algoritmo Caos V2 (Sorteo de Impostores sin repetir patrón)
    int safeImpostorCount = impostorCount;
    if (safeImpostorCount >= lockedPlayers.length) safeImpostorCount = 1;

    List<int> bagOfIndices = List.generate(lockedPlayers.length, (i) => i);

    for (int i = 0; i < safeImpostorCount; i++) {
      if (bagOfIndices.isEmpty) break;

      // Usamos la semilla global que nunca se reinicia
      int randomIndex = _random.nextInt(bagOfIndices.length);
      int luckyPlayerIndex = bagOfIndices[randomIndex];

      lockedPlayers[luckyPlayerIndex].role = 'impostor';
      bagOfIndices.removeAt(randomIndex); // Sacamos al jugador de la bolsa
    }

    // 4. Reinicio de turno y estado
    currentTurnIndex = 0;
    status = GameStatus.playing;
    remainingSeconds = initialTimeSeconds;

    // Feedback general (lo sienten todos porque el cel está en la mesa)
    Vibration.vibrate(pattern: GameConstants.hapticSuccess);
    notifyListeners();
  }

  void nextTurn() {
    _hapticLight();
    currentTurnIndex++;
    notifyListeners();
  }

  Player getCurrentPlayer() {
    final active = players.where((p) => p.isLocked).toList();
    if (currentTurnIndex >= active.length) currentTurnIndex = 0;
    return active[currentTurnIndex];
  }

  void startTimer() {
    WakelockPlus.enable();
    isTimerRunning = true;
    _timer?.cancel();

    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (remainingSeconds > 0) {
        remainingSeconds--;

        if (remainingSeconds <= 10 && remainingSeconds > 0) {
          _playTick();

          if (remainingSeconds <= 5) {
            Vibration.vibrate(pattern: [0, 50, 50, 50]);
          } else {
            Vibration.vibrate(duration: 50);
          }
        }
        notifyListeners();
      } else {
        stopTimer(finished: true);
      }
    });
    notifyListeners();
  }

  void pauseTimer() {
    isTimerRunning = false;
    _timer?.cancel();
    stopAudio();
    notifyListeners();
  }

  void stopTimer({bool finished = false}) {
    _timer?.cancel();
    isTimerRunning = false;
    WakelockPlus.disable();
    if (finished) {
      status = GameStatus.finished;
      Vibration.vibrate(pattern: GameConstants.hapticAlarm);
      playAlarm();
    }
    notifyListeners();
  }

  void finishGameAndVote() {
    _timer?.cancel();
    isTimerRunning = false;
    stopAudio();
    WakelockPlus.disable();
    notifyListeners();
  }

  void addExtraTime() {
    remainingSeconds += 60;
    stopAudio();
    status = GameStatus.playing;
    if (isTimerRunning) {
      _timer?.cancel();
      startTimer();
    }
    _hapticLight();
    notifyListeners();
  }

  // --- OPTIMIZACIÓN: Revancha Rápida ---
  void prepareNewMatch() {
    _timer?.cancel();
    stopAudio();
    WakelockPlus.disable();
    isTimerRunning = false;

    // Al llamar startGame, garantizamos una limpieza interna de roles,
    // nueva extracción de palabras y nuevos impostores usando el Random global.
    startGame();
  }

  // --- OPTIMIZACIÓN: Hard Reset al Menú ---
  void exitGame() {
    _cleanup();
    selectedCategories.clear(); // Limpia los temas
    
    // Oyuncuların kilitlerini açıyoruz ama isim ve PIN'lerini koruyoruz
    for (var p in players) {
      p.isLocked = false;
      p.role = 'civilian';
    }
    
    status = GameStatus.setup;
    _savePlayers(); // Son durumu kaydet
    notifyListeners();
  }

  void _cleanup() {
    _timer?.cancel();
    stopAudio();
    WakelockPlus.disable();
    status = GameStatus.setup;
    isTimerRunning = false;
    currentTurnIndex = 0;
  }

  @override
  void dispose() {
    _timer?.cancel();
    _audioPlayer.dispose();
    _effectPlayer.dispose();
    super.dispose();
  }
}
