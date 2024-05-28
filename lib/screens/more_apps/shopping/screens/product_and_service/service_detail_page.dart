import 'dart:convert';

import 'package:Slydo/constant.dart';
import 'package:Slydo/data/currency.dart';
import 'package:Slydo/data/environment.dart';
import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/main.dart';
import 'package:Slydo/screens/more_apps/messaging/chat/models/chat_conversation.dart';
import 'package:Slydo/screens/more_apps/messaging/chat/share_in_chat/ShareInChat.dart';
import 'package:Slydo/screens/more_apps/review/models/review.dart';
import 'package:Slydo/screens/more_apps/review/review_auth.dart';
import 'package:Slydo/screens/more_apps/review/tiles/review_tile.dart';
import 'package:Slydo/screens/more_apps/shopping/models/store.dart';
import 'package:Slydo/screens/more_apps/shopping/screens/product_and_service/checkout_product_service.dart';
import 'package:Slydo/screens/more_apps/user_profile/models/user.dart';
import 'package:Slydo/screens/more_apps/user_profile/screens/user_profile_module_new/profile_template/utils.dart';
import 'package:Slydo/utils/slydo_app_icon_icons.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/bottom_sheet_item.dart';
import 'package:Slydo/widget/curved_btn.dart';
import 'package:Slydo/widget/item_display_card.dart';
import 'package:Slydo/widget/loading_indicator.dart';
import 'package:Slydo/widget/rounded_background_icon.dart';
import 'package:badges/badges.dart' as badges;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:share/share.dart';
import 'package:uuid/uuid.dart';

import '../../../../../routes/route_constants.dart';
import '../../../../../utils/navigation_util.dart';
import '../../../../../utils/slydo_app_icon_new_icons.dart';
import '../../../user_profile/user_auth.dart';
import '../../../yarn/models/share_as_yarn_model.dart';
import '../../../yarn/share_as_a_yarn_screen.dart';
import '../../../yarn/yarn_auth.dart';
import '../../../yarn/yarn_dashboard_bloc.dart';
import '../../shopping_auth.dart';

// ignore: must_be_immutable
class ServiceDetailPage extends StatefulWidget {
  var arguments;

  ServiceDetailPage({required this.arguments});

  @override
  _ServiceDetailPageState createState() =>
      _ServiceDetailPageState(arguments: arguments);
}

class _ServiceDetailPageState extends State<ServiceDetailPage>
    with TickerProviderStateMixin {
  var arguments;
  bool canRate = false;
  late DashboardBloc _dashboardBloc;
  bool noReviewInList = false;

  _ServiceDetailPageState({this.arguments});

  Service? service;
  late CustomerProfileBloc customerProfileBloc;
  late UserBloc userBloc;
  late BasketBloc basketBloc;
  List<String?>? imgList = [];

  final _auth = ShoppingAuthService();

  late bool isValidCustomer;
  bool isOtherItemFetched = false;
  bool isOtherItemIsEmpty = true;
  ScrollController _scrollController = ScrollController();

  List<dynamic> sellersOtherItems = [];

  int _current = 0;

  /// variables for reviews
  List<Review> reviewList = [];
  bool isReviewLoading = false;
  int? reviewCount;

  String? serviceId;
  bool serviceIsLoading = false;
  late YarnDashboardBloc yarnDashboardBloc;

  @override
  void initState() {
    service = arguments['service'];
    if (service != null) {
      serviceId = service?.id;
    } else {
      serviceId = arguments['serviceId'];
    }

    userBloc = Provider.of<UserBloc>(context, listen: false);
    fetchService(serviceId!);
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        if (!isOtherItemFetched) {
          getOtherItems();
        }
      }
    });

    fetchReviewList();
    super.initState();
  }

  void fetchService(String serviceId) async {
    debugPrint('SERVICE ID :: $serviceId');

    if (mounted)
      setState(() {
        serviceIsLoading = true;
      });
    _auth.getService(serviceId).then((value) {
      if (mounted) {
        service = value;
        imgList = service?.serverImages;
        serviceIsLoading = false;
        if (mounted) setState(() {});
      }
    }).catchError((e) {
      if (mounted)
        setState(() {
          serviceIsLoading = false;
        });
      Navigator.pop(context);
      showToast(message: e.toString());
    });
    ;
  }

  Future canReviewService() async {
    final Map<String, String> data = {};
    data['provider'] = service?.provider ?? "";
    data['buyer'] = userBloc.user.userName!;
    data['type'] = 'services';
    data['id'] = service?.id ?? "";

    debugPrint('service data :: ${data}');

    ReviewAuth().checkIfCanReviewProductOrService(data).then((value) {
      canRate = value;
      if (mounted) setState(() {});
    }).catchError(
      (error) {},
    );
    return true;
  }

  void fetchReviewList() async {
    isReviewLoading = true;
    if (mounted) setState(() {});

    await ReviewAuth().fetchServiceReviews(serviceId: serviceId).then((value) {
      final List? tempList =
          value.containsKey('results') ? value['results'] as List : [];
      value.containsKey('count') ? reviewCount = value["count"] : 0;
      canRate = value['can_rate'];

      reviewList = [];
      tempList?.forEach((element) {
        reviewList.add(Review.fromJson(element));
      });

      isReviewLoading = false;
      if (mounted) setState(() {});
    }).catchError((error) {
      debugPrint("Error:- $error");
      isReviewLoading = false;
      if (mounted) setState(() {});
    });
  }

  void getOtherItems() {
    _auth
        .ownersOrderProductsAndServices(
            type: "services", userId: service?.provider, exclude: service?.id)
        .then((value) {
      if (value.isNotEmpty) {
        if (mounted) {
          setState(() {
            isOtherItemIsEmpty = false;
            sellersOtherItems = value;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            isOtherItemIsEmpty = true;
          });
        }
      }
    });
    isOtherItemFetched = true;
  }

  @override
  Widget build(BuildContext context) {
    customerProfileBloc = Provider.of<CustomerProfileBloc>(context);
    _dashboardBloc = Provider.of<DashboardBloc>(context);
    basketBloc = Provider.of<BasketBloc>(context);
    yarnDashboardBloc = Provider.of<YarnDashboardBloc>(context, listen: false);
    isValidCustomer = userBloc.user.userName != service?.provider;
    return WillPopScope(
      onWillPop: () async {
        customerProfileBloc.customer = null;
        Navigator.pop(context, "back pressed");
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: appBar() as PreferredSizeWidget?,
        floatingActionButton: isValidCustomer ? floatingActionBar() : null,
        body: _buildServiceDetailsPage(context),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      ),
    );
  }

  Widget appBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.white,
      titleSpacing: 0,
      automaticallyImplyLeading: false,
      leading: IconButton(
        icon: Icon(
          Icons.keyboard_arrow_left,
          color: navyBlue,
          size: 24,
        ),
        onPressed: () {
          Navigator.pop(context, "back pressed");
        },
      ),
      title: Text(
        AppLocalization.of(context)!.serviceDetail,
        style: TextStyle(
            color: blackFont, fontSize: 18, fontWeight: FontWeight.bold),
      ),
      actions: <Widget>[
        menuBtn(),
        if (isValidCustomer)
          const SizedBox(
            width: 8,
          )
        else
          Container(),
        if (isValidCustomer) goToCartWidget() else Container(),
        const SizedBox(
          width: 16,
        ),
      ],
    );
  }

  void showUserProfileActionsSheet() {
    showModalBottomSheet<void>(
        backgroundColor: Colors.transparent,
        context: context,
        builder: (BuildContext context) {
          return Card(
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20)),
              ),
              color: Colors.white,
              margin: EdgeInsets.zero,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: generateBottomSheetItem(),
                ),
              ));
        });
  }

  Widget menuBtn() {
    return RoundedBackgroundIcon(
      height: 34,
      width: 34,
      icon: Icon(
        SlydoAppIcon.menu,
        size: 16,
        color: blackFont,
      ),
      onTap: () {
        showUserProfileActionsSheet();
      },
      backgroundColor: iconBtnGrey,
      enableMargin: true,
    );
  }

  void selectShareOptionBottomSheet() {
    showModalBottomSheet<void>(
        backgroundColor: Colors.transparent,
        context: context,
        builder: (BuildContext context) {
          return Card(
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20)),
              ),
              color: Colors.white,
              margin: EdgeInsets.zero,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: generateBottomSheetItem(),
                ),
              ));
        });
  }

  List<Widget> generateBottomSheetItem() {
    final List<Widget> list = [];

    final PermissionType? hasPermission =
        userBloc.user.hasWritePermission(ProtectionPermission.product);

    list.add(
      bottomSheetItem(
        title: "Edit",
        iconData: SlydoAppIcon.edit,
        onTap: () async {
          if (hasPermission == PermissionType.WRITE) {
            Navigator.pop(context);
            final result = await Navigator.of(context).pushNamed(
              '/edit-service',
              arguments: {
                "serviceId": serviceId,
              },
            );

            if (result != null) {
              if (result is String) {
                if (result == "delete_item" || result == "update_item") {
                  //To refresh the service list page
                  Navigator.pop(context, 'update_item');
                }
              }
            }
          } else {
            showToast(
                message: AppLocalization.of(context)?.doNotPermission ?? "");
          }
        },
      ),
    );

    list.add(bottomSheetItem(
      title: "Share",
      iconData: SlydoAppIcon.share,
      onTap: () async {
        Navigator.pop(context);

        final shareBody =
            "http://slydo.co/store/${service?.provider}/services/${service?.id}";
        Share.share(
          shareBody,
          subject: messageDecoderWithEmoji(service?.name) ?? "",
        );
      },
    ));

    list.add(
      bottomSheetItem(
        isLast: true,
        title: "Share in Chat",
        iconData: SlydoAppIcon.text_message,
        onTap: () async {
          Navigator.pop(context);
          sendItemToUsersInChat();
        },
      ),
    );

    list.add(
      bottomSheetItem(
        isLast: true,
        title: "Share As A Yarn",
        iconData: SlydoAppIconNew.dashboard_yarn,
        onTap: () async {
          Navigator.pop(context);
          shareAsYarn();
        },
      ),
    );

    return list;
  }

  Future shareAsYarn() async {
    /*  AddYarnAndQuestion yarn = AddYarnAndQuestion();
    yarn.body = service?.name ?? "";
    yarn.attachment = {
      "service": service?.toJson().cast<String, dynamic>() ?? {}
    };
    bool data = await YarnAuth().addYarnAndQuestion(yarn);
    if (data) {
      showToast(message: "Share in Yarn successfully created");
    } */

    NavigationUtil.push(context,
        screen: ShareAsAyarnScreen(
            askCategories: yarnDashboardBloc.yarnCategories,
            shareAsYarnModel: ShareAsYarnModel.shareAsYarnModel,
            serviceModel: service,
            callback: (params) async {
              params
                ..attachment = {
                  "service": service?.toJson().cast<String, dynamic>() ?? {}
                };
              logger.d(params.toAddMap());
              final bool data =
                  await YarnAuth().addYarnAndQuestion(params, '', '');
              if (data) {
                showToast(message: "Shared in Yarn successfully");
              }
            }));
  }

  void sendItemToUsersInChat() async {
    final List<ChatConversation?> listOfRecipient =
        await ShareInChat().selectShareCustomer(context);
    debugPrint("Selected users = ${listOfRecipient.length}");

    final String url = AppConfig.baseUrl +
        "/api/v1/${service is Product ? "products" : "services"}/" +
        (service?.id ?? "") +
        "/";

    final Map<String, dynamic>? itemData =
        await ShoppingAuthService().getProductOrService(url);

    listOfRecipient.forEach((recipient) {
      addProductOrServiceToChat(
          item: service,
          itemData: itemData,
          recipientUser: recipient!,
          url: url);
    });
  }

  void addProductOrServiceToChat(
      {Map<String, dynamic>? itemData,
      required ChatConversation recipientUser,
      String? url,
      dynamic item}) async {
    final Map<String, dynamic> data = {
      "meta_data": jsonEncode(itemData),
      "check_id": const Uuid().v4(),
      "conversation_id": recipientUser.conversationId,
      "author": userBloc.user.userName,
      "message": url,
      "kind": item is Product ? "product" : "service",
      "created_at": DateTime.now().toUtc().toString(),
      "type": "chatroom_message",
    };
    await sendDataToSocket(data);
  }

  Widget goToCartWidget() {
    return RoundedBackgroundIcon(
      height: 34,
      width: 34,
      icon: badges.Badge(
        badgeContent: getBadgeContent(),
        position: badges.BadgePosition.topEnd(end: 0, top: 0),
        badgeAnimation: const badges.BadgeAnimation.rotation(
          animationDuration: Duration(seconds: 1),
          colorChangeAnimationDuration: Duration(seconds: 1),
          loopAnimation: false,
          curve: Curves.fastOutSlowIn,
          colorChangeAnimationCurve: Curves.easeInCubic,
        ),
        badgeStyle: badges.BadgeStyle(
            shape: badges.BadgeShape.circle,
            badgeColor: naturalGreen,
            padding: basketBloc.basketItems.length == 0
                ? const EdgeInsets.all(0)
                : const EdgeInsets.all(4)),
        child: Center(
          child: Icon(
            SlydoAppIcon.cart,
            size: 16,
            color: blackFont,
          ),
        ),
      ),
      onTap: () {
        NavigationUtil.pushNamed(context, routeName: Routes.SHOPPING_CART);
      },
      backgroundColor: iconBtnGrey,
      enableMargin: true,
    );
  }

  Widget getUserProfile() {
    return GestureDetector(
      child: userImageUserInitialsPic(
          service!.providerAvatar!, service!.providerFullName!, 15, 35),
      onTap: () async {
        Navigator.pushNamed(context, Routes.USER_PROFILE,
            arguments: {"searchedUserName": service?.provider});
      },
    );
  }

  Widget messageSellerWidget() {
    return RoundedBackgroundIcon(
      borderRadius: 16,
      height: 44,
      width: 44,
      icon: Icon(
        SlydoAppIcon.message,
        color: navyBlue,
        size: 22,
      ),
      backgroundColor: navyBlue.withOpacity(0.08),
      onTap: () {
        if (isValidCustomer) {
          Navigator.of(context).pushNamed(Routes.COMPOSE_MESSAGE, arguments: {
            'recipient': service?.provider,
            'subject': service?.name,
          });
        } else {
          showToast(message: "You can not message yourself !!");
        }
      },
    );
  }

  Widget addToCartWidget() {
    return RoundedBackgroundIcon(
      borderRadius: 16,
      height: 44,
      width: 44,
      icon: Icon(
        SlydoAppIcon.add_cart,
        color: service!.isAvailable! ? navyBlue : greyBorderColor,
        size: 22,
      ),
      backgroundColor: navyBlue.withOpacity(0.08),
      onTap: () async {
        showSnackbar(context, message: "Coming soon");
        // if (service?.isAvailable!) {
        //   if (isValidCustomer) {
        //     String type = service is Product ? "product" : "service";
        //     basketBloc.addItemToCart(item: service, type: type);
        //     late var mapData;
        //     basketBloc.items.forEach((element) {
        //       if (element["item"].id == service?.id) {
        //         mapData = element;
        //         return;
        //       }
        //     });
        //     Map data = {
        //       "type": type,
        //       "id": mapData["item"].id,
        //       "qty": mapData["qty"],
        //     };
        //     debugPrint("Data From Service Page : $data");
        //     await _auth.addItemToShoppingCart(data);
        //   } else {
        //     showToast(
        //         message:
        //             AppLocalization.of(context)!.youCanNotPurchaseThisItem);
        //   }
        // } else {
        //   showToast(message: AppLocalization.of(context)!.serviceOutOfStock);
        // }
      },
    );
  }

  Widget goToBasket() {
    return badges.Badge(
      badgeContent: getBadgeContent(),
      position: badges.BadgePosition.topEnd(end: 6, top: 6),
      badgeAnimation: const badges.BadgeAnimation.rotation(
        animationDuration: Duration(seconds: 1),
        colorChangeAnimationDuration: Duration(seconds: 1),
        loopAnimation: false,
        curve: Curves.fastOutSlowIn,
        colorChangeAnimationCurve: Curves.easeInCubic,
      ),
      badgeStyle: badges.BadgeStyle(
        shape: badges.BadgeShape.circle,
        badgeColor: naturalGreen,
        padding: basketBloc.basketItems.length == 0
            ? const EdgeInsets.all(0)
            : const EdgeInsets.all(4),
      ),
      child: IconButton(
        icon: const Icon(
          Icons.shopping_cart,
          color: Colors.white,
        ),
        onPressed: () {
          Navigator.of(context).pushNamedAndRemoveUntil(
            Routes.DASHBOARD,
            (Route<dynamic> route) => false,
            arguments: {"dashboardIndex": 2},
          );
        },
      ),
    );
  }

  Widget? getBadgeContent() {
    if (basketBloc.basketItems.length == 0) {
      return null;
    }
    return Text(
      getBadgeCount().toString(),
      style: const TextStyle(
          fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold),
    );
  }

  String getBadgeCount() {
    int totalItem = 0;
    basketBloc.basketItems.forEach((element) {
      totalItem = totalItem + int.parse(element.qty.toString());
    });
    return totalItem > 99 ? '99+' : totalItem.toString();
  }

  Widget floatingActionBar() {
    return Card(
      elevation: 10,
      shadowColor: boxShadowTwo,
      margin: EdgeInsets.zero,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8.0),
        child: Row(
          children: <Widget>[
            messageSellerWidget(),
            const SizedBox(
              width: 8,
            ),
            addToCartWidget(),
            const SizedBox(width: 8),
            _buildPayButtonWidget(),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceDetailsPage(BuildContext context) {
    if (serviceIsLoading) {
      return buildProductShimmerLoadingIndicator(isLoading: serviceIsLoading);
    }
    return ListView(
      controller: _scrollController,
      children: <Widget>[
        Column(
          children: [
            _buildServiceImagesWidgets(),
            Container(
              padding: const EdgeInsets.only(right: 16, left: 16, top: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  _buildServiceTitleAndPriceWidget(),
                  const SizedBox(
                    height: 24,
                  ),
                  Divider(
                    height: 0,
                    color: dividerColor,
                    thickness: 1,
                  ),
                  const SizedBox(
                    height: 12,
                  ),
                  _buildShortInfoWidget(),
                  const SizedBox(
                    height: 16,
                  ),
                  Divider(
                    height: 0,
                    color: dividerColor,
                    thickness: 1,
                  ),
                  const SizedBox(
                    height: 12,
                  ),
                  _buildAvailableFromAndShareWidgets(),
                  const SizedBox(
                    height: 16,
                  ),
                  Divider(
                    height: 0,
                    color: dividerColor,
                    thickness: 1,
                  ),
                  const SizedBox(
                    height: 12,
                  ),
                  _buildDescriptionWidget(),
                  const SizedBox(
                    height: 16,
                  ),
                  Divider(
                    height: 0,
                    color: dividerColor,
                    thickness: 1,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  _buildSellerInfoWidget(),
                  const SizedBox(
                    height: 10,
                  ),
                  _buildReviewList(),
                  const SizedBox(
                    height: 16,
                  ),
                  _buildWriteReview(),
                ],
              ),
            ),
            Divider(
              height: 0,
              color: dividerColor,
              thickness: 1,
            ),
            const SizedBox(
              height: 16,
            ),
            if (isOtherItemIsEmpty)
              Container()
            else
              _buildProviderOtherServices(),
            SizedBox(height: isValidCustomer ? 60.0 : 20),
          ],
        ),
      ],
    );
  }

  Widget buildReviewTitle() {
    return Text(
      reviewCount != null ? "Review ($reviewCount)" : "Reviews",
      style: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 14,
        color: blackFont,
      ),
    );
  }

  Widget _buildReviewList() {
    return reviewList.length == 0
        ? Center(
            child: Text(
              "No Review yet",
              style: TextStyle(
                color: blackFont,
                fontSize: 14,
                fontFamily: "Inter",
              ),
            ),
          )
        : Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  buildReviewTitle(),
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).pushNamed(Routes.REVIEW_LIST_SCREEN,
                          arguments: {"reviewedService": service});
                    },
                    child: Text(
                      "See all",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: navyBlue,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Column(
                children: reviewList
                    .map(
                      (review) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: ReviewTile(
                          review: review,
                          service: service,
                        ),
                      ),
                    )
                    .toList(),
              ),
            ],
          );
  }

  Widget _buildDescriptionWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "More Information",
          style: TextStyle(
              color: blackFont, fontSize: 12, fontWeight: FontWeight.bold),
        ),
        const SizedBox(
          height: 8,
        ),
        Text(
          messageDecoderWithEmoji(service?.description)!,
          style: TextStyle(
            fontSize: 14,
            color: darkGrey,
          ),
          textAlign: TextAlign.justify,
        ),
      ],
    );
  }

  Widget _buildWriteReview() {
    if (service?.provider == userBloc.user.userName) {
      return Container();
    }

    if (!canRate) {
      return Container();
    }

    return Column(
      children: [
        GestureDetector(
          onTap: () async {
            final result = await Navigator.of(context).pushNamed(
              Routes.ADD_REVIEW,
              arguments: {
                "service": service,
              },
            );

            if (result != null) {
              if (result is bool) {
                if (result) fetchReviewList();
              }
            }
          },
          child: Container(
            width: double.infinity,
            child: Center(
              child: Text(
                "Write a review",
                style: TextStyle(
                    color: navyBlue, fontWeight: FontWeight.w700, fontSize: 16),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildSellerInfoWidget() {
    return service?.providerAvatar == null
        ? Container()
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Provider",
                style: TextStyle(
                    color: blackFont,
                    fontSize: 12,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(
                height: 8,
              ),
              ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                leading: GestureDetector(
                  onTap: () {
                    Navigator.of(context).pushNamed(Routes.PHOTO_VIEWER,
                        arguments: service?.providerAvatar);
                  },
                  child: Container(
                    height: 48,
                    width: 48,
                    child: ClipOval(
                      child: CachedNetworkImage(
                        imageUrl: service!.providerAvatar!,
                        fit: BoxFit.fitHeight,
                        errorWidget: imageErrorWidget,
                        filterQuality: FilterQuality.high,
                      ),
                    ),
                  ),
                ),
                title: userNameWithVerifiedIcon(
                  name: service?.providerFullName ?? '',
                  isVerified: false,
                  textStyle: TextStyle(
                      fontSize: 14,
                      color: blackFont,
                      fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  service?.provider ?? "",
                  style: TextStyle(
                    fontSize: 12,
                    color: darkGrey,
                  ),
                  textAlign: TextAlign.justify,
                ),
                onTap: () {
                  Navigator.pushNamed(context, Routes.USER_PROFILE,
                      arguments: {"searchedUserName": service?.provider});
                },
              ),
            ],
          );
  }

  Widget _buildServiceImagesWidgets() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: imgList?.length == 0
          ? AspectRatio(
              aspectRatio: 1.5,
              child: Center(
                child: CircularLoadingIndicator(),
              ),
            )
          : imgList?.length == 1
              ? Stack(
                  children: [
                    AspectRatio(
                      aspectRatio: 1.5,
                      child: Container(
                        child: Center(
                          child: ClipRRect(
                            borderRadius:
                                const BorderRadius.all(Radius.circular(10)),
                            child: CachedNetworkImage(
                              placeholder: (context, url) =>
                                  Center(child: CircularLoadingIndicator()),
                              imageUrl: imgList![0]!,
                              fit: BoxFit.cover,
                              height: double.infinity,
                              width: double.infinity,
                              errorWidget: productAndServiceBigErrorWidget,
                            ),
                          ),
                        ),
                      ),
                    ),
                    serviceStockAndDetailTag(),
                    // getOutOfStockTag(),
                  ],
                )
              : Column(
                  children: <Widget>[
                    Stack(
                      children: <Widget>[
                        CarouselSlider(
                          options: CarouselOptions(
                              enableInfiniteScroll: false,
                              viewportFraction: 1.0,
                              enlargeCenterPage: true,
                              autoPlay: false,
                              aspectRatio: 1.5,
                              onPageChanged: (index, _) {
                                if (mounted) {
                                  setState(() {
                                    _current = index;
                                  });
                                }
                              }),
                          items: imgList!
                              .map((item) => Stack(
                                    children: [
                                      Container(
                                        child: Center(
                                          child: ClipRRect(
                                            borderRadius:
                                                const BorderRadius.all(
                                                    Radius.circular(10)),
                                            child: CachedNetworkImage(
                                              placeholder: (context, url) => Center(
                                                  child:
                                                      CircularLoadingIndicator()),
                                              imageUrl: item!,
                                              errorWidget:
                                                  productAndServiceBigErrorWidget,
                                              fit: BoxFit.cover,
                                              height: double.infinity,
                                              width: double.infinity,
                                            ),
                                          ),
                                        ),
                                      ),
                                      serviceStockAndDetailTag(),
                                      // getOutOfStockTag(),
                                    ],
                                  ))
                              .toList(),
                        ),
                        Positioned(
                          bottom: 0,
                          left: MediaQuery.of(context).size.width / 2 -
                              (5 * imgList!.length),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: imgList!.map((url) {
                              final int index = imgList!.indexOf(url);
                              return Container(
                                width: 5.0,
                                height: 5.0,
                                margin: const EdgeInsets.symmetric(
                                    vertical: 10.0, horizontal: 2.0),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: _current == index
                                      ? navyBlue
                                      : navyBlueLight,
                                ),
                              );
                            }).toList(),
                          ),
                        )
                      ],
                    ),
                  ],
                ),
    );
  }

  Widget serviceStockAndDetailTag() {
    if (service?.availableFrom?.isAfter(DateTime.now()) ?? false) {
      return Positioned(
        top: 20,
        right: 10,
        child: showColoredLabeledWidget(
            text: AppLocalization.of(context)!.comingSoon, color: starYellow),
      );
    } else if (service?.isAvailable == false) {
      return Positioned(
        top: 20,
        right: 10,
        child: showColoredLabeledWidget(
            text: AppLocalization.of(context)!.outOfStock, color: red),
      );
    } else {
      return const SizedBox();
    }
  }

  Widget getOutOfStockTag() {
    if (!service!.isAvailable!) {
      return Positioned(
        left: 8,
        top: 8,
        child: getColoredLabeledWidget(
            text: AppLocalization.of(context)!.outOfStock, color: starYellow),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildServiceTitleAndPriceWidget() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                //name,
                messageDecoderWithEmoji(service?.name)!,
                style: TextStyle(
                    fontSize: 16,
                    color: blackFont,
                    fontWeight: FontWeight.bold),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      worldCurrencies[service?.currency!]!,
                      style: TextStyle(
                          fontFamily: "Inter",
                          fontSize: 18.0,
                          color: navyBlue,
                          fontWeight: FontWeight.bold),
                    ),
                    Text(
                      moneyDisplayNormalizer(
                          int.parse(service?.price.toString() ?? "")),
                      style: TextStyle(
                          fontSize: 18.0,
                          color: navyBlue,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 5),
              getRating(
                numberOfRating: service?.rating?.toInt(),
              ),
            ],
          ),
        ),
        copyQrCode(),
      ],
    );
  }

  Widget copyQrCode() {
    return Card(
      shadowColor: boxShadow,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: EdgeInsets.zero,
      child: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: dividerColor)),
        padding: const EdgeInsets.all(10),
        child: InkWell(
          child: service?.qrCode == ""
              ? Center(child: CircularLoadingIndicator())
              : GestureDetector(
                  onTap: () {
                    Navigator.of(context).pushNamed(Routes.PHOTO_VIEWER,
                        arguments: service?.qrCode);
                  },
                  child: CachedNetworkImage(
                    imageUrl: service?.qrCode ?? "",
                    height: 40,
                    width: 40,
                    errorWidget: imageErrorWidget,
                    filterQuality: FilterQuality.high,
                    fit: BoxFit.fill,
                    placeholder: (context, url) =>
                        Center(child: CircularLoadingIndicator()),
                  ),
                ),
          onTap: () {
            Clipboard.setData(ClipboardData(text: service?.qrCode!));
            showToast(message: AppLocalization.of(context)!.copied);
          },
        ),
      ),
    );
  }

  Widget _buildShortInfoWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Description",
          style: TextStyle(
              color: blackFont, fontSize: 12, fontWeight: FontWeight.bold),
        ),
        const SizedBox(
          height: 8,
        ),
        Row(
          children: <Widget>[
            Expanded(
              child: Text(
                messageDecoderWithEmoji(service!.shortDescription)!,
                style: TextStyle(
                  color: darkGrey,
                  fontSize: 14,
                ),
                textAlign: TextAlign.justify,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAvailableFromAndShareWidgets() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Date",
          style: TextStyle(
              color: blackFont, fontSize: 12, fontWeight: FontWeight.bold),
        ),
        const SizedBox(
          height: 8,
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10), color: lightGrey),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Icon(
                SlydoAppIcon.date,
                color: Colors.black,
                size: 16,
              ),
              const SizedBox(
                width: 8.0,
              ),
              Text(
                "${service?.availableFrom!.day}/${service!.availableFrom!.month}/${service!.availableFrom!.year}",
                style: TextStyle(
                  color: blackFont,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProviderOtherServices() {
    return Container(
      height: 290,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  AppLocalization.of(context)!.providersOtherService,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: blackFont,
                  ),
                ),
                GestureDetector(
                  child: Text(
                    AppLocalization.of(context)!.seeAll,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: navyBlue,
                    ),
                  ),
                  onTap: () {
                    Navigator.pushNamed(context, Routes.USER_PROFILE,
                        arguments: {
                          "searchedUserName": service!.provider,
                          "index": 3
                        });
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: sellersOtherItems.length,
              scrollDirection: Axis.horizontal,
              separatorBuilder: (context, index) {
                return const SizedBox(width: 15);
              },
              itemBuilder: (context, index) => DisplayService(
                service: sellersOtherItems[index],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPayButtonWidget() {
    return Expanded(
      child: CurvedButton(
        isPaymentBtn: true,
        backgroundColor: service!.isAvailable! ? navyBlue : greyBorderColor,
        textColor: Colors.white,
        text: "PAY NOW",
        onPressed: () async {
          showSnackbar(context, message: "Coming soon");
          // if (service!.isAvailable!) {
          //   if (isValidCustomer) {
          //     bool result = await showDisclaimerDialogueForGoods(context);
          //     if (result) {
          //       getRecipient();
          //       navigateToSendPayment();
          //     }
          //   } else {
          //     showToast(
          //         message:
          //             AppLocalization.of(context)!.youCanNotPurchaseThisItem);
          //   }
          // } else {
          //   showToast(message: AppLocalization.of(context)!.serviceOutOfStock);
          // }
        },
      ),
    );
  }

  // Pull the user from the server
  void getRecipient() async {
    customerProfileBloc.customer =
        await UserAuth().fetchCustomerProfile(service!.provider);
  }

  void navigateToSendPayment() {
    basketBloc.productOrService.clear();
    final Map<dynamic, dynamic> result = {
      "type": 'service',
      "results": service!.toJson()
    };

    basketBloc.buyProductOrServiceNow('service', result);
    NavigationUtil.push(context, screen: const CheckoutProductService());
  }

  @override
  void dispose() {
    imgList!.clear();
    _scrollController.dispose();
    super.dispose();
  }
}
