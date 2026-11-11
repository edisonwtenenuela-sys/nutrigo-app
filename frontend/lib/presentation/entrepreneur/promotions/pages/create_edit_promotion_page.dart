import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import 'package:emprendedor/core/theme/role_theme.dart';
import 'package:emprendedor/data/models/entrepreneur/promotions/promotion_model.dart';
import 'package:emprendedor/features/entrepreneur/controllers/index.dart';
import 'package:emprendedor/presentation/entrepreneur/promotions/widgets/index.dart';
import 'package:emprendedor/presentation/shared/widgets/app_feedback.dart';

class CreateEditPromotionPage extends StatefulWidget {
  final PromotionModel? promotionToEdit;

  const CreateEditPromotionPage({super.key, this.promotionToEdit});

  @override
  State<CreateEditPromotionPage> createState() =>
      _CreateEditPromotionPageState();
}

class _CreateEditPromotionPageState extends State<CreateEditPromotionPage> {
  late final PromotionFormController _formController;

  static const double _sectionSpacing = 11;

  int _currentStep = 0;

  bool get _isFirstStep => _currentStep == 0;

  @override
  void initState() {
    super.initState();

    _formController = PromotionFormController(
      promotion: widget.promotionToEdit,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<ProductController>().initUser();
    });
  }

  @override
  void dispose() {
    _formController.dispose();
    super.dispose();
  }

  Future<void> _selectDate({required bool isStart}) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isStart
          ? _formController.startDate
          : _formController.endDate,
      firstDate: isStart ? _formController.today : _formController.startDate,
      lastDate: DateTime(2030, 12, 31),
    );

    if (!mounted || picked == null) return;

    _formController.applyPickedDate(isStart: isStart, picked: picked);
  }

  Future<void> _showFeedback(PromotionFormSubmitResult result) {
    return showAppMessage(
      context,
      role: AppFeedbackRole.entrepreneur,
      type: result.success ? AppFeedbackType.success : AppFeedbackType.error,
      title: result.title,
      message: result.message,
    );
  }

  void _goToNextStep() {
    if (!(_formController.formKey.currentState?.validate() ?? false)) return;

    FocusScope.of(context).unfocus();
    setState(() => _currentStep = 1);
  }

  void _goBackStep() {
    FocusScope.of(context).unfocus();
    setState(() => _currentStep = 0);
  }

  Future<void> _submitForm() async {
    if (_formController.isSubmitting) return;

    final result = await _formController
        .submit(context.read<PromotionController>())
        .timeout(
          const Duration(seconds: 18),
          onTimeout: () {
            _formController.clearSubmittingState();
            return const PromotionFormSubmitResult(
              success: false,
              title: 'No se pudo guardar',
              message:
                  'No se pudo guardar la promoción. Revisa tu conexión a internet e inténtalo nuevamente.',
            );
          },
        );

    if (!mounted) return;

    await _showFeedback(result);

    if (result.success && mounted) {
      Navigator.of(context).pop();
    }
  }

  Widget _sectionGap() => SizedBox(height: _sectionSpacing.h);

  void _adjustDiscountValue(double delta) {
    final current =
        double.tryParse(_formController.discountValueController.text.trim()) ??
        0;

    final next = current + delta;

    final clamped = _formController.discountType == DiscountType.percentage
        ? next.clamp(0, 100).toDouble()
        : next.clamp(0, double.infinity).toDouble();

    _formController.discountValueController.text = clamped % 1 == 0
        ? clamped.toStringAsFixed(0)
        : clamped.toStringAsFixed(2);

    _formController.discountValueController.selection = TextSelection.collapsed(
      offset: _formController.discountValueController.text.length,
    );
  }

  Widget _buildStepProgress() {
    const palette = RoleTheme.entrepreneur;

    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(15.r),
        border: Border.all(color: palette.primary.withValues(alpha: 0.09)),
      ),
      child: Row(
        children: [
          Expanded(
            child: _PromotionStepChip(
              number: '1',
              label: 'Datos',
              selected: _isFirstStep,
              completed: !_isFirstStep,
              onTap: _goBackStep,
            ),
          ),
          SizedBox(width: 6.w),
          Expanded(
            child: _PromotionStepChip(
              number: '2',
              label: 'Aplicación',
              selected: !_isFirstStep,
              completed: false,
              onTap: _isFirstStep ? null : () {},
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainInfoSection() {
    return PromotionSectionCard(
      title: 'Información principal',
      subtitle: 'Nombre y descripción visible para tus clientes.',
      icon: Icons.discount_rounded,
      child: Column(
        children: [
          PromotionFormField(
            controller: _formController.nameController,
            label: 'Nombre de la promoción',
            icon: Icons.local_offer_outlined,
            validator: _formController.requiredValidator,
          ),
          SizedBox(height: 9.h),
          PromotionFormField(
            controller: _formController.descriptionController,
            label: 'Descripción',
            icon: Icons.description_outlined,
            maxLines: 3,
          ),
        ],
      ),
    );
  }

  Widget _buildDiscountSection() {
    return PromotionSectionCard(
      title: 'Descuento',
      subtitle: 'Define si el beneficio será por porcentaje o monto.',
      icon: Icons.percent_rounded,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _PromotionFieldLabel('Tipo de descuento'),
          SizedBox(height: 7.h),
          PromotionDiscountSelector(
            selectedType: _formController.discountType,
            isSubmitting: _formController.isSubmitting,
            onChanged: _formController.setDiscountType,
          ),
          SizedBox(height: 11.h),
          const _PromotionFieldLabel('Valor del descuento'),
          SizedBox(height: 7.h),
          Row(
            children: [
              Expanded(
                child: PromotionFormField(
                  controller: _formController.discountValueController,
                  label: _formController.discountType == DiscountType.percentage
                      ? 'Ej: 15'
                      : 'Ej: 2.50',
                  icon: _formController.discountType == DiscountType.percentage
                      ? Icons.percent_rounded
                      : Icons.attach_money_rounded,
                  suffixText:
                      _formController.discountType == DiscountType.percentage
                      ? '%'
                      : null,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  validator: _formController.discountValidator,
                ),
              ),
              SizedBox(width: 8.w),
              _DiscountStepper(
                onDecrease: () => _adjustDiscountValue(
                  _formController.discountType == DiscountType.percentage
                      ? -1
                      : -0.50,
                ),
                onIncrease: () => _adjustDiscountValue(
                  _formController.discountType == DiscountType.percentage
                      ? 1
                      : 0.50,
                ),
              ),
            ],
          ),
          SizedBox(height: 9.h),
          _PromotionInfoNote(
            text: _formController.discountType == DiscountType.percentage
                ? 'El descuento se aplicará sobre el total de la compra.'
                : 'El monto se descontará del total de la compra.',
          ),
        ],
      ),
    );
  }

  Widget _buildProductSelectionSection(ProductController productController) {
    return PromotionSectionCard(
      title: 'Productos aplicables',
      subtitle: 'Elige todo el catálogo o productos específicos.',
      icon: Icons.inventory_2_rounded,
      child: ProductSelectionSection(
        selectedScope: _formController.selectedScope,
        products: productController.products,
        selectedProductIds: _formController.selectedProductIds,
        isLoading: productController.isLoading,
        onScopeChanged: _formController.setScope,
        onToggleProduct: _formController.toggleProduct,
      ),
    );
  }

  Widget _buildDateRangeSection() {
    return PromotionSectionCard(
      title: 'Vigencia',
      subtitle: 'Indica el período de disponibilidad.',
      icon: Icons.calendar_month_rounded,
      child: Column(
        children: [
          PromotionDatePickerTile(
            title: 'Fecha de inicio',
            dateText: _formController.formatDate(_formController.startDate),
            onTap: _formController.isSubmitting
                ? null
                : () => _selectDate(isStart: true),
          ),
          SizedBox(height: 8.h),
          PromotionDatePickerTile(
            title: 'Fecha de finalización',
            dateText: _formController.formatDate(_formController.endDate),
            onTap: _formController.isSubmitting
                ? null
                : () => _selectDate(isStart: false),
          ),
          SizedBox(height: 9.h),
          const _PromotionInfoNote(
            text:
                'La promoción estará activa desde el inicio de la fecha seleccionada hasta el final del día de finalización.',
          ),
        ],
      ),
    );
  }

  List<Widget> _buildStepSections(ProductController productController) {
    if (_isFirstStep) {
      return [_buildMainInfoSection(), _sectionGap(), _buildDiscountSection()];
    }

    return [
      _buildProductSelectionSection(productController),
      _sectionGap(),
      _buildDateRangeSection(),
    ];
  }

  Widget _buildStepActions() {
    const palette = RoleTheme.entrepreneur;

    if (_isFirstStep) {
      return Align(
        alignment: Alignment.centerRight,
        child: TextButton.icon(
          onPressed: _formController.isSubmitting ? null : _goToNextStep,
          icon: Icon(Icons.arrow_forward_rounded, size: 17.sp),
          label: Text(
            'Continuar',
            style: TextStyle(fontSize: 12.7.sp, fontWeight: FontWeight.w900),
          ),
          style: TextButton.styleFrom(
            foregroundColor: palette.primary,
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
          ),
        ),
      );
    }

    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 44.h,
            child: OutlinedButton.icon(
              onPressed: _formController.isSubmitting ? null : _goBackStep,
              icon: Icon(Icons.arrow_back_rounded, size: 17.sp),
              label: Text(
                'Atrás',
                style: TextStyle(
                  fontSize: 12.5.sp,
                  fontWeight: FontWeight.w900,
                ),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: palette.primary,
                backgroundColor: palette.primary.withValues(alpha: 0.025),
                side: BorderSide(
                  color: palette.primary.withValues(alpha: 0.18),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.r),
                ),
              ),
            ),
          ),
        ),
        SizedBox(width: 10.w),
        Expanded(
          flex: 2,
          child: PromotionSubmitButton(
            isSubmitting: _formController.isSubmitting,
            isEditing: _formController.isEditing,
            onPressed: _submitForm,
          ),
        ),
      ],
    );
  }

  Widget _buildFormContent(ProductController productController) {
    return ListView(
      physics: const ClampingScrollPhysics(),
      padding: EdgeInsets.fromLTRB(14.w, 8.h, 14.w, 18.h),
      children: [
        PromotionFormHeader(isEditing: _formController.isEditing),
        _sectionGap(),
        _buildStepProgress(),
        _sectionGap(),
        ..._buildStepSections(productController),
        SizedBox(height: 14.h),
        _buildStepActions(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final productController = context.watch<ProductController>();
    const palette = RoleTheme.entrepreneur;

    return ListenableBuilder(
      listenable: _formController,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: palette.background,
          resizeToAvoidBottomInset: true,
          appBar: AppBar(
            backgroundColor: palette.background,
            surfaceTintColor: palette.background,
            elevation: 0,
            centerTitle: true,
            title: Text(
              _formController.isEditing
                  ? 'Editar promoción'
                  : 'Crear promoción',
              style: TextStyle(
                color: palette.text,
                fontSize: 18.sp,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          body: SafeArea(
            top: false,
            child: Form(
              key: _formController.formKey,
              child: _buildFormContent(productController),
            ),
          ),
        );
      },
    );
  }
}

class _PromotionStepChip extends StatelessWidget {
  final String number;
  final String label;
  final bool selected;
  final bool completed;
  final VoidCallback? onTap;

  const _PromotionStepChip({
    required this.number,
    required this.label,
    required this.selected,
    required this.completed,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const palette = RoleTheme.entrepreneur;

    final foreground = selected ? palette.surface : palette.mutedText;
    final activeColor = selected ? palette.primary : palette.primary;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(13.r),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 7.h),
        decoration: BoxDecoration(
          color: selected
              ? activeColor
              : palette.primary.withValues(alpha: 0.045),
          borderRadius: BorderRadius.circular(13.r),
          border: Border.all(
            color: selected
                ? activeColor
                : palette.primary.withValues(alpha: 0.08),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 20.w,
              height: 20.w,
              decoration: BoxDecoration(
                color: selected
                    ? palette.surface.withValues(alpha: 0.22)
                    : palette.primary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: completed
                    ? Icon(
                        Icons.check_rounded,
                        color: palette.primary,
                        size: 13.sp,
                      )
                    : Text(
                        number,
                        style: TextStyle(
                          color: foreground,
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
              ),
            ),
            SizedBox(width: 7.w),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: foreground,
                  fontSize: 10.8.sp,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PromotionFieldLabel extends StatelessWidget {
  final String text;

  const _PromotionFieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    const palette = RoleTheme.entrepreneur;

    return Text(
      text,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        color: palette.text,
        fontSize: 10.5.sp,
        fontWeight: FontWeight.w800,
      ),
    );
  }
}

class _PromotionInfoNote extends StatelessWidget {
  final String text;

  const _PromotionInfoNote({required this.text});

  @override
  Widget build(BuildContext context) {
    const palette = RoleTheme.entrepreneur;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: palette.primary.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(11.r),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline_rounded,
            color: RoleTheme.iconColorFor(
              Icons.info_outline_rounded,
              fallback: palette.primary,
            ),
            size: 15.sp,
          ),
          SizedBox(width: 7.w),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: palette.primary,
                fontSize: 9.7.sp,
                fontWeight: FontWeight.w700,
                height: 1.2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DiscountStepper extends StatelessWidget {
  final VoidCallback onDecrease;
  final VoidCallback onIncrease;

  const _DiscountStepper({required this.onDecrease, required this.onIncrease});

  @override
  Widget build(BuildContext context) {
    const palette = RoleTheme.entrepreneur;

    return Container(
      height: 46.h,
      width: 56.w,
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(11.r),
        border: Border.all(color: palette.primary.withValues(alpha: 0.14)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _StepperIconButton(
            icon: Icons.keyboard_arrow_down_rounded,
            onTap: onDecrease,
          ),
          Container(
            width: 1,
            height: 18.h,
            color: palette.primary.withValues(alpha: 0.08),
          ),
          _StepperIconButton(
            icon: Icons.keyboard_arrow_up_rounded,
            onTap: onIncrease,
          ),
        ],
      ),
    );
  }
}

class _StepperIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _StepperIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    const palette = RoleTheme.entrepreneur;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8.r),
      child: SizedBox(
        width: 24.w,
        height: 38.h,
        child: Icon(
          icon,
          color: RoleTheme.iconColorFor(icon, fallback: palette.primary),
          size: 18.sp,
        ),
      ),
    );
  }
}
