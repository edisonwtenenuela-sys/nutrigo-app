import 'package:emprendedor/core/navigation/app_navigator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:emprendedor/core/theme/role_theme.dart';
import 'package:emprendedor/features/nutritionist/controllers/nutritionist_profile_controller.dart';
import 'package:emprendedor/presentation/auth/pages/auth_wrapper.dart';
import 'package:emprendedor/presentation/shared/widgets/app_feedback.dart';

class NutritionistSaveButton extends StatelessWidget {
  const NutritionistSaveButton({super.key});

  Future<void> _save(
      BuildContext context,
      NutritionistProfileController controller,
      ) async {
    final result = await controller.saveProfileResult();

    if (!context.mounted) return;

    await showAppMessage(
      context,
      role: AppFeedbackRole.nutritionist,
      type: result.success
          ? AppFeedbackType.success
          : AppFeedbackType.error,
      title: result.success
          ? 'Perfil guardado'
          : 'No se pudo guardar',
      message: result.message,
    );

    if (result.requiresAuthRedirect && context.mounted) {
      AppNavigator.replaceAll(context, const AuthWrapper());
      return;
    }

    if (result.success &&
        context.mounted &&
        Navigator.of(context).canPop()) {
      Navigator.of(context).maybePop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<NutritionistProfileController>();
    const palette = RoleTheme.nutritionist;

    return SizedBox(
      width: double.infinity,
      height: 52.h,
      child: ElevatedButton.icon(
        onPressed: controller.isSaving
            ? null
            : () => _save(context, controller),
        icon: controller.isSaving
            ? SizedBox(
          width: 18.w,
          height: 18.w,
          child: const CircularProgressIndicator(
            strokeWidth: 2,
            color: Colors.white,
            trackGap: 2,
          ),
        )
            : Icon(
          Icons.save_outlined,
          size: 19.sp,
        ),
        label: Text(
          controller.isSaving ? 'Guardando...' : 'Guardar perfil',
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.w900,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: palette.primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor:
          palette.primary.withValues(alpha: 0.45),
          disabledForegroundColor: Colors.white70,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18.r),
          ),
        ),
      ),
    );
  }
}