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
import '../providers/game_provider.dart';
import '../providers/language_provider.dart'; // <--- IMPORTANTE: Importamos el LanguageProvider
import '../widgets/common.dart';
import '../widgets/inputs.dart';
import '../config/theme.dart';
import 'login_screen.dart';
import 'punishments_screen.dart';

class ConfigScreen extends StatelessWidget {
  const ConfigScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final game = Provider.of<GameProvider>(context);
    final lang = Provider.of<LanguageProvider>(
      context,
    ); // <--- Instanciamos el provider de idioma

    return Scaffold(
      body: GameBackground(
        child: Column(
          children: [
            GameNavBar(
              title: lang.translate('config_title'), // <--- Texto dinámico
              onBack: () => Navigator.pop(context),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _Counter(
                      lang.translate('config_impostors'), // <--- Texto dinámico
                      "${game.impostorCount}",
                      game.adjustImpostors,
                    ),
                    const SizedBox(height: 20),
                    _Counter(
                      lang.translate('config_time'), // <--- Texto dinámico
                      "${(game.initialTimeSeconds / 60).floor()}:${(game.initialTimeSeconds % 60).toString().padLeft(2, '0')}",
                      (d) => game.adjustTime(d * 30),
                    ),

                    // --- NUEVO BOTÓN PARA EDITAR CASTIGOS ---
                    const SizedBox(height: 30),
                    GameCard(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const PunishmentsScreen(),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Quitamos el const de la lista para permitir datos dinámicos
                          Text(
                            lang.translate(
                              'config_edit_punishments',
                            ), // <--- Texto dinámico
                            style: const TextStyle(
                              fontFamily: 'Bungee',
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                          const Icon(Icons.edit_note, color: AppColors.accent),
                        ],
                      ),
                    ),
                    // ----------------------------------------
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: BouncyButton(
                text: lang.translate('config_btn_start'), // <--- Texto dinámico
                onPressed: () {
                  game.startGame();
                  // Usamos pushAndRemoveUntil para reiniciar la pila de navegación
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                    (r) => false,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Counter extends StatelessWidget {
  final String label;
  final String value;
  final Function(int) onChange;
  const _Counter(this.label, this.value, this.onChange);

  @override
  Widget build(BuildContext context) {
    return GameCard(
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 14,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _RoundBtn(icon: Icons.remove, onTap: () => onChange(-1)),
              Text(value, style: AppTheme.heading(36)),
              _RoundBtn(icon: Icons.add, onTap: () => onChange(1)),
            ],
          ),
        ],
      ),
    );
  }
}

class _RoundBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _RoundBtn({required this.icon, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
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
}
