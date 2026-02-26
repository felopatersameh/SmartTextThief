import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../Config/app_config.dart';
import '../../../Core/Resources/resources.dart';
import '../../../Core/Services/Notifications/notification_model.dart';
import '../../../Core/Utils/Enums/notification_type.dart';
import 'Widgets/notification_card.dart';
import 'cubit/notifications_cubit.dart';
import '../../../Config/Routes/name_routes.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final cubit = context.read<NotificationsCubit>();
      unawaited(
        cubit.ensureInitialized().then((_) => cubit.markAllAsRead()),
      );
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(NameRoutes.notification.titleAppBar)),
      body: BlocConsumer<NotificationsCubit, NotificationsState>(
        listener: (context, state) {},
        builder: (context, state) {
          if (state.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          final notifications = state.notificationsList;

          return RefreshIndicator(
            onRefresh: () => context.read<NotificationsCubit>().refresh(),
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: AppConfig.physicsCustomScrollView,
              ),
              slivers: [
                if (notifications.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            AppIcons.notificationsNone,
                            size: 80,
                            color: AppColors.white38,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            NotificationStrings.noNotificationsYet,
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(color: AppColors.white70),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            NotificationStrings.noNotificationsHint,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(color: AppColors.white54),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  ..._buildGroupedNotifications(
                    context,
                    notifications,
                    onNotificationTap: (id) => unawaited(
                      context.read<NotificationsCubit>().openNotification(id),
                    ),
                  ),
                const SliverToBoxAdapter(child: SizedBox(height: 20)),
              ],
            ),
          );
        },
      ),
    );
  }

  static const List<NotificationType> _sectionOrder = [
    NotificationType.examEnding,
    NotificationType.examEnded,
    NotificationType.submit,
    NotificationType.createdExam,
    NotificationType.examStarted,
    NotificationType.joinedSubject,
    NotificationType.updated,
    NotificationType.other,
  ];

  List<Widget> _buildGroupedNotifications(
    BuildContext context,
    List<NotificationModel> notifications, {
    required void Function(String id) onNotificationTap,
  }) {
    final grouped = <NotificationType, List<NotificationModel>>{};
    for (final n in notifications) {
      grouped.putIfAbsent(n.titleTopic, () => []).add(n);
    }

    final slivers = <Widget>[];

    for (final type in _sectionOrder) {
      final list = grouped[type];
      if (list == null || list.isEmpty) continue;

      slivers.add(
        SliverToBoxAdapter(
          child: _SectionHeader(type: type, count: list.length),
        ),
      );
      slivers.add(
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final n = list[index];
              return NotificationCard(
                notification: n,
                onTap: () => onNotificationTap(n.id),
              );
            },
            childCount: list.length,
          ),
        ),
      );
    }

    return slivers;
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.type, required this.count});

  final NotificationType type;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 4.h),
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: type.iconColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12.r),
        border: Border(
          left: BorderSide(
            color: type.iconColor,
            width: 4,
          ),
        ),
      ),
      child: Row(
        children: [
          // Container(
          //   padding: EdgeInsets.all(8.w),
          //   decoration: BoxDecoration(
          //     color: type.iconColor.withValues(alpha: 0.2),
          //     borderRadius: BorderRadius.circular(10.r),
          //   ),
          //   child: Icon(
          //     type.icon,
          //     size: 20.sp,
          //     color: type.iconColor,
          //   ),
          // ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              type.channelName,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: type.iconColor.withValues(alpha: 0.95),
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: type.iconColor.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Text(
              '$count',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: type.iconColor,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
