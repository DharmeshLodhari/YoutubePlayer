import 'package:Slydo/routes/route_constants.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';

class DeepLinkService {
  DeepLinkService._();

  static DeepLinkService? _instance;

  static DeepLinkService? get instance {
    _instance ??= DeepLinkService._();
    return _instance;
  }

  ValueNotifier<String> referrerCode = ValueNotifier<String>('');

  FirebaseDynamicLinks dynamicLink = FirebaseDynamicLinks.instance;

  Future<void> handleDynamicLinks(BuildContext context) async {
    final data = await dynamicLink.getInitialLink();
    if (data != null) {
      _handleDeepLink(context: context, data: data);
    }

    //handle foreground
    dynamicLink.onLink.listen((event) {
      _handleDeepLink(data: event, context: context);
    }).onError((v) {
      debugPrint('Failed: $v');
    });
  }

  Future<void> _handleDeepLink(
      {required BuildContext context, PendingDynamicLinkData? data}) async {
    final Uri deepLink = data!.link;
    final profile = deepLink.pathSegments.contains('/profile');
    // var isBusiness = deepLink.pathSegments.contains('business');
    if (profile) {
      final code = deepLink.queryParameters['searchedUserName'];
      if (code != null) {
        Navigator.pushNamed(context, Routes.USER_PROFILE,
            arguments: {"searchedUserName": "cameraman"});

        debugPrint('ReferrerCode $referrerCode');

        referrerCode.notifyListeners();
      }
    }
    // if (isBusiness) {
    //   print("isbusiness");
    //
    //   var code = deepLink.queryParameters['id'];
    //   print("code$code");
    //   if (code != null) {
    //     BusinessModel addBusinessModel =
    //     await AuthHelper().getUserSelectedBusinesses(code.toInt());
    //     Navigator.of(context).push(MaterialPageRoute(
    //         builder: (context) =>
    //             HomeInfoScreen(addBusinessModel: addBusinessModel)));
    //     debugPrint('ReferrerCode $referrerCode');
    //     referrerCode.notifyListeners();
    //   }
    // }
  }
}
