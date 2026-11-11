import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ProductFormErrorCard extends StatelessWidget {
  final String message;

  const ProductFormErrorCard({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(15.r),
        border: Border.all(color: Colors.red.withValues(alpha: 0.14)),
      ),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.red,
          fontSize: 12.5.sp,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}








