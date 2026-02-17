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
import '../providers/language_provider.dart'; // Importación necesaria
import '../widgets/common.dart';
import '../widgets/inputs.dart';
import '../config/theme.dart';

class PunishmentsScreen extends StatefulWidget {
  const PunishmentsScreen({super.key});
  @override
  State<PunishmentsScreen> createState() => _PunishmentsScreenState();
}

class _PunishmentsScreenState extends State<PunishmentsScreen> {
  final _controller = TextEditingController();

  void _add(GameProvider game) {
    if (_controller.text.trim().isEmpty) return;
    game.addPunishment(_controller.text.trim());
    _controller.clear();
    FocusScope.of(context).unfocus(); // Ocultar teclado
  }

  @override
  Widget build(BuildContext context) {
    final game = Provider.of<GameProvider>(context);
    final lang = Provider.of<LanguageProvider>(context);

    return Scaffold(
      body: GameBackground(
        child: Column(
          children: [
            GameNavBar(
              title: lang.translate('punishments_title'),
              onBack: () => Navigator.pop(context),
              action: IconButton(
                icon: const Icon(Icons.restore, color: AppColors.error),
                onPressed: () => _confirmReset(context, game, lang),
              ),
            ),

            // Input para agregar nuevo
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Expanded(
                    child: MinimalInput(
                      controller: _controller,
                      hint: lang.translate('punishments_input_hint'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  IconButton(
                    icon: const Icon(
                      Icons.add_circle,
                      color: AppColors.accent,
                      size: 40,
                    ),
                    onPressed: () => _add(game),
                  ),
                ],
              ),
            ),

            // Lista de castigos
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                itemCount: game.punishments.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (ctx, i) {
                  return Dismissible(
                    key: UniqueKey(),
                    direction: DismissDirection.endToStart,
                    onDismissed: (_) => game.removePunishment(i),
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 20),
                      decoration: BoxDecoration(
                        color: AppColors.error,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    child: GameCard(
                      child: Row(
                        children: [
                          Text(
                            "${i + 1}.",
                            style: const TextStyle(
                              color: Colors.white30,
                              fontFamily: 'Bungee',
                            ),
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: Text(
                              game.punishments[i],
                              style: const TextStyle(
                                fontFamily: 'YoungSerif',
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            // Nota informativa
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                lang.translate('punishments_swipe_delete'),
                style: AppTheme.body(12),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmReset(
    BuildContext context,
    GameProvider game,
    LanguageProvider lang,
  ) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.bgBottom,
        title: Text(
          lang.translate('punishments_restore_title'),
          style: const TextStyle(color: Colors.white, fontFamily: 'Bungee'),
        ),
        content: Text(
          lang.translate('punishments_restore_desc'),
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(lang.translate('punishments_btn_cancel')),
          ),
          TextButton(
            onPressed: () {
              // Aquí se soluciona el error pidiendo los castigos correspondientes
              final defaultPunishments = lang.getDefaultPunishments();
              game.resetPunishments(defaultPunishments);
              Navigator.pop(context);
            },
            child: Text(
              lang.translate('punishments_btn_restore'),
              style: const TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}
