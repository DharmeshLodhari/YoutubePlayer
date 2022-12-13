import 'package:Slydo/screens/more_apps/yarn/widgets/view_ask_media.dart';
import 'package:Slydo/utils/colors.dart';
import 'package:Slydo/utils/navigation_util.dart';
import 'package:Slydo/utils/util.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class YarnSingleMediaPreview extends StatelessWidget {
  const YarnSingleMediaPreview(
      {required this.imageUrl,
      required this.mediaType,
      required this.isSingleImage,
      this.imagePoster,
      Key? key})
      : super(key: key);

  final String imageUrl;
  final String mediaType;
  final String? imagePoster;
  final bool isSingleImage;

  @override
  Widget build(BuildContext context) {
    if (isSingleImage) {
      return Center(
        child: Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(width: 2.0, color: lightGreyYarn)),
          // constraints: BoxConstraints(maxHeight: 300),
          child: Container(
            child: Stack(
              alignment: Alignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: CachedNetworkImage(
                    imageUrl:
                        mediaType == 'video' ? imagePoster ?? '' : imageUrl,
                    fit: BoxFit.cover,
                    errorWidget: imageErrorWidget,
                    progressIndicatorBuilder: (context, url, progress) =>
                        Container(
                      child: Center(
                        child: CircularProgressIndicator(
                          color: navyBlue,
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
                        //padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: white,
                          shape: BoxShape.circle
                        ),
                        child: Center(
                          child: Icon(
                            Icons.play_circle_rounded,
                            size: 40,
                            color: HexColor("#4060DB"),
                          ),
                        ),
                      ),
                    )
                  ),
                ]
              ],
            ),
          ),
        ),
      );
    }
    return Container(
      height: (MediaQuery.of(context).size.width - 32) / 2,
      width: (MediaQuery.of(context).size.width - 32) / 2,
      child: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(width: 2, color: lightGreyYarn)),
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: CachedNetworkImage(
                imageUrl: mediaType == 'video' ? imagePoster ?? '' : imageUrl,
                fit: BoxFit.cover,
                height: double.infinity,
                width: double.infinity,
                errorWidget: imageErrorWidget,
                progressIndicatorBuilder: (context, url, progress) => Container(
                  child: Center(
                    child: CircularProgressIndicator(
                      color: navyBlue,
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
                      //padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                          color: white,
                          shape: BoxShape.circle
                      ),
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
