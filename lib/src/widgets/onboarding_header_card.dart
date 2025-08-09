import 'package:flutter/material.dart';

class OnboardingHeaderCard extends StatelessWidget {
  final String? title;
  final String? description;
  final int stepNumber; // 1-based
  final int? totalSteps;
  final double borderRadius;
  final EdgeInsets margin;
  final EdgeInsets padding;

  // Warna default disetel agar mirip contoh (biru lembut + border lebih gelap)
  final Color backgroundColor;
  final Color borderColor;
  final Color textColor;
  final bool showGreenDot;
  final double? fixedWidth;
  final double? fixedHeight;
  final double? mainFontSize;

  const OnboardingHeaderCard({
    Key? key,
    this.title,
    this.description,
    required this.stepNumber,
    this.totalSteps,
    this.borderRadius = 10,
    this.margin = const EdgeInsets.symmetric(horizontal: 10),
    this.padding = const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
    this.backgroundColor =
        const Color(0xFFAEC6FF), // light blue like screenshot
    this.borderColor = const Color(0xFF3E4D87), // deeper bluish border
    this.textColor = const Color(0xFF10213A),
    this.showGreenDot = true,
    this.fixedWidth,
    this.fixedHeight,
    this.mainFontSize,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final hasTitle = (title ?? '').trim().isNotEmpty;
    final hasDescription =
        (description != null && description!.trim().isNotEmpty);
    final String mainLineText =
        hasTitle ? (title ?? '') : (description?.trim() ?? '');
    final bool showDescriptionBelow = hasDescription && hasTitle;

    final card = Container(
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: borderColor.withOpacity(0.95), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.10),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: showDescriptionBelow
            ? CrossAxisAlignment.start
            : CrossAxisAlignment.center,
        children: [
          // Teks judul + (opsional) deskripsi
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // "2. Play, Learn and Earn Coins"
                Text(
                  '${stepNumber.toString()}. $mainLineText',
                  // Bold, size 16 seperti contoh
                  style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.w700,
                    fontSize: mainFontSize ?? 16,
                    height: 1.2,
                  ),
                ),
                if (showDescriptionBelow) ...[
                  const SizedBox(height: 4),
                  Text(
                    description!,
                    // Perbesar deskripsi dan biarkan membungkus tanpa elipsis
                    style: TextStyle(
                      color: textColor.withOpacity(0.9),
                      fontSize: 14.5,
                      height: 1.25,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Titik hijau kecil di kanan
          if (showGreenDot) ...[
            const SizedBox(width: 8),
            Container(
              width: 10,
              height: 10,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFF8EF2BE), // minty green like screenshot
              ),
            ),
          ],
        ],
      ),
    );

    if (fixedWidth != null || fixedHeight != null) {
      return SizedBox(
        width: fixedWidth,
        height: fixedHeight,
        child: card,
      );
    }
    return card;
  }
}
