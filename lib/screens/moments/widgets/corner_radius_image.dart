import 'dart:io';
import 'package:flutter/material.dart';

class CornerRadiusImage extends StatelessWidget {
  final String imagePath;
  final double cornerRadius;
  final bool isVideo;
  final Widget? widget;

  CornerRadiusImage(
      {required this.imagePath,
      this.cornerRadius = 10.0,
      this.isVideo = false,
      this.widget});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(cornerRadius),
      child: !isVideo
          ? Image.file(
              File(imagePath),
              fit: BoxFit.cover,
            )
          : widget,
    );
  }
}

class CornerRadiusVideo extends StatelessWidget {
  final double cornerRadius;
  final Widget? widget;

  CornerRadiusVideo({this.cornerRadius = 10.0, this.widget});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(cornerRadius),
      child: SizedBox(height: 250, width: 200, child: widget),
    );
  }
}
