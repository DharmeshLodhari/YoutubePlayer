import 'dart:io';

import 'package:Slydo/data/currency.dart';
import 'package:Slydo/screens/blog/user_post/user_post_auth.dart';
import 'package:Slydo/screens/blog/user_post/user_post_list.dart';
import 'package:Slydo/screens/messaging/chat/models/channel_model.dart';
import 'package:Slydo/screens/messaging/message_auth.dart';
import 'package:Slydo/screens/moments/models/comment_model.dart';
import 'package:Slydo/screens/moments/models/moments_model.dart';
import 'package:Slydo/screens/moments/screens/moments_service.dart';
import 'package:Slydo/screens/more_apps/shopping/models/store.dart';
import 'package:Slydo/screens/more_apps/shopping/shopping_auth.dart';
import 'package:Slydo/screens/user_profile/models/user.dart';
import 'package:Slydo/screens/user_profile/screens/user_profile_module_new/user_about_screen.dart';
import 'package:Slydo/screens/user_profile/screens/user_profile_module_new/user_channel_screen.dart';
import 'package:Slydo/screens/user_profile/screens/user_profile_module_new/user_product_list.dart';
import 'package:Slydo/screens/user_profile/screens/user_profile_module_new/user_review_list.dart';
import 'package:Slydo/screens/user_profile/screens/user_profile_module_new/user_service_list.dart';
import 'package:Slydo/screens/user_profile/tiles/moment_tab_tile.dart';
import 'package:Slydo/screens/yarn/widgets/myfeed.dart';
import 'package:Slydo/screens/yarn/yarn_auth.dart';
import 'package:Slydo/widget/keep_alive_page.dart';
import 'package:flutter/material.dart';

import '../../../../../../utils/util.dart';
import '../event_list.dart';

double getBgHeightOfAppBar(
    double textHeight, String bio, bool hasAddress, bool hasContact) {
  final int bioLength = bio.length;
  // debugPrint('GET Text Height -> $textHeight');
  // debugPrint('GET BIO LEN -> $bioLength');
  // debugPrint('GET ADDRESS -> $hasAddress');
  // debugPrint('GET CONTACT -> $hasContact');

  double? height;

  if (bioLength == 0) {
    // if (hasAddress && hasContact) {
    //   height = 380;
    // } else if (hasAddress || hasContact) {
    //   height = 360;
    // } else {
    //   height = 340;
    // }
    // if (Platform.isAndroid) {
    height = 300;
    // } else {
    //   height = 330;
    // }
  } else if (bioLength <= 50) {
    // if (hasAddress && hasContact) {
    //   height = 350;
    // } else if (hasAddress || hasContact) {
    //   height = 400;
    // } else {
    //   height = 380;
    // }
    if (Platform.isAndroid) {
      height = 370;
    } else {
      height = 340;
    }
  } else if (bioLength <= 100) {
    // if (hasAddress && hasContact) {
    //   height = 460;
    // } else if (hasAddress || hasContact) {
    //   height = 460;
    // } else {
    //   height = 400;
    // }
    if (Platform.isAndroid) {
      height = 390;
    } else {
      height = 360;
    }
  } else if (bioLength <= 200) {
    // if (hasAddress && hasContact) {
    //   height = 460;
    // } else if (hasAddress || hasContact) {
    //   height = 480;
    // } else {
    //   height = 460;
    // }
    if (Platform.isAndroid) {
      height = 420;
    } else {
      height = 390;
    }
  }

  // debugPrint('GET HEIGHT -> $height');

  height ??= 300;

  return height;
}

Future<List> fetchYarnData(String? searchedUserName, String isChannel) async {
  Map<String, dynamic>? data;
  try {
    data = await YarnAuth().getAllYarn("", "",
        type: "my-topics",
        isType: false,
        userName: searchedUserName,
        isChannel: isChannel);
  } catch (error) {}
  if (data != null) {
    // debugPrint('IS SHOW YARN ---> $data');

    final List<dynamic> result = data["results"];
    if (result.isNotEmpty) return result;
  }

  return [];
}

Future<List> fetchChannelData(String? searchedUserName) async {
  BasePaginationModel<List<ChannelModel>>? basePaginationModel;
  try {
    basePaginationModel = await MessageAuth()
        .getChannels(nextUrl: '', searchText: '', ownerName: searchedUserName);
  } catch (error) {}
  if (basePaginationModel != null) {
    // debugPrint('IS SHOW CHANNELS ---> $basePaginationModel');

    final List<dynamic> result = basePaginationModel.result;
    if (result.isNotEmpty) return result;
  }

  return [];
}

Future<List> fetchPostData(
    String? searchedUserName, String? channelUserName) async {
  Map<String, dynamic>? data;
  try {
    data = await UserPostAuth().listUserPosts(
        next: '', userName: searchedUserName, channelUserName: channelUserName);
  } catch (error) {
    debugPrint('IS SHOW POST error ---> $error');
  }
  if (data != null) {
    // debugPrint('IS SHOW POST ---> $data');

    final List<dynamic> result = data["results"];
    if (result.isNotEmpty) return result;
  }

  // debugPrint('IS SHOW POST error ---> $data');

  return [];
}

Future<List> fetchMomentData(
    String? searchedUserName, String? channelUsername) async {
  List<MomentsModel> momentsModel = [];
  try {
    momentsModel = await MomentsService().getMomentsWithOwnerName(
        ownerName: searchedUserName!, channelUsername: channelUsername);
  } catch (error) {}
  if (momentsModel.isNotEmpty) {
    // debugPrint('IS SHOW MOMENTS ---> $momentsModel');

    final List<dynamic> result = momentsModel;
    if (result.isNotEmpty) return result;
  }

  return [];
}

Future<List> fetchProductData(String? searchedUserName, bool? isChannel) async {
  Map<String, dynamic>? data;
  try {
    data = await ShoppingAuthService()
        .listOfProduct("", "", "", isChannel, userName: searchedUserName);
  } catch (error) {}
  if (data != null) {
    // debugPrint('IS SHOW PRODUCT ---> $data');
    final List<dynamic> result = data["results"];
    if (result.isNotEmpty) return result;
  }

  return [];
}

Future<List> fetchServiceData(String? searchedUserName) async {
  Map<String, dynamic>? data;
  try {
    data = await ShoppingAuthService()
        .listServicesByProvider("", "", userName: searchedUserName);
  } catch (error) {}
  if (data != null) {
    final List<dynamic> result = data["results"];
    if (result.isNotEmpty) return result;
  }

  return [];
}

Widget yarnTab(String? searchedUserName, String isChannel) {
  return KeepAlivePage(
      child: MyFeedView(userName: searchedUserName, isChannel: isChannel));
}

Widget channelTab(String? searchedUserName) {
  return KeepAlivePage(
      child: UserChannelsList(
    ownerName: searchedUserName,
    isSearch: true,
  ));
}

Widget postTab(CustomerProfile? searchedUser, String? channelUserName) {
  return KeepAlivePage(
    child: UserPostList(user: searchedUser, channelUserName: channelUserName),
  );
}

Widget momentTab(CustomerProfile? searchedUser, String channelUsername) {
  return KeepAlivePage(
    child: MomentsTab(
        searchedUser: searchedUser, channelUsername: channelUsername),
  );
}

Widget productTab(CustomerProfile? searchedUser, bool isOwner, bool isChannel,
    {String? next, String? type}) {
  return UserProductList(
    user: searchedUser,
    isOwner: isOwner,
    channel: isChannel,
    next: next,
    type: type,
  );
}

Widget serviceTab(CustomerProfile? searchedUser, bool isOwner) {
  return KeepAlivePage(
    child: UserServiceList(
      user: searchedUser,
      isOwner: isOwner,
    ),
  );
}

Widget reviewTab(CustomerProfile? searchedUser) {
  return KeepAlivePage(
    child: Center(child: UserReviewList(user: searchedUser)),
  );
}

Widget eventTab(CustomerProfile? searchedUser) {
  return KeepAlivePage(
    child: Center(child: EventList(user: searchedUser)),
  );
}

Widget hoursTab(CustomerProfile? searchedUser) {
  return KeepAlivePage(child: UserAboutScreen(user: searchedUser));
}

String getInitials(String fullName) {
  if (fullName.isEmpty) {
    return '';
  }

  final words = fullName.trim().split(' ');
  final initials =
      words.where((word) => word.isNotEmpty).map((word) => word[0]);

  return initials.take(2).join();
}

String getGroupUsername(String channelUsername) {
  if (channelUsername.contains(' ')) {
    return channelUsername.replaceAll(' ', '');
  } else {
    return channelUsername;
  }
}

/*Widget showDiscountValue(
    String discountType, num discountValue, String? currency) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
    decoration: BoxDecoration(
        color: verifyGreen, borderRadius: BorderRadius.circular(5)),
    child: Text(
      "-${discountType == "percentage" ? "$discountValue% off" : worldCurrencies[currency!]! + moneyDisplayNormalizer(discountValue.toInt()).toString()}",
      style: TextStyle(
        color: white,
        fontSize: 10,
        fontFamily: 'Inter',
        fontWeight: FontWeight.w700,
      ),
    ),
  );
}*/

Widget showDiscountValue(
    String discountType, num discountValue, String? currency) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    color: lightGreenBg,
    child: RichText(
      text: TextSpan(
        text:
            "-${discountType == "percentage" ? "$discountValue% OFF" : worldCurrencies[currency!]! + moneyDisplayNormalizer(discountValue.toInt()).toString()}",
        style: TextStyle(
          color: naturalGreen,
          fontSize: 12,
          fontFamily: 'Inter',
          fontWeight: FontWeight.w700,
        ),
        children: [
          const WidgetSpan(child: SizedBox(width: 3)),
          TextSpan(
            text: 'Discount Sales',
            style: TextStyle(
              fontSize: 12,
              fontFamily: 'Inter',
              color: blackFont,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
      textAlign: TextAlign.center,
      softWrap: true,
      overflow: TextOverflow.ellipsis,
    ),
  );
}

/*Widget showColoredLabeledWidget({required String text, required Color color}) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
    decoration:
        BoxDecoration(color: color, borderRadius: BorderRadius.circular(5)),
    child: Text(
      text,
      style: TextStyle(
        color: white,
        fontSize: 10,
        fontFamily: 'Inter',
        fontWeight: FontWeight.w700,
      ),
    ),
  );
}*/

Widget showColoredLabeledWidgetProductDetails(
    {required String text,
    required Color color,
    Product? product,
    Variant? selectedVariant,
    String? date}) {
  return Container(
    alignment: Alignment.center,
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
    color: color,
    child: RichText(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: getProductDetailsColors(product!, selectedVariant),
          fontSize: 12,
          fontFamily: 'Inter',
          fontWeight: FontWeight.w700,
        ),
        children: [
          const WidgetSpan(child: SizedBox(width: 5)),
          TextSpan(
            text: date ?? "",
            style: TextStyle(
              fontSize: 12,
              fontFamily: 'Inter',
              color: blackFont,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
      textAlign: TextAlign.center,
      softWrap: true,
      overflow: TextOverflow.ellipsis,
    ),
  );
}

Widget showColoredLabeledWidgetServiceDetails({
  required String text,
  String? date,
  required Color color,
  required Service? service,
}) {
  return Container(
    alignment: Alignment.center,
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
    color: color,
    child: RichText(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: getServiceDetailsColors(service!),
          fontSize: 12,
          fontFamily: 'Inter',
          fontWeight: FontWeight.w700,
        ),
        children: [
          const WidgetSpan(child: SizedBox(width: 5)),
          TextSpan(
            text: date ?? "",
            style: TextStyle(
              fontSize: 12,
              fontFamily: 'Inter',
              color: blackFont,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
      textAlign: TextAlign.center,
      softWrap: true,
      overflow: TextOverflow.ellipsis,
    ),
  );
}

Color getServiceDetailsColors(Service service) {
  if (service.availableFrom?.isAfter(DateTime.now()) ?? false) {
    return starYellow;
  } else if (service.isAvailable == false) {
    return red;
  } else {
    return transparent;
  }
}

Color getProductDetailsColors(Product product, Variant? selectedVariant) {
  if ((product.variantModels?.isEmpty ?? false) &&
      (product.availableFrom?.isAfter(DateTime.now()) ?? false)) {
    return starYellow;
  } else if ((product.variantModels?.isEmpty ?? false) &&
      product.trackInventory == true &&
      ((product.quantity ?? 0) <= 0)) {
    return red;
  } else if ((product.discountedPrice != null &&
          product.discountedPrice != 0) ||
      (product.pricePercentageChange != null &&
              product.pricePercentageChange != 0.0 ||
          selectedVariant != null)) {
    return naturalGreen;
  } else {
    return transparent;
  }
}

Widget showColoredLabeledWidgetService({
  required String text,
  required Color color,
  required Service service,
}) {
  return Container(
    alignment: Alignment.center,
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
    color: color,
    child: Text(
      text,
      style: TextStyle(
        color: getServiceStockTextColors(service),
        fontSize: 10,
        fontFamily: 'Inter',
        fontWeight: FontWeight.w700,
      ),
    ),
  );
}

Color getServiceStockTextColors(Service service) {
  if (service.availableFrom?.isAfter(DateTime.now()) ?? false) {
    return starYellow;
  } else if (service.isAvailable == false) {
    return red;
  } else {
    return transparent;
  }
}

Widget showColoredLabeledWidgetProductStock(
    {required String text,
    required Color color,
    required Product product,
    String? date}) {
  return Container(
    alignment: Alignment.center,
    color: color,
    child: RichText(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: getProductStockTextColors(product),
          fontSize: 12,
          fontFamily: 'Inter',
          fontWeight: FontWeight.w700,
        ),
        children: [
          const WidgetSpan(child: SizedBox(width: 5)),
          TextSpan(
            text: date ?? "",
            style: TextStyle(
              fontSize: 12,
              fontFamily: 'Inter',
              color: blackFont,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
      textAlign: TextAlign.center,
      softWrap: true,
      overflow: TextOverflow.ellipsis,
    ),
  );
}

Color getProductStockTextColors(Product product) {
  if (product.availableFrom?.isAfter(DateTime.now()) ?? false) {
    return starYellow;
  } else if (product.trackInventory == true && product.quantity! <= 0) {
    return red;
  } else if ((product.discountedPrice != null &&
          product.discountedPrice != 0) ||
      (product.pricePercentageChange != null &&
          product.pricePercentageChange != 0.0)) {
    return naturalGreen;
  } else {
    return transparent;
  }
}
