import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../setting.dart';

class NoConnectionScreen extends StatelessWidget {
  const NoConnectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A1929),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.wifi_off, color: Colors.redAccent, size: 80.sp),
              SizedBox(height: 20.h),
              Text(
                'No Internet Connection',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10.h),
              Text(
                'Please check your internet connection and try again',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[300], fontSize: 16.sp),
              ),
              SizedBox(height: 30.h),
              ElevatedButton.icon(
                onPressed: () {
                  final internet =
                      context.read<SettingsCubit>().getConnectivity();
                  if (!internet) return;
                  context.canPop()
                      ? context.pop()
                      : context.go(NameRoutes.splash);
                },
                icon: const Icon(Icons.refresh, color: Colors.black),
                label: Text(
                  'Retry',
                  style: TextStyle(fontSize: 14.sp, color: Colors.black),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2196F3),
                  padding: EdgeInsets.symmetric(
                    horizontal: 40.w,
                    vertical: 15.h,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
