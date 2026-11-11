import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppErrorState extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const AppErrorState({
    super.key,
    required this.message,
    this.onRetry,
  });

  static const _defaultTitle = 'Ocurrió un problema';

  Widget _buildRetryButton() {
    if (onRetry == null) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        SizedBox(height: 20.h),
        ElevatedButton.icon(
          onPressed: onRetry,
          icon: Icon(Icons.refresh, size: 20.sp),
          label: Text(
            'Reintentar',
            style: TextStyle(fontSize: 14.sp),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Center(
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 24.w,
            vertical: 40.h,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 70.sp,
                color: colors.error,
              ),
              SizedBox(height: 16.h),
              Text(
                _defaultTitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  color: colors.error,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15.sp,
                  color: colors.onSurfaceVariant,
                ),
              ),
              _buildRetryButton(),
            ],
          ),
        ),
      ),
    );
  }
}