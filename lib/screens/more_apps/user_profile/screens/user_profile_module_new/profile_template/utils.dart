import 'package:Slydo/data/currency.dart';
import 'package:Slydo/screens/moments/models/comment_model.dart';
import 'package:Slydo/screens/moments/models/moments_model.dart';
import 'package:Slydo/screens/moments/screens/moments_service.dart';
import 'package:Slydo/screens/more_apps/messaging/chat/models/channel_model.dart';
import 'package:Slydo/screens/more_apps/messaging/message_auth.dart';
import 'package:Slydo/screens/more_apps/shopping/shopping_auth.dart';
import 'package:Slydo/screens/more_apps/user_post/user_post_auth.dart';
import 'package:Slydo/screens/more_apps/user_post/user_post_list.dart';
import 'package:Slydo/screens/more_apps/user_profile/models/user.dart';
import 'package:Slydo/screens/more_apps/user_profile/screens/user_profile_module_new/user_about_screen.dart';
import 'package:Slydo/screens/more_apps/user_profile/screens/user_profile_module_new/user_channel_screen.dart';
import 'package:Slydo/screens/more_apps/user_profile/screens/user_profile_module_new/user_product_list.dart';
import 'package:Slydo/screens/more_apps/user_profile/screens/user_profile_module_new/user_review_list.dart';
import 'package:Slydo/screens/more_apps/user_profile/screens/user_profile_module_new/user_service_list.dart';
import 'package:Slydo/screens/more_apps/user_profile/tiles/moment_tab_tile.dart';
import 'package:Slydo/screens/more_apps/yarn/widgets/myfeed.dart';
import 'package:Slydo/screens/more_apps/yarn/yarn_auth.dart';
import 'package:Slydo/widget/keep_alive_page.dart';
import 'package:flutter/material.dart';

import '../../../../../../utils/util.dart';
import '../event_list.dart';

double getBgHeightOfAppBar(String bio, bool hasAddress, bool hasContact) {
  int bioLength = bio.length;
  debugPrint('GET BIO LEN -> $bioLength');
  debugPrint('GET ADDRESS -> $hasAddress');
  debugPrint('GET CONTACT -> $hasContact');

  double? height;

  if (bioLength == 0) {
    // if (hasAddress && hasContact) {
    //   height = 380;
    // } else if (hasAddress || hasContact) {
    //   height = 360;
    // } else {
    //   height = 340;
    // }
    height = 300;
  } else if (bioLength <= 50) {
    // if (hasAddress && hasContact) {
    //   height = 350;
    // } else if (hasAddress || hasContact) {
    //   height = 400;
    // } else {
    //   height = 380;
    // }
    height = 335;
  } else if (bioLength <= 100) {
    // if (hasAddress && hasContact) {
    //   height = 460;
    // } else if (hasAddress || hasContact) {
    //   height = 460;
    // } else {
    //   height = 400;
    // }
    height = 350;
  } else if (bioLength <= 200) {
    // if (hasAddress && hasContact) {
    //   height = 460;
    // } else if (hasAddress || hasContact) {
    //   height = 480;
    // } else {
    //   height = 460;
    // }
    height = 375;
  }

  debugPrint('GET HEIGHT -> $height');

  if (height == null) {
    height = 300;
  }

  return height;
}

fetchYarnData(String? searchedUserName, String isChannel) async {
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

    List<dynamic> result = data["results"];
    if (result.isNotEmpty) return result;
  }

  return [];
}

fetchChannelData(String? searchedUserName) async {
  BasePaginationModel<List<ChannelModel>>? basePaginationModel;
  try {
    basePaginationModel = await MessageAuth()
        .getChannels(nextUrl: '', searchText: '', ownerName: searchedUserName);
  } catch (error) {}
  if (basePaginationModel != null) {
    // debugPrint('IS SHOW CHANNELS ---> $basePaginationModel');

    List<dynamic> result = basePaginationModel.result;
    if (result.isNotEmpty) return result;
  }

  return [];
}

fetchPostData(String? searchedUserName, String? channelUserName) async {
  Map<String, dynamic>? data;
  try {
    data = await UserPostAuth().listUserPosts(
        next: '', userName: searchedUserName, channelUserName: channelUserName);
  } catch (error) {
    debugPrint('IS SHOW POST error ---> $error');
  }
  if (data != null) {
    // debugPrint('IS SHOW POST ---> $data');

    List<dynamic> result = data["results"];
    if (result.isNotEmpty) return result;
  }

  debugPrint('IS SHOW POST error ---> $data');

  return [];
}

fetchMomentData(String? searchedUserName, String? channelUsername) async {
  List<MomentsModel> momentsModel = [];
  try {
    momentsModel = await MomentsService().getMomentsWithOwnerName(
        ownerName: searchedUserName!, channelUsername: channelUsername);
  } catch (error) {}
  if (momentsModel.isNotEmpty) {
    // debugPrint('IS SHOW MOMENTS ---> $momentsModel');

    List<dynamic> result = momentsModel;
    if (result.isNotEmpty) return result;
  }

  return [];
}

fetchProductData(String? searchedUserName, bool? isChannel) async {
  Map<String, dynamic>? data;
  try {
    data = await ShoppingAuthService()
        .listOfProduct("", "", "", isChannel, userName: searchedUserName);
  } catch (error) {}
  if (data != null) {
    debugPrint('IS SHOW PRODUCT ---> $data');
    List<dynamic> result = data["results"];
    if (result.isNotEmpty) return result;
  }

  return [];
}

fetchServiceData(String? searchedUserName) async {
  Map<String, dynamic>? data;
  try {
    data = await ShoppingAuthService()
        .listServicesByProvider("", "", userName: searchedUserName);
  } catch (error) {}
  if (data != null) {
    List<dynamic> result = data["results"];
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
  return KeepAlivePage(
    child: UserProductList(
        user: searchedUser,
        isOwner: isOwner,
        channel: isChannel,
        next: next,
        type: type),
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
    return "${channelUsername.replaceAll(' ', '')}";
  } else {
    return channelUsername;
  }
}

Widget showDiscountValue(String discountType, num discountValue, currency) {
  return Container(
    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
    decoration: BoxDecoration(
        color: verifyGreen, borderRadius: BorderRadius.circular(5)),
    child: Text(
      "-" +
          (discountType == "percentage"
              ? discountValue.toString() + "% off"
              : worldCurrencies[currency!]! +
                  moneyDisplayNormalizer(discountValue.toInt()).toString()),
      style: TextStyle(
        color: white,
        fontSize: 10,
        fontFamily: 'Inter',
        fontWeight: FontWeight.w700,
      ),
    ),
  );
}

bool checkDiscount(bool discountIsActive, num discountedPrice, num price) {
  if (discountIsActive &
      (discountedPrice != null) &
      (price != discountedPrice)) {
    return true;
  }
  return false;
}
