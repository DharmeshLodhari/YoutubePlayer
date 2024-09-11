import 'package:Slydo/screens/yarn/widgets/view_ask_media.dart';
import 'package:Slydo/utils/navigation_util.dart';
import 'package:Slydo/utils/util.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class YarnSingleMediaPreview extends StatelessWidget {
  const YarnSingleMediaPreview({
    super.key,
    required this.imageUrl,
    required this.mediaType,
    required this.isSingleImage,
    this.imagePoster,
    required this.type,
  });

  final String imageUrl;
  final String mediaType;
  final String? imagePoster;
  final bool isSingleImage;
  //this determine if its coming from yarn dashboard or comment
  final String type;

  @override
  Widget build(BuildContext context) {
    if (isSingleImage) {
      return Stack(
        alignment: Alignment.center,
        children: [
          Container(
            height: type == 'yarn' ? 310 : 150,
            width: MediaQuery.of(context).size.width,
            // constraints: BoxConstraints(maxHeight: 307, minHeight: 175),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: darkGrey.withOpacity(
                      .4,
                    ),
                    width: .5)),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: CachedNetworkImage(
                // memCacheWidth: 300,
                fadeInDuration: const Duration(milliseconds: 400),
                imageUrl: mediaType == 'video' ? imagePoster ?? '' : imageUrl,
                fit: BoxFit.cover,
                errorWidget: imageErrorWidget,
                progressIndicatorBuilder: (context, url, progress) => Center(
                  child: CircularProgressIndicator(
                    color: yarnBlack,
                  ),
                ),
              ),
            ),
          ),
          if (mediaType == 'video') ...[
            Center(
                child: InkWell(
              onTap: () {
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
              },
              child: Container(
                height: 50,
                width: 50,
                decoration: BoxDecoration(color: white, shape: BoxShape.circle),
                child: Center(
                  child: Icon(
                    Icons.play_circle_rounded,
                    size: 40,
                    color: HexColor("#4060DB"),
                  ),
                ),
              ),
            )),
          ]
        ],
      );
    }
    return SizedBox(
      height: (MediaQuery.of(context).size.width - 32) / 2,
      width: (MediaQuery.of(context).size.width - 32) / 2,
      child: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
                color: darkGrey.withOpacity(
                  .4,
                ),
                width: .5)),
        child: Stack(
          children: [
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: CachedNetworkImage(
                  // memCacheWidth: 300,
                  fadeInDuration: const Duration(milliseconds: 400),
                  imageUrl: mediaType == 'video' ? imagePoster ?? '' : imageUrl,
                  fit: BoxFit.cover,
                  height: double.infinity,
                  width: double.infinity,
                  errorWidget: imageErrorWidget,
                  progressIndicatorBuilder: (context, url, progress) => Center(
                    child: CircularProgressIndicator(
                      color: yarnBlack,
                    ),
                  ),
                ),
              ),
            ),
            if (mediaType == 'video') ...[
              Center(
                child: InkWell(
                  onTap: () {
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
                  },
                  child: Container(
                    height: 50,
                    width: 50,
                    decoration:
                        BoxDecoration(color: white, shape: BoxShape.circle),
                    child: Center(
                      child: Icon(
                        Icons.play_circle_rounded,
                        size: 40,
                        color: HexColor("#4060DB"),
                      ),
                    ),
                  ),
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }
}
