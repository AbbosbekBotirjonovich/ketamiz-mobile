import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../menu/notifications/notifications_screen.dart';

/// A consistent circular notification bell used across the app (home top bar,
/// profile header, …). Tapping opens the notifications screen.
class NotificationButton extends StatelessWidget {
  const NotificationButton({super.key, this.hasUnread = false, this.size = 44});

  /// Shows a small dot when there are unread notifications.
  final bool hasUnread;
  final double size;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const NotificationsScreen()),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: AppTheme.border),
            ),
            child: const Icon(
              Icons.notifications_none_rounded,
              color: AppTheme.purple,
              size: 22,
            ),
          ),
          if (hasUnread)
            Positioned(
              right: 9,
              top: 9,
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: AppTheme.red,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 1.5),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
