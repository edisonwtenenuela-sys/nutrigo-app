import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:emprendedor/core/theme/role_theme.dart';

class ReviewStarsSelector extends StatelessWidget {
  final int rating;
  final ValueChanged<int> onChanged;

  const ReviewStarsSelector({
    super.key,
    required this.rating,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        final value = index + 1;

        return IconButton(
          onPressed: () => onChanged(value),
          icon: Icon(
            value <= rating
                ? Icons.star_rounded
                : Icons.star_border_rounded,
            color: RoleTheme.iconRating,
            size: 34.sp,
          ),
        );
      }),
    );
  }
}