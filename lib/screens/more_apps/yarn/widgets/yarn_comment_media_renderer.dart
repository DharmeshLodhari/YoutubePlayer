import 'dart:async';

import 'package:Slydo/screens/more_apps/yarn/models/Topics/CommentDetails.dart';
import 'package:Slydo/screens/more_apps/yarn/widgets/overlay_yarn_photo.dart';
import 'package:Slydo/screens/more_apps/yarn/widgets/view_ask_media.dart';
import 'package:Slydo/screens/more_apps/yarn/widgets/yarn_single_media_preview.dart';
import 'package:flutter/material.dart';
import 'package:swipe_image_gallery/swipe_image_gallery.dart';

import '../../../../utils/navigation_util.dart';

class YarnCommentMediaRender extends StatefulWidget {
  final YarnComment yarnTopic;
  YarnCommentMediaRender({Key? key, required this.yarnTopic}) : super(key: key);

  @override
  State<YarnCommentMediaRender> createState() => _YarnCommentMediaRenderState();
}

class _YarnCommentMediaRenderState extends State<YarnCommentMediaRender> {
  StreamController<Widget> overlayController =
      StreamController<Widget>.broadcast();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return _buildImageView();
  }

  Widget _buildImageView() {
    if (widget.yarnTopic.media.length == 1) {
      return _buildSingleImageView();
    } else if (widget.yarnTopic.media.length == 2) {
      return _buildTwoImageView();
    } else if (widget.yarnTopic.media.length == 3) {
      return _buildThreeImageView();
    } else if (widget.yarnTopic.media.length == 4) {
      return _buildFourImageView();
    }
    return const SizedBox();
  }

  Widget _buildSingleImageView() {
    return _buildCommonImageView(
        imageUrl: widget.yarnTopic.media.first.mediaUrl ?? '',
        mediaType: widget.yarnTopic.media.first.mediaType ?? '',
        imagePoster: widget.yarnTopic.media.first.mediaPoster ?? '',
        isSingleImage: true);
  }

  Widget _buildTwoImageView() {
    return Container(
      height: 150,
      child: Row(
        children: [
          Expanded(
            child: _buildCommonImageView(
                imageUrl: widget.yarnTopic.media[0].mediaUrl ?? '',
                mediaType: widget.yarnTopic.media[0].mediaType ?? '',
                imagePoster: widget.yarnTopic.media[0].mediaPoster ?? ''),
          ),
          const SizedBox(
            width: 8,
          ),
          Expanded(
            child: _buildCommonImageView(
                imageUrl: widget.yarnTopic.media[1].mediaUrl ?? '',
                mediaType: widget.yarnTopic.media[1].mediaType ?? '',
                imagePoster: widget.yarnTopic.media[1].mediaPoster ?? ''),
          ),
        ],
      ),
    );
  }

  Widget _buildThreeImageView() {
    return Container(
      height: 150,
      child: Row(
        children: [
          Expanded(
            child: _buildCommonImageView(
                imageUrl: widget.yarnTopic.media[0].mediaUrl ?? '',
                mediaType: widget.yarnTopic.media[0].mediaType ?? '',
                imagePoster: widget.yarnTopic.media[0].mediaPoster ?? ''),
          ),
          const SizedBox(
            width: 8,
          ),
          Expanded(
            child: _buildCommonImageView(
                imageUrl: widget.yarnTopic.media[1].mediaUrl ?? '',
                mediaType: widget.yarnTopic.media[1].mediaType ?? '',
                imagePoster: widget.yarnTopic.media[1].mediaPoster ?? ''),
          ),
          const SizedBox(
            width: 8,
          ),
          Expanded(
            child: _buildCommonImageView(
                imageUrl: widget.yarnTopic.media[2].mediaUrl ?? '',
                mediaType: widget.yarnTopic.media[2].mediaType ?? '',
                imagePoster: widget.yarnTopic.media[2].mediaPoster ?? ''),
          ),
        ],
      ),
    );
  }

  Widget _buildFourImageView() {
    return Container(
      // height: 120,
      child: Column(
        children: [
          Container(
            height: 150,
            child: Row(
              children: [
                Expanded(
                  child: _buildCommonImageView(
                      imageUrl: widget.yarnTopic.media[0].mediaUrl ?? '',
                      mediaType: widget.yarnTopic.media[0].mediaType ?? '',
                      imagePoster: widget.yarnTopic.media[0].mediaPoster ?? ''),
                ),
                const SizedBox(
                  width: 8,
                ),
                Expanded(
                  child: _buildCommonImageView(
                      imageUrl: widget.yarnTopic.media[1].mediaUrl ?? '',
                      mediaType: widget.yarnTopic.media[1].mediaType ?? '',
                      imagePoster: widget.yarnTopic.media[1].mediaPoster ?? ''),
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 8,
          ),
          Container(
            height: 150,
            child: Row(
              children: [
                Expanded(
                  child: _buildCommonImageView(
                      imageUrl: widget.yarnTopic.media[2].mediaUrl ?? '',
                      mediaType: widget.yarnTopic.media[2].mediaType ?? '',
                      imagePoster: widget.yarnTopic.media[2].mediaPoster ?? ''),
                ),
                const SizedBox(
                  width: 8,
                ),
                Expanded(
                  child: _buildCommonImageView(
                      imageUrl: widget.yarnTopic.media[3].mediaUrl ?? '',
                      mediaType: widget.yarnTopic.media[3].mediaType ?? '',
                      imagePoster: widget.yarnTopic.media[3].mediaPoster ?? ''),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommonImageView(
      {required String imageUrl,
      required String mediaType,
      String? imagePoster,
      bool isSingleImage = false}) {
    return InkWell(
      onTap: () async {
        if (mediaType == 'video') {
          NavigationUtil.push(
            context,
            screen: ViewAskMedia(
              arguments: {
                "type": mediaType,
                "file": imageUrl,
                "poster": imagePoster
              },
            ),
          );
        } else {
          // Navigator.of(context).pushNamed(
          //   Routes.PHOTO_VIEWER,
          //   arguments: imageUrl,
          // );

          final List<Widget> imageList = [];
          for (var item in widget.yarnTopic.media) {
            imageList.add(Image.network('${item.mediaUrl.toString()}'));
          }

          return SwipeImageGallery(
            context: context,
            children: imageList,
            onSwipe: (index) {
              overlayController.add(OverlayYarnPhoto(
                title: '${index + 1}/${imageList.length}',
              ));
            },
            overlayController: overlayController,
            initialOverlay: OverlayYarnPhoto(
              title: '1/${imageList.length}',
            ),
          ).show();
        }
      },
      child: _buildSingleAndMultiImageView(
          imageUrl: imageUrl,
          mediaType: mediaType,
          imagePoster: imagePoster,
          isSingleImage: isSingleImage),
    );
  }

  Widget _buildSingleAndMultiImageView({
    required String imageUrl,
    required String mediaType,
    String? imagePoster,
    required bool isSingleImage,
  }) {
    return YarnSingleMediaPreview(
        imageUrl: imageUrl,
        isSingleImage: isSingleImage,
        mediaType: mediaType,
        imagePoster: imagePoster,
        type:
            'comment' //this determine if its coming from yarn dashboard or comment
        );
  }
}
