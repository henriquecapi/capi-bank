// Barra de abas pixel — Capi-Bank
// Traducao visual da TabBar do SemUmReal-mobile para Flutter.
// Original (tab-bar.tsx): altura minima 72, fundo branco (paper),
// borda superior de 2px preta, 5 icones de 24px, ativo = ink #111111,
// inativo = muted #6B6B6B, espacamento lateral 16.
// Os icones sao os Pixelarticons do original (viewBox 24x24). Os dados
// dos caminhos SVG (icons.ts) foram traduzidos para Path do Flutter
// por um mini-parser abaixo — mesmo desenho, so muda a tecnologia.

import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Abas do app, na mesma ordem do original.
enum AppTab { home, transactions, novo, reports, profile }

const Map<AppTab, String> tabLabels = {
  AppTab.home: 'INÍCIO',
  AppTab.transactions: 'TRANS.',
  AppTab.novo: 'NOVO',
  AppTab.reports: 'RELAT.',
  AppTab.profile: 'PERFIL',
};

/// Caminhos SVG (pixelarticons, viewBox 24x24) do icons.ts original.
/// home, arrows-horizontal, plus-box, chart, user — nesta ordem.
const Map<AppTab, List<String>> _tabIconPaths = {
  AppTab.home: [
    'M4 20h16v2H4zm16-10h2v10h-2zM2 10h2v10H2zm2-2h2v2H4zm2-2h2v2H6zm2-2h2v2H8zm2-2h4v2h-4zm4 2h2v2h-2zm2 2h2v2h-2zm2 2h2v2h-2zM8 14h2v6H8zm2-2h4v2h-4zm4 2h2v6h-2z',
  ],
  AppTab.transactions: [
    'M13 13v-2h10v2zm6 2v-2h2v2zm-2 2v-2h2v2zm2-6V9h2v2z',
    'M17 15V7h2v8zm-6-2v-2H1v2zm-6 2v-2H3v2zm2 2v-2H5v2zm-2-6V9H3v2z',
    'M7 15V7H5v8z',
  ],
  AppTab.novo: [
    'M4 2h16v2H4zm0 18h16v2H4zM2 4h2v16H2zm18 0h2v16h-2zM7 11h10v2H7z',
    'M11 17V7h2v10z',
  ],
  AppTab.reports: [
    'M4 2h16v2H4zm0 18h16v2H4zM2 4h2v16H2zm18 0h2v16h-2zM7 11h2v6H7zm4-4h2v10h-2zm4 6h2v4h-2z',
  ],
  AppTab.profile: [
    'M9 2h6v2H9zm0 8h6v2H9zm6-6h2v6h-2zM7 4h2v6H7zM4 18h2v4H4zm14 0h2v4h-2zM8 14h8v2H8zm-2 2h2v2H6zm10 0h2v2h-2z',
  ],
};

/// Mini-parser para o subconjunto de SVG usado pelos Pixelarticons:
/// M/m (mover), H/h (horizontal), V/v (vertical), L/l (linha), Z/z.
/// Numeros podem ser negativos e colados no comando (ex.: "h-2").
Path _parseSvgPath(String data) {
  final path = Path();
  final tokenRe = RegExp(r'[MmHhVvLlZz]|-?\d*\.?\d+');
  final tokens = tokenRe.allMatches(data).map((m) => m.group(0)!).toList();

  double x = 0, y = 0;
  double startX = 0, startY = 0;
  var i = 0;

  double num() => double.parse(tokens[i++]);

  while (i < tokens.length) {
    final cmd = tokens[i++];
    switch (cmd) {
      case 'M':
        x = num();
        y = num();
        path.moveTo(x, y);
        startX = x;
        startY = y;
        // Pares extras apos M viram linhas (nao usados aqui, por seguranca).
        while (i + 1 < tokens.length &&
            !_isCommand(tokens[i]) &&
            !_isCommand(tokens[i + 1])) {
          x = num();
          y = num();
          path.lineTo(x, y);
        }
        break;
      case 'm':
        x += num();
        y += num();
        path.moveTo(x, y);
        startX = x;
        startY = y;
        while (i + 1 < tokens.length &&
            !_isCommand(tokens[i]) &&
            !_isCommand(tokens[i + 1])) {
          x += num();
          y += num();
          path.lineTo(x, y);
        }
        break;
      case 'H':
        x = num();
        path.lineTo(x, y);
        break;
      case 'h':
        x += num();
        path.lineTo(x, y);
        break;
      case 'V':
        y = num();
        path.lineTo(x, y);
        break;
      case 'v':
        y += num();
        path.lineTo(x, y);
        break;
      case 'L':
        x = num();
        y = num();
        path.lineTo(x, y);
        break;
      case 'l':
        x += num();
        y += num();
        path.lineTo(x, y);
        break;
      case 'Z':
      case 'z':
        path.close();
        x = startX;
        y = startY;
        break;
    }
  }
  return path;
}

bool _isCommand(String t) => RegExp(r'^[MmHhVvLlZz]$').hasMatch(t);

/// Desenha um icone pixel (24x24) com a cor informada.
class PixelIconPaint extends CustomPainter {
  final AppTab tab;
  final Color color;

  PixelIconPaint({required this.tab, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    final scale = size.width / 24;
    canvas.save();
    canvas.scale(scale, scale);
    for (final d in _tabIconPaths[tab]!) {
      canvas.drawPath(_parseSvgPath(d), paint);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant PixelIconPaint old) =>
      old.tab != tab || old.color != color;
}

/// Icone pixel de 24px, pronto para usar fora da barra tambem.
class PixelTabIcon extends StatelessWidget {
  final AppTab tab;
  final Color color;
  final double size;

  const PixelTabIcon({
    super.key,
    required this.tab,
    required this.color,
    this.size = 24,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: PixelIconPaint(tab: tab, color: color)),
    );
  }
}

/// Barra inferior EXATAMENTE como o original: 72px de altura,
/// fundo branco, borda superior de 2px preta, 5 abas com icone
/// de 24px e rotulo em Press Start 2P 8px embaixo.
class PixelTabBar extends StatelessWidget {
  final AppTab active;
  final ValueChanged<AppTab> onTabPress;

  const PixelTabBar({
    super.key,
    required this.active,
    required this.onTabPress,
  });

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;
    return Container(
      height: AppLayout.tabBarHeight + (bottomInset > 8 ? bottomInset - 8 : 0),
      padding: EdgeInsets.only(
        left: AppSpacing.s2,
        right: AppSpacing.s2,
        bottom: bottomInset > 8 ? bottomInset : 8,
        top: 8,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.line, width: 2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: AppTab.values.map((tab) {
          final selected = tab == active;
          final color = selected ? AppColors.ink : AppColors.muted;
          return Expanded(
            child: InkWell(
              onTap: () => onTabPress(tab),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  PixelTabIcon(tab: tab, color: color, size: 24),
                  const SizedBox(height: 4),
                  Text(
                    tabLabels[tab]!,
                    style: AppText.pixel(8, color: color),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
