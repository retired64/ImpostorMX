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
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'config/theme.dart';

// --- PROVIDERS ---
import 'providers/game_provider.dart';
import 'providers/language_provider.dart'; // <-- NUEVO IMPORT

// --- SCREENS ---
import 'screens/category_screen.dart';
import 'screens/player_setup_screen.dart';
import 'screens/config_screen.dart';
import 'screens/login_screen.dart';
import 'screens/reveal_screen.dart';
import 'screens/timer_screen.dart';
import 'screens/voting_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(
    MultiProvider(
      providers: [
        // Instanciamos el manejador de idiomas primero
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
        // Instanciamos el manejador del juego
        ChangeNotifierProvider(create: (_) => GameProvider()),
      ],
      child: const ImpostorApp(),
    ),
  );
}

class ImpostorApp extends StatelessWidget {
  const ImpostorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Impostor MX',
      theme: AppTheme.theme,
      initialRoute: '/',
      routes: {
        '/': (context) => const CategoryScreen(),
        '/players': (context) => const PlayerSetupScreen(),
        '/config': (context) => const ConfigScreen(),
        '/login': (context) => const LoginScreen(),
        '/reveal': (context) => const RevealScreen(),
        '/timer': (context) => const TimerScreen(),
        '/voting': (context) => const VotingScreen(),
      },
    );
  }
}
