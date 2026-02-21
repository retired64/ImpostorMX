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

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vibration/vibration.dart';
import '../providers/game_provider.dart';
import '../providers/language_provider.dart';
import '../widgets/common.dart';
import '../config/theme.dart';
import '../config/constants.dart';
import 'reveal_screen.dart';
import '../utils/sound_manager.dart';

// ─────────────────────────────────────────────
//  LoginScreen – root widget
// ─────────────────────────────────────────────
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  String _pin = '';

  // ── Shake controller (error) ──────────────────
  late final AnimationController _shakeCtrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 500),
  );
  late final Animation<double> _shakeAnim = TweenSequence<double>([
    TweenSequenceItem(tween: Tween(begin: 0, end: -12), weight: 1),
    TweenSequenceItem(tween: Tween(begin: -12, end: 12), weight: 2),
    TweenSequenceItem(tween: Tween(begin: 12, end: -10), weight: 2),
    TweenSequenceItem(tween: Tween(begin: -10, end: 10), weight: 2),
    TweenSequenceItem(tween: Tween(begin: 10, end: -6), weight: 2),
    TweenSequenceItem(tween: Tween(begin: -6, end: 6), weight: 2),
    TweenSequenceItem(tween: Tween(begin: 6, end: 0), weight: 1),
  ]).animate(CurvedAnimation(parent: _shakeCtrl, curve: Curves.linear));

  // ── Flash‑error colour controller ────────────
  late final AnimationController _flashCtrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 600),
  );
  late final Animation<Color?> _flashColor = ColorTween(
    begin: AppColors.accent,
    end: AppColors.error,
  ).animate(CurvedAnimation(parent: _flashCtrl, curve: Curves.easeInOut));

  // ── Success glow controller ───────────────────
  late final AnimationController _successCtrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 400),
  );
  late final Animation<double> _successScale = Tween<double>(
    begin: 1.0,
    end: 1.6,
  ).animate(CurvedAnimation(parent: _successCtrl, curve: Curves.easeOut));

  // ── State flags ───────────────────────────────
  bool _isError = false;
  bool _isSuccess = false;

  @override
  void dispose() {
    _shakeCtrl.dispose();
    _flashCtrl.dispose();
    _successCtrl.dispose();
    super.dispose();
  }

  // ─────────────────────────────────────────────
  //  Input logic
  // ─────────────────────────────────────────────
  Future<void> _tap(String val, Player p) async {
    if (_isError || _isSuccess || _pin.length >= 4) return;

    setState(() => _pin += val);

    if (_pin.length == 4) {
      if (_pin == p.pin) {
        await _handleSuccess();
      } else {
        await _handleError();
      }
    }
  }

  Future<void> _handleSuccess() async {
    setState(() => _isSuccess = true);
    Vibration.vibrate(pattern: GameConstants.hapticSuccess);
    await _successCtrl.forward();
    if (!mounted) return;
    await Future.delayed(const Duration(milliseconds: 150));
    if (!mounted) return;
    Navigator.pushReplacement(context, _buildFadeRoute(const RevealScreen()));
  }

  Future<void> _handleError() async {
    setState(() => _isError = true);
    Vibration.vibrate(pattern: GameConstants.hapticError);
    _flashCtrl.forward();
    await _shakeCtrl.forward();
    _shakeCtrl.reset();
    _flashCtrl.reset();
    await Future.delayed(const Duration(milliseconds: 80));
    if (mounted) {
      setState(() {
        _pin = '';
        _isError = false;
      });
    }
  }

  void _backspace() {
    if (_isError || _isSuccess) return;
    setState(() {
      if (_pin.isNotEmpty) _pin = _pin.substring(0, _pin.length - 1);
    });
  }

  // ─────────────────────────────────────────────
  //  Build
  // ─────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final p = Provider.of<GameProvider>(context).getCurrentPlayer();
    final lang = Provider.of<LanguageProvider>(context);

    return Scaffold(
      body: GameBackground(
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isTablet = constraints.maxWidth > 600;
              final contentWidth = isTablet
                  ? constraints.maxWidth * 0.55
                  : constraints.maxWidth;

              return Center(
                child: SizedBox(
                  width: contentWidth,
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: constraints.maxWidth * 0.06,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildHeader(lang, p, constraints),
                        SizedBox(height: constraints.maxHeight * 0.05),
                        _buildPinIndicators(constraints),
                        SizedBox(height: constraints.maxHeight * 0.06),
                        _buildNumpad(p, constraints),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  //  Header section
  // ─────────────────────────────────────────────
  Widget _buildHeader(
    LanguageProvider lang,
    Player p,
    BoxConstraints constraints,
  ) {
    final lockSize = constraints.maxWidth * 0.11;
    return Column(
      children: [
        // Glassmorphic lock badge
        ClipRRect(
          borderRadius: BorderRadius.circular(lockSize * 0.35),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(
              width: lockSize,
              height: lockSize,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(lockSize * 0.35),
                color: Colors.white.withOpacity(0.07),
                border: Border.all(
                  color: AppColors.accent.withOpacity(0.35),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.accent.withOpacity(0.25),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Icon(
                Icons.lock_outline_rounded,
                color: AppColors.accent,
                size: lockSize * 0.52,
              ),
            ),
          ),
        ),
        SizedBox(height: constraints.maxHeight * 0.025),
        // "Turno de" label
        Text(
          lang.translate('login_turn_of').toUpperCase(),
          style: TextStyle(
            fontFamily: 'YoungSerif',
            fontSize: constraints.maxWidth * 0.038,
            color: Colors.white54,
            letterSpacing: 2.5,
          ),
        ),
        SizedBox(height: constraints.maxHeight * 0.008),
        // Player name with neon shimmer
        ShaderMask(
          shaderCallback: (bounds) => LinearGradient(
            colors: [Colors.white, AppColors.accent, Colors.white],
            stops: const [0.0, 0.5, 1.0],
          ).createShader(bounds),
          child: Text(
            p.name,
            style: TextStyle(
              fontFamily: 'Bungee',
              fontSize: constraints.maxWidth * 0.092,
              color: Colors.white,
              letterSpacing: 1.5,
              shadows: [
                Shadow(
                  color: AppColors.accent.withOpacity(0.6),
                  blurRadius: 18,
                ),
              ],
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────
  //  PIN dot indicators
  // ─────────────────────────────────────────────
  Widget _buildPinIndicators(BoxConstraints constraints) {
    final dotSize = constraints.maxWidth * 0.048;
    final dotSpacing = constraints.maxWidth * 0.05;

    return AnimatedBuilder(
      animation: Listenable.merge([_shakeAnim, _flashColor, _successScale]),
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(_shakeAnim.value, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(4, (i) {
              final isFilled = i < _pin.length;
              final dotColor = _isError
                  ? (_flashColor.value ?? AppColors.error)
                  : _isSuccess
                  ? Colors.greenAccent.shade200
                  : AppColors.accent;

              return Padding(
                padding: EdgeInsets.symmetric(horizontal: dotSpacing / 2),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  curve: Curves.easeOut,
                  width: isFilled
                      ? dotSize * (_isSuccess ? _successScale.value : 1.2)
                      : dotSize,
                  height: isFilled
                      ? dotSize * (_isSuccess ? _successScale.value : 1.2)
                      : dotSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isFilled ? dotColor : Colors.transparent,
                    border: Border.all(
                      color: isFilled
                          ? dotColor
                          : Colors.white.withOpacity(0.2),
                      width: 2,
                    ),
                    boxShadow: isFilled
                        ? [
                            BoxShadow(
                              color: dotColor.withOpacity(0.7),
                              blurRadius: 12,
                              spreadRadius: 2,
                            ),
                          ]
                        : null,
                  ),
                ),
              );
            }),
          ),
        );
      },
    );
  }

  // ─────────────────────────────────────────────
  //  Numpad
  // ─────────────────────────────────────────────
  Widget _buildNumpad(Player p, BoxConstraints constraints) {
    // 3 columns, responsive key size
    final availableWidth =
        constraints.maxWidth * 0.88; // respects horizontal padding
    final keySpacing = availableWidth * 0.055;
    final keySize = (availableWidth - keySpacing * 2) / 3;

    return SizedBox(
      width: availableWidth,
      child: Column(
        children: [
          // Rows 1-3: digits 1-9
          ...List.generate(3, (row) {
            return Padding(
              padding: EdgeInsets.only(bottom: keySpacing),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(3, (col) {
                  final digit = '${row * 3 + col + 1}';
                  return _NumKey(
                    val: digit,
                    size: keySize,
                    onTap: () => _tap(digit, p),
                  );
                }),
              ),
            );
          }),
          // Row 4: empty | 0 | backspace
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(width: keySize, height: keySize), // spacer
              _NumKey(val: '0', size: keySize, onTap: () => _tap('0', p)),
              _BackspaceKey(size: keySize, onTap: _backspace),
            ],
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  //  Route helper
  // ─────────────────────────────────────────────
  Route _buildFadeRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (_, __, ___) => page,
      transitionDuration: const Duration(milliseconds: 450),
      transitionsBuilder: (_, anim, __, child) =>
          FadeTransition(opacity: anim, child: child),
    );
  }
}

// ─────────────────────────────────────────────
//  Numeric key with press animation
// ─────────────────────────────────────────────
class _NumKey extends StatefulWidget {
  final String val;
  final double size;
  final VoidCallback onTap;

  const _NumKey({required this.val, required this.size, required this.onTap});

  @override
  State<_NumKey> createState() => _NumKeyState();
}

class _NumKeyState extends State<_NumKey> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 80),
    reverseDuration: const Duration(milliseconds: 200),
  );
  late final Animation<double> _scale = Tween<double>(
    begin: 1.0,
    end: 0.82,
  ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeIn));
  late final Animation<double> _glow = Tween<double>(
    begin: 0.0,
    end: 1.0,
  ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _onTap() async {
    Vibration.vibrate(duration: 10);
    SoundManager.playClick();
    widget.onTap();
    await _ctrl.forward();
    await _ctrl.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _onTap,
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (context, child) {
          return Transform.scale(
            scale: _scale.value,
            child: Container(
              width: widget.size,
              height: widget.size,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Colors.white.withOpacity(0.09 + _glow.value * 0.06),
                    Colors.white.withOpacity(0.03),
                  ],
                ),
                border: Border.all(
                  color: AppColors.accent.withOpacity(0.15 + _glow.value * 0.4),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.accent.withOpacity(_glow.value * 0.45),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: child,
            ),
          );
        },
        child: Text(
          widget.val,
          style: TextStyle(
            fontFamily: 'Bungee',
            fontSize: widget.size * 0.38,
            color: Colors.white,
            shadows: [
              Shadow(color: AppColors.accent.withOpacity(0.5), blurRadius: 8),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Backspace key
// ─────────────────────────────────────────────
class _BackspaceKey extends StatefulWidget {
  final double size;
  final VoidCallback onTap;

  const _BackspaceKey({required this.size, required this.onTap});

  @override
  State<_BackspaceKey> createState() => _BackspaceKeyState();
}

class _BackspaceKeyState extends State<_BackspaceKey>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 80),
    reverseDuration: const Duration(milliseconds: 200),
  );
  late final Animation<double> _scale = Tween<double>(
    begin: 1.0,
    end: 0.78,
  ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeIn));

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _onTap() async {
    Vibration.vibrate(duration: 8);
    SoundManager.playClick();
    widget.onTap();
    await _ctrl.forward();
    await _ctrl.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _onTap,
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (context, _) {
          return Transform.scale(
            scale: _scale.value,
            child: Container(
              width: widget.size,
              height: widget.size,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.error.withOpacity(0.12),
                    AppColors.error.withOpacity(0.03),
                  ],
                ),
                border: Border.all(
                  color: AppColors.error.withOpacity(0.3),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.error.withOpacity(0.08),
                    blurRadius: 14,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Icon(
                Icons.backspace_rounded,
                color: AppColors.error,
                size: widget.size * 0.38,
              ),
            ),
          );
        },
      ),
    );
  }
}
