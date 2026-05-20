import 'package:bujuan_music/widgets/loading.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons_pro/hugeicons.dart';

class CachedImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final double borderRadius;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget? errorWidget;
  final int pWidth;
  final int pHeight;

  const CachedImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.borderRadius = 8.0,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
    this.pWidth = 500,
    this.pHeight = 500,
  });

  //唱片机
  @override
  Widget build(BuildContext context) {
    if (borderRadius == 0) {
      return imageUrl.isEmpty
          ? Container(height: height, width: width, color: Colors.grey.withAlpha(140))
          : CachedNetworkImage(
              imageUrl: imageUrl.startsWith('http:') ? imageUrl.replaceFirst('http:', 'https:') : imageUrl,
              width: width,
              height: height,
              fit: fit,
              httpHeaders: const {
                'Referer': 'https://music.163.com',
                'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/92.0.4515.159 Safari/537.36',
              },
              placeholder: (context, url) => placeholder ?? _defaultPlaceholder(),
              errorWidget: (context, url, error) => errorWidget ?? _defaultErrorWidget(),
              fadeInDuration: const Duration(milliseconds: 300),
              fadeOutDuration: const Duration(milliseconds: 200),
            );
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: imageUrl.isEmpty
          ? Container(height: height, width: width, color: Colors.grey.withAlpha(140))
          : CachedNetworkImage(
              imageUrl: '$imageUrl?param=${pWidth}y$pHeight',
              width: width,
              height: height,
              fit: fit,
              placeholder: (context, url) => placeholder ?? _defaultPlaceholder(),
              errorWidget: (context, url, error) => errorWidget ?? _defaultErrorWidget(),
              fadeInDuration: const Duration(milliseconds: 300),
              fadeOutDuration: const Duration(milliseconds: 200),
            ),
    );
  }

  Widget _defaultPlaceholder() {
    return Container(
      width: width,
      height: height,
      color: Colors.grey.shade200,
      child: Icon(HugeIconsStroke.image01),
    );
  }

  Widget _defaultErrorWidget() {
    return Container(
      width: width,
      height: height,
      color: Colors.grey.shade300,
      child: LoadingIndicator(size: Size((width ?? 0) / 3, (width ?? 0) / 3)),
    );
  }
}
