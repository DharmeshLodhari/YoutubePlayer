import 'package:Slydo/screens/more_apps/ask/models/Topics/YarnTopic.dart';
import 'package:Slydo/screens/more_apps/ask/widgets/view_ask_media.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../routes/route_constants.dart';
import '../../../../utils/navigation_util.dart';
import '../../../../utils/util.dart';

class AskMediaRender extends StatefulWidget {
  YarnTopic? yarnTopic;
  AskMediaRender({Key? key, this.yarnTopic}) : super(key: key);

  @override
  State<AskMediaRender> createState() => _AskMediaRenderState();
}

class _AskMediaRenderState extends State<AskMediaRender> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return _buildImageView();
  }

  Widget _buildImageView() {
    if (widget.yarnTopic!.media!.length == 1) {
      return _buildSingleImageView();
    } else if (widget.yarnTopic!.media!.length == 2) {
      return _buildTwoImageView();
    } else if (widget.yarnTopic!.media!.length == 3) {
      return _buildThreeImageView();
    } else if (widget.yarnTopic!.media!.length == 4) {
      return _buildFourImageView();
    }
    return SizedBox();
  }

  Widget _buildSingleImageView() {
    return _buildCommonImageView(
      imageUrl: widget.yarnTopic!.media!.first.file ?? '',
      mediaType: widget.yarnTopic!.media!.first.mediaType ?? '',
      imagePoster: widget.yarnTopic!.media!.first.imagePoster ?? '',
      isSingleImage: true
    );
  }

  Widget _buildTwoImageView() {
    return Container(
      height: 175,
      child: Row(
        children: widget.yarnTopic!.media!.map((mediaFile) {
          return Expanded(
            child: _buildCommonImageView(
              imageUrl: mediaFile.file ?? '',
              mediaType: mediaFile.mediaType ?? '',
              imagePoster: mediaFile.imagePoster ?? ''
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildThreeImageView() {
    return Container(
      height: 175,
      child: Row(
        children: widget.yarnTopic!.media!.map((mediaFile) {
          return Expanded(
            child: _buildCommonImageView(
              imageUrl: mediaFile.file ?? '',
              mediaType: mediaFile.mediaType ?? '',
              imagePoster: mediaFile.imagePoster ?? ''
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildFourImageView() {
    return Container(
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildCommonImageView(
                    imageUrl: widget.yarnTopic!.media![0].file ?? '' ,
                    mediaType: widget.yarnTopic!.media![0].mediaType ?? '',
                    imagePoster: widget.yarnTopic!.media![0].imagePoster ?? ''
                ),
              ),
              Expanded(
                child: _buildCommonImageView(
                    imageUrl: widget.yarnTopic!.media![1].file ?? '' ,
                    mediaType: widget.yarnTopic!.media![1].mediaType ?? '',
                    imagePoster: widget.yarnTopic!.media![1].imagePoster ?? ''
                ),
              ),
            ],
          ),
          SizedBox(height: 8,),
          Row(
            children: [
              Expanded(
                child: _buildCommonImageView(
                    imageUrl: widget.yarnTopic!.media![2].file ?? '' ,
                    mediaType: widget.yarnTopic!.media![2].mediaType ?? '',
                    imagePoster: widget.yarnTopic!.media![2].imagePoster ?? ''
                ),
              ),
              Expanded(
                child: _buildCommonImageView(
                    imageUrl: widget.yarnTopic!.media![3].file ?? '' ,
                    mediaType: widget.yarnTopic!.media![3].mediaType ?? '',
                    imagePoster: widget.yarnTopic!.media![3].imagePoster ?? ''
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCommonImageView({required String imageUrl, required String mediaType,String? imagePoster, bool isSingleImage = false}) {
    return InkWell(
      onTap: () {
        if (mediaType == 'video') {
          NavigationUtil.push(
            context,
            screen: ViewAskMedia(arguments: {"type": mediaType, "file": imageUrl, "poster": imagePoster},),
          );
        } else {
          Navigator.of(context).pushNamed(Routes.PHOTO_VIEWER,
            arguments: imageUrl,);
        }
      },
      child: _buildSingleAndMultiImageView(
        imageUrl: imageUrl,
        mediaType: mediaType,
        imagePoster: imagePoster,
        isSingleImage: isSingleImage
      ),
    );
  }

  Widget _buildSingleAndMultiImageView({required String imageUrl, required String mediaType,String? imagePoster, required bool isSingleImage}) {
    if (isSingleImage) {
      return Container(
        width: double.infinity,
        child: Container(
          child: Stack(
            alignment: Alignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: CachedNetworkImage(
                  imageUrl: mediaType == 'video' ? imagePoster ?? '' : imageUrl,
                  fit: BoxFit.cover,
                  errorWidget: imageErrorWidget,
                ),
              ),
              if (mediaType == 'video')...[
                IconButton(
                  onPressed: () {
                    NavigationUtil.push(
                      context,
                      screen: ViewAskMedia(arguments: {"type": mediaType, "file": imageUrl, "poster": imagePoster},),
                    );
                  },
                  icon: Icon(
                    Icons.play_circle_outline_rounded,
                    size: 30,
                  ),
                  color: Colors.white,
                ),
              ]
            ],
          ),
        ),
      );
    }
    return Container(
      height: (MediaQuery.of(context).size.width - 40) / 2,
      width: (MediaQuery.of(context).size.width - 40) / 2,
      padding: EdgeInsets.symmetric(horizontal: 5),
      child: Container(
        child: Stack(
          alignment: Alignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: CachedNetworkImage(
                imageUrl: mediaType == 'video' ? imagePoster ?? '' : imageUrl,
                fit: BoxFit.cover,
                height: double.infinity,
                width: double.infinity,
                errorWidget: imageErrorWidget,
              ),
            ),
            if (mediaType == 'video')...[
              IconButton(
                onPressed: () {
                  NavigationUtil.push(
                    context,
                    screen: ViewAskMedia(arguments: {"type": mediaType, "file": imageUrl, "poster": imagePoster},),
                  );
                },
                icon: Icon(
                  Icons.play_circle_outline_rounded,
                  size: 30,
                ),
                color: Colors.white,
              ),
            ]
          ],
        ),
      ),
    );
  }
}