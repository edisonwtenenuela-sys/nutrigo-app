import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:emprendedor/core/navigation/app_navigator.dart';
import 'package:emprendedor/core/services/auth/user_session_service.dart';
import 'package:emprendedor/core/theme/role_theme.dart';
import 'package:emprendedor/data/models/entrepreneur/promotions/promotion_model.dart';
import 'package:emprendedor/features/entrepreneur/controllers/index.dart';
import 'package:emprendedor/presentation/entrepreneur/promotions/pages/create_edit_promotion_page.dart';
import 'package:emprendedor/presentation/entrepreneur/promotions/pages/promotion_detail_page.dart';
import 'package:emprendedor/presentation/entrepreneur/promotions/widgets/index.dart';
import 'package:emprendedor/presentation/shared/widgets/common/app_error_state.dart';

enum _PromotionStatusFilter { all, active, scheduled, expired }

class PromotionsPage extends StatefulWidget {
  const PromotionsPage({super.key});

  @override
  State<PromotionsPage> createState() => _PromotionsPageState();
}

class _PromotionsPageState extends State<PromotionsPage> {
  final UserSessionService _sessionService = UserSessionService();
  bool _initialized = false;
  _PromotionStatusFilter _selectedFilter = _PromotionStatusFilter.all;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_initialized) return;
    _initialized = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _loadPromotionsIfNeeded();
    });
  }

  Future<void> _loadPromotionsIfNeeded() async {
    final controller = context.read<PromotionController>();
    if (controller.hasUserId || controller.hasLoadedPromotions) return;

    await controller.setUserId(_sessionService.currentUserId());
  }

  void _goToDetail(BuildContext context, PromotionModel promotion) {
    AppNavigator.push(context, PromotionDetailPage(promotion: promotion));
  }

  void _goToCreate(BuildContext context) {
    AppNavigator.push(context, const CreateEditPromotionPage());
  }

  List<PromotionModel> _filteredPromotions(List<PromotionModel> promotions) {
    return switch (_selectedFilter) {
      _PromotionStatusFilter.all => promotions,
      _PromotionStatusFilter.active =>
        promotions
            .where((promotion) => promotion.status == PromotionStatus.active)
            .toList(),
      _PromotionStatusFilter.scheduled =>
        promotions
            .where((promotion) => promotion.status == PromotionStatus.scheduled)
            .toList(),
      _PromotionStatusFilter.expired =>
        promotions
            .where((promotion) => promotion.status == PromotionStatus.expired)
            .toList(),
    };
  }

  int _countByFilter(
    List<PromotionModel> promotions,
    _PromotionStatusFilter filter,
  ) {
    return switch (filter) {
      _PromotionStatusFilter.all => promotions.length,
      _PromotionStatusFilter.active =>
        promotions
            .where((promotion) => promotion.status == PromotionStatus.active)
            .length,
      _PromotionStatusFilter.scheduled =>
        promotions
            .where((promotion) => promotion.status == PromotionStatus.scheduled)
            .length,
      _PromotionStatusFilter.expired =>
        promotions
            .where((promotion) => promotion.status == PromotionStatus.expired)
            .length,
    };
  }

  @override
  Widget build(BuildContext context) {
    const palette = RoleTheme.entrepreneur;
    final controller = context.watch<PromotionController>();

    return Scaffold(
      backgroundColor: palette.background,
      body: _buildPageBody(context, controller, palette),
      floatingActionButton: controller.promotions.isEmpty
          ? null
          : _buildCreatePromotionFab(context, palette),
    );
  }

  Widget _buildPageBody(
    BuildContext context,
    PromotionController controller,
    RolePalette palette,
  ) {
    return SafeArea(
      top: false,
      child: RefreshIndicator(
        color: palette.primary,
        onRefresh: controller.fetchPromotions,
        child: _buildContent(context, controller, palette),
      ),
    );
  }

  Widget _buildCreatePromotionFab(BuildContext context, RolePalette palette) {
    return SizedBox(
      width: 34.w,
      height: 34.w,
      child: Material(
        color: palette.primary,
        borderRadius: BorderRadius.circular(12.r),
        child: InkWell(
          onTap: () => _goToCreate(context),
          borderRadius: BorderRadius.circular(12.r),
          child: Icon(Icons.add_rounded, color: palette.surface, size: 18.sp),
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    PromotionController controller,
    RolePalette palette,
  ) {
    final uiState = PromotionListController.resolveUiState(controller);

    if (uiState == PromotionsUiState.loading) {
      return _buildLoadingState(palette);
    }

    if (uiState == PromotionsUiState.error) {
      return _buildErrorState(
        message: controller.errorMessage!,
        controller: controller,
      );
    }

    if (uiState == PromotionsUiState.empty) {
      return _buildEmptyState(context);
    }

    return _buildPromotionsList(context, controller);
  }

  Widget _buildLoadingState(RolePalette palette) {
    return Center(child: CircularProgressIndicator(color: palette.primary));
  }

  Widget _buildErrorState({
    required String message,
    required PromotionController controller,
  }) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(height: 120.h),
        AppErrorState(message: message, onRetry: controller.fetchPromotions),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.fromLTRB(14.w, 18.h, 14.w, 96.h),
          children: [
            ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight - 114.h,
              ),
              child: Center(
                child: PromotionEmptyState(
                  onCreatePromotion: () => _goToCreate(context),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPromotionsList(
    BuildContext context,
    PromotionController controller,
  ) {
    final promotions = controller.promotions;
    final filteredPromotions = _filteredPromotions(promotions);

    return ListView(
      physics: const BouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      ),
      padding: EdgeInsets.fromLTRB(14.w, 8.h, 14.w, 96.h),
      children: [
        PromotionsSummaryHeader(promotions: promotions),
        _PromotionsFilterBar(
          selectedFilter: _selectedFilter,
          countFor: (filter) => _countByFilter(promotions, filter),
          onChanged: (filter) => setState(() => _selectedFilter = filter),
        ),
        SizedBox(height: 12.h),
        if (filteredPromotions.isEmpty)
          _FilteredPromotionsEmptyCard(filter: _selectedFilter)
        else
          for (final promotion in filteredPromotions)
            PromotionCard(
              promotion: promotion,
              onTap: () => _goToDetail(context, promotion),
            ),
      ],
    );
  }
}

class _PromotionsFilterBar extends StatelessWidget {
  final _PromotionStatusFilter selectedFilter;
  final int Function(_PromotionStatusFilter filter) countFor;
  final ValueChanged<_PromotionStatusFilter> onChanged;

  const _PromotionsFilterBar({
    required this.selectedFilter,
    required this.countFor,
    required this.onChanged,
  });

  String _label(_PromotionStatusFilter filter) {
    return switch (filter) {
      _PromotionStatusFilter.all => 'Todas',
      _PromotionStatusFilter.active => 'Activas',
      _PromotionStatusFilter.scheduled => 'Programadas',
      _PromotionStatusFilter.expired => 'Expiradas',
    };
  }

  Color _color(_PromotionStatusFilter filter) {
    const palette = RoleTheme.entrepreneur;

    return switch (filter) {
      _PromotionStatusFilter.all => palette.primary,
      _PromotionStatusFilter.active => palette.secondary,
      _PromotionStatusFilter.scheduled => palette.primary,
      _PromotionStatusFilter.expired => RoleTheme.iconDanger,
    };
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: [
          for (final filter in _PromotionStatusFilter.values) ...[
            _PromotionFilterChip(
              label: _label(filter),
              count: countFor(filter),
              color: _color(filter),
              isSelected: selectedFilter == filter,
              onTap: () => onChanged(filter),
            ),
            SizedBox(width: 8.w),
          ],
        ],
      ),
    );
  }
}

class _PromotionFilterChip extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _PromotionFilterChip({
    required this.label,
    required this.count,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const palette = RoleTheme.entrepreneur;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999.r),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: EdgeInsets.symmetric(horizontal: 11.w, vertical: 7.h),
        decoration: BoxDecoration(
          color: isSelected ? color : color.withValues(alpha: 0.075),
          borderRadius: BorderRadius.circular(999.r),
          border: Border.all(color: color.withValues(alpha: 0.18)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: isSelected ? palette.surface : color,
                fontSize: 10.5.sp,
                fontWeight: FontWeight.w900,
              ),
            ),
            SizedBox(width: 5.w),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
              decoration: BoxDecoration(
                color: isSelected
                    ? palette.surface.withValues(alpha: 0.18)
                    : color.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(999.r),
              ),
              child: Text(
                '$count',
                style: TextStyle(
                  color: isSelected ? palette.surface : color,
                  fontSize: 9.sp,
                  fontWeight: FontWeight.w900,
                  height: 1,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilteredPromotionsEmptyCard extends StatelessWidget {
  final _PromotionStatusFilter filter;

  const _FilteredPromotionsEmptyCard({required this.filter});

  String get _title {
    return switch (filter) {
      _PromotionStatusFilter.all => 'Sin promociones registradas',
      _PromotionStatusFilter.active => 'Sin promociones activas',
      _PromotionStatusFilter.scheduled => 'Sin promociones programadas',
      _PromotionStatusFilter.expired => 'Sin promociones expiradas',
    };
  }

  String get _message {
    return switch (filter) {
      _PromotionStatusFilter.all =>
        'Crea una promoción para impulsar tus ventas.',
      _PromotionStatusFilter.active =>
        'Cuando una promoción esté vigente, aparecerá aquí.',
      _PromotionStatusFilter.scheduled =>
        'Las promociones futuras aparecerán en esta sección.',
      _PromotionStatusFilter.expired =>
        'Aquí verás las promociones que ya finalizaron.',
    };
  }

  @override
  Widget build(BuildContext context) {
    const palette = RoleTheme.entrepreneur;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 24.h),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(22.r),
        border: Border.all(color: palette.primary.withValues(alpha: 0.08)),
      ),
      child: Column(
        children: [
          Container(
            width: 58.w,
            height: 58.w,
            decoration: BoxDecoration(
              color: palette.primary.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.local_offer_outlined,
              color: RoleTheme.iconColorFor(
                Icons.local_offer_outlined,
                fallback: palette.primary,
              ),
              size: 27.sp,
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            _title,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: palette.text,
              fontSize: 15.sp,
              fontWeight: FontWeight.w900,
            ),
          ),
          SizedBox(height: 5.h),
          Text(
            _message,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: palette.mutedText,
              fontSize: 11.2.sp,
              fontWeight: FontWeight.w600,
              height: 1.25,
            ),
          ),
        ],
      ),
    );
  }
}
