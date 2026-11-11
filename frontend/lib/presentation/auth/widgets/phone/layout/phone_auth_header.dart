import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:emprendedor/core/theme/role_theme.dart';
import 'package:emprendedor/presentation/shared/widgets/nutrigo_logo_mark.dart';

class PhoneAuthHeader extends StatelessWidget {
  final bool isLogin;
  final String selectedRole;
  final int currentStep;

  const PhoneAuthHeader({
    super.key,
    required this.isLogin,
    required this.selectedRole,
    this.currentStep = 1,
  });

  String get _title {
    return isLogin ? 'Acceso seguro por SMS' : 'Registro guiado por SMS';
  }

  String get _subtitle {
    if (isLogin) {
      return 'Entra a NutriGo verificando tu número celular en pocos pasos.';
    }

    switch (selectedRole) {
      case 'cliente':
        return 'Crea tu cuenta de cliente y confirma tu número celular.';
      case 'nutricionista':
        return 'Registra tu perfil profesional para revisión del administrador.';
      case 'emprendedor':
      default:
        return 'Registra tu negocio y solicita acceso a la plataforma.';
    }
  }

  String get _thirdStepLabel => isLogin ? 'Inicio' : 'Perfil';

  @override
  Widget build(BuildContext context) {
    final isCodeStep = currentStep >= 2;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        16.w,
        isCodeStep ? 12.h : 16.h,
        16.w,
        isCodeStep ? 11.h : 14.h,
      ),
      decoration: BoxDecoration(
        color: RoleTheme.brandBadgeBackground,
        borderRadius: BorderRadius.circular(26.r),
        border: Border.all(
          color: RoleTheme.brandSoft.withValues(alpha: 0.72),
        ),
        boxShadow: [
          BoxShadow(
            color: RoleTheme.brandPrimary.withValues(alpha: 0.08),
            blurRadius: 24.r,
            offset: Offset(0, 12.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: isCodeStep ? 46.w : 58.w,
                height: isCodeStep ? 46.w : 58.w,
                decoration: BoxDecoration(
                  color: RoleTheme.brandSurface,
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(color: RoleTheme.brandBorder),
                ),
                child: Padding(
                  padding: EdgeInsets.all(isCodeStep ? 6.w : 7.w),
                  child: NutriGoLogoMark(size: isCodeStep ? 34.w : 44.w),
                ),
              ),
              SizedBox(width: isCodeStep ? 10.w : 13.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _title,
                      style: TextStyle(
                        color: RoleTheme.brandText,
                        fontSize: isCodeStep ? 16.6.sp : 18.5.sp,
                        fontWeight: FontWeight.w900,
                        height: 1.08,
                      ),
                    ),
                    SizedBox(height: isCodeStep ? 3.h : 6.h),
                    Text(
                      _subtitle,
                      maxLines: isCodeStep ? 1 : 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: RoleTheme.brandMutedText,
                        fontSize: isCodeStep ? 10.4.sp : 11.2.sp,
                        fontWeight: FontWeight.w700,
                        height: 1.26,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: isCodeStep ? 11.h : 15.h),
          Row(
            children: [
              _HeaderStep(number: '1', label: 'Número', state: _stepState(1)),
              _StepDivider(state: _lineState(1)),
              _HeaderStep(number: '2', label: 'Código', state: _stepState(2)),
              _StepDivider(state: _lineState(2)),
              _HeaderStep(
                number: '3',
                label: _thirdStepLabel,
                state: _stepState(3),
              ),
            ],
          ),
        ],
      ),
    );
  }

  _PhoneStepState _stepState(int step) {
    if (currentStep > step) return _PhoneStepState.completed;
    if (currentStep == step) return _PhoneStepState.active;
    return _PhoneStepState.pending;
  }

  _PhoneStepState _lineState(int step) {
    return currentStep > step
        ? _PhoneStepState.completed
        : _PhoneStepState.pending;
  }
}

class _HeaderStep extends StatelessWidget {
  final String number;
  final String label;
  final _PhoneStepState state;

  const _HeaderStep({
    required this.number,
    required this.label,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 28.w,
          height: 28.w,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: _bubbleColor(),
            shape: BoxShape.circle,
            border: Border.all(color: _borderColor(), width: 1.2.w),
          ),
          child: state == _PhoneStepState.completed
              ? Icon(
            Icons.check_rounded,
            size: 16.sp,
            color: _textColor(),
          )
              : Text(
            number,
            style: TextStyle(
              color: _textColor(),
              fontSize: 11.sp,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          label,
          style: TextStyle(
            color: _labelColor(),
            fontSize: 8.5.sp,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }

  Color _bubbleColor() {
    switch (state) {
      case _PhoneStepState.completed:
        return RoleTheme.iconValidation.withValues(alpha: 0.16);
      case _PhoneStepState.active:
        return RoleTheme.brandSurface;
      case _PhoneStepState.pending:
        return RoleTheme.brandChipBackground;
    }
  }

  Color _borderColor() {
    switch (state) {
      case _PhoneStepState.completed:
        return RoleTheme.iconValidation.withValues(alpha: 0.92);
      case _PhoneStepState.active:
        return RoleTheme.brandPrimary.withValues(alpha: 0.55);
      case _PhoneStepState.pending:
        return RoleTheme.brandBorder;
    }
  }

  Color _textColor() {
    switch (state) {
      case _PhoneStepState.completed:
        return RoleTheme.iconValidation;
      case _PhoneStepState.active:
        return RoleTheme.brandPrimary;
      case _PhoneStepState.pending:
        return RoleTheme.brandSecondary;
    }
  }

  Color _labelColor() {
    switch (state) {
      case _PhoneStepState.completed:
      case _PhoneStepState.active:
        return RoleTheme.brandText;
      case _PhoneStepState.pending:
        return RoleTheme.brandMutedText;
    }
  }
}

class _StepDivider extends StatelessWidget {
  final _PhoneStepState state;

  const _StepDivider({required this.state});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: EdgeInsets.only(bottom: 17.h),
        child: Container(
          height: 3.h,
          margin: EdgeInsets.symmetric(horizontal: 8.w),
          decoration: BoxDecoration(
            color: _color(),
            borderRadius: BorderRadius.circular(20.r),
          ),
        ),
      ),
    );
  }

  Color _color() {
    switch (state) {
      case _PhoneStepState.completed:
        return RoleTheme.iconValidation.withValues(alpha: 0.85);
      case _PhoneStepState.active:
        return RoleTheme.brandPrimary.withValues(alpha: 0.72);
      case _PhoneStepState.pending:
        return RoleTheme.brandSoft.withValues(alpha: 0.55);
    }
  }
}

enum _PhoneStepState { pending, active, completed }
