import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';

import '../../../theme/app_theme.dart';
import '../../widgets/containers/leading_back.dart';
import '../../widgets/texts/text_14h_400w.dart';
import '../../widgets/texts/text_16h_500w.dart';

/// A simple notification model. Until a backend feed exists, the screen shows
/// an empty state.
class AppNotification {
  final String title;
  final String body;
  final DateTime? date;
  final bool read;

  const AppNotification({
    required this.title,
    required this.body,
    this.date,
    this.read = false,
  });
}

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key, this.notifications = const []});

  final List<AppNotification> notifications;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const LeadingBack(),
        title: Text16h500w(title: translate("home.notifications")),
        centerTitle: true,
      ),
      body: notifications.isEmpty
          ? _buildEmptyState()
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: notifications.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, i) => _NotificationTile(notifications[i]),
            ),
    );
  }

  Widget _buildEmptyState() {
    return Builder(
      builder: (context) => Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  color: AppTheme.purple.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.notifications_none_rounded,
                    size: 40, color: AppTheme.purple),
              ),
              const SizedBox(height: 20),
              Text16h500w(title: translate("home.no_notifications")),
              const SizedBox(height: 6),
              Text(
                translate("home.no_notifications_msg"),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: AppTheme.fontFamily,
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  height: 1.5,
                  color: AppTheme.gray,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile(this.notification);
  final AppNotification notification;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppTheme.purple.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.notifications_rounded,
                size: 20, color: AppTheme.purple),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text16h500w(title: notification.title),
                if (notification.body.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text14h400w(
                    title: notification.body,
                    color: AppTheme.gray,
                  ),
                ],
              ],
            ),
          ),
          if (!notification.read) ...[
            const SizedBox(width: 8),
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: AppTheme.purple,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
