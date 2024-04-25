import 'package:Slydo/routes/route_constants.dart';
import 'package:Slydo/screens/more_apps/payment_link/payment_link_cashout.dart';
import 'package:Slydo/screens/post_detail_page.dart';
import 'package:Slydo/utils/enums.dart';
import 'package:Slydo/utils/global_key.dart';
import 'package:Slydo/utils/navigation_util.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uni_links/uni_links.dart';

class UniLinksService {
  static String _promoId = '';
  static String get promoId => _promoId;
  static bool get hasPromoId => _promoId.isNotEmpty;

  static void reset() => _promoId = '';

  static init() async {
    // This is used for cases when: APP is not running and the user clicks on a link.
    try {
      final Uri? uri = await getInitialUri();
      _uniLinkHandler(uri: uri);
    } on PlatformException {
      if (kDebugMode)
        print("(PlatformException) Failed to receive initial uri.");
    } on FormatException catch (error) {
      if (kDebugMode)
        print(
            "(FormatException) Malformed Initial URI received. Error: $error");
    }

    // This is used for cases when: APP is already running and the user clicks on a link.
    uriLinkStream.listen((Uri? uri) async {
      _uniLinkHandler(uri: uri);
    }, onError: (error) {
      if (kDebugMode) print('UniLinks onUriLink error: $error');
    });
  }

  static void _uniLinkHandler({required Uri? uri}) async {
    debugPrint("uri ===>$uri");
    // if (uri == null || uri.queryParameters.isEmpty) return;
    // String receivedPromoId = params['searchedUserName'] ?? '';
    // debugPrint("receivedPromoId : $receivedPromoId");
    if (uri == null) return;
    Map<String, String> params = uri.queryParameters;

    // Split the URL by '/'
    List<String> parts = uri.toString().split('/');

    if (parts[2] == "slydo.co") {
      SharedPreferences _sharedPreferences =
          await SharedPreferences.getInstance();
      var result = _sharedPreferences.getBool('isLoggedOut');

      if (result != null && result == true) return;

      debugPrint("slydo ===>");
      if (parts.length >= 3) if (parts[3] == "user") {
        if (parts.length >= 4)
          Navigator.pushNamed(myGlobals.context!, Routes.USER_PROFILE,
              arguments: {
                "searchedUserName": parts[4],
              });
      } else if (parts[3] == "payment-link") {
        if (parts.length >= 4)
          NavigationUtil.push(myGlobals.context!,
              screen: PaymentLinkCashOut(
                id: parts[4],
              ));
      } else if (parts[3] == "store") {
        if (parts.length >= 5) {
          if (parts[5] == "products") {
            Navigator.pushNamed(myGlobals.context!, Routes.PRODUCT, arguments: {
              "productId": parts[6],
            });
          } else if (parts[5] == "services") {
            Navigator.pushNamed(myGlobals.context!, Routes.SERVICE_DETAIL,
                arguments: {
                  "serviceId": parts[6],
                });
          } else if (parts[5] == "blogs") {
            Navigator.of(myGlobals.context!).push(
              MaterialPageRoute(
                builder: (context) {
                  return PostDetailPage(
                    onDeleteBlog: () {},
                    postType: PostType.blog,
                    postId: parts[6],
                  );
                },
              ),
            );
          }
        } else {
          Navigator.pushNamed(myGlobals.context!, Routes.USER_PROFILE,
              arguments: {
                "searchedUserName": parts[4],
              });
        }
      }
    }
  }
}
