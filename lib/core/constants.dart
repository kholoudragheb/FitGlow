import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppConstants {
  // Colors
  static const Color primaryColor = Color(0xFFD1FF00); // Lime Green
  static const Color backgroundColor = Color(0xFF000000); // Black
  static const Color surfaceColor = Color(0xFF121212); // Dark Grey Cards
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Color(0xFF9E9E9E);
  static const Color errorColor = Color(0xFFCF6679);

  // Styling
  static const double defaultRadius = 24.0;
  static const EdgeInsets defaultPadding = EdgeInsets.all(20.0);

  // Text Styles
  static TextStyle get headlineLarge => GoogleFonts.poppins(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: textPrimary,
  );

  static TextStyle get headlineMedium => GoogleFonts.poppins(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    color: textPrimary,
  );

  static TextStyle get bodyLarge => GoogleFonts.poppins(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: textPrimary,
  );

  static TextStyle get bodyMedium => GoogleFonts.poppins(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: textSecondary,
  );

  static TextStyle get buttonText => GoogleFonts.poppins(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: Colors.black,
  );

  // Asset Paths - Icons (Shared)
  static const String iconSearch = 'lib/assets/icons/shared/search.svg';
  static const String iconFilter = 'lib/assets/icons/shared/filter.svg';
  static const String iconBack = 'lib/assets/icons/shared/back.svg';
  static const String iconTime = 'lib/assets/icons/shared/time.svg';
  static const String iconBookmark = 'lib/assets/icons/shared/bookmark.svg';
  
  // Navigation Icons
  static const String navHome = 'lib/assets/icons/navigation/nav_home.svg';
  static const String navHomeFilled = 'lib/assets/icons/navigation/nav_home_filled.svg';
  static const String navWorkout = 'lib/assets/icons/nutrition/icon_nav_workout_inactive.svg';
  static const String navWorkoutFilled = 'lib/assets/icons/nutrition/icon_nav_workout_active.svg';
  static const String navNutrition = 'lib/assets/icons/nutrition/icon_nav_nutrition_inactive.svg';
  static const String navNutritionFilled = 'lib/assets/icons/nutrition/icon_nav_nutrition_active.svg';
  static const String navStore = 'lib/assets/icons/navigation/nav_store.svg';
  static const String navStoreFilled = 'lib/assets/icons/navigation/nav_store_filled.svg';
  static const String navProfile = 'lib/assets/icons/navigation/nav_profile.svg';
  static const String navProfileFilled = 'lib/assets/icons/navigation/nav_profile_filled.svg';
  
  // Header Icons
  static const String iconChat = 'lib/assets/icons/home/header_chat.svg';
  static const String iconNotification = 'lib/assets/icons/home/header_notification.svg';

  // Player Icons
  static const String iconPlay = 'lib/assets/icons/player/play.svg';
  static const String iconPause = 'lib/assets/icons/player/pause.svg';
  static const String iconNext = 'lib/assets/icons/player/next.svg';
  static const String iconPrev = 'lib/assets/icons/player/prev.svg';
  static const String iconFullscreen = 'lib/assets/icons/player/fullscreen.svg';
  
  // Payment & Status Icons
  static const String iconApplePay = 'lib/assets/icons/auth/icon_apple_pay.svg';
  static const String iconPaypal = 'lib/assets/icons/auth/icon_paypal.svg';
  static const String iconCard = 'lib/assets/icons/auth/icon_card.svg';
  static const String iconStar = 'lib/assets/icons/store/icon_star.svg';
  static const String iconNotificationEmpty = 'lib/assets/icons/home/icon_notification_empty.svg';
  
  // Chat & Interaction Icons
  static const String iconBot = 'lib/assets/icons/icon_bot.svg';
  static const String iconSend = 'lib/assets/icons/icon_send.svg';
  static const String iconMic = 'lib/assets/icons/icon_mic.svg';
  static const String iconAttach = 'lib/assets/icons/icon_attach.svg'; // If exists later
  static const String iconEmoji = 'lib/assets/icons/icon_emoji.svg';
  static const String iconVideo = 'lib/assets/icons/icon_video.svg';
  static const String iconPhone = 'lib/assets/icons/icon_phone.svg';
  static const String iconAdd = 'lib/assets/icons/shared/icon_add.svg';
  static const String iconArrowRight = 'lib/assets/icons/shared/arrow_right.svg';
  static const String iconDoubleCheck = 'lib/assets/icons/chat/icon_checks.svg';
}
