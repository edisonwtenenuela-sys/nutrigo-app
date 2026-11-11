import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'package:emprendedor/core/navigation/app_navigator.dart';
import 'package:emprendedor/core/theme/role_theme.dart';
import 'package:emprendedor/data/models/entrepreneur/index.dart';
import 'package:emprendedor/features/entrepreneur/controllers/index.dart';
import 'package:emprendedor/presentation/entrepreneur/promotions/dialogs/delete_promotion_dialog.dart';
import 'package:emprendedor/presentation/entrepreneur/promotions/pages/create_coupon_page.dart';
import 'package:emprendedor/presentation/entrepreneur/promotions/pages/create_edit_promotion_page.dart';
import 'package:emprendedor/presentation/shared/widgets/app_feedback.dart';

class PromotionDetailPage extends StatelessWidget {
  final PromotionModel promotion;

  const PromotionDetailPage({super.key, required this.promotion});

  Color _statusColor(PromotionStatus status) {
    const palette = RoleTheme.entrepreneur;

    return switch (status) {
      PromotionStatus.active => palette.secondary,
      PromotionStatus.scheduled => palette.primary,
      PromotionStatus.expired => RoleTheme.iconDanger,
    };
  }

  String _statusLabel(PromotionStatus status) {
    return switch (status) {
      PromotionStatus.active => 'Activa',
      PromotionStatus.scheduled => 'Programada',
      PromotionStatus.expired => 'Expirada',
    };
  }

  String _discountText() {
    if (promotion.discountType == DiscountType.percentage) {
      return '${promotion.discountValue.toStringAsFixed(0)}% OFF';
    }

    return '${_moneyText(promotion.discountValue)} OFF';
  }

  String _moneyText(double value) {
    return NumberFormat.currency(
      locale: 'es_ES',
      symbol: r'$',
      decimalDigits: 2,
    ).format(value);
  }

  String _shortDateText(DateTime date) {
    return DateFormat('dd/MM/yyyy', 'es_ES').format(date);
  }

  String _createdDateText() {
    final createdAt =
        promotion.createdAt?.toDate() ?? promotion.startDate.toDate();

    return _shortDateText(createdAt);
  }

  String _scopeText() {
    return switch (promotion.scope) {
      PromotionScope.all => 'Todo el catálogo',
      PromotionScope.product => '${promotion.productIds.length} productos',
    };
  }

  String _couponText(List<CouponModel> coupons) {
    final activeCoupons = coupons.where((coupon) => coupon.canBeUsed).toList();

    if (activeCoupons.isEmpty) return 'Sin cupón activo';

    return activeCoupons.first.code;
  }

  Future<void> _goToEdit(BuildContext context) async {
    await AppNavigator.push(
      context,
      CreateEditPromotionPage(promotionToEdit: promotion),
    );
  }

  Future<void> _goToCoupon(BuildContext context) async {
    await AppNavigator.push(context, CreateCouponPage(promotion: promotion));
  }

  Future<void> _deletePromotion(BuildContext context) async {
    final controller = context.read<PromotionController>();

    final confirm = await showDeletePromotionDialog(
      context: context,
      promotionName: promotion.name,
    );

    if (!confirm || !context.mounted) return;

    final result = await PromotionListController.deletePromotion(
      controller,
      promotion,
    );

    if (!context.mounted) return;

    await showAppMessage(
      context,
      role: AppFeedbackRole.entrepreneur,
      type: result.success ? AppFeedbackType.success : AppFeedbackType.error,
      title: result.title,
      message: result.message,
    );

    if (result.success && context.mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    const palette = RoleTheme.entrepreneur;

    final color = _statusColor(promotion.status);
    final controller = context.read<PromotionController>();

    return Scaffold(
      backgroundColor: palette.background,
      body: SafeArea(
        child: StreamBuilder<List<CouponModel>>(
          stream: promotion.id == null
              ? const Stream.empty()
              : controller.getCoupons(promotion.id!),
          builder: (context, snapshot) {
            final coupons = snapshot.data ?? const <CouponModel>[];
            final activeCoupons = coupons
                .where((coupon) => coupon.canBeUsed)
                .length;
            final usedCoupons = coupons.where((coupon) => coupon.isUsed).length;

            return ListView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.fromLTRB(22.w, 10.h, 22.w, 24.h),
              children: [
                const _DetailTopBar(title: 'Detalle de promoción'),
                SizedBox(height: 14.h),
                _PromotionHeroCard(
                  promotion: promotion,
                  color: color,
                  statusLabel: _statusLabel(promotion.status),
                  createdText: _createdDateText(),
                  discountText: _discountText(),
                ),
                SizedBox(height: 10.h),
                _DetailInfoCard(
                  children: [
                    _DetailInfoRow(
                      icon: Icons.inventory_2_outlined,
                      title: 'Aplica a',
                      value: _scopeText(),
                      color: color,
                    ),
                    const _DetailDivider(),
                    _DetailInfoRow(
                      icon: Icons.confirmation_number_outlined,
                      title: 'Cupón',
                      value: _couponText(coupons),
                      color: color,
                    ),
                    const _DetailDivider(),
                    _DetailInfoRow(
                      icon: Icons.price_change_outlined,
                      title: 'Monto mínimo de compra',
                      value: coupons.isEmpty
                          ? 'No aplica'
                          : _moneyText(coupons.first.minimumPurchase),
                      color: color,
                    ),
                    const _DetailDivider(),
                    _ValidityInfoRow(promotion: promotion, color: color),
                  ],
                ),
                SizedBox(height: 10.h),
                _DescriptionCard(description: promotion.description),
                SizedBox(height: 10.h),
                _StatsCard(
                  couponsCount: coupons.length,
                  activeCoupons: activeCoupons,
                  usedCoupons: usedCoupons,
                ),
                SizedBox(height: 14.h),
                _ActionButton(
                  label: 'Editar promoción',
                  icon: Icons.edit_rounded,
                  color: palette.primary,
                  filled: true,
                  onTap: () => _goToEdit(context),
                ),
                SizedBox(height: 9.h),
                _ActionButton(
                  label: 'Crear cupón',
                  icon: Icons.confirmation_number_rounded,
                  color: palette.primary,
                  onTap: () => _goToCoupon(context),
                ),
                SizedBox(height: 9.h),
                _ActionButton(
                  label: 'Eliminar promoción',
                  icon: Icons.delete_outline_rounded,
                  color: RoleTheme.iconDanger,
                  onTap: () => _deletePromotion(context),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _DetailTopBar extends StatelessWidget {
  final String title;

  const _DetailTopBar({required this.title});

  @override
  Widget build(BuildContext context) {
    const palette = RoleTheme.entrepreneur;

    return SizedBox(
      height: 38.h,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: InkWell(
              onTap: () => Navigator.of(context).pop(),
              borderRadius: BorderRadius.circular(999.r),
              child: Padding(
                padding: EdgeInsets.all(5.w),
                child: Icon(
                  Icons.arrow_back_rounded,
                  color: palette.text,
                  size: 21.sp,
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 42.w),
            child: Text(
              title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: palette.text,
                fontSize: 16.sp,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PromotionHeroCard extends StatelessWidget {
  final PromotionModel promotion;
  final Color color;
  final String statusLabel;
  final String createdText;
  final String discountText;

  const _PromotionHeroCard({
    required this.promotion,
    required this.color,
    required this.statusLabel,
    required this.createdText,
    required this.discountText,
  });

  @override
  Widget build(BuildContext context) {
    const palette = RoleTheme.entrepreneur;

    final promotionName = promotion.name.trim().isEmpty
        ? 'Promoción'
        : promotion.name.trim();

    return Container(
      padding: EdgeInsets.all(11.w),
      decoration: _cardDecoration(),
      child: Row(
        children: [
          _PercentIcon(color: color, size: 42.w),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _StatusBadge(label: statusLabel, color: color),
                SizedBox(height: 5.h),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        promotionName,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: palette.text,
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w900,
                          height: 1.05,
                        ),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Flexible(
                      child: _DiscountBadge(text: discountText, color: color),
                    ),
                  ],
                ),
                SizedBox(height: 4.h),
                Text(
                  'Creada el $createdText',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: palette.mutedText,
                    fontSize: 9.5.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DiscountBadge extends StatelessWidget {
  final String text;
  final Color color;

  const _DiscountBadge({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(999.r),
      ),
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: color,
          fontSize: 10.2.sp,
          fontWeight: FontWeight.w900,
          height: 1,
        ),
      ),
    );
  }
}

class _DetailInfoCard extends StatelessWidget {
  final List<Widget> children;

  const _DetailInfoCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: _cardDecoration(),
      child: Column(children: children),
    );
  }
}

class _DetailInfoRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color color;

  const _DetailInfoRow({
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    const palette = RoleTheme.entrepreneur;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      child: Row(
        children: [
          _MiniIcon(icon: icon, color: color),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: palette.mutedText,
                    fontSize: 9.3.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  value,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: palette.text,
                    fontSize: 11.sp,
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
}

class _ValidityInfoRow extends StatelessWidget {
  final PromotionModel promotion;
  final Color color;

  const _ValidityInfoRow({required this.promotion, required this.color});

  String _date(DateTime date) {
    return DateFormat('dd/MM/yyyy', 'es_ES').format(date);
  }

  @override
  Widget build(BuildContext context) {
    const palette = RoleTheme.entrepreneur;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      child: Row(
        children: [
          _MiniIcon(icon: Icons.event_available_rounded, color: color),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Vigencia',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: palette.text,
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 7.h),
                Row(
                  children: [
                    Expanded(
                      child: _DateColumn(
                        label: 'Fecha de inicio',
                        value: _date(promotion.startDate.toDate()),
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 30.h,
                      color: palette.mutedText.withValues(alpha: 0.12),
                    ),
                    Expanded(
                      child: _DateColumn(
                        label: 'Fecha de finalización',
                        value: _date(promotion.endDate.toDate()),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DateColumn extends StatelessWidget {
  final String label;
  final String value;

  const _DateColumn({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    const palette = RoleTheme.entrepreneur;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: palette.mutedText,
              fontSize: 8.7.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: palette.text,
              fontSize: 10.5.sp,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _DescriptionCard extends StatelessWidget {
  final String description;

  const _DescriptionCard({required this.description});

  @override
  Widget build(BuildContext context) {
    const palette = RoleTheme.entrepreneur;

    final text = description.trim().isEmpty
        ? 'Sin descripción registrada.'
        : description.trim();

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12.w),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle(
            icon: Icons.description_outlined,
            title: 'Descripción',
          ),
          SizedBox(height: 7.h),
          Text(
            text,
            style: TextStyle(
              color: palette.mutedText,
              fontSize: 10.8.sp,
              fontWeight: FontWeight.w600,
              height: 1.25,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatsCard extends StatelessWidget {
  final int couponsCount;
  final int activeCoupons;
  final int usedCoupons;

  const _StatsCard({
    required this.couponsCount,
    required this.activeCoupons,
    required this.usedCoupons,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle(
            icon: Icons.query_stats_rounded,
            title: 'Estadísticas rápidas',
          ),
          SizedBox(height: 10.h),
          Row(
            children: [
              Expanded(
                child: _StatItem(label: 'Cupones', value: '$couponsCount'),
              ),
              const _DetailDivider(vertical: true),
              Expanded(
                child: _StatItem(label: 'Activos', value: '$activeCoupons'),
              ),
              const _DetailDivider(vertical: true),
              Expanded(
                child: _StatItem(label: 'Usados', value: '$usedCoupons'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;

  const _StatItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    const palette = RoleTheme.entrepreneur;

    return Column(
      children: [
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: palette.primary,
            fontSize: 12.5.sp,
            fontWeight: FontWeight.w900,
          ),
        ),
        SizedBox(height: 3.h),
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: palette.mutedText,
            fontSize: 8.6.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool filled;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
    this.filled = false,
  });

  @override
  Widget build(BuildContext context) {
    const palette = RoleTheme.entrepreneur;

    return SizedBox(
      width: double.infinity,
      height: 42.h,
      child: filled
          ? ElevatedButton.icon(
              onPressed: onTap,
              icon: Icon(icon, size: 16.sp),
              label: FittedBox(fit: BoxFit.scaleDown, child: Text(label)),
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                foregroundColor: palette.surface,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(13.r),
                ),
                textStyle: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w900,
                ),
              ),
            )
          : OutlinedButton.icon(
              onPressed: onTap,
              icon: Icon(icon, size: 16.sp),
              label: FittedBox(fit: BoxFit.scaleDown, child: Text(label)),
              style: OutlinedButton.styleFrom(
                foregroundColor: color,
                backgroundColor: color.withValues(alpha: 0.055),
                side: BorderSide(color: color.withValues(alpha: 0.12)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(13.r),
                ),
                textStyle: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
    );
  }
}

class _PercentIcon extends StatelessWidget {
  final Color color;
  final double size;

  const _PercentIcon({required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Icon(Icons.percent_rounded, color: color, size: 25.sp),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String label;
  final Color color;

  const _StatusBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 4.5.w,
            height: 4.5.w,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          SizedBox(width: 5.w),
          Flexible(
            child: Text(
              label,
              maxLines: 2,
              style: TextStyle(
                color: color,
                fontSize: 9.sp,
                fontWeight: FontWeight.w900,
                height: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniIcon extends StatelessWidget {
  final IconData icon;
  final Color color;

  const _MiniIcon({required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 30.w,
      height: 30.w,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Icon(icon, color: color, size: 16.sp),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final IconData icon;
  final String title;

  const _SectionTitle({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    const palette = RoleTheme.entrepreneur;

    return Row(
      children: [
        Icon(
          icon,
          color: RoleTheme.iconColorFor(icon, fallback: palette.primary),
          size: 15.sp,
        ),
        SizedBox(width: 6.w),
        Expanded(
          child: Text(
            title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: palette.text,
              fontSize: 12.sp,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ],
    );
  }
}

class _DetailDivider extends StatelessWidget {
  final bool vertical;

  const _DetailDivider({this.vertical = false});

  @override
  Widget build(BuildContext context) {
    final color = RoleTheme.entrepreneur.mutedText.withValues(alpha: 0.10);

    if (vertical) {
      return Container(width: 1, height: 30.h, color: color);
    }

    return Divider(
      height: 1,
      thickness: 1,
      indent: 12.w,
      endIndent: 12.w,
      color: color,
    );
  }
}

BoxDecoration _cardDecoration() {
  const palette = RoleTheme.entrepreneur;

  return BoxDecoration(
    color: palette.surface,
    borderRadius: BorderRadius.circular(17.r),
    border: Border.all(color: palette.primary.withValues(alpha: 0.06)),
    boxShadow: [
      BoxShadow(
        color: palette.primary.withValues(alpha: 0.035),
        blurRadius: 12.r,
        offset: Offset(0, 6.h),
      ),
    ],
  );
}
