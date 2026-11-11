import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:emprendedor/core/theme/role_theme.dart';
import 'package:emprendedor/data/models/shared/cart_item_model.dart';

class CartItemCard extends StatelessWidget {
  final CartItemModel item;
  final bool isRemoving;
  final bool isProcessing;

  final VoidCallback onIncrease;
  final VoidCallback onDecrease;
  final VoidCallback onRemove;

  const CartItemCard({
    super.key,
    required this.item,
    required this.isRemoving,
    required this.isProcessing,
    required this.onIncrease,
    required this.onDecrease,
    required this.onRemove,
  });

  bool get _isDisabled => isProcessing || isRemoving;

  Widget _buildTopRow(RolePalette palette) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            item.name,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: palette.text,
              fontWeight: FontWeight.w900,
              fontSize: 14.8.sp,
              height: 1.1,
            ),
          ),
        ),
        SizedBox(width: 4.w),
        InkWell(
          borderRadius: BorderRadius.circular(20.r),
          onTap: _isDisabled ? null : onRemove,
          child: Padding(
            padding: EdgeInsets.all(4.w),
            child: Icon(
              Icons.delete_outline_rounded,
              color: RoleTheme.iconDanger,
              size: 20.sp,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPriceColumn(RolePalette palette) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (item.hasDiscount)
          Text(
            '\$${item.originalTotal.toStringAsFixed(2)}',
            style: TextStyle(
              color: palette.mutedText,
              fontSize: 10.5.sp,
              fontWeight: FontWeight.w900,
              decoration: TextDecoration.lineThrough,
              decorationColor: palette.mutedText,
              decorationThickness: 1.4,
            ),
          ),
        Text(
          '\$${item.total.toStringAsFixed(2)}',
          style: TextStyle(
            color: palette.primary,
            fontSize: 17.sp,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    const palette = RoleTheme.client;

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 260),
      opacity: isRemoving ? 0.0 : 1.0,
      child: AnimatedScale(
        duration: const Duration(milliseconds: 260),
        scale: isRemoving ? 0.94 : 1.0,
        child: Container(
          margin: EdgeInsets.only(bottom: 12.h),
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            color: palette.surface,
            borderRadius: BorderRadius.circular(22.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.045),
                blurRadius: 18.r,
                offset: Offset(0, 8.h),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ProductThumb(imageUrl: item.imageUrl),
              SizedBox(width: 13.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTopRow(palette),
                    SizedBox(height: 7.h),
                    Row(
                      children: [
                        if (item.approxCalories != null)
                          _InfoChip(
                            icon: Icons.local_fire_department_rounded,
                            label:
                                '${item.approxCalories!.toStringAsFixed(0)} kcal',
                          ),
                        if (item.isValidated) ...[
                          if (item.approxCalories != null) SizedBox(width: 6.w),
                          const _InfoChip(
                            icon: Icons.verified_rounded,
                            label: 'Validado',
                          ),
                        ],
                      ],
                    ),
                    SizedBox(height: 12.h),
                    Row(
                      children: [
                        _QuantityStepper(
                          quantity: item.quantity,
                          disabled: _isDisabled,
                          onIncrease: onIncrease,
                          onDecrease: onDecrease,
                        ),
                        SizedBox(width: 8.w),
                        Flexible(child: _buildPriceColumn(palette)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProductThumb extends StatelessWidget {
  final String? imageUrl;

  const _ProductThumb({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    final hasImage = imageUrl != null && imageUrl!.trim().isNotEmpty;

    final size = 78.r;

    return ClipRRect(
      borderRadius: BorderRadius.circular(17.r),
      child: SizedBox.square(
        dimension: size,
        child: hasImage
            ? CachedNetworkImage(
                imageUrl: imageUrl!,
                fadeInDuration: const Duration(milliseconds: 120),
                memCacheWidth: 220,
                memCacheHeight: 220,
                imageBuilder: (context, imageProvider) => DecoratedBox(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: imageProvider,
                      fit: BoxFit.cover,
                      alignment: Alignment.center,
                    ),
                  ),
                ),
                placeholder: (context, url) => _loadingPlaceholder(),
                errorWidget: (context, url, error) => _placeholder(),
              )
            : _placeholder(),
      ),
    );
  }

  Widget _loadingPlaceholder() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [RoleTheme.brandSurface, RoleTheme.brandSurfaceTint],
        ),
      ),
    );
  }

  Widget _placeholder() {
    const palette = RoleTheme.client;

    return Container(
      color: palette.primary.withValues(alpha: 0.08),
      child: Icon(
        Icons.restaurant_menu_rounded,
        color: RoleTheme.iconColorFor(
          Icons.restaurant_menu_rounded,
          fallback: palette.primary,
        ),
        size: 28.sp,
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    const palette = RoleTheme.client;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: palette.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: RoleTheme.iconColorFor(icon, fallback: palette.primary),
            size: 12.sp,
          ),
          SizedBox(width: 3.w),
          Text(
            label,
            style: TextStyle(
              color: palette.primary,
              fontSize: 9.5.sp,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuantityStepper extends StatelessWidget {
  final int quantity;
  final bool disabled;
  final VoidCallback onIncrease;
  final VoidCallback onDecrease;

  const _QuantityStepper({
    required this.quantity,
    required this.disabled,
    required this.onIncrease,
    required this.onDecrease,
  });

  @override
  Widget build(BuildContext context) {
    const palette = RoleTheme.client;

    return Container(
      height: 30.h,
      decoration: BoxDecoration(
        color: RoleTheme.brandSurfaceTint,
        borderRadius: BorderRadius.circular(15.r),
        border: Border.all(color: RoleTheme.brandBorder, width: 0.8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _StepperButton(
            icon: Icons.remove_rounded,
            disabled: disabled,
            onTap: onDecrease,
          ),
          SizedBox(
            width: 28.w,
            child: Text(
              '$quantity',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: palette.text,
                fontSize: 11.5.sp,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          _StepperButton(
            icon: Icons.add_rounded,
            disabled: disabled,
            onTap: onIncrease,
          ),
        ],
      ),
    );
  }
}

class _StepperButton extends StatelessWidget {
  final IconData icon;
  final bool disabled;
  final VoidCallback onTap;

  const _StepperButton({
    required this.icon,
    required this.disabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const palette = RoleTheme.client;

    return InkWell(
      borderRadius: BorderRadius.circular(12.r),
      onTap: disabled ? null : onTap,
      child: SizedBox(
        width: 26.w,
        height: 30.h,
        child: Icon(
          icon,
          color: disabled ? palette.mutedText : palette.primary,
          size: 15.sp,
        ),
      ),
    );
  }
}








