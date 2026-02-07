import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'name_routes.dart';

class ErrorScreen extends StatelessWidget {
  const ErrorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A1929),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, color: Colors.red, size: 80.sp),
              SizedBox(height: 20.h),
              Text(
                '404',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 40.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10.h),
              Text(
                'Page not found',
                style: TextStyle(color: Colors.grey, fontSize: 16.sp),
              ),
              SizedBox(height: 30.h),
              ElevatedButton(
                onPressed: () => context.go(NameRoutes.splash),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2196F3),
                  padding: EdgeInsets.symmetric(
                    horizontal: 40.w,
                    vertical: 15.h,
                  ),
                ),
                child: Text(
                  'Return to home',
                  style: TextStyle(fontSize: 14.sp),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
