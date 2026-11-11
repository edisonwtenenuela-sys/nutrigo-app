import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class BusinessLogo extends StatelessWidget {
  final String? imageUrl;

  const BusinessLogo({super.key, this.imageUrl});

  @override
  Widget build(BuildContext context) {
    final image = imageUrl?.trim();
    final size = 54.w;

    return SizedBox(
      width: size,
      height: size,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15.r),
        child: image == null || image.isEmpty
            ? _fallback(size: 28.sp)
            : CachedNetworkImage(
                imageUrl: image,
                fit: BoxFit.cover,
                memCacheWidth: 180,
                memCacheHeight: 180,
                placeholder: (context, url) =>
                    Container(color: Colors.white.withValues(alpha: 0.12)),
                errorWidget: (context, url, error) => _fallback(size: 26.sp),
              ),
      ),
    );
  }

  Widget _fallback({required double size}) {
    return Container(
      color: Colors.white.withValues(alpha: 0.18),
      child: Icon(Icons.storefront_rounded, color: Colors.white, size: size),
    );
  }
}
