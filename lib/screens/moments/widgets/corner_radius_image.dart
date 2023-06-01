import 'dart:io';
import 'package:flutter/material.dart';

class CornerRadiusImage extends StatelessWidget {
  final String imagePath;
  final double cornerRadius;

  CornerRadiusImage({required this.imagePath, this.cornerRadius = 10.0});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(cornerRadius),
      child: Image.file(
        File(imagePath),
        fit: BoxFit.cover,
      ),
    );
  }
}