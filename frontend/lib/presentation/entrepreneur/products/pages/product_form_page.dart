import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:emprendedor/core/theme/role_theme.dart';
import 'package:emprendedor/data/models/entrepreneur/catalog/product_model.dart';
import 'package:emprendedor/features/entrepreneur/controllers/index.dart';
import 'package:emprendedor/presentation/entrepreneur/products/widgets/index.dart';
import 'package:emprendedor/presentation/shared/widgets/app_feedback.dart';

class ProductFormPage extends StatefulWidget {
  const ProductFormPage({super.key, this.productToEdit});

  final ProductModel? productToEdit;

  @override
  State<ProductFormPage> createState() => _ProductFormPageState();
}

class _ProductFormPageState extends State<ProductFormPage> {
  late final ProductFormController _formController;
  bool _initialized = false;
  String? _submitProgressMessage;

  bool get _isSubmittingProduct => _submitProgressMessage != null;

  @override
  void initState() {
    super.initState();
    _formController = ProductFormController(product: widget.productToEdit);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    _initialized = true;

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      final controller = context.read<ProductController>();
      controller.clearErrorMessage();
      controller.clearSelectedImage();
      await controller.initUser();
      if (!mounted) return;
      controller.clearErrorMessage();
    });
  }

  @override
  void dispose() {
    _formController.dispose();
    super.dispose();
  }

  Future<void> _saveProduct(ProductController controller) async {
    if (_isSubmittingProduct) return;

    controller.clearErrorMessage();

    final hasNewImage = controller.selectedImageFile != null;
    setState(() {
      _submitProgressMessage = hasNewImage
          ? 'Preparando imagen del producto...'
          : 'Enviando producto a validación...';
    });

    if (hasNewImage) {
      await Future<void>.delayed(const Duration(milliseconds: 350));
      if (!mounted) return;
      setState(() {
        _submitProgressMessage = 'Subiendo imagen y enviando a validación...';
      });
    }

    final result = await _formController
        .submit(controller)
        .timeout(
          const Duration(seconds: 28),
          onTimeout: () {
            controller.clearLoadingState();
            return const ProductFormSubmitResult(
              success: false,
              message:
                  'No se pudo guardar el producto. Revisa tu conexión a internet e inténtalo nuevamente.',
            );
          },
        );

    if (!mounted) return;

    if (result.success) {
      Navigator.of(context).pop();
      return;
    }

    setState(() => _submitProgressMessage = null);
    controller.clearErrorMessage();

    showAppMessage(
      context,
      role: AppFeedbackRole.entrepreneur,
      type: AppFeedbackType.error,
      title: 'No se pudo guardar',
      message: result.message,
    );
  }

  void _continueToNutritionStep(ProductController controller) {
    final result = _formController.validateBasicStep(controller);
    if (result != null) {
      showAppMessage(
        context,
        role: AppFeedbackRole.entrepreneur,
        type: AppFeedbackType.error,
        title: 'Revisa el producto',
        message: result.message,
      );
      return;
    }

    _formController.goToNutritionStep();
  }

  void _continueToReviewStep() {
    final result = _formController.validateNutritionStep();
    if (result != null) {
      showAppMessage(
        context,
        role: AppFeedbackRole.entrepreneur,
        type: AppFeedbackType.error,
        title: 'Revisa la información',
        message: result.message,
      );
      return;
    }

    _formController.goToReviewStep();
  }

  Widget _buildStepIndicator() {
    const palette = RoleTheme.entrepreneur;
    final step = _formController.currentStep;
    final labels = ['Datos básicos', 'Nutrición', 'Revisión y alertas'];

    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: palette.primary.withValues(alpha: 0.10)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Paso ${step + 1} de 3',
                style: TextStyle(
                  color: palette.primary,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const Spacer(),
              Flexible(
                child: Text(
                  labels[step],
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: palette.mutedText,
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 9.h),
          ClipRRect(
            borderRadius: BorderRadius.circular(999.r),
            child: LinearProgressIndicator(
              minHeight: 7.h,
              value: (step + 1) / 3,
              backgroundColor: palette.primary.withValues(alpha: 0.10),
              valueColor: AlwaysStoppedAnimation<Color>(palette.primary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContinueButton(
    ProductController controller,
    VoidCallback onPressed,
  ) {
    const palette = RoleTheme.entrepreneur;

    return Align(
      alignment: Alignment.centerRight,
      child: TextButton.icon(
        onPressed: controller.isLoading ? null : onPressed,
        icon: Icon(Icons.arrow_forward_rounded, size: 18.sp),
        label: Text(
          'Continuar',
          style: TextStyle(fontSize: 12.8.sp, fontWeight: FontWeight.w900),
        ),
        style: TextButton.styleFrom(
          foregroundColor: palette.primary,
          disabledForegroundColor: palette.primary.withValues(alpha: 0.35),
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          visualDensity: VisualDensity.compact,
        ),
      ),
    );
  }

  Widget _buildStepNavigationActions({
    required ProductController controller,
    required VoidCallback onBack,
    required VoidCallback onNext,
  }) {
    const palette = RoleTheme.entrepreneur;

    return Row(
      children: [
        TextButton.icon(
          onPressed: controller.isLoading ? null : onBack,
          icon: Icon(Icons.arrow_back_rounded, size: 18.sp),
          label: Text(
            'Atrás',
            style: TextStyle(fontSize: 12.8.sp, fontWeight: FontWeight.w900),
          ),
          style: TextButton.styleFrom(
            foregroundColor: palette.primary,
            disabledForegroundColor: palette.primary.withValues(alpha: 0.35),
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            visualDensity: VisualDensity.compact,
          ),
        ),
        const Spacer(),
        TextButton.icon(
          onPressed: controller.isLoading ? null : onNext,
          icon: Icon(Icons.arrow_forward_rounded, size: 18.sp),
          label: Text(
            'Continuar',
            style: TextStyle(fontSize: 12.8.sp, fontWeight: FontWeight.w900),
          ),
          style: TextButton.styleFrom(
            foregroundColor: palette.primary,
            disabledForegroundColor: palette.primary.withValues(alpha: 0.35),
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            visualDensity: VisualDensity.compact,
          ),
        ),
      ],
    );
  }

  Widget _buildFinalActions(ProductController controller) {
    const palette = RoleTheme.entrepreneur;

    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 46.h,
            child: OutlinedButton.icon(
              onPressed: controller.isLoading || _isSubmittingProduct
                  ? null
                  : _formController.goToNutritionStep,
              icon: Icon(Icons.arrow_back_rounded, size: 18.sp),
              label: Text(
                'Atrás',
                style: TextStyle(
                  fontSize: 12.8.sp,
                  fontWeight: FontWeight.w900,
                ),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: palette.primary,
                side: BorderSide(
                  color: palette.primary.withValues(alpha: 0.22),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.r),
                ),
              ),
            ),
          ),
        ),
        SizedBox(width: 10.w),
        Expanded(
          flex: 2,
          child: ProductSubmitButton(
            isLoading: controller.isLoading || _isSubmittingProduct,
            isEditing: _formController.isEditing,
            loadingLabel: _submitProgressMessage,
            onPressed: () => _saveProduct(controller),
          ),
        ),
      ],
    );
  }

  Widget _buildBasicInfoSection(ProductController controller) {
    return ProductFormSectionCard(
      title: 'Información básica',
      icon: Icons.restaurant_menu_rounded,
      child: Column(
        children: [
          ProductFormField(
            controller: _formController.nameController,
            label: 'Nombre del producto',
            icon: Icons.fastfood_outlined,
            validator: _formController.requiredValidator,
            compact: true,
          ),
          SizedBox(height: 8.h),
          ProductFormField(
            controller: _formController.priceController,
            label: 'Precio',
            icon: Icons.attach_money_rounded,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            validator: _formController.priceValidator,
            compact: true,
          ),
          SizedBox(height: 8.h),
          ProductCategoryDropdown(
            selectedCategory: _formController.selectedCategory,
            categories: controller.categories,
            onChanged: _formController.setCategory,
            compact: true,
          ),
        ],
      ),
    );
  }

  Widget _buildNutritionSection() {
    return ProductFormSectionCard(
      title: 'Detalle nutricional',
      icon: Icons.health_and_safety_rounded,
      child: Column(
        children: [
          ProductFormField(
            controller: _formController.descriptionController,
            label: 'Descripción',
            icon: Icons.description_outlined,
            maxLines: 3,
            validator: _formController.requiredValidator,
          ),
          SizedBox(height: 10.h),
          ProductFormField(
            controller: _formController.ingredientsController,
            label: 'Ingredientes separados por coma',
            icon: Icons.list_alt_rounded,
            maxLines: 3,
            validator: _formController.requiredValidator,
          ),
          SizedBox(height: 10.h),
          ProductFormField(
            controller: _formController.servingSizeController,
            label: _formController.servingSizeLabel,
            icon: Icons.scale_rounded,
            validator: _formController.requiredValidator,
          ),
          SizedBox(height: 10.h),
          ProductFormField(
            controller: _formController.caloriesController,
            label: 'Calorías aproximadas',
            icon: Icons.local_fire_department_outlined,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            validator: _formController.caloriesValidator,
          ),
          SizedBox(height: 10.h),
          Row(
            children: [
              Expanded(
                child: ProductFormField(
                  controller: _formController.proteinController,
                  label: 'Proteínas (g)',
                  icon: Icons.fitness_center_rounded,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  validator: _formController.optionalNumberValidator,
                  compact: true,
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: ProductFormField(
                  controller: _formController.fatsController,
                  label: 'Grasas (g)',
                  icon: Icons.water_drop_rounded,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  validator: _formController.optionalNumberValidator,
                  compact: true,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          ProductFormField(
            controller: _formController.carbohydratesController,
            label: 'Carbohidratos (g)',
            icon: Icons.grain_rounded,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            validator: _formController.optionalNumberValidator,
            compact: true,
          ),
        ],
      ),
    );
  }

  Widget _buildReviewSection() {
    return ProductFormSectionCard(
      title: 'Revisión y alertas',
      icon: Icons.fact_check_rounded,
      child: Column(
        children: [
          ProductFormField(
            controller: _formController.allergensController,
            label: 'Alérgenos separados por coma',
            icon: Icons.warning_amber_rounded,
            maxLines: 2,
          ),
          SizedBox(height: 10.h),
          ProductFormField(
            controller: _formController.dietaryTagsController,
            label: 'Etiquetas dietarias separadas por coma',
            icon: Icons.eco_rounded,
            maxLines: 2,
          ),
        ],
      ),
    );
  }

  Widget _buildImageSection(ProductController controller) {
    return ProductFormSectionCard(
      title: 'Imagen del producto',
      icon: Icons.image_rounded,
      child: ProductImagePickerSection(
        isLoading: controller.isLoading,
        selectedImagePath: controller.selectedImageFile?.path,
        currentImageUrl: widget.productToEdit?.imageUrl,
        onPickImage: controller.pickImage,
      ),
    );
  }

  Widget _buildFormContent(ProductController controller) {
    return ListView(
      physics: const BouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      ),
      padding: EdgeInsets.fromLTRB(14.w, 6.h, 14.w, 24.h),
      children: [
        ProductFormHeader(isEditing: _formController.isEditing),
        SizedBox(height: 12.h),
        _buildStepIndicator(),
        SizedBox(height: 12.h),
        if (_formController.isBasicStep) ...[
          _buildBasicInfoSection(controller),
          SizedBox(height: 12.h),
          _buildImageSection(controller),
          SizedBox(height: 16.h),
          _buildContinueButton(
            controller,
            () => _continueToNutritionStep(controller),
          ),
        ] else if (_formController.isNutritionStep) ...[
          _buildNutritionSection(),
          SizedBox(height: 16.h),
          _buildStepNavigationActions(
            controller: controller,
            onBack: _formController.goToBasicStep,
            onNext: _continueToReviewStep,
          ),
        ] else ...[
          _buildReviewSection(),
          SizedBox(height: 12.h),
          const ProductValidationNotice(),
          if (_submitProgressMessage != null) ...[
            SizedBox(height: 12.h),
            ProductSubmitProgressCard(message: _submitProgressMessage!),
          ],
          SizedBox(height: 16.h),
          _buildFinalActions(controller),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<ProductController>();
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
            iconTheme: IconThemeData(color: palette.text),
            title: Text(
              _formController.isEditing
                  ? 'Editar producto'
                  : 'Agregar producto',
              style: TextStyle(
                color: palette.text,
                fontSize: 19.sp,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          body: controller.userId == null && controller.isLoading
              ? Center(child: CircularProgressIndicator(color: palette.primary))
              : SafeArea(
                  top: false,
                  child: Form(
                    key: _formController.formKey,
                    child: _buildFormContent(controller),
                  ),
                ),
        );
      },
    );
  }
}
