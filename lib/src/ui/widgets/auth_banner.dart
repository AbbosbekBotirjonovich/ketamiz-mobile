import 'package:flutter/material.dart';

/// Banner shown at the top of the auth screens (login / register / forgot).
///
/// Rendered at full width without stretching (aspect ratio preserved). The
/// box is shorter than the image's natural height, so the top stays intact
/// and only the bottom is clipped.
class AuthBanner extends StatelessWidget {
  const AuthBanner({super.key});

  /// Source image is 1264×848 → height / width.
  static const double _imgAspect = 848 / 1264;

  /// Portion of the natural height kept visible (the rest is cropped at the
  /// bottom).
  static const double _visibleFactor = 0.75;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = width * _imgAspect * _visibleFactor;
    return ClipRect(
      child: SizedBox(
        width: double.infinity,
        height: height,
        child: Image.asset(
          'assets/banner/banner-auth.png',
          width: double.infinity,
          fit: BoxFit.fitWidth,
          alignment: Alignment.topCenter,
        ),
      ),
    );
  }
}
