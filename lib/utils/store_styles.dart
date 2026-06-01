import 'package:flutter/material.dart';

/// Store design tokens — same design system as Nutrition screens.
class StoreColors {
  static const Color primary = Color(0xFFD0FD3E);
  static const Color background = Color(0xFF181818);
  static const Color cardBackground = Color(0xFF222222);
  static const Color textWhite = Color(0xFFF0F0F0);
  static const Color textGrey = Color(0xFF5C5C5C);
  static const Color textBlack = Color(0xFF0C0C0C);
  static const Color border = Color(0xFF5C5C5C);
  static const Color red = Color(0xFFE93636);
  static const Color inputBorder = Color(0xFF6D6D6D);
  static const Color textHint = Color(0xFF545454);
  static const Color textLightGrey = Color(0xFF9D9D9D);
  static const Color textLighterGrey = Color(0xFFB1B1B1);
  static const Color textDim = Color(0xFFD1CDCD);
}

class StoreTextStyles {
  static const TextStyle headline = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: StoreColors.textWhite,
  );

  static const TextStyle title = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: StoreColors.textWhite,
  );

  static const TextStyle subTitle = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: StoreColors.textWhite,
  );

  static const TextStyle body = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: StoreColors.textWhite,
  );

  static const TextStyle bodyBold = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 14,
    fontWeight: FontWeight.w700,
    color: StoreColors.primary,
  );

  static const TextStyle caption = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: StoreColors.textWhite,
  );

  static const TextStyle captionSmall = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 8,
    fontWeight: FontWeight.w500,
    color: StoreColors.textGrey,
  );

  static const TextStyle button = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: StoreColors.textBlack,
  );
}
