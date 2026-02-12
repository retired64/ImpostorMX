import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/game_provider.dart';
import '../widgets/common.dart';
import '../config/theme.dart';
import '../words.dart';
import '../utils/sound_manager.dart';
import 'create_category_screen.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  bool _showTutorial = false;

  // --- FUNCIONES DE NAVEGACIÓN Y URL ---
  Future<void> _launchUrl(String urlString) async {
    final Uri url = Uri.parse(urlString);
    try {
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        debugPrint("No se pudo abrir $url");
      }
    } catch (e) {
      debugPrint("Error abriendo URL: $e");
    }
  }

  Future<void> _launchKoFi() async =>
      await _launchUrl('https://ko-fi.com/impostormx');
  Future<void> _launchOfficialSite() async =>
      await _launchUrl('https://impostormx.store/');

  void _goToCreateCategory() {
    Navigator.pop(context); // Cerrar el modal primero
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CreateCategoryScreen()),
    );
  }

  // --- MOSTRAR EL MENÚ PRINCIPAL (SETTINGS) ---
  void _showSettingsModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => Container(
        padding: const EdgeInsets.all(25),
        decoration: const BoxDecoration(
          color: AppColors.bgBottom,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          border: Border(top: BorderSide(color: AppColors.accent, width: 2)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "MENÚ",
              style: TextStyle(
                fontFamily: 'Bungee',
                fontSize: 24,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 25),

            // 1. BOTÓN CREAR CATEGORÍA (Estilo Ko-fi)
            _MenuButton(
              text: "Crear Categoría",
              color: AppColors.accent, // Verde neón
              textColor: Colors.black,
              icon: Icons.add_circle_outline,
              iconColor: Colors.black,
              onTap: _goToCreateCategory,
            ),

            const SizedBox(height: 15),

            // 2. BOTÓN SITIO OFICIAL (Estilo Ko-fi)
            _MenuButton(
              text: "Sitio Oficial",
              color: const Color(0xFF800020), // Rojo Vino
              textColor: Colors.white,
              // Usamos tu imagen png aquí
              customIcon: Image.asset(
                'assets/images/impostor.png',
                height: 24,
                errorBuilder: (c, o, s) =>
                    const Icon(Icons.public, color: Colors.white),
              ),
              onTap: _launchOfficialSite,
            ),

            const SizedBox(height: 25),
            const Divider(color: Colors.white24),
            const SizedBox(height: 10),

            const Text(
              "¡Apoya el desarrollo!",
              style: TextStyle(
                fontFamily: 'YoungSerif',
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 10),

            // 3. BOTÓN KO-FI (Con animación especial)
            _AnimatedKoFiButton(onTap: _launchKoFi),

            const SizedBox(height: 20),
            const Text(
              "v2.0 Open Source - by Retired64",
              style: TextStyle(color: Colors.white24, fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final game = Provider.of<GameProvider>(context);

    return Scaffold(
      floatingActionButton: _showTutorial
          ? null
          : FloatingActionButton(
              backgroundColor: AppColors.accent,
              onPressed: () => setState(() => _showTutorial = true),
              child: const Icon(
                Icons.help_outline,
                color: Colors.black,
                size: 30,
              ),
            ),

      body: Stack(
        children: [
          GameBackground(
            child: Column(
              children: [
                // --- CABECERA LIMPIA Y MEJORADA ---
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Títulos
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "impostormx.store",
                            style: TextStyle(
                              fontFamily: 'YoungSerif',
                              fontSize: 14,
                              color: AppColors.textDim,
                            ),
                          ),
                          Text(
                            "Elige un tema",
                            style: TextStyle(
                              fontFamily: 'Bungee',
                              fontSize: 32,
                              color: AppColors.text,
                            ),
                          ),
                        ],
                      ),

                      // ÚNICO BOTÓN: AJUSTES (Mejorado)
                      GestureDetector(
                        onTap: () => _showSettingsModal(context),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.accent,
                              width: 2,
                            ), // Borde verde neón
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.accent.withOpacity(0.2),
                                blurRadius: 10,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.settings,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // GRID DE CATEGORÍAS
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.all(20),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 15,
                          mainAxisSpacing: 15,
                          childAspectRatio: 0.85,
                        ),
                    itemCount: game.allCategories.length,
                    itemBuilder: (ctx, i) {
                      final cat = game.allCategories[i];
                      final isCustom = i >= GAME_CATEGORIES.length;
                      return GestureDetector(
                        onTap: () {
                          SoundManager.playClick();
                          game.selectCategory(cat);
                          Navigator.pushNamed(context, '/players');
                        },
                        onLongPress: isCustom
                            ? () => _showOptions(context, game, cat)
                            : null,
                        child: Container(
                          decoration: BoxDecoration(
                            color: cat.color.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: cat.color.withOpacity(0.5),
                              width: 2,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                cat.icon,
                                style: const TextStyle(fontSize: 50),
                              ),
                              const SizedBox(height: 15),
                              Text(
                                cat.name,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontFamily: 'Bungee',
                                  fontSize: 18,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                "${cat.words.length} cartas",
                                style: const TextStyle(
                                  fontFamily: 'YoungSerif',
                                  fontSize: 12,
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // TUTORIAL
          if (_showTutorial)
            GestureDetector(
              onTap: () => setState(() => _showTutorial = false),
              child: Container(
                color: Colors.black87,
                width: double.infinity,
                height: double.infinity,
              ),
            ),

          if (_showTutorial)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _TutorialCard(
                  onClose: () => setState(() => _showTutorial = false),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _showOptions(BuildContext context, GameProvider game, Category cat) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: AppColors.bgBottom,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit, color: AppColors.accent),
              title: const Text(
                "Editar",
                style: TextStyle(color: Colors.white, fontFamily: 'YoungSerif'),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CreateCategoryScreen(categoryToEdit: cat),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: AppColors.error),
              title: const Text(
                "Eliminar",
                style: TextStyle(color: Colors.white, fontFamily: 'YoungSerif'),
              ),
              onTap: () {
                Navigator.pop(context);
                game.deleteCustomCategory(cat.id);
              },
            ),
          ],
        ),
      ),
    );
  }
}

// --- WIDGET GENÉRICO DE MENÚ (Estilo Ko-fi pero estático) ---
class _MenuButton extends StatelessWidget {
  final String text;
  final Color color;
  final Color textColor;
  final IconData? icon;
  final Widget? customIcon;
  final Color? iconColor;
  final VoidCallback onTap;

  const _MenuButton({
    required this.text,
    required this.color,
    required this.textColor,
    this.icon,
    this.customIcon,
    this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 55,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: Colors.white.withOpacity(0.8), width: 2),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.5),
              blurRadius: 15,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (customIcon != null) customIcon!,
            if (icon != null)
              Icon(icon, color: iconColor ?? textColor, size: 26),
            const SizedBox(width: 10),
            Text(
              text,
              style: TextStyle(
                fontFamily: 'Bungee',
                color: textColor,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- WIDGET KO-FI ANIMADO (El original con latido) ---
class _AnimatedKoFiButton extends StatefulWidget {
  final VoidCallback onTap;
  const _AnimatedKoFiButton({required this.onTap});

  @override
  State<_AnimatedKoFiButton> createState() => _AnimatedKoFiButtonState();
}

class _AnimatedKoFiButtonState extends State<_AnimatedKoFiButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: Tween(
        begin: 0.95,
        end: 1.05,
      ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut)),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          height: 60, // Un pelín más grande para resaltar
          decoration: BoxDecoration(
            color: const Color(0xFF29ABE0),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF29ABE0).withOpacity(0.5),
                blurRadius: 15,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Image.asset(
                  'assets/images/kofi.png',
                  errorBuilder: (c, o, s) =>
                      const Icon(Icons.coffee, color: Colors.white),
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                "Invítame un Café",
                style: TextStyle(
                  fontFamily: 'Bungee',
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
              const SizedBox(width: 20),
            ],
          ),
        ),
      ),
    );
  }
}

// --- WIDGET TUTORIAL (Sin cambios) ---
class _TutorialCard extends StatefulWidget {
  final VoidCallback onClose;
  const _TutorialCard({required this.onClose});

  @override
  State<_TutorialCard> createState() => _TutorialCardState();
}

class _TutorialCardState extends State<_TutorialCard> {
  int _currentStep = 0;
  late AudioPlayer _audioPlayer;
  bool _isPlaying = false;

  final List<Map<String, String>> _steps = [
    {
      "title": "PASO 1",
      "text":
          "Elige una categoría temática para jugar. ¡Usa el botón de Ajustes (⚙️) para crear las tuyas propias!",
    },
    {
      "title": "PASO 2",
      "text":
          "Pasa el celular para que cada uno configure su nombre y PIN, una vez completado dale em continuar y configura cuántos Impostores habrá en la partida. ahí mismo puedes configurar el tiempo de debate y poner tus propios castigos de la ruleta.",
    },
    {
      "title": "PASO 3",
      "text":
          "Pasen el celular. Cada jugador deberá ingresar su PIN, una vez completado verá su palabra secreta, pero... ¡El Impostor no verá nada!",
    },
    {
      "title": "PASO 4",
      "text":
          "¡A debatir! Hagan preguntas y describan su palabra sin ser muy obvios para no ayudar al Impostor.",
    },
    {
      "title": "PASO 5",
      "text":
          "Cuando el tiempo acabe, voten por quien crean que miente. ¡Si atrapan al Impostor, ganan los civiles! Si el Impostor sobrevive, gana él! El perdedor de la partida tendrá que girar la ruleta de castigos... ¡Suerte!",
    },
  ];

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _audioPlayer.onPlayerComplete.listen((event) {
      if (mounted) setState(() => _isPlaying = false);
    });
  }

  @override
  void dispose() {
    _audioPlayer.stop();
    _audioPlayer.dispose();
    super.dispose();
  }

  void _toggleAudio() async {
    if (_isPlaying) {
      await _audioPlayer.pause();
      setState(() => _isPlaying = false);
    } else {
      await _audioPlayer.play(AssetSource('sounds/pasos.mp3'));
      setState(() => _isPlaying = true);
    }
  }

  void _next() {
    if (_currentStep < _steps.length - 1) {
      setState(() => _currentStep++);
    } else {
      widget.onClose();
    }
  }

  @override
  Widget build(BuildContext context) {
    final step = _steps[_currentStep];
    final isLast = _currentStep == _steps.length - 1;
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: AppColors.bgBottom,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: AppColors.accent, width: 2),
        boxShadow: [
          BoxShadow(
            color: AppColors.accent.withOpacity(0.3),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                step["title"]!,
                style: const TextStyle(
                  fontFamily: 'Bungee',
                  fontSize: 24,
                  color: AppColors.accent,
                ),
              ),
              Row(
                children: [
                  IconButton(
                    onPressed: _toggleAudio,
                    icon: Icon(
                      _isPlaying ? Icons.stop_circle_outlined : Icons.volume_up,
                      color: _isPlaying ? AppColors.error : Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 5),
                  IconButton(
                    onPressed: widget.onClose,
                    icon: const Icon(Icons.close, color: Colors.white54),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 15),
          Text(
            step["text"]!,
            style: const TextStyle(
              fontFamily: 'YoungSerif',
              fontSize: 18,
              color: Colors.white,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: List.generate(
                  _steps.length,
                  (index) => Container(
                    margin: const EdgeInsets.only(right: 6),
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: index == _currentStep
                          ? Colors.white
                          : Colors.white24,
                    ),
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: _next,
                style: ElevatedButton.styleFrom(
                  backgroundColor: isLast ? AppColors.error : AppColors.accent,
                  foregroundColor: isLast ? Colors.white : Colors.black,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  isLast ? "FINALIZAR" : "SIGUIENTE",
                  style: const TextStyle(fontFamily: 'Bungee', fontSize: 14),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
