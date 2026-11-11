import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:emprendedor/core/theme/role_theme.dart';
import 'package:emprendedor/presentation/auth/widgets/index.dart';

class PhoneAccessCard extends StatelessWidget {
  final bool isLogin;
  final String selectedRole;
  final bool isLoading;
  final bool otpSent;
  final String verificationId;
  final RolePalette palette;
  final String documentType;
  final int documentDigitLimit;
  final TextEditingController phoneController;
  final TextEditingController otpController;
  final TextEditingController nameController;
  final TextEditingController addressController;
  final TextEditingController ageController;
  final TextEditingController dietaryGoalController;
  final TextEditingController documentNumberController;
  final TextEditingController businessDescriptionController;
  final TextEditingController specialtyController;
  final TextEditingController licenseNumberController;
  final TextEditingController professionalDescriptionController;
  final TextEditingController nutritionistEmailController;
  final TextEditingController contactEmailController;
  final VoidCallback onSendCode;
  final VoidCallback onVerifyOtp;
  final ValueChanged<String> onDocumentTypeChanged;

  const PhoneAccessCard({
    super.key,
    required this.isLogin,
    required this.selectedRole,
    required this.isLoading,
    required this.otpSent,
    required this.verificationId,
    required this.palette,
    required this.documentType,
    required this.documentDigitLimit,
    required this.phoneController,
    required this.otpController,
    required this.nameController,
    required this.addressController,
    required this.ageController,
    required this.dietaryGoalController,
    required this.documentNumberController,
    required this.businessDescriptionController,
    required this.specialtyController,
    required this.licenseNumberController,
    required this.professionalDescriptionController,
    required this.nutritionistEmailController,
    required this.contactEmailController,
    required this.onSendCode,
    required this.onVerifyOtp,
    required this.onDocumentTypeChanged,
  });

  Widget _buildRegistrationBlock() {
    return const SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    final phoneNumber = phoneController.text.trim();

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(otpSent ? 14.w : 16.w),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(26.r),
        border: Border.all(color: palette.primary.withValues(alpha: 0.10)),
        boxShadow: [
          BoxShadow(
            color: palette.shadow,
            blurRadius: 22.r,
            offset: Offset(0, 10.h),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          PhonePanelHeader(otpSent: otpSent, palette: palette),
          SizedBox(height: otpSent ? 12.h : 16.h),
          Align(
            alignment: Alignment.centerLeft,
            child: _buildRegistrationBlock(),
          ),
          if (otpSent) ...[
            _PhoneOtpSummary(
              palette: palette,
              phoneNumber: phoneNumber,
              isLoading: isLoading,
              onResendCode: onSendCode,
            ),
          ] else ...[
            PhoneNumberInput(
              controller: phoneController,
              palette: palette,
              enabled: !isLoading,
            ),
            SizedBox(height: 12.h),
            PhoneSecurityNote(palette: palette),
            SizedBox(height: 16.h),
            PhoneSendCodeButton(
              palette: palette,
              isLoading: isLoading,
              otpSent: otpSent,
              onPressed: onSendCode,
            ),
          ],
          PhoneOtpForm(
            otpController: otpController,
            isLoading: isLoading,
            otpSent: otpSent,
            canVerify: verificationId.isNotEmpty,
            onVerifyOtp: onVerifyOtp,
            palette: palette,
          ),
        ],
      ),
    );
  }
}

class _PhoneOtpSummary extends StatelessWidget {
  final RolePalette palette;
  final String phoneNumber;
  final bool isLoading;
  final VoidCallback onResendCode;

  const _PhoneOtpSummary({
    required this.palette,
    required this.phoneNumber,
    required this.isLoading,
    required this.onResendCode,
  });

  @override
  Widget build(BuildContext context) {
    final safePhone = phoneNumber.isEmpty ? 'tu número' : phoneNumber;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(12.w, 10.h, 10.w, 10.h),
      decoration: BoxDecoration(
        color: palette.primary.withValues(alpha: 0.055),
        borderRadius: BorderRadius.circular(17.r),
        border: Border.all(color: palette.primary.withValues(alpha: 0.12)),
      ),
      child: Row(
        children: [
          Container(
            width: 36.w,
            height: 36.w,
            decoration: BoxDecoration(
              color: palette.surface,
              borderRadius: BorderRadius.circular(13.r),
            ),
            child: Icon(
              Icons.mark_email_read_rounded,
              color: RoleTheme.iconColorFor(
                Icons.mark_email_read_rounded,
                fallback: palette.primary,
              ),
              size: 19.sp,
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Código enviado',
                  style: TextStyle(
                    color: palette.text,
                    fontSize: 12.4.sp,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  '+593 $safePhone',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: palette.mutedText,
                    fontSize: 11.4.sp,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          TextButton.icon(
            onPressed: isLoading ? null : onResendCode,
            icon: Icon(Icons.refresh_rounded, size: 15.sp),
            label: Text(
              'Reenviar',
              style: TextStyle(
                fontSize: 11.3.sp,
                fontWeight: FontWeight.w900,
              ),
            ),
            style: TextButton.styleFrom(
              foregroundColor: palette.primary,
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
            ),
          ),
        ],
      ),
    );
  }
}