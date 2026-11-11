import 'package:emprendedor/core/theme/role_theme.dart';
import 'package:emprendedor/features/client/controllers/client_profile_controller.dart';
import 'package:emprendedor/features/client/controllers/client_profile_edit_controller.dart';
import 'package:emprendedor/presentation/client/profile/widgets/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ClientProfileAllergies extends StatelessWidget {
  final ClientProfileController controller;

  const ClientProfileAllergies({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8.w,
          runSpacing: 8.h,
          children: ClientProfileEditController.allergyOptions.map((allergy) {
            final selected = controller.selectedAllergies.contains(allergy);

            return FilterChip(
              label: Text(
                allergy,
                style: TextStyle(
                  color: selected ? RoleTheme.iconHealth : RoleTheme.brandText,
                  fontSize: 10.5.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
              selected: selected,
              onSelected: (_) => controller.toggleAllergy(allergy),
              showCheckmark: true,
              checkmarkColor: RoleTheme.iconHealth,
              backgroundColor: RoleTheme.brandSurface,
              selectedColor: RoleTheme.iconHealth.withValues(alpha: 0.10),
              side: BorderSide(
                color: selected
                    ? RoleTheme.iconHealth.withValues(alpha: 0.28)
                    : RoleTheme.brandBorder,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18.r),
              ),
              visualDensity: VisualDensity.compact,
            );
          }).toList(),
        ),
        SizedBox(height: 10.h),
        Row(
          children: [
            Expanded(
              child: ProfileField(
                controller: controller.allergyInputController,
                label: 'Otra alergia',
                icon: Icons.add_circle_outline_rounded,
              ),
            ),
            SizedBox(width: 8.w),
            Container(
              decoration: BoxDecoration(
                color: RoleTheme.iconHealth.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(14.r),
                border: Border.all(
                  color: RoleTheme.iconHealth.withValues(alpha: 0.14),
                ),
              ),
              child: IconButton(
                onPressed: controller.addCustomAllergy,
                icon: Icon(
                  Icons.add_rounded,
                  color: RoleTheme.iconHealth,
                  size: 21.sp,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
