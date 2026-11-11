import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:emprendedor/core/theme/role_theme.dart';
import 'package:emprendedor/features/nutritionist/controllers/nutritionist_location_picker_controller.dart';

class NutritionistLocationPickerPage extends StatefulWidget {
  final double? initialLatitude;
  final double? initialLongitude;

  const NutritionistLocationPickerPage({
    super.key,
    this.initialLatitude,
    this.initialLongitude,
  });

  @override
  State<NutritionistLocationPickerPage> createState() =>
      _NutritionistLocationPickerPageState();
}

class _NutritionistLocationPickerPageState
    extends State<NutritionistLocationPickerPage> {
  late final NutritionistLocationPickerController _controller;

  @override
  void initState() {
    super.initState();

    _controller = NutritionistLocationPickerController(
      initialLatitude: widget.initialLatitude,
      initialLongitude: widget.initialLongitude,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _confirmLocation() {
    Navigator.pop(context, _controller.result.toMap());
  }

  @override
  Widget build(BuildContext context) {
    const palette = RoleTheme.nutritionist;

    return Scaffold(
      backgroundColor: palette.background,
      appBar: AppBar(
        backgroundColor: palette.background,
        surfaceTintColor: palette.background,
        scrolledUnderElevation: 0,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: palette.text),
        title: Text(
          'Seleccionar ubicación',
          style: TextStyle(
            fontSize: 19.sp,
            fontWeight: FontWeight.w900,
            color: palette.text,
          ),
        ),
      ),
      body: ListenableBuilder(
        listenable: _controller,
        builder: (context, _) {
          return Stack(
            children: [
              GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: _controller.selectedLocation,
                  zoom: 15,
                ),
                myLocationEnabled: true,
                myLocationButtonEnabled: true,
                zoomControlsEnabled: false,
                onTap: _controller.selectLocation,
                markers: {
                  Marker(
                    markerId: const MarkerId('selected_location'),
                    position: _controller.selectedLocation,
                  ),
                },
              ),
              Positioned(
                left: 16.w,
                right: 16.w,
                bottom: 86.h,
                child: Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: palette.surface,
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(
                      color: palette.primary.withValues(alpha: 0.10),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: palette.shadow,
                        blurRadius: 12.r,
                        offset: Offset(0, 6.h),
                      ),
                    ],
                  ),
                  child: Text(
                    _controller.selectedAddress,
                    style: TextStyle(
                      color: palette.text,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w700,
                      height: 1.25,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 16.w,
                right: 16.w,
                bottom: 18.h,
                child: SafeArea(
                  child: SizedBox(
                    height: 52.h,
                    child: ElevatedButton.icon(
                      onPressed: _confirmLocation,
                      icon: Icon(
                        Icons.check_circle_rounded,
                        color: RoleTheme.iconColorFor(
                          Icons.check_circle_rounded,
                          fallback: palette.surface,
                        ),
                      ),
                      label: Text(
                        'Usar esta ubicación',
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: palette.primary,
                        foregroundColor: palette.surface,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18.r),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}