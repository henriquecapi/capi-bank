// Widgets pixel compartilhados — Capi-Bank
// Cartoes pretos com cantos quadrados, botoes pretos, campo e erro pixel.
// Usados por Login, Cadastro e Home para manter o mesmo visual P&B.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';

/// Cartao preto com cantinhos brancos, como a Home do SemUmReal.
class PixelCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  const PixelCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.s2),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.panel,
        border: Border.all(color: AppColors.paper, width: 3),
      ),
      child: Stack(
        children: [
          Padding(padding: padding, child: child),
          const Positioned(top: -2, left: -2, child: _Corner()),
          const Positioned(top: -2, right: -2, child: _Corner()),
          const Positioned(bottom: -2, left: -2, child: _Corner()),
          const Positioned(bottom: -2, right: -2, child: _Corner()),
        ],
      ),
    );
  }
}

class _Corner extends StatelessWidget {
  const _Corner();
  @override
  Widget build(BuildContext context) {
    return Container(width: 6, height: 6, color: AppColors.paper);
  }
}

/// Botao preto, texto branco em pixel, cantos retos.
class PixelButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool busy;

  const PixelButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.busy = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: busy ? null : onPressed,
        child: busy
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.paper,
                ),
              )
            : Text(label),
      ),
    );
  }
}

/// Caixa de erro com borda grossa.
class PixelError extends StatelessWidget {
  final String? message;
  const PixelError({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    if (message == null || message!.isEmpty) return const SizedBox.shrink();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.s1),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.error, width: 3),
      ),
      child: Text(
        message!,
        style: AppText.label(color: AppColors.error),
      ),
    );
  }
}

/// Campo de texto pixel.
/// [borderWidth] padrao 3 (grosso); a tela de login usa 2, igual ao
/// campo do SemUmReal original (border.width).
class PixelField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? hint;
  final TextInputType keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final bool enabled;
  final double borderWidth;

  const PixelField({
    super.key,
    required this.controller,
    required this.label,
    this.hint,
    this.keyboardType = TextInputType.text,
    this.inputFormatters,
    this.enabled = true,
    this.borderWidth = 3,
  });

  @override
  Widget build(BuildContext context) {
    final border = OutlineInputBorder(
      borderSide: BorderSide(color: AppColors.ink, width: borderWidth),
      borderRadius: BorderRadius.zero,
    );
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      enabled: enabled,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: border,
        enabledBorder: border,
        focusedBorder: border,
      ),
    );
  }
}
