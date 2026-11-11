import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:emprendedor/core/theme/role_theme.dart';
import 'package:emprendedor/features/client/controllers/client_location_picker_controller.dart';
import 'package:emprendedor/presentation/shared/widgets/app_feedback.dart';

class SelectLocationPage extends StatefulWidget {
  const SelectLocationPage({
    super.key,
    this.initialAddress,
    this.initialLatitude,
    this.initialLongitude,
    this.useCurrentLocationAsInitial = true,
  });

  final String? initialAddress;
  final double? initialLatitude;
  final double? initialLongitude;
  final bool useCurrentLocationAsInitial;

  @override
  State<SelectLocationPage> createState() => _SelectLocationPageState();
}

class _SelectLocationPageState extends State<SelectLocationPage> {
  late final ClientLocationPickerController _controller;

  GoogleMapController? _mapController;

  @override
  void initState() {
    super.initState();
    _controller = ClientLocationPickerController(
      initialAddress: widget.initialAddress,
      initialLatitude: widget.initialLatitude,
      initialLongitude: widget.initialLongitude,
      useCurrentLocationAsInitial: widget.useCurrentLocationAsInitial,
    );
    _controller.loadInitialPosition();
  }

  @override
  void dispose() {
    _mapController?.dispose();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _goToCurrentLocation() async {
    final feedback = await _controller.goToCurrentLocation();
    final position = _controller.selectedPosition;

    if (position != null) {
      await _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(position, 16),
      );
    }

    if (!mounted || feedback == null) return;

    showAppMessage(
      context,
      role: AppFeedbackRole.client,
      type: feedback.isError ? AppFeedbackType.error : AppFeedbackType.warning,
      title: feedback.title,
      message: feedback.message,
    );
  }

  void _confirmSelection() {
    final result = _controller.result;
    if (result == null) return;

    Navigator.of(context).pop(result);
  }

  AppBar _buildAppBar() {
    const palette = RoleTheme.client;

    return AppBar(
      backgroundColor: palette.background,
      elevation: 0,
      centerTitle: true,
      title: Text(
        'Seleccionar ubicación',
        style: TextStyle(
          color: palette.text,
          fontWeight: FontWeight.w900,
          fontSize: 20.sp,
        ),
      ),
    );
  }

  Widget _buildAddressPanel() {
    const palette = RoleTheme.client;

    return Positioned(
      top: 16.h,
      left: 16.w,
      right: 16.w,
      child: Container(
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: palette.surface,
          borderRadius: BorderRadius.circular(18.r),
          border: Border.all(
            color: RoleTheme.iconLocation.withValues(alpha: 0.10),
          ),
          boxShadow: [
            BoxShadow(
              color: RoleTheme.iconLocation.withValues(alpha: 0.08),
              blurRadius: 12.r,
              offset: Offset(0, 4.h),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Dirección seleccionada',
              style: TextStyle(
                color: palette.text,
                fontWeight: FontWeight.w900,
                fontSize: 14.sp,
              ),
            ),
            SizedBox(height: 6.h),
            Text(
              _controller.selectedAddress,
              style: TextStyle(
                color: palette.mutedText,
                height: 1.35,
                fontSize: 13.sp,
              ),
            ),
            if (_controller.isResolvingAddress) ...[
              SizedBox(height: 10.h),
              const LinearProgressIndicator(color: RoleTheme.iconLocation),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingActions() {
    const palette = RoleTheme.client;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: FloatingActionButton.small(
                backgroundColor: palette.surface,
                foregroundColor: RoleTheme.iconLocation,
                onPressed: _goToCurrentLocation,
                child: Icon(
                  Icons.my_location_rounded,
                  color: RoleTheme.iconColorFor(
                    Icons.my_location_rounded,
                    fallback: RoleTheme.iconLocation,
                  ),
                  size: 22.sp,
                ),
              ),
            ),
            SizedBox(height: 12.h),
            SizedBox(
              width: double.infinity,
              height: 52.h,
              child: ElevatedButton.icon(
                onPressed: _controller.canConfirm ? _confirmSelection : null,
                icon: Icon(
                  Icons.check_rounded,
                  color: _controller.canConfirm
                      ? RoleTheme.iconValidation
                      : RoleTheme.brandMutedText.withValues(alpha: 0.45),
                  size: 22.sp,
                ),
                label: Text(
                  'Usar ubicación',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 15.sp,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: RoleTheme.iconValidation.withValues(
                    alpha: 0.06,
                  ),
                  foregroundColor: RoleTheme.iconValidation,
                  disabledBackgroundColor: RoleTheme.iconValidation.withValues(
                    alpha: 0.04,
                  ),
                  disabledForegroundColor: RoleTheme.brandMutedText.withValues(
                    alpha: 0.45,
                  ),
                  side: BorderSide(
                    color: RoleTheme.iconValidation.withValues(alpha: 0.20),
                  ),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18.r),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMapBody() {
    if (_controller.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: RoleTheme.iconLocation),
      );
    }

    return Stack(
      children: [
        GoogleMap(
          initialCameraPosition: CameraPosition(
            target: _controller.initialPosition,
            zoom: 15,
          ),
          myLocationEnabled: _controller.hasLocationPermission,
          myLocationButtonEnabled: false,
          zoomControlsEnabled: false,
          markers: _controller.markers,
          onMapCreated: (controller) {
            _mapController = controller;
          },
          onTap: _controller.selectPosition,
        ),
        _buildAddressPanel(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    const palette = RoleTheme.client;

    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: palette.background,
          appBar: _buildAppBar(),
          body: _buildMapBody(),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerFloat,
          floatingActionButton: _buildFloatingActions(),
        );
      },
    );
  }
}
