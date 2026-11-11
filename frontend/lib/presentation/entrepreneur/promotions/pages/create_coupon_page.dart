import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:emprendedor/core/theme/role_theme.dart';
import 'package:emprendedor/data/models/entrepreneur/index.dart';
import 'package:emprendedor/features/entrepreneur/controllers/index.dart';
import 'package:emprendedor/presentation/entrepreneur/promotions/widgets/coupon/coupon_promotion_summary_card.dart';
import 'package:emprendedor/presentation/shared/widgets/app_feedback.dart';

class CreateCouponPage extends StatefulWidget {
  final PromotionModel promotion;

  const CreateCouponPage({super.key, required this.promotion});

  @override
  State<CreateCouponPage> createState() => _CreateCouponPageState();
}

class _CreateCouponPageState extends State<CreateCouponPage> {
  late final CouponFormController _formController;

  final Random _couponCodeRandom = Random();

  bool _autoGenerateCode = true;

  @override
  void initState() {
    super.initState();
    _formController = CouponFormController(promotion: widget.promotion);
    _generateCouponCode();
  }

  @override
  void dispose() {
    _formController.dispose();
    super.dispose();
  }

  String _buildCouponCode() {
    final source = widget.promotion.name.toUpperCase().replaceAll(
      RegExp(r'[^A-Z0-9]'),
      '',
    );

    final prefix = source.isEmpty
        ? 'CUPON'
        : source.substring(0, min(6, source.length));

    final value = widget.promotion.discountValue.round().toString();
    final suffix = (_couponCodeRandom.nextInt(90) + 10).toString();

    return '$prefix$value$suffix';
  }

  void _generateCouponCode() {
    _formController.couponCodeController.text = _buildCouponCode();
  }

  void _refreshCouponCode() {
    if (!_autoGenerateCode) {
      setState(() => _autoGenerateCode = true);
    }

    _generateCouponCode();
  }

  void _toggleCodeMode(bool autoGenerate) {
    setState(() => _autoGenerateCode = autoGenerate);

    if (autoGenerate) {
      _generateCouponCode();
    } else {
      _formController.couponCodeController.clear();
    }
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _formController.validityDate ?? _formController.today,
      firstDate: _formController.today,
      lastDate: DateTime(2030, 12, 31),
    );

    if (!mounted || picked == null) return;

    _formController.applyPickedDate(picked);
  }

  Future<void> _showFeedback(CouponFormSubmitResult result) {
    return showAppMessage(
      context,
      role: AppFeedbackRole.entrepreneur,
      type: result.success ? AppFeedbackType.success : AppFeedbackType.error,
      title: result.title,
      message: result.message,
    );
  }

  Future<void> _submitForm() async {
    if (_formController.isSubmitting) return;

    final result = await _formController.submit(
      context.read<PromotionController>(),
    );

    if (!mounted) return;

    await _showFeedback(result);

    if (result.success && mounted) {
      Navigator.of(context).pop();
    }
  }

  Widget _buildCouponDataSection() {
    const palette = RoleTheme.entrepreneur;

    return _CouponSectionCard(
      title: 'Datos del cupón',
      subtitle: 'Define el código, compra mínima y reglas de uso.',
      icon: Icons.confirmation_number_rounded,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _CouponFieldLabel(
            icon: Icons.local_offer_outlined,
            text: 'Código del cupón',
          ),
          SizedBox(height: 8.h),
          _CodeModeTile(
            selected: _autoGenerateCode,
            title: 'Generar código automáticamente',
            subtitle: 'El sistema generará un código único.',
            onTap: () => _toggleCodeMode(true),
          ),
          SizedBox(height: 7.h),
          _CodeModeTile(
            selected: !_autoGenerateCode,
            title: 'Ingresar código manualmente',
            subtitle: 'Escribe tu propio código.',
            onTap: () => _toggleCodeMode(false),
          ),
          SizedBox(height: 9.h),
          TextFormField(
            controller: _formController.couponCodeController,
            readOnly: _autoGenerateCode,
            validator: _formController.couponCodeValidator,
            textCapitalization: TextCapitalization.characters,
            textAlign: TextAlign.center,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]')),
              UpperCaseTextFormatter(),
            ],
            style: TextStyle(
              color: palette.text,
              fontSize: 13.sp,
              fontWeight: FontWeight.w900,
              letterSpacing: 5.w,
            ),
            decoration: InputDecoration(
              suffixIcon: IconButton(
                onPressed: _refreshCouponCode,
                icon: Icon(
                  Icons.refresh_rounded,
                  color: palette.primary,
                  size: 18.sp,
                ),
              ),
              filled: true,
              fillColor: palette.primary.withValues(alpha: 0.025),
              isDense: true,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 12.w,
                vertical: 9.h,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(
                  color: palette.primary.withValues(alpha: 0.45),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(color: palette.primary, width: 1.2.w),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(
                  color: RoleTheme.iconDanger.withValues(alpha: 0.75),
                ),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(
                  color: RoleTheme.iconDanger,
                  width: 1.2.w,
                ),
              ),
            ),
          ),
          SizedBox(height: 12.h),
          const _CouponFieldLabel(
            icon: Icons.attach_money_rounded,
            text: 'Compra mínima (opcional)',
          ),
          SizedBox(height: 7.h),
          TextFormField(
            controller: _formController.minPurchaseController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            validator: _formController.minPurchaseValidator,
            style: TextStyle(
              color: palette.text,
              fontSize: 12.sp,
              fontWeight: FontWeight.w800,
            ),
            decoration: _fieldDecoration(
              hintText: '0.00',
              icon: Icons.attach_money_rounded,
            ),
          ),
          SizedBox(height: 5.h),
          Text(
            'Deja en 0 si no requiere compra mínima.',
            style: TextStyle(
              color: palette.mutedText,
              fontSize: 9.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildValiditySection() {
    const palette = RoleTheme.entrepreneur;

    return _CouponSectionCard(
      title: 'Vigencia del cupón',
      subtitle: 'Define hasta cuándo podrá usarse el cupón.',
      icon: Icons.calendar_month_rounded,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Fecha de validez',
            style: TextStyle(
              color: palette.primary,
              fontSize: 9.5.sp,
              fontWeight: FontWeight.w900,
            ),
          ),
          SizedBox(height: 6.h),
          InkWell(
            onTap: _formController.isSubmitting ? null : _selectDate,
            borderRadius: BorderRadius.circular(13.r),
            child: InputDecorator(
              decoration: _fieldDecoration(icon: Icons.calendar_month_rounded),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      _formController.formattedDate,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: palette.text,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  SizedBox(width: 6.w),
                  Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: palette.mutedText,
                    size: 18.sp,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormContent() {
    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.fromLTRB(14.w, 8.h, 14.w, 24.h),
      children: [
        CouponPromotionSummaryCard(
          promotionName: widget.promotion.name,
          discountText: _formController.discountText,
        ),
        SizedBox(height: 10.h),
        _buildCouponDataSection(),
        SizedBox(height: 10.h),
        _buildValiditySection(),
        SizedBox(height: 14.h),
        _CreateCouponButton(
          isSubmitting: _formController.isSubmitting,
          onPressed: _submitForm,
        ),
        SizedBox(height: 8.h),
        _CancelCouponButton(onPressed: () => Navigator.of(context).pop()),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    const palette = RoleTheme.entrepreneur;

    return ListenableBuilder(
      listenable: _formController,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: palette.background,
          appBar: AppBar(
            backgroundColor: palette.background,
            surfaceTintColor: palette.background,
            elevation: 0,
            centerTitle: true,
            title: Text(
              'Crear cupón',
              style: TextStyle(
                color: palette.text,
                fontSize: 17.sp,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          body: SafeArea(
            top: false,
            child: Form(
              key: _formController.formKey,
              child: _buildFormContent(),
            ),
          ),
        );
      },
    );
  }
}

class _CouponSectionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Widget child;

  const _CouponSectionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    const palette = RoleTheme.entrepreneur;

    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: palette.primary.withValues(alpha: 0.07)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 31.w,
                height: 31.w,
                decoration: BoxDecoration(
                  color: palette.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(
                  icon,
                  color: RoleTheme.iconColorFor(
                    icon,
                    fallback: palette.primary,
                  ),
                  size: 16.sp,
                ),
              ),
              SizedBox(width: 9.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: palette.text,
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: palette.mutedText,
                        fontSize: 9.5.sp,
                        fontWeight: FontWeight.w600,
                        height: 1.25,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          child,
        ],
      ),
    );
  }
}

class _CouponFieldLabel extends StatelessWidget {
  final IconData icon;
  final String text;

  const _CouponFieldLabel({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    const palette = RoleTheme.entrepreneur;

    return Row(
      children: [
        Icon(icon, color: palette.primary, size: 14.sp),
        SizedBox(width: 6.w),
        Expanded(
          child: Text(
            text,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: palette.text,
              fontSize: 10.3.sp,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ],
    );
  }
}

class _CodeModeTile extends StatelessWidget {
  final bool selected;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _CodeModeTile({
    required this.selected,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const palette = RoleTheme.entrepreneur;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: palette.primary.withValues(alpha: selected ? 0.045 : 0.018),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: selected
                ? palette.primary.withValues(alpha: 0.28)
                : palette.primary.withValues(alpha: 0.08),
          ),
        ),
        child: Row(
          children: [
            Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: selected ? palette.primary : palette.mutedText,
              size: 15.sp,
            ),
            SizedBox(width: 9.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: palette.text,
                      fontSize: 10.3.sp,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: palette.mutedText,
                      fontSize: 8.8.sp,
                      fontWeight: FontWeight.w600,
                      height: 1.2,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CreateCouponButton extends StatelessWidget {
  final bool isSubmitting;
  final VoidCallback onPressed;

  const _CreateCouponButton({
    required this.isSubmitting,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    const palette = RoleTheme.entrepreneur;

    return SizedBox(
      width: double.infinity,
      height: 42.h,
      child: ElevatedButton.icon(
        onPressed: isSubmitting ? null : onPressed,
        icon: isSubmitting
            ? SizedBox(
                width: 16.w,
                height: 16.w,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: palette.surface,
                ),
              )
            : Icon(
                Icons.confirmation_number_rounded,
                color: palette.surface,
                size: 16.sp,
              ),
        label: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(isSubmitting ? 'Creando...' : 'Crear cupón'),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: palette.primary,
          foregroundColor: palette.surface,
          disabledBackgroundColor: palette.primary.withValues(alpha: 0.40),
          disabledForegroundColor: palette.surface.withValues(alpha: 0.80),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(13.r),
          ),
          textStyle: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w900),
        ),
      ),
    );
  }
}

class _CancelCouponButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _CancelCouponButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    const palette = RoleTheme.entrepreneur;

    return SizedBox(
      width: double.infinity,
      height: 38.h,
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          foregroundColor: palette.primary,
          backgroundColor: palette.primary.withValues(alpha: 0.045),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(13.r),
          ),
          textStyle: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w900),
        ),
        child: const Text('Cancelar'),
      ),
    );
  }
}

InputDecoration _fieldDecoration({String? hintText, IconData? icon}) {
  const palette = RoleTheme.entrepreneur;

  return InputDecoration(
    hintText: hintText,
    hintStyle: TextStyle(
      color: palette.mutedText,
      fontSize: 11.sp,
      fontWeight: FontWeight.w600,
    ),
    prefixIcon: icon == null
        ? null
        : Icon(icon, color: palette.primary, size: 18.sp),
    filled: true,
    fillColor: palette.primary.withValues(alpha: 0.025),
    isDense: true,
    contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(13.r)),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(13.r),
      borderSide: BorderSide(color: palette.primary.withValues(alpha: 0.10)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(13.r),
      borderSide: BorderSide(color: palette.primary, width: 1.2.w),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(13.r),
      borderSide: BorderSide(
        color: RoleTheme.iconDanger.withValues(alpha: 0.75),
      ),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(13.r),
      borderSide: BorderSide(color: RoleTheme.iconDanger, width: 1.2.w),
    ),
  );
}

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final upperText = newValue.text.toUpperCase();

    return newValue.copyWith(
      text: upperText,
      selection: newValue.selection,
      composing: TextRange.empty,
    );
  }
}
