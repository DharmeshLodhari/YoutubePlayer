import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class RotatedImage extends StatefulWidget {
  final String image;

  const RotatedImage(this.image, {super.key});

  @override
  State<RotatedImage> createState() => _RotatedImageState();
}

class _RotatedImageState extends State<RotatedImage>
    with SingleTickerProviderStateMixin {
  AnimationController? animationController;
  Animation<double>? animation;

  @override
  void initState() {
    super.initState();
    animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3, milliseconds: 500),
    )..addListener(() => setState(() {}));
    animation = CurvedAnimation(
      parent: animationController!,
      curve: Curves.linear,
    );
    animationController!.repeat();
  }

  @override
  void dispose() {
    animationController!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: animation!,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(100),
        child: CachedNetworkImage(
          imageUrl: widget.image,
          width: 50,
          height: 50,
        ),
      ),
    );
  }
}
