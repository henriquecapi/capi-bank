// Arte do joguinho — Capi-Bank
// Traducao em CustomPaint da arte do login do SemUmReal (login-game.jpg):
// sol-moeda com $ e raios, montanhas cinzas, chao preto pixelado e,
// embaixo, um dolarzinho (nota de dolar com bracos e pernas) correndo
// da esquerda para a direita, estilo Mario side-scroller.
// So preto, branco e cinza — nada de verde. Animado com
// AnimationController; ha tambem uma versao estatica para telas vazias.

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

/// Sol-moeda estatico: circulo com $ no meio e raios em volta.
class PixelSunCoin extends StatelessWidget {
  final double size;
  const PixelSunCoin({super.key, this.size = 96});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _SunCoinPainter()),
    );
  }
}

class _SunCoinPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = size.width * 0.32;
    final ink = Paint()
      ..color = AppColors.ink
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    final fill = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    // Raios: 12 tracinhos pixel ao redor do circulo.
    final ray = Paint()
      ..color = AppColors.ink
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.square;
    for (var i = 0; i < 12; i++) {
      final a = i * math.pi / 6;
      final p1 = Offset(
        c.dx + math.cos(a) * (r + 6),
        c.dy + math.sin(a) * (r + 6),
      );
      final p2 = Offset(
        c.dx + math.cos(a) * (r + 16),
        c.dy + math.sin(a) * (r + 16),
      );
      canvas.drawLine(p1, p2, ray);
    }

    canvas.drawCircle(c, r, fill);
    canvas.drawCircle(c, r, ink);
    canvas.drawCircle(c, r * 0.72, ink);

    final tp = TextPainter(
      text: TextSpan(
        text: '\$',
        style: GoogleFonts.pressStart2p(
          fontSize: r * 0.85,
          color: AppColors.ink,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(
      canvas,
      Offset(c.dx - tp.width / 2, c.dy - tp.height / 2),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

/// Nota de dolar com bracos e pernas, desenhada numa caixa 120x80.
/// [phase] alterna as pernas (0 ou 1) para o efeito de corrida.
/// [jump] 0 no chao, 1 no auge do pulo: no ar as pernas fecham
/// e ficam paradas juntas; ao voltar ao chao, abrem de novo
/// e a corrida continua.
class _DollarBillPainter extends CustomPainter {
  final int phase; // 0 ou 1
  final double bob; // 0..1, altura do pulo
  final double jump; // 0..1, quanto do pulo do toque

  _DollarBillPainter({required this.phase, required this.bob, this.jump = 0});

  @override
  void paint(Canvas canvas, Size size) {
    final ink = Paint()
      ..color = AppColors.ink
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.square;
    final inkFill = Paint()
      ..color = AppColors.ink
      ..style = PaintingStyle.fill;
    final whiteFill = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    // Pulo: o corpo inteiro sobe alguns pixels no meio do passo.
    canvas.translate(0, -4 * bob);

    // --- Pernas (alternam a cada passo) ---
    final legPaint = Paint()
      ..color = AppColors.ink
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.square;
    final hipY = 58.0;
    final groundY = 76.0;
    if (jump > 0.05) {
      // No ar: pernas fechadas e paradas juntas, sem alternar.
      canvas.drawLine(Offset(48, hipY), Offset(54, groundY - 6), legPaint);
      canvas.drawLine(Offset(72, hipY), Offset(66, groundY - 6), legPaint);
      canvas.drawRect(Rect.fromLTWH(48, groundY - 8, 10, 4), inkFill);
      canvas.drawRect(Rect.fromLTWH(62, groundY - 8, 10, 4), inkFill);
    } else if (phase == 0) {
      // Perna esquerda a frente, direita atras.
      canvas.drawLine(Offset(48, hipY), Offset(40, groundY), legPaint);
      canvas.drawLine(Offset(72, hipY), Offset(82, groundY - 4), legPaint);
      canvas.drawRect(Rect.fromLTWH(34, groundY - 2, 10, 4), inkFill);
      canvas.drawRect(Rect.fromLTWH(80, groundY - 6, 10, 4), inkFill);
    } else {
      canvas.drawLine(Offset(48, hipY), Offset(38, groundY - 4), legPaint);
      canvas.drawLine(Offset(72, hipY), Offset(80, groundY), legPaint);
      canvas.drawRect(Rect.fromLTWH(32, groundY - 6, 10, 4), inkFill);
      canvas.drawRect(Rect.fromLTWH(78, groundY - 2, 10, 4), inkFill);
    }

    // --- Bracos (para tras, como correndo) ---
    canvas.drawLine(const Offset(10, 34), const Offset(0, 26), legPaint);
    canvas.drawLine(const Offset(110, 34), const Offset(120, 26), legPaint);

    // --- Corpo: a nota ---
    const bill = Rect.fromLTWH(10, 18, 100, 40);
    canvas.drawRect(bill, whiteFill);
    canvas.drawRect(bill, ink);
    canvas.drawRect(const Rect.fromLTWH(16, 24, 88, 28), ink);

    // $ nas laterais e no meio (circulo com $).
    final dollar = (double fontSize, Offset at) {
      final tp = TextPainter(
        text: TextSpan(
          text: '\$',
          style: GoogleFonts.pressStart2p(
            fontSize: fontSize,
            color: AppColors.ink,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, at);
    };
    dollar(12, const Offset(22, 30));
    dollar(12, const Offset(88, 30));
    canvas.drawCircle(const Offset(60, 38), 11, whiteFill);
    canvas.drawCircle(const Offset(60, 38), 11, ink);
    dollar(11, const Offset(55, 32));
  }

  @override
  bool shouldRepaint(covariant _DollarBillPainter old) =>
      old.phase != phase || old.bob != bob || old.jump != jump;
}

/// Fundo da cena: ceu loginSky, montanhas cinzas e chao preto pixelado.
class _GameScenePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Montanhas cinzas em degraus (pixel), atras.
    final lightGrey = Paint()..color = AppColors.stage;
    final midGrey = Paint()..color = AppColors.muted;
    final ground = Paint()..color = AppColors.ink;

    Path mountain(double base, double peakX, double peakY, double w) {
      final p = Path();
      p.moveTo(peakX - w, base);
      // Subida em degraus.
      p.lineTo(peakX - w * 0.6, base - (base - peakY) * 0.55);
      p.lineTo(peakX - w * 0.35, base - (base - peakY) * 0.55);
      p.lineTo(peakX - w * 0.15, base - (base - peakY) * 0.85);
      p.lineTo(peakX, peakY);
      p.lineTo(peakX + w * 0.2, base - (base - peakY) * 0.7);
      p.lineTo(peakX + w * 0.45, base - (base - peakY) * 0.7);
      p.lineTo(peakX + w, base);
      p.close();
      return p;
    }

    canvas.drawPath(
      mountain(size.height - 18, size.width * 0.22, size.height * 0.42, size.width * 0.3),
      lightGrey,
    );
    canvas.drawPath(
      mountain(size.height - 18, size.width * 0.78, size.height * 0.3, size.width * 0.34),
      midGrey,
    );

    // Chao preto com pedrinhas brancas/cinzas.
    canvas.drawRect(
      Rect.fromLTWH(0, size.height - 18, size.width, 18),
      ground,
    );
    final speck = Paint()..color = Colors.white;
    final speckGrey = Paint()..color = AppColors.stage;
    final rng = math.Random(7); // fixo: mesmo chao em todo frame
    for (var i = 0; i < 26; i++) {
      final x = rng.nextDouble() * size.width;
      final y = size.height - 16 + rng.nextDouble() * 12;
      canvas.drawRect(
        Rect.fromLTWH(x, y, 4, 3),
        i.isEven ? speck : speckGrey,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

/// Arte animada do login: sol-moeda em cima, dolarzinho correndo
/// da esquerda para a direita sobre o chao, estilo Mario.
/// Interativa: tocar na area do jogo faz o dinheirinho pular.
/// Nao e video — e animacao desenhada em CustomPaint, por isso
/// responde ao toque.
class CoinGame extends StatefulWidget {
  final double height;
  const CoinGame({super.key, this.height = 210});

  @override
  State<CoinGame> createState() => _CoinGameState();
}

class _CoinGameState extends State<CoinGame>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final AnimationController _jumpCtrl;

  void _jump() {
    if (_jumpCtrl.isAnimating) return;
    _jumpCtrl.forward(from: 0);
  }

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();
    _jumpCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _jumpCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _jump,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        height: widget.height,
        width: double.infinity,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            return AnimatedBuilder(
              animation: Listenable.merge([_ctrl, _jumpCtrl]),
              builder: (context, _) {
                final t = _ctrl.value;
                // Da esquerda (fora da tela) ate a direita (fora da tela).
                final x = -90 + t * (width + 180);
                final phase = ((t * 12).floor()) % 2;
                final bob = (math.sin(t * math.pi * 12)).abs() * 0.5;
                // Pulo do toque: sobe e desce em 650 ms, ate 80 px.
                final jumpProgress = math.sin(_jumpCtrl.value * math.pi);
                final jumpY = jumpProgress * 80;
                return Stack(
                  children: [
                    Positioned.fill(
                      child: CustomPaint(painter: _GameScenePainter()),
                    ),
                    // Dica do toque, em cima a esquerda.
                    Positioned(
                      left: 16,
                      top: 8,
                      child: Text(
                        'TOQUE PARA PULAR',
                        style: GoogleFonts.pressStart2p(
                          fontSize: 9,
                          color: AppColors.ink,
                        ),
                      ),
                    ),
                    // Sol-moeda no canto superior direito.
                    const Positioned(
                      right: 16,
                      top: 4,
                      child: PixelSunCoin(size: 84),
                    ),
                    Positioned(
                      left: x,
                      bottom: 10 + jumpY,
                      child: SizedBox(
                        width: 120,
                        height: 80,
                        child: CustomPaint(
                          painter: _DollarBillPainter(
                            phase: phase,
                            // No ar o balanco da corrida para, as pernas ficam fechadas.
                            bob: jumpProgress > 0.05 ? 0 : bob,
                            jump: jumpProgress,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }
}

/// Versao estatica da cena (sem animacao), para telas vazias.
class CoinGameStatic extends StatelessWidget {
  final double height;
  const CoinGameStatic({super.key, this.height = 150});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: Stack(
        children: [
          Positioned.fill(child: CustomPaint(painter: _GameScenePainter())),
          const Positioned(
            right: 16,
            top: 4,
            child: PixelSunCoin(size: 64),
          ),
          Positioned(
            left: 32,
            bottom: 10,
            child: SizedBox(
              width: 120,
              height: 80,
              child: CustomPaint(
                painter: _DollarBillPainter(phase: 0, bob: 0),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
