// Arte do joguinho — Capi-Bank
// Traducao em CustomPaint da arte do login do SemUmReal (login-game.jpg):
// sol sem $ no meio e com raios, montanhas cinzas, chao preto pixelado e,
// embaixo, um dolarzinho (nota de dolar com bracos e pernas) correndo
// da esquerda para a direita, estilo Mario side-scroller.
// Base preto, branco e cinza. Animado com
// AnimationController; ha tambem uma versao estatica para telas vazias.
// Carregar (segurar e riscar): o sol enche de baixo para cima
// como um copo d'agua, o dourado subindo ate virar moeda amarela,
// e o dinheirinho carrega junto, ficando verde — os dois com o
// mesmo progresso, sem mostrar percentual.

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

/// Sol estatico: circulo sem $ no meio, so com raios em volta.
/// [gold] 0 = sol branco P&B, 1 = moedinha totalmente dourada/amarela.
/// O dourado enche de baixo para cima, como um copo d'agua.
class PixelSunCoin extends StatelessWidget {
  final double size;
  final double gold;
  const PixelSunCoin({super.key, this.size = 96, this.gold = 0});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _SunCoinPainter(gold: gold)),
    );
  }
}

class _SunCoinPainter extends CustomPainter {
  final double gold; // 0..1
  _SunCoinPainter({this.gold = 0});

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = size.width * 0.32;
    final outline = Color.lerp(AppColors.ink, AppColors.goldDark, gold)!;
    final ink = Paint()
      ..color = outline
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    final whiteFill = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    final goldFill = Paint()
      ..color = AppColors.gold
      ..style = PaintingStyle.fill;

    // Raios: 12 tracinhos pixel ao redor do circulo.
    // Virando moeda, os raios encolhem ate quase sumir.
    final ray = Paint()
      ..color = outline
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.square;
    final rayLen = 16 - 10 * gold;
    for (var i = 0; i < 12; i++) {
      final a = i * math.pi / 6;
      final p1 = Offset(
        c.dx + math.cos(a) * (r + 6),
        c.dy + math.sin(a) * (r + 6),
      );
      final p2 = Offset(
        c.dx + math.cos(a) * (r + 6 + rayLen),
        c.dy + math.sin(a) * (r + 6 + rayLen),
      );
      canvas.drawLine(p1, p2, ray);
    }

    // Enche de baixo para cima como um copo d'agua: o dourado
    // sobe de dentro do circulo, recortado pela borda dele.
    // gold = 0: tudo branco. gold = 1: tudo dourado.
    canvas.save();
    canvas.clipPath(Path()..addOval(Rect.fromCircle(center: c, radius: r)));
    canvas.drawCircle(c, r, whiteFill);
    if (gold > 0) {
      final fillHeight = 2 * r * gold;
      canvas.drawRect(
        Rect.fromLTWH(c.dx - r, c.dy + r - fillHeight, 2 * r, fillHeight),
        goldFill,
      );
    }
    canvas.restore();
    canvas.drawCircle(c, r, ink);
    canvas.drawCircle(c, r * 0.72, ink);
    // Sem $ no meio do sol — fica so o circulo limpo.
  }

  @override
  bool shouldRepaint(covariant _SunCoinPainter old) => old.gold != gold;
}

/// Nota de dolar com bracos e pernas, desenhada numa caixa 120x80.
/// [phase] alterna as pernas (0 ou 1) para o efeito de corrida.
/// [jump] 0 no chao, 1 no auge do pulo: no ar as pernas fecham
/// e ficam paradas juntas; ao voltar ao chao, abrem de novo
/// e a corrida continua.
/// [green] 0 = nota branca P&B, 1 = nota totalmente verde.
/// Carrega junto com o sol (mesmo progresso do riscar):
/// sol vira moeda amarela, dinheiro vira verde.
class _DollarBillPainter extends CustomPainter {
  final int phase; // 0 ou 1
  final double bob; // 0..1, altura do pulo
  final double jump; // 0..1, quanto do pulo do toque
  final double green; // 0..1, quanto o dinheiro ja carregou

  _DollarBillPainter(
      {required this.phase, required this.bob, this.jump = 0, this.green = 0});

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
    // A nota carrega em verde junto com o sol: 0 = branca, 1 = verde.
    final billFill = Paint()
      ..color = Color.lerp(Colors.white, AppColors.moneyGreen, green)!
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
    canvas.drawRect(bill, billFill);
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
    canvas.drawCircle(const Offset(60, 38), 11, billFill);
    canvas.drawCircle(const Offset(60, 38), 11, ink);
    dollar(11, const Offset(55, 32));
  }

  @override
  bool shouldRepaint(covariant _DollarBillPainter old) =>
      old.phase != phase ||
      old.bob != bob ||
      old.jump != jump ||
      old.green != green;
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

/// Arte animada do login: sol em cima, dolarzinho correndo
/// da esquerda para a direita sobre o chao, estilo Mario.
/// Interativa: toque rapido na area faz o dinheirinho pular.
/// Segurar e riscar a area toda (dedo no celular, mouse no
/// computador) vai revelando a moedinha dourada no lugar do sol
/// e deixando o dinheirinho verde, os dois com o mesmo progresso;
/// ao soltar, os dois voltam suavemente ao P&B. Sem percentual
/// na tela — o carregamento se ve so pela cor. O sol tambem tem
/// uma tremidinha de falha da Matrix de tempos em tempos.
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

  // Riscar: 0 = sol normal, 1 = moedinha 100% dourada.
  double _scratch = 0;
  bool _scratching = false;
  bool _fading = false;

  void _jump() {
    if (_jumpCtrl.isAnimating) return;
    _jumpCtrl.forward(from: 0);
  }

  void _onPanStart(DragStartDetails details) {
    _scratching = true;
    _fading = false;
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (!_scratching) return;
    // Cada ~600 px riscados revelam 100% da moedinha.
    setState(() {
      _scratch = (_scratch + details.delta.distance / 600).clamp(0, 1).toDouble();
    });
  }

  void _onPanEnd(DragEndDetails details) {
    _scratching = false;
    _fadeScratch();
  }

  Future<void> _fadeScratch() async {
    if (_fading) return;
    _fading = true;
    // Some suavemente em ~600 ms ao soltar o dedo/mouse.
    while (mounted && _scratch > 0 && !_scratching) {
      await Future.delayed(const Duration(milliseconds: 16));
      if (!mounted || _scratching) break;
      setState(() => _scratch = (_scratch - 0.03).clamp(0, 1).toDouble());
    }
    _fading = false;
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
      onPanStart: _onPanStart,
      onPanUpdate: _onPanUpdate,
      onPanEnd: _onPanEnd,
      onPanCancel: () {
        _scratching = false;
        _fadeScratch();
      },
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
                // Falha da Matrix no sol: a cada ~2,5 s ele treme
                // rapido por 0,3 s e volta ao normal.
                final seconds = t * 6;
                final inGlitch = (seconds % 2.5) < 0.3 ? 1.0 : 0.0;
                final glitchX = inGlitch * math.sin(seconds * 80) * 2.5;
                final glitchY = inGlitch * math.cos(seconds * 63) * 2;
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
                        'TOQUE PULA • RISQUE P/ DOURAR',
                        style: GoogleFonts.pressStart2p(
                          fontSize: 8,
                          color: AppColors.ink,
                        ),
                      ),
                    ),
                    // Sol sem $ no meio, com tremidinha da Matrix
                    // e virando moeda dourada conforme o quanto
                    // foi riscado. Tela maior que 600: sol no
                    // centro; tela menor: sol a direita, como antes.
                    Positioned(
                      left: width > 600 ? (width - 84) / 2 : null,
                      right: width > 600 ? null : 16,
                      top: 4,
                      child: Transform.translate(
                        offset: Offset(glitchX, glitchY),
                        child: PixelSunCoin(size: 84, gold: _scratch),
                      ),
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
                            // Dinheiro carrega em verde junto com o sol.
                            green: _scratch,
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
