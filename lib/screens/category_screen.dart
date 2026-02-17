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
import 'package:audioplayers/audioplayers.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/game_provider.dart';
import '../providers/language_provider.dart'; // <-- Importamos el LanguageProvider
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
    // Necesitamos escuchar los cambios aquí adentro si usamos un modal
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) {
        // Usamos un Builder interno para suscribirnos al provider de idiomas
        return Consumer<LanguageProvider>(
          builder: (context, lang, child) {
            return Container(
              padding: const EdgeInsets.all(25),
              decoration: const BoxDecoration(
                color: AppColors.bgBottom,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                border: Border(
                  top: BorderSide(color: AppColors.accent, width: 2),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    lang.translate('menu_title'),
                    style: const TextStyle(
                      fontFamily: 'Bungee',
                      fontSize: 24,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 25),

                  // 1. BOTÓN CREAR CATEGORÍA (Estilo Ko-fi)
                  _MenuButton(
                    text: lang.translate('btn_create_category'),
                    color: AppColors.accent, // Verde neón
                    textColor: Colors.black,
                    icon: Icons.add_circle_outline,
                    iconColor: Colors.black,
                    onTap: _goToCreateCategory,
                  ),

                  const SizedBox(height: 15),

                  // 2. BOTÓN SITIO OFICIAL (Estilo Ko-fi)
                  _MenuButton(
                    text: lang.translate('btn_official_site'),
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
                  const SizedBox(height: 15),

                  // --- NUEVO SELECTOR DE IDIOMA ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.language,
                        color: Colors.white54,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      _LangButton(
                        text: 'ES',
                        isSelected: lang.currentLanguage == 'es',
                        onTap: () => lang.setLanguage('es'),
                      ),
                      const SizedBox(width: 10),
                      _LangButton(
                        text: 'EN',
                        isSelected: lang.currentLanguage == 'en',
                        onTap: () => lang.setLanguage('en'),
                      ),
                      const SizedBox(width: 10),
                      _LangButton(
                        text: 'PT',
                        isSelected: lang.currentLanguage == 'pt',
                        onTap: () => lang.setLanguage('pt'),
                      ),
                    ],
                  ),

                  const SizedBox(height: 15),
                  const Divider(color: Colors.white24),
                  const SizedBox(height: 10),

                  Text(
                    lang.translate('txt_support'),
                    style: const TextStyle(
                      fontFamily: 'YoungSerif',
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // 3. BOTÓN KO-FI (Con animación especial)
                  _AnimatedKoFiButton(
                    text: lang.translate('btn_kofi'),
                    onTap: _launchKoFi,
                  ),

                  const SizedBox(height: 20),
                  Text(
                    lang.translate('txt_version'),
                    style: const TextStyle(color: Colors.white24, fontSize: 10),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final game = Provider.of<GameProvider>(context);
    final lang = Provider.of<LanguageProvider>(context);
    game.currentLang = lang.currentLanguage;

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
                          const Text(
                            "impostormx.store",
                            style: TextStyle(
                              fontFamily: 'YoungSerif',
                              fontSize: 14,
                              color: AppColors.textDim,
                            ),
                          ),
                          Text(
                            lang.translate('txt_choose_theme'),
                            style: const TextStyle(
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
                      // CORRECCIÓN: Usamos la función dinámica para contar las categorías base del idioma actual
                      final isCustom =
                          i >= getGameCategories(lang.currentLanguage).length;

                      return GestureDetector(
                        onTap: () {
                          SoundManager.playClick();
                          game.selectCategory(cat);
                          Navigator.pushNamed(context, '/players');
                        },
                        onLongPress: isCustom
                            ? () => _showOptions(context, game, cat, lang)
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
                                "${cat.words.length} ${lang.translate('txt_cards')}",
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

  void _showOptions(
    BuildContext context,
    GameProvider game,
    Category cat,
    LanguageProvider lang,
  ) {
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
              title: Text(
                lang.translate('btn_edit'),
                style: const TextStyle(
                  color: Colors.white,
                  fontFamily: 'YoungSerif',
                ),
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
              title: Text(
                lang.translate('btn_delete'),
                style: const TextStyle(
                  color: Colors.white,
                  fontFamily: 'YoungSerif',
                ),
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

// --- WIDGET PARA SELECCIONAR IDIOMA ---
class _LangButton extends StatelessWidget {
  final String text;
  final bool isSelected;
  final VoidCallback onTap;

  const _LangButton({
    required this.text,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        SoundManager.playClick();
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.accent : Colors.white10,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: isSelected ? AppColors.accent : Colors.white24,
            width: 2,
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontFamily: 'Bungee',
            color: isSelected ? Colors.black : Colors.white54,
            fontSize: 14,
          ),
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

// --- WIDGET KO-FI ANIMADO ---
class _AnimatedKoFiButton extends StatefulWidget {
  final String text;
  final VoidCallback onTap;
  const _AnimatedKoFiButton({required this.text, required this.onTap});

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
          height: 60,
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
              Text(
                widget.text,
                style: const TextStyle(
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

// --- WIDGET TUTORIAL CON IDIOMAS ---
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
    final langCode = Provider.of<LanguageProvider>(
      context,
      listen: false,
    ).currentLanguage;
    if (_isPlaying) {
      await _audioPlayer.pause();
      setState(() => _isPlaying = false);
    } else {
      // Usamos la variable langCode para buscar el audio correcto
      await _audioPlayer.play(AssetSource('sounds/$langCode/pasos.mp3'));
      setState(() => _isPlaying = true);
    }
  }

  void _next(int totalSteps) {
    if (_currentStep < totalSteps - 1) {
      setState(() => _currentStep++);
    } else {
      widget.onClose();
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);

    // Los pasos se generan dentro del build para que reaccionen al cambio de idioma
    final List<Map<String, String>> steps = [
      {
        "title": lang.translate('tut_step1_title'),
        "text": lang.translate('tut_step1_desc'),
      },
      {
        "title": lang.translate('tut_step2_title'),
        "text": lang.translate('tut_step2_desc'),
      },
      {
        "title": lang.translate('tut_step3_title'),
        "text": lang.translate('tut_step3_desc'),
      },
      {
        "title": lang.translate('tut_step4_title'),
        "text": lang.translate('tut_step4_desc'),
      },
      {
        "title": lang.translate('tut_step5_title'),
        "text": lang.translate('tut_step5_desc'),
      },
    ];

    final step = steps[_currentStep];
    final isLast = _currentStep == steps.length - 1;

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
                  steps.length,
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
                onPressed: () => _next(steps.length),
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
                  isLast
                      ? lang.translate('tut_btn_finish')
                      : lang.translate('tut_btn_next'),
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
