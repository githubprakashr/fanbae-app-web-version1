import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PreviewNetworkImageUi extends StatelessWidget {
  const PreviewNetworkImageUi({super.key, this.image});

  final String? image;

  @override
  Widget build(BuildContext context) {
    return (image != null && image != "")
        ? CachedNetworkImage(imageUrl: image ?? "", fit: BoxFit.cover)
        : const Offstage();
  }
}
