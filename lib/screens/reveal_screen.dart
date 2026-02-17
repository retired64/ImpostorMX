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

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vibration/vibration.dart';
import '../providers/game_provider.dart';
import '../providers/language_provider.dart'; // <--- IMPORTAMOS EL LANGUAGE PROVIDER
import '../widgets/common.dart';
import '../widgets/inputs.dart';
import '../config/theme.dart';
import '../config/constants.dart';
import 'login_screen.dart';
import 'timer_screen.dart';

class RevealScreen extends StatefulWidget {
  const RevealScreen({super.key});
  @override
  State<RevealScreen> createState() => _RevealScreenState();
}

class _RevealScreenState extends State<RevealScreen> {
  bool _isPeeking = false;

  @override
  Widget build(BuildContext context) {
    final game = Provider.of<GameProvider>(context);
    final lang = Provider.of<LanguageProvider>(
      context,
    ); // <--- INSTANCIAMOS EL IDIOMA

    final isImpostor = game.getCurrentPlayer().role == 'impostor';
    final roleColor = isImpostor ? AppColors.error : AppColors.accent;

    return Scaffold(
      body: GameBackground(
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                lang.translate('reveal_hold'),
                style: AppTheme.heading(20),
              ), // <--- TEXTO DINÁMICO
              const SizedBox(height: 10),
              Text(
                lang.translate('reveal_to_see'),
                style: AppTheme.body(14),
              ), // <--- TEXTO DINÁMICO
              const Spacer(),
              GestureDetector(
                onTapDown: (_) {
                  setState(() => _isPeeking = true);
                  Vibration.vibrate(pattern: GameConstants.hapticPeek);
                },
                onTapUp: (_) => setState(() => _isPeeking = false),
                onTapCancel: () => setState(() => _isPeeking = false),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  width: 300,
                  height: 400,
                  decoration: BoxDecoration(
                    color: _isPeeking
                        ? AppColors.bgBottom
                        : AppColors.cardHidden,
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: _isPeeking ? roleColor : Colors.white24,
                      width: _isPeeking ? 4 : 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: _isPeeking
                            ? roleColor.withOpacity(0.4)
                            : Colors.black45,
                        blurRadius: 30,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: _isPeeking
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              isImpostor ? Icons.fingerprint : Icons.search,
                              size: 80,
                              color: roleColor,
                            ),
                            const SizedBox(height: 20),
                            Text(
                              isImpostor
                                  ? lang.translate('reveal_impostor')
                                  : lang.translate(
                                      'reveal_civilian',
                                    ), // <--- TEXTO DINÁMICO
                              style: TextStyle(
                                fontFamily: 'YoungSerif',
                                fontSize: 36,
                                color: roleColor,
                              ),
                            ),
                            const SizedBox(height: 30),
                            if (!isImpostor)
                              Text(
                                game.secretWord.toUpperCase(),
                                style: const TextStyle(
                                  fontFamily: 'YoungSerif',
                                  fontSize: 40,
                                  color: Colors.white,
                                ),
                              ),
                            if (isImpostor)
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                ),
                                child: Text(
                                  lang.translate(
                                    'reveal_deceive',
                                  ), // <--- TEXTO DINÁMICO
                                  textAlign: TextAlign.center,
                                  style: AppTheme.body(18),
                                ),
                              ),
                          ],
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.lock,
                              size: 60,
                              color: Colors.white24,
                            ),
                            const SizedBox(height: 20),
                            Text(
                              lang.translate(
                                'reveal_top_secret',
                              ), // <--- TEXTO DINÁMICO
                              style: const TextStyle(
                                fontFamily: 'YoungSerif',
                                fontSize: 30,
                                color: Colors.white24,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.all(30),
                child: BouncyButton(
                  text: lang.translate(
                    'reveal_btn_continue',
                  ), // <--- TEXTO DINÁMICO
                  color: Colors.white,
                  onPressed: () {
                    final active = game.players
                        .where((p) => p.isLocked)
                        .toList();
                    if (game.currentTurnIndex < active.length - 1) {
                      game.nextTurn();
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                      );
                    } else {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const TimerScreen()),
                      );
                    }
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
