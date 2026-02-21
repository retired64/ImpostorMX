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

import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vibration/vibration.dart';
import '../providers/game_provider.dart';
import '../providers/language_provider.dart';
import '../widgets/common.dart';
import '../widgets/inputs.dart';
import '../config/theme.dart';
import 'login_screen.dart';
import 'timer_screen.dart';

// ─────────────────────────────────────────────
//  RevealScreen – root widget
// ─────────────────────────────────────────────
class RevealScreen extends StatefulWidget {
  const RevealScreen({super.key});

  @override
  State<RevealScreen> createState() => _RevealScreenState();
}

class _RevealScreenState extends State<RevealScreen>
    with TickerProviderStateMixin {
  bool _isPeeking = false;

  // ── Flip (card reveal) ────────────────────────
  late final AnimationController _flipCtrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 420),
  );
  late final Animation<double> _flipAnim = Tween<double>(
    begin: 0.0,
    end: 1.0,
  ).animate(CurvedAnimation(parent: _flipCtrl, curve: Curves.easeInOutCubic));

  // ── Impostor glitch / shake ───────────────────
  late final AnimationController _glitchCtrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 90),
  );
  late final Animation<double> _glitchAnim = TweenSequence<double>([
    TweenSequenceItem(tween: Tween(begin: 0.0, end: -5.0), weight: 1),
    TweenSequenceItem(tween: Tween(begin: -5.0, end: 5.0), weight: 2),
    TweenSequenceItem(tween: Tween(begin: 5.0, end: -3.0), weight: 2),
    TweenSequenceItem(tween: Tween(begin: -3.0, end: 3.0), weight: 2),
    TweenSequenceItem(tween: Tween(begin: 3.0, end: 0.0), weight: 1),
  ]).animate(CurvedAnimation(parent: _glitchCtrl, curve: Curves.linear));

  // ── Background dim for impostor ───────────────
  late final AnimationController _dimCtrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 350),
  );
  late final Animation<double> _dimAnim = Tween<double>(
    begin: 0.0,
    end: 0.45,
  ).animate(CurvedAnimation(parent: _dimCtrl, curve: Curves.easeOut));

  // ── Glow pulse ────────────────────────────────
  late final AnimationController _pulseCtrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  )..repeat(reverse: true);
  late final Animation<double> _pulseAnim = Tween<double>(
    begin: 0.55,
    end: 1.0,
  ).animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));

  @override
  void dispose() {
    _flipCtrl.dispose();
    _glitchCtrl.dispose();
    _dimCtrl.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  // ─────────────────────────────────────────────
  //  Press logic (IDENTICAL haptics for both roles)
  // ─────────────────────────────────────────────
  Future<void> _onPressDown(bool isImpostor) async {
    if (_isPeeking) return;
    setState(() => _isPeeking = true);

    // Vibración corta, seca y silenciosa. Idéntica para Civil o Impostor.
    Vibration.vibrate(duration: 40);

    await _flipCtrl.forward();
    if (isImpostor && mounted) {
      _dimCtrl.forward();
      _startGlitchLoop();
    }
  }

  void _startGlitchLoop() {
    if (!mounted || !_isPeeking) return;
    _glitchCtrl.forward(from: 0).then((_) {
      if (mounted && _isPeeking) {
        Future.delayed(
          Duration(milliseconds: 600 + math.Random().nextInt(800)),
          () => _startGlitchLoop(),
        );
      }
    });
  }

  Future<void> _onPressUp() async {
    if (!_isPeeking) return;
    setState(() => _isPeeking = false);
    _glitchCtrl.stop();
    _dimCtrl.reverse();
    await _flipCtrl.reverse();
  }

  // ─────────────────────────────────────────────
  //  Build
  // ─────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final game = Provider.of<GameProvider>(context);
    final lang = Provider.of<LanguageProvider>(context);
    final p = game.getCurrentPlayer();
    final isImpostor = p.role == 'impostor';
    final roleColor = isImpostor ? AppColors.error : AppColors.accent;

    return Scaffold(
      body: GameBackground(
        child: Stack(
          children: [
            // ── Background dim overlay (impostor only) ──
            AnimatedBuilder(
              animation: _dimAnim,
              builder: (_, __) => IgnorePointer(
                child: Container(
                  color: Colors.black.withOpacity(_dimAnim.value),
                ),
              ),
            ),

            // ── Main layout ──────────────────────────────
            SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final cardWidth =
                      constraints.maxWidth *
                      (constraints.maxWidth > 600 ? 0.5 : 0.82);
                  final cardHeight = cardWidth * 1.42;

                  return Column(
                    children: [
                      SizedBox(height: constraints.maxHeight * 0.04),
                      _buildInstructions(lang, constraints, isImpostor),
                      const Spacer(),
                      _buildCard(
                        lang: lang,
                        game: game,
                        isImpostor: isImpostor,
                        roleColor: roleColor,
                        cardWidth: cardWidth,
                        cardHeight: cardHeight,
                        constraints: constraints,
                      ),
                      const Spacer(),
                      _buildContinueButton(lang, game),
                      SizedBox(height: constraints.maxHeight * 0.03),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  //  Instruction header
  // ─────────────────────────────────────────────
  Widget _buildInstructions(
    LanguageProvider lang,
    BoxConstraints constraints,
    bool isImpostor,
  ) {
    return Column(
      children: [
        Text(
          lang.translate('reveal_hold').toUpperCase(),
          style: TextStyle(
            fontFamily: 'Bungee',
            fontSize: constraints.maxWidth * 0.055,
            color: Colors.white,
            letterSpacing: 2,
            shadows: [
              Shadow(color: AppColors.accent.withOpacity(0.5), blurRadius: 10),
            ],
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: constraints.maxHeight * 0.008),
        Text(
          lang.translate('reveal_to_see'),
          style: TextStyle(
            fontFamily: 'YoungSerif',
            fontSize: constraints.maxWidth * 0.038,
            color: Colors.white38,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────
  //  Flip card
  // ─────────────────────────────────────────────
  Widget _buildCard({
    required LanguageProvider lang,
    required GameProvider game,
    required bool isImpostor,
    required Color roleColor,
    required double cardWidth,
    required double cardHeight,
    required BoxConstraints constraints,
  }) {
    return GestureDetector(
      onTapDown: (_) => _onPressDown(isImpostor),
      onTapUp: (_) => _onPressUp(),
      onTapCancel: () => _onPressUp(),
      child: AnimatedBuilder(
        animation: Listenable.merge([_flipAnim, _glitchAnim, _pulseAnim]),
        builder: (context, _) {
          final angle = _flipAnim.value * math.pi;
          final isShowingBack = angle > math.pi / 2;
          final displayAngle = isShowingBack ? angle - math.pi : angle;

          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateY(displayAngle)
              ..translate(_glitchAnim.value, 0.0),
            child: isShowingBack
                ? _CardFront(
                    isImpostor: isImpostor,
                    roleColor: roleColor,
                    cardWidth: cardWidth,
                    cardHeight: cardHeight,
                    game: game,
                    lang: lang,
                    pulseValue: _pulseAnim.value,
                    constraints: constraints,
                  )
                : _CardBack(
                    cardWidth: cardWidth,
                    cardHeight: cardHeight,
                    lang: lang,
                    constraints: constraints,
                  ),
          );
        },
      ),
    );
  }

  // ─────────────────────────────────────────────
  //  Continue button
  // ─────────────────────────────────────────────
  Widget _buildContinueButton(LanguageProvider lang, GameProvider game) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: BouncyButton(
        text: lang.translate('reveal_btn_continue'),
        color: Colors.white,
        onPressed: () {
          final active = game.players.where((p) => p.isLocked).toList();
          if (game.currentTurnIndex < active.length - 1) {
            game.nextTurn();
            Navigator.pushReplacement(context, _fadeRoute(const LoginScreen()));
          } else {
            Navigator.pushReplacement(context, _fadeRoute(const TimerScreen()));
          }
        },
      ),
    );
  }

  Route _fadeRoute(Widget page) => PageRouteBuilder(
    pageBuilder: (_, __, ___) => page,
    transitionDuration: const Duration(milliseconds: 400),
    transitionsBuilder: (_, anim, __, child) =>
        FadeTransition(opacity: anim, child: child),
  );
}

// ─────────────────────────────────────────────
//  Card Back (hidden state)
// ─────────────────────────────────────────────
class _CardBack extends StatelessWidget {
  final double cardWidth;
  final double cardHeight;
  final LanguageProvider lang;
  final BoxConstraints constraints;

  const _CardBack({
    required this.cardWidth,
    required this.cardHeight,
    required this.lang,
    required this.constraints,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(cardWidth * 0.1),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          width: cardWidth,
          height: cardHeight,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(cardWidth * 0.1),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(0.07),
                Colors.white.withOpacity(0.02),
              ],
            ),
            border: Border.all(
              color: Colors.white.withOpacity(0.12),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.55),
                blurRadius: 40,
                spreadRadius: 8,
              ),
            ],
          ),
          child: _SecurityPattern(
            cardWidth: cardWidth,
            cardHeight: cardHeight,
            lang: lang,
            constraints: constraints,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Security pattern inside the card back
// ─────────────────────────────────────────────
class _SecurityPattern extends StatelessWidget {
  final double cardWidth;
  final double cardHeight;
  final LanguageProvider lang;
  final BoxConstraints constraints;

  const _SecurityPattern({
    required this.cardWidth,
    required this.cardHeight,
    required this.lang,
    required this.constraints,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Decorative diagonal lines (security pattern)
        CustomPaint(
          size: Size(cardWidth, cardHeight),
          painter: _SecurityLinePainter(),
        ),
        // Central content
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.fingerprint,
                size: cardWidth * 0.28,
                color: Colors.white.withOpacity(0.15),
              ),
              SizedBox(height: cardHeight * 0.04),
              Text(
                lang.translate('reveal_top_secret').toUpperCase(),
                style: TextStyle(
                  fontFamily: 'Bungee',
                  fontSize: cardWidth * 0.08,
                  color: Colors.white.withOpacity(0.2),
                  letterSpacing: 3,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: cardHeight * 0.025),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: cardWidth * 0.08,
                  vertical: cardHeight * 0.012,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.1),
                    width: 1,
                  ),
                ),
                child: Text(
                  'IMPOSTOR MX',
                  style: TextStyle(
                    fontFamily: 'YoungSerif',
                    fontSize: cardWidth * 0.06,
                    color: Colors.white.withOpacity(0.12),
                    letterSpacing: 4,
                  ),
                ),
              ),
              SizedBox(height: cardHeight * 0.06),
              Icon(
                Icons.touch_app_outlined,
                size: cardWidth * 0.12,
                color: Colors.white.withOpacity(0.18),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
//  Card Front (revealed state)
// ─────────────────────────────────────────────
class _CardFront extends StatelessWidget {
  final bool isImpostor;
  final Color roleColor;
  final double cardWidth;
  final double cardHeight;
  final GameProvider game;
  final LanguageProvider lang;
  final double pulseValue;
  final BoxConstraints constraints;

  const _CardFront({
    required this.isImpostor,
    required this.roleColor,
    required this.cardWidth,
    required this.cardHeight,
    required this.game,
    required this.lang,
    required this.pulseValue,
    required this.constraints,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(cardWidth * 0.1),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          width: cardWidth,
          height: cardHeight,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(cardWidth * 0.1),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isImpostor
                  ? [
                      AppColors.error.withOpacity(0.18),
                      Colors.black.withOpacity(0.6),
                      AppColors.error.withOpacity(0.08),
                    ]
                  : [
                      AppColors.accent.withOpacity(0.18),
                      Colors.black.withOpacity(0.5),
                      AppColors.accent.withOpacity(0.06),
                    ],
              stops: const [0.0, 0.5, 1.0],
            ),
            border: Border.all(
              color: roleColor.withOpacity(0.55 + pulseValue * 0.35),
              width: 2.5,
            ),
            boxShadow: [
              BoxShadow(
                color: roleColor.withOpacity(0.35 * pulseValue),
                blurRadius: 45,
                spreadRadius: 10,
              ),
              BoxShadow(
                color: roleColor.withOpacity(0.15),
                blurRadius: 20,
                spreadRadius: 3,
              ),
            ],
          ),
          child: isImpostor
              ? _ImpostorContent(
                  lang: lang,
                  roleColor: roleColor,
                  cardWidth: cardWidth,
                  cardHeight: cardHeight,
                  pulseValue: pulseValue,
                )
              : _CivilianContent(
                  lang: lang,
                  roleColor: roleColor,
                  secretWord: game.secretWord,
                  cardWidth: cardWidth,
                  cardHeight: cardHeight,
                ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Civilian card content
// ─────────────────────────────────────────────
class _CivilianContent extends StatelessWidget {
  final LanguageProvider lang;
  final Color roleColor;
  final String secretWord;
  final double cardWidth;
  final double cardHeight;

  const _CivilianContent({
    required this.lang,
    required this.roleColor,
    required this.secretWord,
    required this.cardWidth,
    required this.cardHeight,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.shield_outlined, size: cardWidth * 0.22, color: roleColor),
        SizedBox(height: cardHeight * 0.03),
        Text(
          lang.translate('reveal_civilian').toUpperCase(),
          style: TextStyle(
            fontFamily: 'Bungee',
            fontSize: cardWidth * 0.09,
            color: roleColor,
            letterSpacing: 2,
            shadows: [
              Shadow(color: roleColor.withOpacity(0.6), blurRadius: 12),
            ],
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: cardHeight * 0.05),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: cardWidth * 0.06),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: cardWidth * 0.07,
              vertical: cardHeight * 0.025,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(cardWidth * 0.06),
              color: Colors.white.withOpacity(0.06),
              border: Border.all(
                color: Colors.white.withOpacity(0.15),
                width: 1,
              ),
            ),
            child: Text(
              secretWord.toUpperCase(),
              style: TextStyle(
                fontFamily: 'Bungee',
                fontSize: cardWidth * 0.13,
                color: Colors.white,
                letterSpacing: 3,
                shadows: [
                  Shadow(color: roleColor.withOpacity(0.4), blurRadius: 16),
                ],
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        SizedBox(height: cardHeight * 0.04),
        Text(
          'TU PALABRA SECRETA',
          style: TextStyle(
            fontFamily: 'YoungSerif',
            fontSize: cardWidth * 0.055,
            color: Colors.white30,
            letterSpacing: 2,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
//  Impostor card content
// ─────────────────────────────────────────────
class _ImpostorContent extends StatelessWidget {
  final LanguageProvider lang;
  final Color roleColor;
  final double cardWidth;
  final double cardHeight;
  final double pulseValue;

  const _ImpostorContent({
    required this.lang,
    required this.roleColor,
    required this.cardWidth,
    required this.cardHeight,
    required this.pulseValue,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Glitch scan-line decorative effect
        CustomPaint(
          size: Size(cardWidth, cardHeight),
          painter: _GlitchScanlinePainter(roleColor, pulseValue),
        ),
        // Content
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.visibility_off_outlined,
              size: cardWidth * 0.25,
              color: roleColor.withOpacity(0.8 + pulseValue * 0.2),
            ),
            SizedBox(height: cardHeight * 0.025),
            ShaderMask(
              shaderCallback: (bounds) => LinearGradient(
                colors: [roleColor, Colors.white, roleColor],
                stops: const [0.0, 0.5, 1.0],
              ).createShader(bounds),
              child: Text(
                lang.translate('reveal_impostor').toUpperCase(),
                style: TextStyle(
                  fontFamily: 'Bungee',
                  fontSize: cardWidth * 0.1,
                  color: Colors.white,
                  letterSpacing: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: cardHeight * 0.04),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: cardWidth * 0.08),
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: cardWidth * 0.06,
                  vertical: cardHeight * 0.022,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(cardWidth * 0.05),
                  color: roleColor.withOpacity(0.08),
                  border: Border.all(
                    color: roleColor.withOpacity(0.3),
                    width: 1.5,
                  ),
                ),
                child: Text(
                  lang.translate('reveal_deceive'),
                  style: TextStyle(
                    fontFamily: 'YoungSerif',
                    fontSize: cardWidth * 0.065,
                    color: Colors.white70,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
//  Custom Painters
// ─────────────────────────────────────────────
class _SecurityLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.025)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    const spacing = 18.0;
    for (double i = -size.height; i < size.width + size.height; i += spacing) {
      canvas.drawLine(
        Offset(i, 0),
        Offset(i + size.height, size.height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_SecurityLinePainter old) => false;
}

class _GlitchScanlinePainter extends CustomPainter {
  final Color color;
  final double pulseValue;

  const _GlitchScanlinePainter(this.color, this.pulseValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(0.03 + pulseValue * 0.04)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    for (double y = 0; y < size.height; y += 8) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(_GlitchScanlinePainter old) =>
      old.pulseValue != pulseValue;
}
