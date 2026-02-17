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
import '../providers/language_provider.dart'; // <--- IMPORTAMOS EL LANGUAGE PROVIDER
import '../widgets/common.dart';
import '../config/theme.dart';
import 'result_screen.dart';

class VotingScreen extends StatelessWidget {
  const VotingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final game = Provider.of<GameProvider>(context);
    final lang = Provider.of<LanguageProvider>(
      context,
    ); // <--- INSTANCIAMOS EL IDIOMA

    return Scaffold(
      body: GameBackground(
        child: Column(
          children: [
            GameNavBar(
              title: lang.translate('voting_title'), // <--- TEXTO DINÁMICO
              onBack: () => Navigator.pop(context),
            ),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.all(20),
                itemCount: game.players.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (ctx, i) {
                  final p = game.players[i];
                  return GameCard(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                          backgroundColor: AppColors.bgBottom,
                          title: Text(
                            // Sustituimos la etiqueta [NAME] por el nombre real del jugador
                            lang
                                .translate('voting_confirm_title')
                                .replaceAll('[NAME]', p.name),
                            style: const TextStyle(color: Colors.white),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text(
                                lang.translate(
                                  'voting_btn_cancel',
                                ), // <--- TEXTO DINÁMICO
                                style: const TextStyle(color: Colors.white54),
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        ResultScreen(votedPlayer: p),
                                  ),
                                );
                              },
                              child: Text(
                                lang.translate(
                                  'voting_btn_confirm',
                                ), // <--- TEXTO DINÁMICO
                                style: const TextStyle(
                                  color: AppColors.accent,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(p.name, style: AppTheme.heading(18)),
                        const Icon(Icons.how_to_vote, color: Colors.white24),
                      ],
                    ),
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
