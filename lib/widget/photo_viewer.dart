import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/LoadingIndicator.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class PhotoViewer extends StatefulWidget {
  String? imageUrl;

  PhotoViewer({Key? key, required this.imageUrl}) : super(key: key);

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
      body: PhotoView(
        imageProvider: NetworkImage(imageUrl!),
        backgroundDecoration: BoxDecoration(color: Colors.black),
        loadingBuilder: (context, event) {
          if (event != null) {
            return Container(
              child: Center(
                child: CircularProgressIndicator(
                  value: ((100 * event.cumulativeBytesLoaded) /
                          event.expectedTotalBytes!) /
                      100,
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation(navyBlue),
                  backgroundColor: Colors.transparent,
                ),
              ),
            );
          }
          return Center(child: CircularLoadingIndicator());
        },
        errorBuilder: (context, error, stackTrace) => Center(
          child: CachedNetworkImage(imageUrl: defaultImage),
        ),
      ),
    );
  }
}
