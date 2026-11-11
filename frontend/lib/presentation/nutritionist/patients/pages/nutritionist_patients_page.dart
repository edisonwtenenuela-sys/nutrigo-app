import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:emprendedor/core/theme/role_theme.dart';
import 'package:emprendedor/features/nutritionist/controllers/index.dart';
import 'package:emprendedor/presentation/nutritionist/patients/widgets/index.dart';

class NutritionistPatientsPage extends StatefulWidget {
  const NutritionistPatientsPage({super.key});

  @override
  State<NutritionistPatientsPage> createState() =>
      _NutritionistPatientsPageState();
}

class _NutritionistPatientsPageState extends State<NutritionistPatientsPage> {
  late final NutritionistPatientsScreenController _screenController;

  @override
  void initState() {
    super.initState();
    _screenController = NutritionistPatientsScreenController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _refreshPatients();
    });
  }

  @override
  void dispose() {
    _screenController.dispose();
    super.dispose();
  }

  Future<void> _refreshPatients() async {
    if (!mounted) return;

    final controller = context.read<NutritionistPatientsController>();

    await _screenController.load(controller);
  }

  Widget _buildEmptyState(RolePalette palette) {
    return RefreshIndicator(
      color: palette.primary,
      onRefresh: _refreshPatients,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(18.w, 14.h, 18.w, 24.h),
        child: SizedBox(
          height: MediaQuery.sizeOf(context).height * 0.66,
          child: const NutritionistPatientsEmptyState(),
        ),
      ),
    );
  }

  Widget _buildPatientsList({
    required RolePalette palette,
    required List<Map<String, dynamic>> patients,
    required List<Map<String, dynamic>> filteredPatients,
  }) {
    final overview = _screenController.buildOverview(patients);

    return RefreshIndicator(
      color: palette.primary,
      onRefresh: _refreshPatients,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 20.h),
        children: [
          NutritionistPatientsOverviewCard(
            total: overview.total,
            active: overview.active,
            completed: overview.completed,
          ),
          SizedBox(height: 13.h),
          NutritionistPatientSearchBox(
            controller: _screenController.searchController,
            query: _screenController.query,
            onChanged: _screenController.setQuery,
          ),
          SizedBox(height: 15.h),
          NutritionistPatientsListHeader(
            palette: palette,
            query: _screenController.query,
            count: filteredPatients.length,
          ),
          SizedBox(height: 11.h),
          if (filteredPatients.isEmpty)
            NutritionistNoSearchResults(query: _screenController.query)
          else
            ...filteredPatients.map(
                  (patient) => NutritionistPatientCard(patient: patient),
            ),
        ],
      ),
    );
  }

  Widget _buildPageBody(
      NutritionistPatientsController controller,
      RolePalette palette,
      ) {
    if (controller.isLoading && !controller.hasLoadedOnce) {
      return NutritionistPatientsLoadingState(palette: palette);
    }

    final patients = controller.patients;
    final filteredPatients = _screenController.filteredPatients(patients);

    if (patients.isEmpty) {
      return _buildEmptyState(palette);
    }

    return _buildPatientsList(
      palette: palette,
      patients: patients,
      filteredPatients: filteredPatients,
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<NutritionistPatientsController>();
    const palette = RoleTheme.nutritionist;

    return ListenableBuilder(
      listenable: _screenController,
      builder: (context, _) => _buildPageBody(controller, palette),
    );
  }
}