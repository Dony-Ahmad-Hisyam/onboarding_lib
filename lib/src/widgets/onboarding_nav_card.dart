import 'package:flutter/material.dart';

class OnboardingNavBar extends StatelessWidget {
  final int currentStep; // 1-based
  final int totalSteps;

  // Aksi utama
  final VoidCallback onNext;

  // Aksi kiri: saat step pertama pakai onSkip, selebihnya pakai onBack (jika ada)
  final VoidCallback onSkip;
  final VoidCallback? onBack;

  // Opsi
  final bool useSkipOnFirst; // true: step pertama = Skip, else tetap Back
  final EdgeInsets margin;
  final double buttonHeight;
  final double minButtonWidth;
  final double radius;

  // Warna terang (tidak gelap)
  final Color backBg;
  final Color backFg;
  final Color backBorder;
  final Color nextBg;
  final Color nextFg;
  final Color nextBorder;

  const OnboardingNavBar({
    Key? key,
    required this.currentStep,
    required this.totalSteps,
    required this.onNext,
    required this.onSkip,
    this.onBack,
    this.useSkipOnFirst = true,
    this.margin = const EdgeInsets.symmetric(horizontal: 16),
    this.buttonHeight = 52,
    this.minButtonWidth = 116,
    this.radius = 10,

    // Card terang
    this.backBg = const Color(0xFFEFF1F5), // terang
    this.backFg = const Color(0xFF222831),
    this.backBorder = const Color(0xFFB5BEC9),

    // Next teal terang
    this.nextBg = const Color(0xFF6EC6C5),
    this.nextFg = Colors.white,
    this.nextBorder = const Color(0xFF3C9C9A),
  }) : super(key: key);

  bool get _isLast => currentStep >= totalSteps;

  @override
  Widget build(BuildContext context) {
    final bool isFirst = currentStep <= 1;
    final bool showSkip = useSkipOnFirst && isFirst;

    // Label kiri dinamis (main + optional progress below)
    final String leftMain = showSkip ? 'Skip' : 'Back';
    final String? leftSub = showSkip
        ? null
        : '${(currentStep - 1).clamp(1, totalSteps)}/$totalSteps';

    // Aksi kiri
    VoidCallback? leftTap;
    if (showSkip) {
      leftTap = onSkip;
    } else {
      leftTap =
          onBack; // pastikan di-passing dari overlay -> controller.previousStep
    }

    final String rightMain = _isLast ? 'Finish' : 'Next';
    final String? rightSub = _isLast
        ? null
        : '${(currentStep + 1).clamp(1, totalSteps)}/$totalSteps';

    return Padding(
      padding: margin,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _smallCardButton(
            label: leftMain,
            subLabel: leftSub,
            onTap: leftTap,
            bg: backBg,
            fg: leftTap == null ? backFg.withOpacity(0.5) : backFg,
            border: backBorder,
          ),
          _smallCardButton(
            label: rightMain,
            subLabel: rightSub,
            onTap: onNext,
            bg: nextBg,
            fg: nextFg,
            border: nextBorder,
          ),
        ],
      ),
    );
  }

  Widget _smallCardButton({
    required String label,
    String? subLabel,
    required VoidCallback? onTap,
    required Color bg,
    required Color fg,
    required Color border,
  }) {
    final bool disabled = onTap == null;
    return ConstrainedBox(
      constraints:
          BoxConstraints(minWidth: minButtonWidth, minHeight: buttonHeight),
      child: Opacity(
        opacity: disabled ? 0.85 : 1.0,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(radius),
            child: Ink(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: bg, // solid terang agar tidak terpengaruh overlay
                borderRadius: BorderRadius.circular(radius),
                border: Border.all(color: border, width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.12),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      label,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: fg,
                        fontWeight: FontWeight.w700,
                        fontSize: 13.5,
                        letterSpacing: 0.2,
                        height: 1.0,
                      ),
                    ),
                    if (subLabel != null) ...[
                      const SizedBox(height: 3),
                      Text(
                        subLabel,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: fg.withOpacity(0.85),
                          fontWeight: FontWeight.w600,
                          fontSize: 11.0,
                          height: 1.0,
                        ),
                      ),
                    ]
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
