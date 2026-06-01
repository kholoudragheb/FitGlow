import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ImageUtils {
  static const String baseUrl = 'https://exact-gwenette-fitglow-38dc47eb.koyeb.app';
  static const String defaultCoachPlaceholder = 'lib/assets/images/coaches/coach_1.jpg';
  static const String defaultUserPlaceholder = 'lib/assets/images/profile/user_avatar.png';

  static String? normalizeUrl(String? url) {
    if (url == null || url.isEmpty) return null;
    if (url.startsWith('http')) return url;
    
    // Handle relative paths
    if (url.startsWith('/')) {
      return '$baseUrl$url';
    }
    return '$baseUrl/$url';
  }

  static Widget coachImage({
    required String? url,
    required double width,
    required double height,
    BoxFit fit = BoxFit.cover,
    String? coachId,
  }) {
    final normalizedUrl = normalizeUrl(url);
    
    // Choose fallback asset based on coachId to vary the look
    String fallbackAsset = defaultCoachPlaceholder;
    if (coachId != null) {
      final index = coachId.hashCode % 4 + 1;
      fallbackAsset = 'lib/assets/images/coaches/coach_$index.jpg';
    }

    if (normalizedUrl == null) {
      return Image.asset(
        fallbackAsset,
        width: width,
        height: height,
        fit: fit,
      );
    }

    return CachedNetworkImage(
      imageUrl: normalizedUrl,
      width: width,
      height: height,
      fit: fit,
      placeholder: (context, url) => Container(
        width: width,
        height: height,
        color: Colors.grey[900],
        child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
      ),
      errorWidget: (context, url, error) => Image.asset(
        fallbackAsset,
        width: width,
        height: height,
        fit: fit,
      ),
    );
  }

  static DecorationImage coachDecorationImage({
    required String? url,
    String? coachId,
    BoxFit fit = BoxFit.cover,
  }) {
    final normalizedUrl = normalizeUrl(url);
    
    String fallbackAsset = defaultCoachPlaceholder;
    if (coachId != null) {
      final index = coachId.hashCode % 4 + 1;
      fallbackAsset = 'lib/assets/images/coaches/coach_$index.jpg';
    }

    if (normalizedUrl == null) {
      return DecorationImage(
        image: AssetImage(fallbackAsset),
        fit: fit,
      );
    }

    return DecorationImage(
      image: CachedNetworkImageProvider(normalizedUrl),
      fit: fit,
    );
  }
}
