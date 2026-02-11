import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_fortune_wheel/flutter_fortune_wheel.dart';
import 'package:provider/provider.dart';
import 'package:vibration/vibration.dart';
import 'package:confetti/confetti.dart'; // <--- 1. IMPORTAR LIBRERÍA
import '../providers/game_provider.dart';
import '../widgets/inputs.dart';
import '../config/theme.dart';
import '../utils/sound_manager.dart';
import 'category_screen.dart';

class ResultScreen extends StatelessWidget {
  final Player votedPlayer;
  const ResultScreen({super.key, required this.votedPlayer});

  @override
  Widget build(BuildContext context) {
    final bool isImpostor = votedPlayer.role == 'impostor';

    // Colores de fondo según el resultado
    final bgColor = isImpostor
        ? const Color(0xFF00C853)
        : const Color(0xFFD50000);
    final winnerText = isImpostor
        ? "¡GANAN LOS CIVILES!"
        : "¡GANA EL IMPOSTOR!";
    final loserTitle = isImpostor
        ? "Castigo para el IMPOSTOR"
        : "Castigo para los CIVILES";

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 10),
            // TÍTULO DEL GANADOR
            Text(
              winnerText,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Bungee',
                fontSize: 24,
                color: Colors.white,
                shadows: [Shadow(blurRadius: 10, color: Colors.black45)],
              ),
            ),
            const SizedBox(height: 5),
            Text(
              loserTitle,
              style: const TextStyle(
                fontFamily: 'YoungSerif',
                fontSize: 14,
                color: Colors.white70,
              ),
            ),

            // --- LA RULETA (Con Confeti integrado) ---
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 20,
                ),
                child: const PunishmentRoulette(),
              ),
            ),

            // BOTONES INFERIORES
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: AppColors.bgBottom,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () {
                        Provider.of<GameProvider>(
                          context,
                          listen: false,
                        ).exitGame();
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const CategoryScreen(),
                          ),
                          (r) => false,
                        );
                      },
                      child: const Text(
                        "SALIR",
                        style: TextStyle(
                          color: Colors.white54,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: BouncyButton(
                      text: "JUGAR OTRA",
                      color: AppColors.accent,
                      onPressed: () {
                        Provider.of<GameProvider>(
                          context,
                          listen: false,
                        ).prepareNewMatch();
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const CategoryScreen(),
                          ),
                          (r) => false,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PunishmentRoulette extends StatefulWidget {
  const PunishmentRoulette({super.key});
  @override
  State<PunishmentRoulette> createState() => _PunishmentRouletteState();
}

class _PunishmentRouletteState extends State<PunishmentRoulette> {
  final StreamController<int> _selected = StreamController<int>();
  late ConfettiController _confettiController; // <--- 2. CONTROLADOR

  bool _isSpinning = false;
  int _lastIndex = 0;

  final List<Color> _colors = [
    Colors.redAccent,
    Colors.orangeAccent,
    Colors.amber,
    Colors.green,
    Colors.blueAccent,
    Colors.purpleAccent,
    Colors.pinkAccent,
  ];

  @override
  void initState() {
    super.initState();
    // Duración de la lluvia de confeti (3 segundos)
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 3),
    );
  }

  @override
  void dispose() {
    _selected.close();
    _confettiController.dispose(); // <--- IMPORTANTE: Limpiar memoria
    super.dispose();
  }

  void _spin() {
    if (_isSpinning) return;

    setState(() => _isSpinning = true);
    SoundManager.playClick();

    final punishments = Provider.of<GameProvider>(
      context,
      listen: false,
    ).punishments;

    final index = Random().nextInt(punishments.length);
    _lastIndex = index;
    _selected.add(index);
  }

  @override
  Widget build(BuildContext context) {
    final punishments = Provider.of<GameProvider>(context).punishments;

    // 3. ENVOLVER EN STACK PARA PONER EL CONFETI ENCIMA
    return Stack(
      alignment: Alignment.topCenter, // El confeti cae desde arriba al centro
      children: [
        // --- CAPA 1: La Ruleta y Botones ---
        Column(
          children: [
            Expanded(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // La Rueda
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 6),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: FortuneWheel(
                      selected: _selected.stream,
                      animateFirst: false,
                      physics: CircularPanPhysics(
                        duration: const Duration(seconds: 4),
                        curve: Curves.decelerate,
                      ),
                      onAnimationEnd: () {
                        setState(() => _isSpinning = false);
                        Vibration.vibrate(pattern: [0, 50, 100, 500]);

                        // 4. DISPARAR CONFETI AL TERMINAR
                        _confettiController.play();

                        _showResultDialog();
                      },
                      indicators: const <FortuneIndicator>[
                        FortuneIndicator(
                          alignment: Alignment.topCenter,
                          child: TriangleIndicator(color: Colors.white),
                        ),
                      ],
                      items: [
                        for (int i = 0; i < punishments.length; i++)
                          FortuneItem(
                            style: FortuneItemStyle(
                              color: _colors[i % _colors.length],
                              borderColor: Colors.white24,
                              borderWidth: 2,
                              textAlign: TextAlign.center,
                              textStyle: const TextStyle(
                                fontFamily: 'YoungSerif',
                                fontSize: 14,
                                color: Colors.black87,
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(25.0),
                              child: Text(
                                punishments[i],
                                textAlign: TextAlign.center,
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                  // Botón Central "?"
                  GestureDetector(
                    onTap: _spin,
                    child: Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.grey.shade300,
                          width: 4,
                        ),
                        boxShadow: [
                          const BoxShadow(
                            blurRadius: 10,
                            color: Colors.black26,
                          ),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: _isSpinning
                          ? const CircularProgressIndicator(
                              color: AppColors.accent,
                              strokeWidth: 3,
                            )
                          : const Text(
                              "?",
                              style: TextStyle(
                                fontFamily: 'Bungee',
                                fontSize: 35,
                                color: Colors.black87,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            if (!_isSpinning)
              BouncyButton(
                text: "GIRAR RULETA",
                color: Colors.white,
                onPressed: _spin,
              )
            else
              const Text(
                "¡SUERTE!",
                style: TextStyle(
                  fontFamily: 'Bungee',
                  fontSize: 20,
                  color: Colors.white,
                ),
              ),
          ],
        ),

        // --- CAPA 2: El Widget de Confeti (Invisible hasta disparar) ---
        ConfettiWidget(
          confettiController: _confettiController,
          blastDirectionality:
              BlastDirectionality.explosive, // Explosión en todas direcciones
          shouldLoop: false, // Solo una explosión, no infinito
          colors: const [
            Colors.green,
            Colors.blue,
            Colors.pink,
            Colors.orange,
            Colors.purple,
          ],
          gravity: 0.3, // Caída un poco lenta para apreciar
          numberOfParticles: 25, // Cantidad de papeles
        ),
      ],
    );
  }

  void _showResultDialog() {
    final punishments = Provider.of<GameProvider>(
      context,
      listen: false,
    ).punishments;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.bgBottom,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: [
              const BoxShadow(
                color: Colors.black45,
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "🔥 TU CASTIGO 🔥",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Bungee',
                  color: AppColors.error,
                  fontSize: 24,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                punishments[_lastIndex],
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'YoungSerif',
                  color: Colors.white,
                  fontSize: 22,
                ),
              ),
              const SizedBox(height: 30),
              BouncyButton(
                text: "ACEPTAR",
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
