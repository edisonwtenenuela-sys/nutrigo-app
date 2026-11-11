import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SmoothProfileAvatar extends StatefulWidget {
  final String? imageUrl;
  final bool isLoading;
  final double size;
  final Widget fallback;
  final Color borderColor;
  final double borderWidth;
  final Color overlayColor;
  final Widget? loadingIndicator;
  final BoxShape shape;
  final BorderRadius? borderRadius;
  final BoxFit fit;

  const SmoothProfileAvatar({
    super.key,
    required this.imageUrl,
    required this.fallback,
    this.isLoading = false,
    required this.size,
    this.borderColor = Colors.transparent,
    this.borderWidth = 0,
    this.overlayColor = const Color(0x33000000),
    this.loadingIndicator,
    this.shape = BoxShape.circle,
    this.borderRadius,
    this.fit = BoxFit.cover,
  });

  @override
  State<SmoothProfileAvatar> createState() => _SmoothProfileAvatarState();
}

class _SmoothProfileAvatarState extends State<SmoothProfileAvatar> {
  String? _visibleImageUrl;
  String? _loadingImageUrl;

  bool get _hasVisibleImage =>
      _visibleImageUrl != null && _visibleImageUrl!.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    _visibleImageUrl = widget.imageUrl?.trim();
  }

  @override
  void didUpdateWidget(covariant SmoothProfileAvatar oldWidget) {
    super.didUpdateWidget(oldWidget);

    final oldImageUrl = oldWidget.imageUrl?.trim();
    final newImageUrl = widget.imageUrl?.trim();

    if (newImageUrl == oldImageUrl) return;

    if (newImageUrl == null || newImageUrl.isEmpty) {
      setState(() {
        _visibleImageUrl = null;
        _loadingImageUrl = null;
      });
      return;
    }

    if (newImageUrl == _visibleImageUrl) return;

    setState(() => _loadingImageUrl = newImageUrl);
    _preloadIncomingImage(newImageUrl);
  }

  Future<void> _preloadIncomingImage(String imageUrl) async {
    final provider = CachedNetworkImageProvider(imageUrl);

    try {
      await precacheImage(provider, context);
    } catch (_) {
      if (!mounted || _loadingImageUrl != imageUrl) return;
      setState(() => _loadingImageUrl = null);
      return;
    }

    if (!mounted || _loadingImageUrl != imageUrl) return;

    setState(() {
      _visibleImageUrl = imageUrl;
      _loadingImageUrl = null;
    });
  }

  Widget _buildVisibleImage() {
    if (!_hasVisibleImage) return widget.fallback;

    return SizedBox.expand(
      child: CachedNetworkImage(
        key: ValueKey(_visibleImageUrl),
        imageUrl: _visibleImageUrl!,
        width: widget.size,
        height: widget.size,
        fit: widget.fit,
        fadeInDuration: Duration.zero,
        fadeOutDuration: Duration.zero,
        placeholder: (context, url) => SizedBox.expand(child: widget.fallback),
        errorWidget: (context, url, error) =>
            SizedBox.expand(child: widget.fallback),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final showOverlay = widget.isLoading || _loadingImageUrl != null;

    final shapeBorderRadius = widget.shape == BoxShape.circle
        ? null
        : widget.borderRadius ?? BorderRadius.zero;

    final content = Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        shape: widget.shape,
        borderRadius: shapeBorderRadius,
        border: Border.all(
          color: widget.borderColor,
          width: widget.borderWidth,
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 280),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            child: _buildVisibleImage(),
          ),
          if (showOverlay)
            Container(
              color: widget.overlayColor,
              child: Center(
                child:
                    widget.loadingIndicator ??
                    SizedBox(
                      width: (widget.size * 0.32).w,
                      height: (widget.size * 0.32).w,
                      child: const CircularProgressIndicator(
                        strokeWidth: 2.2,
                        color: Colors.white,
                      ),
                    ),
              ),
            ),
        ],
      ),
    );

    if (widget.shape == BoxShape.circle) {
      return ClipOval(child: content);
    }

    return ClipRRect(
      borderRadius: shapeBorderRadius ?? BorderRadius.zero,
      child: content,
    );
  }
}








