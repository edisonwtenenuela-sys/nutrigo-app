import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:emprendedor/core/theme/role_theme.dart';
import 'package:emprendedor/core/utils/product_category_display.dart';
import 'package:emprendedor/data/models/entrepreneur/catalog/product_model.dart';
import 'package:emprendedor/data/models/entrepreneur/profile/business_profile_model.dart';
import 'package:emprendedor/data/repositories/entrepreneur/profile/business_profile_repository.dart';
import 'package:emprendedor/presentation/nutritionist/products/widgets/actions/nutritionist_product_action_buttons.dart';
import 'package:emprendedor/presentation/nutritionist/products/widgets/card/nutritionist_product_image.dart';
import 'package:emprendedor/presentation/nutritionist/products/widgets/card/nutritionist_product_info_chip.dart';
import 'package:emprendedor/presentation/nutritionist/products/widgets/card/nutritionist_product_review_note.dart';
import 'package:emprendedor/presentation/nutritionist/products/widgets/status/nutritionist_product_status_badge.dart';

class NutritionistProductValidationDetailSheet extends StatelessWidget {
  static final BusinessProfileRepository _businessRepository =
      BusinessProfileRepository();
  static final Map<String, BusinessProfileModel?> _businessProfileCache = {};

  final ProductModel product;
  final bool isProcessing;
  final bool isLoading;
  final BusinessProfileModel? initialBusinessProfile;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  const NutritionistProductValidationDetailSheet({
    super.key,
    required this.product,
    required this.isProcessing,
    required this.isLoading,
    this.initialBusinessProfile,
    required this.onApprove,
    required this.onReject,
  });

  String get _name {
    final value = product.name.trim();
    return value.isEmpty ? 'Sin descripción.' : value;
  }

  String get _description {
    final value = product.description.trim();
    return value.isEmpty ? 'Sin descripción.' : value;
  }

  List<Widget> _infoChips() {
    return [
      NutritionistProductInfoChip(
        icon: Icons.payments_rounded,
        label: '\$${product.price.toStringAsFixed(2)}',
        color: RoleTheme.nutritionist.primary,
      ),
      if (product.category.trim().isNotEmpty)
        NutritionistProductInfoChip(
          icon: Icons.category_rounded,
          label: ProductCategoryDisplay.label(product.category),
          color: RoleTheme.iconInfo,
        ),
    ];
  }

  String _numberValue(double? value, {String suffix = 'g'}) {
    if (value == null) return 'No declarado';
    return '${value.toStringAsFixed(0)} $suffix';
  }

  Widget _nutritionSection() {
    final portion = product.servingSize?.trim();
    final hasPortion = portion?.isNotEmpty == true;
    final hasAnyNutritionData =
        hasPortion ||
        product.approxCalories != null ||
        product.protein != null ||
        product.fats != null ||
        product.carbohydrates != null;

    if (!hasAnyNutritionData) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 14.h),
        Row(
          children: [
            Icon(
              Icons.monitor_heart_rounded,
              color: RoleTheme.iconColorFor(
                Icons.monitor_heart_rounded,
                fallback: RoleTheme.nutritionist.primary,
              ),
              size: 15.sp,
            ),
            SizedBox(width: 5.w),
            Text(
              'Información nutricional',
              style: TextStyle(
                fontSize: 12.5.sp,
                fontWeight: FontWeight.w900,
                color: RoleTheme.nutritionist.text,
              ),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        LayoutBuilder(
          builder: (context, constraints) {
            final itemWidth = (constraints.maxWidth - 8.w) / 2;
            return Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
              children: [
                _nutritionMetricCard(
                  width: itemWidth,
                  icon: Icons.scale_rounded,
                  label: 'Porción',
                  value: hasPortion ? portion! : 'No declarada',
                  color: RoleTheme.nutritionist.primary,
                ),
                _nutritionMetricCard(
                  width: itemWidth,
                  icon: Icons.local_fire_department_rounded,
                  label: 'Calorías',
                  value: product.approxCalories == null
                      ? 'No declaradas'
                      : '${product.approxCalories!.toStringAsFixed(0)} kcal',
                  color: RoleTheme.iconWarning,
                ),
                _nutritionMetricCard(
                  width: itemWidth,
                  icon: Icons.fitness_center_rounded,
                  label: 'Proteínas',
                  value: _numberValue(product.protein),
                  color: RoleTheme.iconValidation,
                ),
                _nutritionMetricCard(
                  width: itemWidth,
                  icon: Icons.water_drop_rounded,
                  label: 'Grasas',
                  value: _numberValue(product.fats),
                  color: RoleTheme.nutritionist.secondary,
                ),
                _nutritionMetricCard(
                  width: constraints.maxWidth,
                  icon: Icons.grain_rounded,
                  label: 'Carbohidratos',
                  value: _numberValue(product.carbohydrates),
                  color: RoleTheme.iconInfo,
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _nutritionMetricCard({
    required double width,
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      width: width,
      padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: color.withValues(alpha: 0.16)),
      ),
      child: Row(
        children: [
          Container(
            width: 26.w,
            height: 26.w,
            decoration: BoxDecoration(
              color: RoleTheme.nutritionist.surface,
              borderRadius: BorderRadius.circular(9.r),
            ),
            child: Icon(icon, color: color, size: 14.sp),
          ),
          SizedBox(width: 7.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  maxLines: 2,
                  style: TextStyle(
                    fontSize: 10.sp,
                    color: RoleTheme.nutritionist.mutedText,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 1.h),
                Text(
                  value,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11.5.sp,
                    color: RoleTheme.nutritionist.text,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _listBlock({
    required String title,
    required List<String> values,
    required IconData icon,
    required Color color,
  }) {
    if (values.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 12.h),
        Row(
          children: [
            Icon(icon, color: color, size: 15.sp),
            SizedBox(width: 5.w),
            Text(
              title,
              style: TextStyle(
                fontSize: 12.5.sp,
                fontWeight: FontWeight.w900,
                color: RoleTheme.nutritionist.text,
              ),
            ),
          ],
        ),
        SizedBox(height: 6.h),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(10.w),
          decoration: BoxDecoration(
            color: RoleTheme.nutritionist.background,
            borderRadius: BorderRadius.circular(14.r),
          ),
          child: Text(
            values.join(', '),
            style: TextStyle(
              fontSize: 11.5.sp,
              height: 1.35,
              color: RoleTheme.nutritionist.mutedText,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Future<BusinessProfileModel?> _loadBusinessProfile() async {
    final userId = product.userId?.trim();
    if (userId == null || userId.isEmpty) return null;
    if (_businessProfileCache.containsKey(userId)) {
      return _businessProfileCache[userId];
    }

    final profile = await _businessRepository.getBusinessProfile(userId);
    _businessProfileCache[userId] = profile;
    return profile;
  }

  BusinessProfileModel? _cachedBusinessProfile() {
    final userId = product.userId?.trim();
    if (userId == null || userId.isEmpty) return null;
    return initialBusinessProfile ?? _businessProfileCache[userId];
  }

  String _businessReviewsText(BusinessProfileModel profile) {
    final hasReviews = profile.totalReviews > 0 && profile.rating > 0;
    if (!hasReviews) return 'sin reseñas';

    final label = profile.totalReviews == 1 ? 'reseña' : 'reseñas';
    return '${profile.rating.toStringAsFixed(1)} (${profile.totalReviews}) $label';
  }

  Widget _businessSection() {
    return FutureBuilder<BusinessProfileModel?>(
      future: _loadBusinessProfile(),
      initialData: _cachedBusinessProfile(),
      builder: (context, snapshot) {
        final profile = snapshot.data;
        final businessName = profile?.name.trim().isNotEmpty == true
            ? profile!.name.trim()
            : 'Negocio no disponible';
        final imageUrl = profile?.profileImageUrl?.trim();

        return Container(
          width: double.infinity,
          margin: EdgeInsets.only(top: 10.h),
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
          decoration: BoxDecoration(
            color: RoleTheme.nutritionist.background,
            borderRadius: BorderRadius.circular(15.r),
            border: Border.all(
              color: RoleTheme.nutritionist.primary.withValues(alpha: 0.10),
            ),
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(9.r),
                child: Container(
                  width: 34.w,
                  height: 34.w,
                  color: RoleTheme.nutritionist.surface,
                  child: imageUrl != null && imageUrl.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: imageUrl,
                          fit: BoxFit.contain,
                          placeholder: (context, url) => Container(
                            margin: EdgeInsets.all(7.w),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEFF6FF),
                              borderRadius: BorderRadius.circular(7.r),
                            ),
                          ),
                          errorWidget: (context, url, error) => Icon(
                            Icons.storefront_rounded,
                            color: RoleTheme.iconColorFor(
                              Icons.storefront_rounded,
                              fallback: RoleTheme.nutritionist.primary,
                            ),
                            size: 18.sp,
                          ),
                        )
                      : Icon(
                          Icons.storefront_rounded,
                          color: RoleTheme.iconColorFor(
                            Icons.storefront_rounded,
                            fallback: RoleTheme.nutritionist.primary,
                          ),
                          size: 18.sp,
                        ),
                ),
              ),
              SizedBox(width: 9.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Negocio solicitante',
                      style: TextStyle(
                        color: RoleTheme.nutritionist.mutedText,
                        fontSize: 9.8.sp,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 1.h),
                    Text(
                      businessName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: RoleTheme.nutritionist.text,
                        fontSize: 12.2.sp,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    if (profile != null) ...[
                      SizedBox(height: 2.h),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            profile.totalReviews > 0 && profile.rating > 0
                                ? Icons.star_rounded
                                : Icons.star_border_rounded,
                            color: RoleTheme.iconWarning,
                            size: 11.sp,
                          ),
                          SizedBox(width: 2.5.w),
                          Flexible(
                            child: Text(
                              _businessReviewsText(profile),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: RoleTheme.nutritionist.mutedText,
                                fontSize: 9.5.sp,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              if (profile != null)
                Icon(
                  Icons.verified_rounded,
                  color: RoleTheme.iconValidation,
                  size: 17.sp,
                ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDisabled = isLoading || isProcessing;
    final canResolve =
        product.validationStatus == NutritionValidationStatus.pending;

    return SafeArea(
      top: false,
      child: DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.88,
        minChildSize: 0.55,
        maxChildSize: 0.95,
        builder: (context, scrollController) {
          return Container(
            decoration: BoxDecoration(
              color: RoleTheme.nutritionist.surface,
              borderRadius: BorderRadius.vertical(top: Radius.circular(26.r)),
            ),
            child: ListView(
              controller: scrollController,
              padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 18.h),
              children: [
                Center(
                  child: Container(
                    width: 42.w,
                    height: 4.h,
                    decoration: BoxDecoration(
                      color: RoleTheme.nutritionist.primary.withValues(
                        alpha: 0.16,
                      ),
                      borderRadius: BorderRadius.circular(99.r),
                    ),
                  ),
                ),
                SizedBox(height: 12.h),
                NutritionistProductImage(imageUrl: product.imageUrl),
                _businessSection(),
                SizedBox(height: 12.h),
                Row(
                  children: [
                    NutritionistProductStatusBadge(
                      status: product.validationStatus,
                    ),
                  ],
                ),
                SizedBox(height: 10.h),
                Text(
                  _name,
                  style: TextStyle(
                    fontSize: 17.sp,
                    fontWeight: FontWeight.w900,
                    color: RoleTheme.nutritionist.text,
                  ),
                ),
                SizedBox(height: 6.h),
                Text(
                  _description,
                  style: TextStyle(
                    fontSize: 12.5.sp,
                    height: 1.35,
                    color: RoleTheme.nutritionist.mutedText,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 10.h),
                Wrap(spacing: 8.w, runSpacing: 8.h, children: _infoChips()),
                _nutritionSection(),
                _listBlock(
                  title: 'Ingredientes',
                  values: product.ingredients,
                  icon: Icons.list_alt_rounded,
                  color: RoleTheme.nutritionist.primary,
                ),
                _listBlock(
                  title: 'Alérgenos declarados',
                  values: product.allergens,
                  icon: Icons.warning_amber_rounded,
                  color: RoleTheme.iconWarning,
                ),
                _listBlock(
                  title: 'Etiquetas dietarias',
                  values: product.dietaryTags,
                  icon: Icons.eco_rounded,
                  color: RoleTheme.iconValidation,
                ),
                SizedBox(height: 12.h),
                if (canResolve) ...[
                  const NutritionistProductReviewNote(),
                  SizedBox(height: 12.h),
                  NutritionistProductActionButtons(
                    isDisabled: isDisabled,
                    onApprove: onApprove,
                    onReject: onReject,
                  ),
                ] else if (product.validationComment?.trim().isNotEmpty ==
                    true) ...[
                  SizedBox(height: 12.h),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: RoleTheme.nutritionist.background,
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(
                        color: RoleTheme.nutritionist.primary.withValues(
                          alpha: 0.10,
                        ),
                      ),
                    ),
                    child: Text(
                      product.validationComment!.trim(),
                      style: TextStyle(
                        fontSize: 11.5.sp,
                        fontWeight: FontWeight.w700,
                        height: 1.35,
                        color: RoleTheme.nutritionist.text,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}
