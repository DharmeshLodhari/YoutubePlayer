import 'package:Slydo/utils/link_preview/web_analyzer.dart';
import 'package:Slydo/utils/util.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

// ignore: must_be_immutable

Map<String, dynamic> detectLinkInText(String text) {
  RegExp exp =
      new RegExp(r'(?:(?:https?|ftp):\/\/)?[\w/\-?=%.@]+\.[\w/\-?=%.]+');
  Iterable<RegExpMatch> matches = exp.allMatches(text);
  String link;
  List<String> listOfLinks = [];
  matches.forEach((match) {
    link = text.substring(match.start, match.end);
    // will match google.com
    if (link.startsWith("@") != true && !link.contains("..")) {
      // don't match @abiola.rasheed as a url
      listOfLinks.add(link);
    }
  });

  Map<String, dynamic> linkData = {"hasLink": false, "links": listOfLinks};

  if (listOfLinks.isEmpty) {
    return linkData;
  } else {
    linkData["hasLink"] = true;
    return linkData;
  }
}

String? getPreviewIcon(String? url) {
  if (url != null) {
    if (url.endsWith('.png') || url.endsWith('.jpg') || url.endsWith('.jpeg')) {
      return url;
    } else {
      return '';
    }
  } else {
    return '';
  }
}

List<Widget> getWebPreview(
    WebInfo webInfo, BuildContext context, String? url, double height) {
  List<Widget> children = [
    Center(
      child: Row(
        children: <Widget>[
          getPreviewIcon(webInfo.icon)!.isEmpty
              ? SizedBox.shrink()
              : CachedNetworkImage(
                  imageUrl: getPreviewIcon(webInfo.icon)!,
                  errorWidget: imageErrorWidget,
                  imageBuilder: (context, imageProvider) {
                    return Image(
                      image: imageProvider,
                      fit: BoxFit.contain,
                      width: 30,
                      height: 30,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(Icons.link);
                      },
                    );
                  },
                ),
          getPreviewIcon(webInfo.icon)!.isEmpty
              ? SizedBox.shrink()
              : const SizedBox(width: 8),
          Expanded(
            child: Text(
              webInfo.title!,
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
        ],
      ),
    ),
  ];

  if (WebAnalyzer.isNotEmpty(webInfo.image)) {
    children.addAll([
      const SizedBox(height: 8),
      Center(
        child: Container(
          constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.width / 2.5),
          child: CachedNetworkImage(
            errorWidget: imageErrorWidget,
            imageUrl: webInfo.image!,
            width: double.infinity,
            fit: BoxFit.fill,
            height: height,
          ),
        ),
      ),
    ]);
  }

  final uri = Uri.parse(url!).host;

  children.addAll([
    const SizedBox(height: 8),
    GestureDetector(
      onTap: () {
        launchUrl(Uri.parse(url));
      },
      child: Align(
        alignment: Alignment.centerLeft,
        child: Container(
          constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.width / 2.5),
          child: Text(
            uri,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: darkGreyYarn, fontSize: 12),
          ),
        ),
      ),
    ),
  ]);

  if (WebAnalyzer.isNotEmpty(webInfo.description)) {
    children.addAll([
      const SizedBox(height: 4),
      GestureDetector(
        onTap: () {
          launchUrl(Uri.parse(url));
        },
        child: Text(
          webInfo.description!,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(color: blackFont, fontSize: 12),
        ),
      ),
      const SizedBox(height: 8),
    ]);
  }

  return children;
}
