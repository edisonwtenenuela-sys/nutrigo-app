import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:emprendedor/core/theme/role_theme.dart';
import 'package:emprendedor/features/nutritionist/controllers/nutritionist_profile_controller.dart';
import 'package:emprendedor/presentation/nutritionist/profile/widgets/form/nutritionist_profile_form.dart';

class NutritionistProfileEditPage extends StatefulWidget {
  const NutritionistProfileEditPage({super.key});

  @override
  State<NutritionistProfileEditPage> createState() =>
      _NutritionistProfileEditPageState();
}

class _NutritionistProfileEditPageState
    extends State<NutritionistProfileEditPage> {
  bool _initialized = false;

  void _loadProfileOnFirstBuild() {
    if (_initialized) return;

    _initialized = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      context.read<NutritionistProfileController>().loadProfile();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadProfileOnFirstBuild();
  }

  AppBar _buildAppBar(RolePalette palette) {
    return AppBar(
      backgroundColor: palette.background,
      surfaceTintColor: palette.background,
      scrolledUnderElevation: 0,
      elevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(color: palette.text),
      leading: Navigator.of(context).canPop()
          ? IconButton(
              tooltip: 'Volver',
              icon: Icon(
                Icons.arrow_back_ios_new_rounded,
                color: RoleTheme.iconColorFor(
                  Icons.arrow_back_ios_new_rounded,
                  fallback: palette.text,
                ),
                size: 20.sp,
              ),
              onPressed: () => Navigator.of(context).maybePop(),
            )
          : null,
      title: Text(
        'Editar perfil',
        style: TextStyle(
          fontSize: 20.sp,
          fontWeight: FontWeight.w900,
          color: palette.text,
        ),
      ),
    );
  }

  Widget _buildBody(NutritionistProfileController controller) {
    final hasProfileError = controller.loadErrorMessage != null;

    return SafeArea(
      child: hasProfileError
          ? _ProfileErrorState(
              message: controller.loadErrorMessage!,
              onRetry: controller.loadProfile,
            )
          : const NutritionistProfileForm(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<NutritionistProfileController>();
    const palette = RoleTheme.nutritionist;

    return Scaffold(
      backgroundColor: palette.background,
      appBar: _buildAppBar(palette),
      body: _buildBody(controller),
    );
  }
}

class _ProfileErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ProfileErrorState({required this.message, required this.onRetry});

  Widget _vGap(double value) => SizedBox(height: value.h);

  Widget _buildRetryButton(RolePalette palette) {
    return SizedBox(
      width: double.infinity,
      height: 46.h,
      child: ElevatedButton.icon(
        onPressed: onRetry,
        style: ElevatedButton.styleFrom(
          backgroundColor: palette.primary,
          foregroundColor: palette.surface,
          disabledBackgroundColor: palette.primary.withValues(alpha: 0.35),
          disabledForegroundColor: palette.surface.withValues(alpha: 0.72),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
        ),
        icon: Icon(
          Icons.refresh_rounded,
          color: RoleTheme.iconColorFor(
            Icons.refresh_rounded,
            fallback: palette.surface,
          ),
          size: 20.sp,
        ),
        label: Text(
          'Reintentar',
          style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w800),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const palette = RoleTheme.nutritionist;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              color: RoleTheme.iconDanger,
              size: 64.sp,
            ),
            _vGap(14),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w700,
                color: RoleTheme.iconDanger,
                height: 1.3,
              ),
            ),
            _vGap(18),
            _buildRetryButton(palette),
          ],
        ),
      ),
    );
  }
}
