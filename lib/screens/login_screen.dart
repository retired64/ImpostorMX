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
import '../config/theme.dart';
import '../config/constants.dart';
import 'reveal_screen.dart';
import '../utils/sound_manager.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String pin = "";

  void _tap(String val, Player p) {
    setState(() {
      if (pin.length < 4) pin += val;

      if (pin.length == 4) {
        // Validar PIN
        if (pin == p.pin) {
          Vibration.vibrate(pattern: GameConstants.hapticSuccess);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const RevealScreen()),
          );
        } else {
          Vibration.vibrate(pattern: GameConstants.hapticError);
          // Pequeña animación visual o delay podría ir aquí,
          // pero por ahora solo limpiamos
          Future.delayed(const Duration(milliseconds: 200), () {
            if (mounted) setState(() => pin = "");
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final p = Provider.of<GameProvider>(context).getCurrentPlayer();
    final lang = Provider.of<LanguageProvider>(
      context,
    ); // <--- OBTENEMOS EL PROVIDER

    return Scaffold(
      body: GameBackground(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.lock_outline, color: Colors.white54, size: 40),
            const SizedBox(height: 20),

            // Texto traducido: "Turno de"
            Text(lang.translate('login_turn_of'), style: AppTheme.body(16)),

            const SizedBox(height: 5),
            Text(p.name, style: AppTheme.heading(32)),
            const SizedBox(height: 40),

            // Indicadores de PIN (puntos)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                4,
                (i) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: i < pin.length ? AppColors.accent : Colors.white10,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 50),

            // Teclado numérico
            _Numpad(
              onTap: (v) => _tap(v, p),
              onBack: () => setState(
                () => pin = pin.isNotEmpty
                    ? pin.substring(0, pin.length - 1)
                    : "",
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Numpad extends StatelessWidget {
  final Function(String) onTap;
  final VoidCallback onBack;
  const _Numpad({required this.onTap, required this.onBack});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 280,
      child: Wrap(
        spacing: 20,
        runSpacing: 20,
        alignment: WrapAlignment.center,
        children: [
          ...List.generate(9, (i) => _NumKey("${i + 1}", onTap)),
          const SizedBox(width: 80), // Espacio para centrar el 0
          _NumKey("0", onTap),
          GestureDetector(
            onTap: onBack,
            child: Container(
              width: 80,
              height: 80,
              alignment: Alignment.center,
              child: const Icon(
                Icons.backspace_outlined,
                color: AppColors.error,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NumKey extends StatelessWidget {
  final String val;
  final Function(String) onTap;
  const _NumKey(this.val, this.onTap);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Vibration.vibrate(duration: 10);
        SoundManager.playClick();
        onTap(val);
      },
      child: Container(
        width: 80,
        height: 80,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withOpacity(0.05),
        ),
        child: Text(
          val,
          style: const TextStyle(
            fontSize: 28,
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
