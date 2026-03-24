import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fanbae/widget/myimage.dart';

// ignore: must_be_immutable
class MyNetworkImage extends StatelessWidget {
  String imagePath;
  double? height, width;
  dynamic fit;
  bool? islandscap, isPagesIcon;
  Color? color;
  BoxShape? shape;

  MyNetworkImage(
      {Key? key,
      required this.imagePath,
      required this.fit,
      this.islandscap,
      this.isPagesIcon,
      this.height,
      this.shape,
      this.color,
      this.width})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Handle empty or null URLs
    if (imagePath.isEmpty) {
      return _buildPlaceholder();
    }

    return SizedBox(
      height: height,
      width: width,
      child: kIsWeb
          ? Image.network(
              imagePath,
              fit: fit,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return _buildPlaceholder();
              },
              errorBuilder: (context, error, stackTrace) {
                return _buildPlaceholder();
              },
            )
          : CachedNetworkImage(
              imageUrl: imagePath,
              fit: fit,
              imageBuilder: (context, imageProvider) => Container(
                decoration: BoxDecoration(
                  shape: shape ?? BoxShape.rectangle,
                  image: DecorationImage(
                      image: imageProvider,
                      fit: fit,
                      invertColors: isPagesIcon == true ? true : false),
                ),
              ),
              placeholder: (context, url) => _buildPlaceholder(),
              errorWidget: (context, url, error) => _buildPlaceholder(),
            ),
    );
  }

  Widget _buildPlaceholder() {
    return MyImage(
      width: width ?? 0,
      height: height ?? 0,
      imagePath: islandscap == false || islandscap == null
          ? "no_image_port.png"
          : "no_image_land.jpg",
      fit: BoxFit.cover,
    );
  }
}
