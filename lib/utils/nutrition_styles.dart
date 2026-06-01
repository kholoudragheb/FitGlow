import 'package:flutter/material.dart';

class NutritionColors {
  static const Color primary = Color(0xFFD0FD3E); // The lime green color
  static const Color background = Color(0xFF181818); // Dark background
  static const Color cardBackground = Color(0xFF222222); // Slightly lighter for cards/inputs
  static const Color textWhite = Color(0xFFF0F0F0);
  static const Color textGrey = Color(0xFF5C5C5C); // For subtitles/icons
  static const Color textRed = Color(0xFFFF2646); // For "Delete all" etc
}

class NutritionTextStyles {
  static const TextStyle title = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: NutritionColors.textWhite,
  );

  static const TextStyle subTitle = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: NutritionColors.textWhite,
  );

  static const TextStyle body = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: NutritionColors.textWhite,
  );
  
  static const TextStyle caption = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: NutritionColors.textWhite,
  );
}
