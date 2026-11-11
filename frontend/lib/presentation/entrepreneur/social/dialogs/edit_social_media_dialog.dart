import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:emprendedor/core/theme/role_theme.dart';
import 'package:emprendedor/data/models/entrepreneur/profile/social_media_model.dart';
import 'package:emprendedor/features/entrepreneur/controllers/index.dart';

Future<SocialMediaModel?> showEditSocialMediaDialog({
  required BuildContext context,
  required SocialMediaModel socialMedia,
}) {
  return showDialog<SocialMediaModel>(
    context: context,
    barrierColor: RoleTheme.entrepreneur.text.withValues(alpha: 0.28),
    builder: (_) => _SocialMediaUrlDialog(socialMedia: socialMedia),
  );
}

class _SocialMediaUrlDialog extends StatefulWidget {
  final SocialMediaModel socialMedia;

  const _SocialMediaUrlDialog({
    required this.socialMedia,
  });

  @override
  State<_SocialMediaUrlDialog> createState() => _SocialMediaUrlDialogState();
}

class _SocialMediaUrlDialogState extends State<_SocialMediaUrlDialog> {
  late final EditSocialMediaController _formController;

  @override
  void initState() {
    super.initState();
    _formController = EditSocialMediaController(
      socialMedia: widget.socialMedia,
    );
  }

  @override
  void dispose() {
    _formController.dispose();
    super.dispose();
  }

  void _save() {
    final updatedModel = _formController.buildUpdatedModel();

    if (updatedModel == null) return;

    Navigator.of(context).pop(updatedModel);
  }

  @override
  Widget build(BuildContext context) {
    const palette = RoleTheme.entrepreneur;

    return ListenableBuilder(
      listenable: _formController,
      builder: (context, _) {
        return AlertDialog(
          backgroundColor: palette.surface,
          surfaceTintColor: palette.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22.r),
          ),
          contentPadding: EdgeInsets.all(20.w),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56.w,
                height: 56.w,
                decoration: BoxDecoration(
                  color: palette.primary.withValues(alpha: 0.09),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.edit_rounded,
                  color: RoleTheme.iconColorFor(
                    Icons.edit_rounded,
                    fallback: palette.primary,
                  ),
                  size: 28.sp,
                ),
              ),
              SizedBox(height: 16.h),
              Text(
                '${_formController.isEditing ? 'Editar' : 'Agregar'} ${widget.socialMedia.type.label}',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: palette.text,
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w900,
                ),
              ),
              SizedBox(height: 16.h),
              TextField(
                controller: _formController.urlController,
                cursorColor: palette.primary,
                keyboardType: TextInputType.url,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _save(),
                style: TextStyle(
                  color: palette.text,
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w700,
                ),
                decoration: InputDecoration(
                  labelText: 'URL',
                  hintText: 'https://ejemplo.com',
                  errorText: _formController.urlError,
                  filled: true,
                  fillColor: palette.primary.withValues(alpha: 0.035),
                  labelStyle: TextStyle(
                    color: palette.mutedText,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w700,
                  ),
                  hintStyle: TextStyle(
                    color: palette.mutedText.withValues(alpha: 0.65),
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                  ),
                  errorStyle: TextStyle(
                    color: RoleTheme.iconDanger,
                    fontSize: 10.5.sp,
                    fontWeight: FontWeight.w700,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16.r),
                    borderSide: BorderSide(
                      color: palette.primary.withValues(alpha: 0.12),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16.r),
                    borderSide: BorderSide(
                      color: palette.primary,
                      width: 1.2.w,
                    ),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16.r),
                    borderSide: BorderSide(
                      color: RoleTheme.iconDanger.withValues(alpha: 0.75),
                    ),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16.r),
                    borderSide: BorderSide(
                      color: RoleTheme.iconDanger,
                      width: 1.2.w,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 22.h),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 42.h,
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: palette.mutedText,
                          side: BorderSide(
                            color: palette.mutedText.withValues(alpha: 0.22),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14.r),
                          ),
                        ),
                        child: Text(
                          'Cancelar',
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: SizedBox(
                      height: 42.h,
                      child: OutlinedButton(
                        onPressed: _save,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: palette.primary,
                          backgroundColor: palette.primary.withValues(
                            alpha: 0.055,
                          ),
                          side: BorderSide(
                            color: palette.primary.withValues(alpha: 0.18),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14.r),
                          ),
                        ),
                        child: Text(
                          'Guardar',
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}