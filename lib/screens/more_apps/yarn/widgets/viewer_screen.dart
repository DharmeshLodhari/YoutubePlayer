import 'package:flutter/material.dart';

class ViewerArranger extends StatelessWidget {
  ViewerArranger({required this.selectedImages, this.onTap, Key? key})
      : super(key: key);

  double SIZE_OF_IMAGE = 25;

  late List<String> selectedImages;
  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return _buildMain();
  }

  Widget _buildMain() {
    int viewerCount = selectedImages.length ?? 0;

    switch (viewerCount) {
      case 0:
        return Container();

      case 1:
        return _buildForOneViewer();

      case 2:
        return _buildForTwoViewer();

      case 3:
        return _buildForThreeViewer();

      case 4:
        return _buildForFourViewer();

      case 5:
        return _buildForFiveViewer();

      default:
        return _buildForMultipleViewer();
    }
  }

  Widget _buildForOneViewer() {
    return _buildCircularImage(selectedImages[0]);
  }

  Widget _buildForTwoViewer() {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        _buildCircularImage(selectedImages[0]),
        Positioned(
          left: SIZE_OF_IMAGE - 10,
          child: _buildCircularImage(
            selectedImages[1],
          ),
        )
      ],
    );
  }

  Widget _buildForThreeViewer() {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        _buildCircularImage(selectedImages[0]),
        Positioned(
          left: SIZE_OF_IMAGE - 10,
          top: -5,
          child: _buildCircularImage(
            selectedImages[1],
          ),
        ),
        Positioned(
          left: SIZE_OF_IMAGE + (10),
          child: _buildCircularImage(
            selectedImages[2],
          ),
        ),
      ],
    );
  }

  Widget _buildForFourViewer() {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        _buildCircularImage(selectedImages[0]),
        Positioned(
          left: SIZE_OF_IMAGE - 10,
          top: -5,
          child: _buildCircularImage(
            selectedImages[1],
          ),
        ),
        Positioned(
          left: SIZE_OF_IMAGE + 15,
          child: _buildCircularImage(
            selectedImages[2],
          ),
        ),
        Positioned(
          top: 20,
          left: SIZE_OF_IMAGE + 5,
          child: _buildCircularImage(
            selectedImages[2],
          ),
        ),
      ],
    );
  }

  Widget _buildForFiveViewer() {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        _buildCircularImage(selectedImages[0]),
        Positioned(
          left: SIZE_OF_IMAGE - 10,
          top: -5,
          child: _buildCircularImage(
            selectedImages[1],
          ),
        ),
        Positioned(
          left: SIZE_OF_IMAGE + 15,
          child: _buildCircularImage(
            selectedImages[2],
          ),
        ),
        Positioned(
          top: 20,
          left: SIZE_OF_IMAGE + 5,
          child: _buildCircularImage(
            selectedImages[3],
          ),
        ),
        Positioned(
          top: 20,
          left: SIZE_OF_IMAGE - 20,
          child: _buildCircularImage(
            selectedImages[4],
          ),
        ),
      ],
    );
  }

  Widget _buildForMultipleViewer() {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        _buildCircularImage(selectedImages[0]),
        Positioned(
          left: SIZE_OF_IMAGE - 10,
          top: -5,
          child: _buildCircularImage(
            selectedImages[1],
          ),
        ),
        Positioned(
          left: SIZE_OF_IMAGE + 15,
          child: _buildCircularImage(
            selectedImages[2],
          ),
        ),
        Positioned(
          top: 20,
          left: SIZE_OF_IMAGE + 5,
          child: _buildCircularImage(
            selectedImages[3],
          ),
        ),
        Positioned(
          top: 20,
          left: SIZE_OF_IMAGE - 20,
          child: _buildCircularImage(
            selectedImages[4],
          ),
        ),
        Positioned(
          top: 20,
          left: SIZE_OF_IMAGE + 25,
          child: _buildText(),
        ),
      ],
    );
  }

  Widget _buildCircularImage(String image) {
    return SizedBox(
      height: SIZE_OF_IMAGE,
      width: SIZE_OF_IMAGE,
      child: ClipOval(
        child: Image.network(
          image,
          height: double.infinity,
          width: double.infinity,
          fit: BoxFit.fill,
        ),
      ),
    );
  }

  Widget _buildText() {
    int count = selectedImages.length - 5;

    return Container(
      height: SIZE_OF_IMAGE,
      width: SIZE_OF_IMAGE,
      child: ClipOval(
        child: Container(
          color: Colors.black,
          child: Center(
              child: Text(
            "+$count",
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          )),
        ),
      ),
    );
  }
}
