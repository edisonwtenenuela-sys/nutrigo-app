import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:emprendedor/core/theme/role_theme.dart';
import 'package:emprendedor/core/utils/professional_registry_utils.dart';
import 'package:emprendedor/data/models/admin/admin_verification_request_model.dart';
import 'package:emprendedor/data/models/admin/nutritionist_verification_request_model.dart';
import 'package:emprendedor/features/admin/controllers/admin_history_controller.dart';
import 'package:emprendedor/presentation/admin/widgets/index.dart';

class AdminVerificationHistoryPage extends StatefulWidget {
  final AdminHistoryStatus initialStatus;

  const AdminVerificationHistoryPage({super.key, required this.initialStatus});

  @override
  State<AdminVerificationHistoryPage> createState() =>
      _AdminVerificationHistoryPageState();
}

class _AdminVerificationHistoryPageState
    extends State<AdminVerificationHistoryPage> {
  late final AdminVerificationHistoryController _controller;

  Widget _vGap(double value) => SizedBox(height: value.h);

  @override
  void initState() {
    super.initState();
    _controller = AdminVerificationHistoryController(
      initialStatus: widget.initialStatus,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildTypeSelector(RolePalette palette) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Container(
        padding: EdgeInsets.all(8.w),
        decoration: BoxDecoration(
          color: palette.surface,
          borderRadius: BorderRadius.circular(24.r),
          border: Border.all(color: palette.primary.withValues(alpha: 0.08)),
        ),
        child: Row(
          children: [
            Expanded(
              child: AdminHistoryFilterChip(
                label: 'Emprendedores',
                selected: _controller.type == AdminHistoryType.entrepreneurs,
                onTap: () =>
                    _controller.changeType(AdminHistoryType.entrepreneurs),
              ),
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: AdminHistoryFilterChip(
                label: 'Nutricionistas',
                selected: _controller.type == AdminHistoryType.nutritionists,
                onTap: () =>
                    _controller.changeType(AdminHistoryType.nutritionists),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const palette = RoleTheme.admin;

    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        final historyList = switch (_controller.type) {
          AdminHistoryType.nutritionists => _NutritionistHistoryList(
            stream: _controller.nutritionistStream,
            isApproved: _controller.isApproved,
          ),
          AdminHistoryType.entrepreneurs => _EntrepreneurHistoryList(
            stream: _controller.entrepreneurStream,
            isApproved: _controller.isApproved,
          ),
        };

        return Scaffold(
          backgroundColor: palette.background,
          appBar: AppBar(
            centerTitle: true,
            elevation: 0,
            backgroundColor: palette.surface,
            surfaceTintColor: palette.surface,
            title: Text(
              _controller.title,
              style: TextStyle(
                fontSize: 19.sp,
                fontWeight: FontWeight.w900,
                color: palette.text,
              ),
            ),
          ),
          body: Column(
            children: [
              _vGap(14),
              _buildTypeSelector(palette),
              _vGap(12),
              Expanded(child: historyList),
            ],
          ),
        );
      },
    );
  }
}

class _EntrepreneurHistoryList extends StatelessWidget {
  final Stream<List<AdminVerificationRequestModel>> stream;
  final bool isApproved;

  const _EntrepreneurHistoryList({
    required this.stream,
    required this.isApproved,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<AdminVerificationRequestModel>>(
      stream: stream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting &&
            !snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final requests = snapshot.data ?? [];

        if (requests.isEmpty) {
          return AdminHistoryEmptyState(
            isApproved: isApproved,
            typeText: 'emprendedores',
          );
        }

        return ListView.builder(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 18.h),
          itemCount: requests.length,
          itemBuilder: (context, index) {
            final request = requests[index];

            return AdminHistoryCard(
              icon: Icons.storefront_rounded,
              iconColor: RoleTheme.admin.primary,
              title: request.businessName.isEmpty
                  ? 'Negocio sin nombre'
                  : request.businessName,
              subtitle: request.email,
              status: request.status,
              createdAt: request.createdAt,
              lines: [
                AdminHistoryLine(
                  icon: Icons.person_rounded,
                  label: 'Responsable',
                  value: request.ownerName,
                ),
                AdminHistoryLine(
                  icon: Icons.phone_rounded,
                  label: 'Teléfono',
                  value: request.phone,
                ),
                AdminHistoryLine(
                  icon: Icons.location_on_rounded,
                  label: 'Dirección',
                  value: request.address,
                ),
                if (request.message?.trim().isNotEmpty == true)
                  AdminHistoryLine(
                    icon: Icons.message_rounded,
                    label: 'Mensaje',
                    value: request.message!,
                  ),
              ],
            );
          },
        );
      },
    );
  }
}

class _NutritionistHistoryList extends StatelessWidget {
  final Stream<List<NutritionistVerificationRequestModel>> stream;
  final bool isApproved;

  const _NutritionistHistoryList({
    required this.stream,
    required this.isApproved,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<NutritionistVerificationRequestModel>>(
      stream: stream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting &&
            !snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final requests = snapshot.data ?? [];

        if (requests.isEmpty) {
          return AdminHistoryEmptyState(
            isApproved: isApproved,
            typeText: 'nutricionistas',
          );
        }

        return ListView.builder(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 18.h),
          itemCount: requests.length,
          itemBuilder: (context, index) {
            final request = requests[index];

            return AdminHistoryCard(
              icon: Icons.health_and_safety_rounded,
              iconColor: RoleTheme.admin.primary,
              title: request.name.isEmpty
                  ? 'Nutricionista sin nombre'
                  : request.name,
              subtitle: request.email.isEmpty
                  ? 'Correo no registrado'
                  : request.email,
              status: request.status,
              createdAt: request.createdAt,
              lines: [
                AdminHistoryLine(
                  icon: Icons.phone_rounded,
                  label: 'teléfono',
                  value: request.phone,
                ),
                AdminHistoryLine(
                  icon: Icons.medical_services_rounded,
                  label: 'Especialidad',
                  value: request.specialty,
                ),
                AdminHistoryLine(
                  icon: Icons.badge_rounded,
                  label:
                      'Registro ${ProfessionalRegistryUtils.registryTypeLabel(request.professionalRegistryType)}',
                  value: request.licenseNumber,
                ),
                AdminHistoryLine(
                  icon: Icons.description_rounded,
                  label: 'Descripción',
                  value: request.professionalDescription,
                ),
                if (request.message?.trim().isNotEmpty == true)
                  AdminHistoryLine(
                    icon: Icons.message_rounded,
                    label: 'Mensaje',
                    value: request.message!,
                  ),
              ],
            );
          },
        );
      },
    );
  }
}








