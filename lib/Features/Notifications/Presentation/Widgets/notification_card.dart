import 'package:flutter/material.dart';
import 'package:smart_text_thief/Core/Resources/resources.dart';
import '../../../../Core/Services/Notifications/notification_model.dart';

class NotificationCard extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback? onTap;

  const NotificationCard({super.key, required this.notification, this.onTap});

  @override
  Widget build(BuildContext context) {
    final showBody = notification.body.trim().isNotEmpty &&
        notification.body.trim() != notification.title.trim();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.notificationCardBackground,
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Icon Container
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: notification.backgroundColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  notification.icon,
                  color: notification.iconColor,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      notification.title,
                      style: const TextStyle(
                        color: AppColors.textWhite,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (showBody) ...[
                      const SizedBox(height: 4),
                      Text(
                        notification.body,
                        style: TextStyle(
                          color: AppColors.textWhite.withValues(alpha: 0.85),
                          fontSize: 13.5,
                          fontWeight: FontWeight.w400,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    if (notification.hasDetails) ...[
                      const SizedBox(height: 4),
                      Text(
                        notification.detailsText,
                        style: TextStyle(
                          color: AppColors.textWhite.withValues(alpha: 0.65),
                          fontSize: 12.5,
                          fontWeight: FontWeight.w400,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 6),
                    Text(
                      notification.formattedTime,
                      style: TextStyle(
                        color: AppColors.textWhite.withValues(alpha: 0.5),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              // Read indicator
              if (!notification.read)
                Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.only(left: 12),
                  decoration: BoxDecoration(
                    color: notification.iconColor,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
