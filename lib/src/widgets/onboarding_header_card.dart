import 'package:flutter/material.dart';

class OnboardingHeaderCard extends StatelessWidget {
  final String title;
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

  const OnboardingHeaderCard({
    Key? key,
    required this.title,
    this.description,
    required this.stepNumber,
    this.totalSteps,
    this.borderRadius = 12,
    this.margin = const EdgeInsets.symmetric(horizontal: 16),
    this.padding = const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
    this.backgroundColor = const Color(0xFFB8C9F5), // soft blue
    this.borderColor = const Color(0xFF5C6FAE), // darker blue border
    this.textColor = const Color(0xFF10213A),
    this.showGreenDot = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final hasDescription =
        (description != null && description!.trim().isNotEmpty);

    return Container(
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: borderColor.withOpacity(0.85), width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: hasDescription
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
                  '${stepNumber.toString()}. $title',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                    height: 1.15,
                  ),
                ),
                if (hasDescription) ...[
                  const SizedBox(height: 4),
                  Text(
                    description!,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: textColor.withOpacity(0.9),
                      fontSize: 13,
                      height: 1.2,
                      fontWeight: FontWeight.w400,
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
                color: Color(0xFF7CF6B1), // hijau muda
              ),
            ),
          ],
        ],
      ),
    );
  }
}
