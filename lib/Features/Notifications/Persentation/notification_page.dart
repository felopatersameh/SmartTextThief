import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../Config/app_config.dart';
import '../../../Core/Resources/resources.dart';
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
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await context.read<NotificationsCubit>().readout();
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(NameRoutes.notification.titleAppBar)),
      body: BlocBuilder<NotificationsCubit, NotificationsState>(
        builder: (context, state) {
          if (state.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          final notifications = state.notificationsList;

          return CustomScrollView(
            physics: AppConfig.physicsCustomScrollView,
            slivers: [
              // Notifications list
              notifications.isEmpty
                  ? SliverFillRemaining(
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
                  : SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        return NotificationCard(
                          notification: notifications[index],
                          onTap: () async {
                            await context.read<NotificationsCubit>().readIn(
                                  notifications[index].id,
                                );
                          },
                        );
                      }, childCount: notifications.length),
                    ),

              // Bottom spacing
              const SliverToBoxAdapter(child: SizedBox(height: 20)),
            ],
          );
        },
      ),
    );
  }
}
