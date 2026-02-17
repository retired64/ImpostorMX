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
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../providers/language_provider.dart'; // <--- IMPORTAMOS EL LANGUAGE PROVIDER
import '../widgets/common.dart';
import '../widgets/inputs.dart';
import '../config/theme.dart';
import '../config/constants.dart';

class PlayerSetupScreen extends StatelessWidget {
  const PlayerSetupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final game = Provider.of<GameProvider>(context);
    final lang = Provider.of<LanguageProvider>(
      context,
    ); // <--- INSTANCIAMOS EL IDIOMA
    final count = game.players.where((p) => p.isLocked).length;

    return Scaffold(
      body: GameBackground(
        child: Column(
          children: [
            GameNavBar(
              // Texto dinámico con la variable del conteo inyectada
              title: "${lang.translate('players_title')} ($count)",
              onBack: () => Navigator.pop(context),
              action: IconButton(
                icon: const Icon(Icons.person_add, color: AppColors.accent),
                onPressed: game.addPlayer,
              ),
            ),
            Expanded(
              child: AnimationLimiter(
                child: ListView.separated(
                  padding: const EdgeInsets.all(20),
                  itemCount: game.players.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (ctx, i) => AnimationConfiguration.staggeredList(
                    position: i,
                    duration: const Duration(milliseconds: 375),
                    child: SlideAnimation(
                      verticalOffset: 50.0,
                      child: FadeInAnimation(
                        child: _PlayerRow(
                          key: ValueKey(game.players[i].id),
                          player: game.players[i],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: BouncyButton(
                text: lang.translate(
                  'players_btn_continue',
                ), // <--- TEXTO DINÁMICO
                onPressed: count >= GameConstants.minPlayers
                    ? () => Navigator.pushNamed(context, '/config')
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlayerRow extends StatelessWidget {
  final Player player;
  const _PlayerRow({super.key, required this.player});

  @override
  Widget build(BuildContext context) {
    final game = Provider.of<GameProvider>(context, listen: false);
    final lang = Provider.of<LanguageProvider>(
      context,
    ); // <--- INSTANCIAMOS EL IDIOMA AQUÍ TAMBIÉN

    if (player.isLocked) {
      return GameCard(
        onTap: () => game.unlockPlayer(player.id),
        borderHighlight: true,
        highlightColor: AppColors.accent,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(Icons.check_circle, color: AppColors.accent),
                const SizedBox(width: 10),
                Text(player.name, style: AppTheme.heading(18)),
              ],
            ),
            const Text(
              "••••",
              style: TextStyle(color: Colors.white30, letterSpacing: 4),
            ),
          ],
        ),
      );
    }
    return GameCard(
      child: Row(
        children: [
          if (game.players.length > 3)
            IconButton(
              icon: const Icon(Icons.close, color: AppColors.error),
              onPressed: () => game.removePlayer(player.id),
            ),
          Expanded(
            child: MinimalInput(
              controller: TextEditingController(text: player.name),
              hint: lang.translate('players_input_name'), // <--- TEXTO DINÁMICO
              onChanged: (v) => game.updatePlayer(player.id, name: v),
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 80,
            child: MinimalInput(
              controller: TextEditingController(text: player.pin),
              hint: lang.translate('players_input_pin'), // <--- TEXTO DINÁMICO
              isPassword: true,
              keyboard: TextInputType.number,
              onChanged: (v) => game.updatePlayer(player.id, pin: v),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.save, color: Colors.white),
            onPressed: () => game.lockPlayer(player.id),
          ),
        ],
      ),
    );
  }
}
