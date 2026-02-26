import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:smart_text_thief/Core/Resources/resources.dart';
import 'package:smart_text_thief/Core/Utils/Enums/notification_type.dart';
import '../../../../Core/Services/Notifications/notification_model.dart';

class NotificationCard extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback? onTap;

  const NotificationCard({super.key, required this.notification, this.onTap});

  bool get _isUrgent =>
      notification.titleTopic == NotificationType.examEnding ||
      notification.titleTopic == NotificationType.examEnded;

  @override
  Widget build(BuildContext context) {
    final showBody = notification.body.trim().isNotEmpty &&
        notification.body.trim() != notification.title.trim();
    final bgColor = notification.read
        ? AppColors.notificationCardBackground.withValues(alpha: 0.7)
        : AppColors.notificationCardBackground;
    final accentWidth = _isUrgent ? 5.0 : 3.0;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(14.r),
        border: Border(
          left: BorderSide(
            color: notification.iconColor,
            width: accentWidth,
          ),
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14.r),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon Container
              Container(
                width: 48.w,
                height: 48.w,
                decoration: BoxDecoration(
                  color: notification.iconColor.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  notification.icon,
                  color: notification.iconColor,
                  size: 24.sp,
                ),
              ),
              SizedBox(width: 14.w),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      notification.title,
                      style: AppTextStyles.bodyMediumSemiBold.copyWith(
                        color: notification.read
                            ? AppColors.white70
                            : AppColors.textWhite,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (showBody) ...[
                      SizedBox(height: 4.h),
                      Text(
                        notification.body,
                        style: AppTextStyles.bodySmallMedium.copyWith(
                          color: AppColors.white70,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    if (notification.hasDetails) ...[
                      SizedBox(height: 4.h),
                      Text(
                        notification.detailsText,
                        style: AppTextStyles.bodySmallMedium.copyWith(
                          color: AppColors.white60,
                          fontSize: 11,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    SizedBox(height: 6.h),
                    Row(
                      children: [
                        Text(
                          notification.formattedTime,
                          style: AppTextStyles.bodySmallMedium.copyWith(
                            color: AppColors.white54,
                            fontSize: 11,
                          ),
                        ),
                        if (!notification.read) ...[
                          SizedBox(width: 8.w),
                          Container(
                            width: 6.w,
                            height: 6.w,
                            decoration: BoxDecoration(
                              color: notification.iconColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
