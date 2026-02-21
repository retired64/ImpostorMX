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

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../providers/language_provider.dart'; // <--- IMPORTAMOS EL LANGUAGE PROVIDER
import '../widgets/common.dart';
import '../widgets/inputs.dart';
import '../config/theme.dart';
import 'voting_screen.dart';

class TimerScreen extends StatefulWidget {
  const TimerScreen({super.key});
  @override
  State<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final g = Provider.of<GameProvider>(context, listen: false);
      g.startTimer();
      g.addListener(_listener);
    });
  }

  void _listener() {
    final g = Provider.of<GameProvider>(context, listen: false);
    final lang = Provider.of<LanguageProvider>(
      context,
      listen: false,
    ); // <--- INSTANCIAMOS EL IDIOMA PARA EL MODAL

    if (g.status == GameStatus.finished && mounted) {
      showDialog(
        barrierDismissible: false,
        context: context,
        builder: (_) => BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Dialog(
            backgroundColor: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                color: AppColors.bgBottom,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: AppColors.error, width: 2),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.timer_off, color: AppColors.error, size: 50),
                  const SizedBox(height: 20),
                  Text(
                    lang.translate('timer_time_up'),
                    style: AppTheme.heading(30),
                  ), // <--- TEXTO DINÁMICO
                  const SizedBox(height: 30),
                  BouncyButton(
                    text: lang.translate(
                      'timer_btn_vote',
                    ), // <--- TEXTO DINÁMICO
                    onPressed: () {
                      g.stopAudio();
                      Navigator.pop(context);
                      g.finishGameAndVote();
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const VotingScreen()),
                      );
                    },
                    color: AppColors.error,
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    try {
      Provider.of<GameProvider>(
        context,
        listen: false,
      ).removeListener(_listener);
    } catch (_) {}
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final g = Provider.of<GameProvider>(context);
    final lang = Provider.of<LanguageProvider>(
      context,
    ); // <--- INSTANCIAMOS EL IDIOMA PARA LA PANTALLA
    final progress = g.remainingSeconds / g.initialTimeSeconds;

    return PopScope(
      canPop: false,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: GameBackground(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                lang.translate('timer_debate'),
                style: AppTheme.heading(20),
              ), // <--- TEXTO DINÁMICO
              const SizedBox(height: 10),

              // --- AQUÍ ESTÁ EL CAMBIO CLAVE ---
              Text(
                g.selectedCategoriesName,
                style: const TextStyle(
                  color: AppColors.accent,
                  letterSpacing: 2,
                ),
              ),

              // ---------------------------------
              const Spacer(),
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 250,
                    height: 250,
                    child: CircularProgressIndicator(
                      value: progress,
                      strokeWidth: 15,
                      backgroundColor: Colors.white10,
                      color: progress < 0.2
                          ? AppColors.error
                          : AppColors.accent,
                    ),
                  ),
                  Text(
                    "${(g.remainingSeconds / 60).floor()}:${(g.remainingSeconds % 60).toString().padLeft(2, '0')}",
                    style: const TextStyle(
                      fontFamily: 'YoungSerif',
                      fontSize: 60,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _RoundBtn(
                    icon: g.isTimerRunning ? Icons.pause : Icons.play_arrow,
                    onTap: g.isTimerRunning ? g.pauseTimer : g.startTimer,
                  ),
                  const SizedBox(width: 20),
                  _RoundBtn(icon: Icons.add_alarm, onTap: g.addExtraTime),
                ],
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.all(30),
                child: BouncyButton(
                  text: lang.translate('timer_btn_vote'), // <--- TEXTO DINÁMICO
                  color: Colors.white,
                  onPressed: () {
                    g.finishGameAndVote();
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const VotingScreen()),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoundBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _RoundBtn({required this.icon, required this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white24),
      ),
      child: Icon(icon, color: Colors.white),
    ),
  );
}
