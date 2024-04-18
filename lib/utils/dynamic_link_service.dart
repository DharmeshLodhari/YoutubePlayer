import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';

class DynamicLinkService {
  final FirebaseDynamicLinks dynamicLink = FirebaseDynamicLinks.instance;

  Future<String> createShareBusinessLink({
    String? businessId,
    String? endpoint,
    String? title,
    String? description,
  }) async {
    final DynamicLinkParameters parameters = DynamicLinkParameters(
      uriPrefix: 'https://slydo.co',
      link: Uri.parse('https://slydo.co/$endpoint$businessId'),
      androidParameters: AndroidParameters(
        packageName: 'com.slydo.slydo',
      ),
      // socialMetaTagParameters: SocialMetaTagParameters(
      //   title: title,
      //   description: description,
      //   imageUrl: Uri.parse(
      //       'https://brandemanager.com/assets/img/business-image.png'),
      // ),
    );

    final ShortDynamicLink shortLink = await dynamicLink.buildShortLink(
      parameters,
    );

    final Uri shortUrl = shortLink.shortUrl;
    return shortUrl.toString();
  }
}
