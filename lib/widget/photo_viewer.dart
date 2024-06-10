import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/loading_indicator.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class PhotoViewer extends StatefulWidget {
  final String? imageUrl;

  PhotoViewer({super.key, required this.imageUrl});

  @override
  _PhotoViewerState createState() => _PhotoViewerState();
}

class _PhotoViewerState extends State<PhotoViewer> {
  String? imageUrl;

  @override
  void initState() {
    imageUrl = widget.imageUrl;
    debugPrint('IMAGE URL --> $imageUrl');
    if (imageUrl == null || imageUrl == "") {
      imageUrl = defaultImage;
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.black,
      ),
      body: checkImageLink(),
    );
  }

  Widget checkImageLink() {
    final bool validURL = Uri.parse(imageUrl!).isAbsolute;

    if (!validURL) {
      return Center(
        child: CircleAvatar(
          backgroundColor: navyBlue,
          radius: 100,
          child: Text(
            imageUrl!,
            style: TextStyle(color: white, fontSize: 100),
          ),
        ),
      );
    } else {
      return PhotoView(
        imageProvider: NetworkImage(imageUrl!),
        backgroundDecoration: const BoxDecoration(color: Colors.black),
        loadingBuilder: (context, event) {
          if (event != null) {
            return Center(
              child: CircularProgressIndicator(
                value: ((100 * event.cumulativeBytesLoaded) /
                        event.expectedTotalBytes!) /
                    100,
                strokeWidth: 2.5,
                valueColor: AlwaysStoppedAnimation(navyBlue),
                backgroundColor: Colors.transparent,
              ),
            );
          }
          return Center(child: CircularLoadingIndicator());
        },
        errorBuilder: (context, error, stackTrace) => Center(
          child: CachedNetworkImage(imageUrl: defaultImage),
        ),
      );
    }
  }
}
