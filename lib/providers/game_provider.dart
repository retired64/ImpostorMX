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
}

enum GameStatus { setup, playing, finished }

class GameProvider with ChangeNotifier {
  // Lógica de Categorías y Jugadores
  List<String> punishments = []; // Lista dinámica de castigos
  List<Category> _customCategories = [];
  List<Category> get allCategories => [
    ...GAME_CATEGORIES,
    ..._customCategories,
  ];
  List<Player> players = [];
  Category? selectedCategory;
  String secretWord = '';

  // Configuración de Partida
  int impostorCount = 1;
  int initialTimeSeconds = GameConstants.defaultTimeSeconds;
  int currentTurnIndex = 0;

  // Estado del Juego
  Timer? _timer;
  int remainingSeconds = 0;
  bool isTimerRunning = false;
  GameStatus status = GameStatus.setup;

  late AudioPlayer _audioPlayer; // Alarma final
  final AudioPlayer _effectPlayer = AudioPlayer(); // NUEVO: Efecto Tic-Tac
  bool _isPlayingAudio = false;

  GameProvider() {
    _audioPlayer = AudioPlayer();
    // Pre-cargamos el sonido del tic-tac para evitar retrasos
    _effectPlayer.setSource(AssetSource('sounds/tictac.mp3'));

    _initGame();
    _loadCustomCategories();
    _loadPunishments();
  }

  void _initGame() {
    for (int i = 0; i < 4; i++) {
      _addEmptyPlayer();
    }
  }

  // --- PERSISTENCIA (CATEGORÍAS) ---
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

  // --- PERSISTENCIA (CASTIGOS / RULETA) ---
  Future<void> _loadPunishments() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getStringList(GameConstants.prefsPunishments);
    if (stored != null && stored.isNotEmpty) {
      punishments = stored;
    } else {
      punishments = List.from(GameConstants.punishments);
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

  Future<void> resetPunishments() async {
    punishments = List.from(GameConstants.punishments);
    await _savePunishments();
    notifyListeners();
  }

  Future<void> _savePunishments() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(GameConstants.prefsPunishments, punishments);
  }

  // --- HARDWARE (AUDIO & VIBRACIÓN) ---
  Future<void> playAlarm() async {
    try {
      if (_isPlayingAudio) await _audioPlayer.stop();
      _isPlayingAudio = true;
      await _audioPlayer.play(AssetSource('sounds/alarm.mp3'));
    } catch (_) {
      _isPlayingAudio = false;
    }
  }

  // NUEVO: Función para reproducir el tic-tac corto
  Future<void> _playTick() async {
    try {
      if (_effectPlayer.state == PlayerState.playing)
        await _effectPlayer.stop();
      await _effectPlayer.play(AssetSource('sounds/tictac.mp3'), volume: 1.0);
    } catch (_) {}
  }

  void stopAudio() {
    try {
      _audioPlayer.stop();
      _effectPlayer.stop(); // También detenemos el efecto si se cancela
    } catch (_) {}
    _isPlayingAudio = false;
  }

  void _hapticLight() => Vibration.vibrate(duration: 10);

  // --- GESTIÓN JUGADORES ---
  void _addEmptyPlayer() {
    players.add(
      Player(
        id:
            DateTime.now().microsecondsSinceEpoch.toString() +
            Random().nextInt(999).toString(),
      ),
    );
    notifyListeners();
  }

  void addPlayer() {
    _addEmptyPlayer();
    _hapticLight();
    notifyListeners();
  }

  void removePlayer(String id) {
    players.removeWhere((p) => p.id == id);
    Vibration.vibrate(pattern: GameConstants.hapticTap);
    notifyListeners();
  }

  void updatePlayer(String id, {String? name, String? pin}) {
    final idx = players.indexWhere((p) => p.id == id);
    if (idx != -1) {
      if (name != null) players[idx].name = name;
      if (pin != null) players[idx].pin = pin;
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
      return true;
    }
    Vibration.vibrate(pattern: GameConstants.hapticError);
    return false;
  }

  void unlockPlayer(String id) {
    final idx = players.indexWhere((p) => p.id == id);
    if (idx != -1) {
      players[idx].isLocked = false;
      players[idx].pin = '';
      _hapticLight();
      notifyListeners();
    }
  }

  // --- AJUSTES ---
  void selectCategory(Category cat) {
    selectedCategory = cat;
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

  // --- GAMEPLAY: ALGORITMO CAOS V2 ---
  void startGame() {
    if (selectedCategory == null) return;

    final lockedPlayers = players.where((p) => p.isLocked).toList();
    if (lockedPlayers.length < GameConstants.minPlayers) return;

    stopAudio();
    _timer?.cancel();
    isTimerRunning = false;

    for (var p in players) {
      p.role = 'civilian';
    }

    final random = Random(DateTime.now().microsecondsSinceEpoch);
    secretWord =
        selectedCategory!.words[random.nextInt(selectedCategory!.words.length)];

    int safeImpostorCount = impostorCount;
    if (safeImpostorCount >= lockedPlayers.length) safeImpostorCount = 1;

    List<int> bagOfIndices = List.generate(lockedPlayers.length, (i) => i);

    for (int i = 0; i < safeImpostorCount; i++) {
      if (bagOfIndices.isEmpty) break;

      int randomIndex = random.nextInt(bagOfIndices.length);
      int luckyPlayerIndex = bagOfIndices[randomIndex];

      lockedPlayers[luckyPlayerIndex].role = 'impostor';
      bagOfIndices.removeAt(randomIndex);
    }

    currentTurnIndex = 0;
    status = GameStatus.playing;
    remainingSeconds = initialTimeSeconds;

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

  // --- TIMER (MODIFICADO CON TIC-TAC) ---
  void startTimer() {
    WakelockPlus.enable();
    isTimerRunning = true;
    _timer?.cancel();

    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (remainingSeconds > 0) {
        remainingSeconds--;

        // >>> NUEVA LÓGICA DE TENSIÓN <<<
        if (remainingSeconds <= 10 && remainingSeconds > 0) {
          // 1. Reproducir sonido Tic-Tac
          _playTick();

          // 2. Vibración Progresiva
          if (remainingSeconds <= 5) {
            // Últimos 5 seg: Vibración doble (más estrés)
            Vibration.vibrate(pattern: [0, 50, 50, 50]);
          } else {
            // Del 10 al 6: Vibración simple (tic)
            Vibration.vibrate(duration: 50);
          }
        }
        // >>> FIN NUEVA LÓGICA <<<

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

  void prepareNewMatch() {
    _cleanup();
    for (var p in players) {
      p.role = 'civilian';
    }

    currentTurnIndex = 0;
    remainingSeconds = initialTimeSeconds;
    status = GameStatus.setup;

    notifyListeners();
  }

  void exitGame() {
    _timer?.cancel();
    stopAudio();
    WakelockPlus.disable();
    players.clear();
    _initGame();
    status = GameStatus.setup;
    notifyListeners();
  }

  void _cleanup() {
    _timer?.cancel();
    stopAudio();
    WakelockPlus.disable();
    selectedCategory = null;
    status = GameStatus.setup;
    isTimerRunning = false;
    currentTurnIndex = 0;
  }

  @override
  void dispose() {
    _timer?.cancel();
    _audioPlayer.dispose();
    _effectPlayer.dispose(); // Limpiamos el nuevo reproductor
    super.dispose();
  }
}
