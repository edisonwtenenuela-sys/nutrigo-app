import 'package:flutter/material.dart';

class NutriGoLogoMark extends StatelessWidget {
  final double size;
  final BoxFit fit;

  const NutriGoLogoMark({
    super.key,
    required this.size,
    this.fit = BoxFit.contain,
  });

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/branding/nutrigo_mark.png',
      width: size,
      height: size,
      fit: fit,
      filterQuality: FilterQuality.high,
    );
  }
}