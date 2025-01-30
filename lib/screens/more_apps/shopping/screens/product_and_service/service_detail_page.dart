import 'dart:convert';

import 'package:Slydo/constant.dart';
import 'package:Slydo/data/currency.dart';
import 'package:Slydo/data/environment.dart';
import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/main.dart';
import 'package:Slydo/routes/route_constants.dart';
import 'package:Slydo/screens/messaging/chat/models/chat_conversation.dart';
import 'package:Slydo/screens/messaging/chat/share_in_chat/share_in_chat.dart';
import 'package:Slydo/screens/more_apps/shopping/models/store.dart';
import 'package:Slydo/screens/more_apps/shopping/screens/product_and_service/checkout_product_service.dart';
import 'package:Slydo/screens/more_apps/shopping/screens/product_and_service/utils.dart';
import 'package:Slydo/screens/more_apps/shopping/shopping_auth.dart';
import 'package:Slydo/screens/review/models/review.dart';
import 'package:Slydo/screens/review/review_auth.dart';
import 'package:Slydo/screens/review/tiles/review_tile.dart';
import 'package:Slydo/screens/user_profile/models/user.dart';
import 'package:Slydo/screens/user_profile/screens/user_profile_module_new/profile_template/utils.dart';
import 'package:Slydo/screens/user_profile/user_auth.dart';
import 'package:Slydo/screens/yarn/models/share_as_yarn_model.dart';
import 'package:Slydo/screens/yarn/share_as_a_yarn_screen.dart';
import 'package:Slydo/screens/yarn/yarn_auth.dart';
import 'package:Slydo/screens/yarn/yarn_dashboard_bloc.dart';
import 'package:Slydo/utils/navigation_util.dart';
import 'package:Slydo/utils/slydo_app_icon_icons.dart';
import 'package:Slydo/utils/slydo_app_icon_new_icons.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/bottom_sheet_item.dart';
import 'package:Slydo/widget/cart_with_badge.dart';
import 'package:Slydo/widget/curved_btn.dart';
import 'package:Slydo/widget/item_display_card.dart';
import 'package:Slydo/widget/loading_indicator.dart';
import 'package:Slydo/widget/rounded_background_icon.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart' as cs;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:uuid/uuid.dart';

// ignore: must_be_immutable
class ServiceDetailPage extends StatefulWidget {
  final dynamic arguments;

  const ServiceDetailPage({super.key, required this.arguments});

  @override
  State<ServiceDetailPage> createState() => _ServiceDetailPageState();
}

class _ServiceDetailPageState extends State<ServiceDetailPage>
    with TickerProviderStateMixin {
  bool canRate = false;
  // late DashboardBloc _dashboardBloc;
  bool noReviewInList = false;

  Service? service;
  late CustomerProfileBloc customerProfileBloc;
  late UserBloc userBloc;
  late BasketBloc basketBloc;
  List<String?>? displayServiceImage = [];
  int selectedIndex = 0;
  bool isSelected = true;

  final _auth = ShoppingAuthService();

  late bool isValidCustomer;
  bool isOtherItemFetched = false;
  bool isOtherItemIsEmpty = true;
  final ScrollController _scrollController = ScrollController();

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
    service = widget.arguments['service'];
    if (service != null) {
      serviceId = service?.id;
    } else {
      serviceId = widget.arguments['serviceId'];
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
    // debugPrint('SERVICE ID :: $serviceId');

    if (mounted) {
      setState(() {
        serviceIsLoading = true;
      });
    }
    _auth.getService(serviceId).then((value) {
      if (mounted) {
        service = value;
        displayServiceImage = service?.serverImages;
        serviceIsLoading = false;
        if (mounted) setState(() {});
      }
    }).catchError((e) {
      if (mounted) {
        setState(() {
          serviceIsLoading = false;
        });
      }
      Navigator.pop(context);
      showToast(message: e.toString());
    });
  }

  Future canReviewService() async {
    final Map<String, String> data = {};
    data['provider'] = service?.provider ?? "";
    data['buyer'] = userBloc.user.userName!;
    data['type'] = 'services';
    data['id'] = service?.id ?? "";

    // debugPrint('service data :: $data');

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
      final List tempList =
          value.containsKey('results') ? value['results'] as List : [];
      value.containsKey('count') ? reviewCount = value["count"] : 0;
      canRate = value['can_rate'];

      reviewList = [];
      for (var element in tempList) {
        reviewList.add(Review.fromJson(element));
      }

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
        backgroundColor: lightGrey,
        appBar: appBar() as PreferredSizeWidget?,
        floatingActionButton: isValidCustomer ? floatingActionBar() : null,
        body: _buildServiceDetailsPage(context),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      ),
    );
  }

  Widget appBar() {
    return AppBar(
      surfaceTintColor: Colors.transparent,
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
        if (isValidCustomer) goToCartWidget() else Container(),
        const SizedBox(
          width: 15,
        ),
        menuBtn(),
        const SizedBox(width: 15),
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
      backgroundColor: transparent,
      enableMargin: false,
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
            final result = await Navigator.pushNamed(
              context,
              Routes.ADD_EDIT_SERVICE,
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
        iconData: SlydoAppIcon.textMessage,
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
        iconData: SlydoAppIconNew.dashboardYarn,
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
        screen: ShareAsYarnScreen(
            askCategories: yarnDashboardBloc.yarnCategories,
            shareAsYarnModel: ShareAsYarnModel.shareAsYarnModel,
            serviceModel: service,
            callback: (params) async {
              params.attachment = {
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
    // debugPrint("Selected users = ${listOfRecipient.length}");

    final String url =
        "${AppConfig.baseUrl}/api/v1/${service is Product ? "products" : "services"}/${service?.id ?? ""}/";

    final Map<String, dynamic>? itemData =
        await ShoppingAuthService().getProductOrService(url);

    for (var recipient in listOfRecipient) {
      addProductOrServiceToChat(
          item: service,
          itemData: itemData,
          recipientUser: recipient!,
          url: url);
    }
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
    return CartWithBadge(
      items: basketBloc.basketItems,
      height: 30,
      width: 30,
      backgroundColor: transparent,
      enableMargin: true,
      onTap: () {
        NavigationUtil.pushNamed(context, routeName: Routes.SHOPPING_CART);
      },
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
        SlydoAppIcon.addCart,
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
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 5.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildImageAndTag(),
              const SizedBox(height: 5),
              if (displayServiceImage!.length > 1)
                _buildHorizontalServiceImageList()
              else
                const SizedBox(),
              const SizedBox(height: 10),
              _buildServiceTitleAndPriceWidget(),
              const SizedBox(height: 10),
              _buildAvailableFromAndShareWidgets(),
              const SizedBox(height: 12),
              _buildShortInfoWidget(),
              const SizedBox(height: 12),
              getHorizontalDivider(),
              const SizedBox(height: 12),
              _buildDescriptionWidget(),
              const SizedBox(height: 12),
              getHorizontalDivider(),
              const SizedBox(height: 12),
              getProductOrServiceSocialMedia(
                  context, "Service", service?.id ?? ""),
              const SizedBox(height: 12),
              getHorizontalDivider(),
              const SizedBox(height: 12),
              _buildSellerInfoWidget(),
              const SizedBox(height: 12),
              getHorizontalDivider(),
              const SizedBox(height: 10),
              _buildReviewList(),
              const SizedBox(height: 12),
              _buildWriteReview(),
              getHorizontalDivider(),
              const SizedBox(height: 12),
              if (isOtherItemIsEmpty)
                Container()
              else
                _buildProviderOtherServices(),
              SizedBox(height: isValidCustomer ? 60.0 : 20),
            ],
          ),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            buildReviewTitle(),
            if (reviewList.isNotEmpty)
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
        if (reviewList.isEmpty)
          Center(
            child: Column(
              children: [
                Image.asset(
                  "assets/images/reviews.png",
                  height: 100,
                  width: 100,
                ),
                Text(
                  "No review to show",
                  style: TextStyle(
                    color: blackFont,
                    fontSize: 16,
                    fontFamily: "Inter",
                  ),
                ),
              ],
            ),
          )
        else
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
          "Description",
          style: TextStyle(
            color: blackFont,
            fontSize: 14,
            fontWeight: FontWeight.bold,
            fontFamily: "Inter",
          ),
        ),
        const SizedBox(
          height: 8,
        ),
        displayQuillFormattedText(
            context, service?.description ?? "", darkGrey, 14, FontWeight.w400),
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
          child: SizedBox(
            width: double.infinity,
            child: Center(
              child: Text(
                "Write a review",
                style: TextStyle(
                  color: navyBlue,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  fontFamily: "Inter",
                ),
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
                "Merchant",
                style: TextStyle(
                  color: blackFont,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  fontFamily: "Inter",
                ),
              ),
              ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                leading: GestureDetector(
                  onTap: () {
                    Navigator.of(context).pushNamed(Routes.PHOTO_VIEWER,
                        arguments: service?.providerAvatar);
                  },
                  child: SizedBox(
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

  Widget _buildImageAndTag() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
      ),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      child: Column(
        children: [
          _buildServiceImagesWidgets(),
          serviceStockAndDetailTag(),
        ],
      ),
    );
  }

  Widget _buildServiceImagesWidgets() {
    return displayServiceImage?.isEmpty ?? false
        ? AspectRatio(
            aspectRatio: 1.5,
            child: Center(
              child: CircularLoadingIndicator(),
            ),
          )
        : displayServiceImage?.length == 1
            ? CachedNetworkImage(
                height: MediaQuery.of(context).size.width - 50,
                width: double.infinity,
                placeholder: (context, url) =>
                    Center(child: CircularLoadingIndicator()),
                imageUrl: displayServiceImage![0]!,
                fit: BoxFit.cover,
                errorWidget: productAndServiceBigErrorWidget,
              )
            : Column(
                children: [
                  Stack(
                    children: [
                      cs.CarouselSlider.builder(
                        key: ValueKey<int>(selectedIndex),
                        options: cs.CarouselOptions(
                          initialPage: selectedIndex,
                          enableInfiniteScroll: false,
                          viewportFraction: 1.0,
                          enlargeCenterPage: true,
                          autoPlay: false,
                          height: MediaQuery.of(context).size.width - 50,
                          onPageChanged: (index, _) {
                            setState(() {
                              selectedIndex = index;
                            });
                            _current = index;
                          },
                        ),
                        itemCount: displayServiceImage?.length,
                        itemBuilder: (context, index, realIndex) {
                          final item = displayServiceImage?[index];
                          return Center(
                            child: CachedNetworkImage(
                              placeholder: (context, url) => Center(
                                child: CircularLoadingIndicator(),
                              ),
                              imageUrl: item ?? "",
                              fit: BoxFit.cover,
                              height: MediaQuery.of(context).size.width - 50,
                              width: double.infinity,
                              errorWidget: productAndServiceBigErrorWidget,
                            ),
                          );
                        },
                      ),
                      Positioned(
                        bottom: 10,
                        left: 0,
                        right: 0,
                        child: Align(
                          alignment: Alignment.center,
                          child: Container(
                            decoration: BoxDecoration(
                              color: bgLightGrey,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            padding: const EdgeInsets.all(7),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _buildServiceCustomTabPhotoAndVideo(
                                  onTap: () {
                                    _onServiceTabSelected(0);
                                  },
                                  text:
                                      "Photo ${selectedIndex + 1}/${displayServiceImage?.length}",
                                  backgroundColor: white,
                                  // backgroundColor:
                                  //     selectedIndex == 0 ? transparent : white,
                                ),
                                // video
                                // _buildCustomTabPhotoAndVideo(
                                //     onTap: () {
                                //       _onTabSelected(1);
                                //     },
                                //     text: "Video",
                                //     backgroundColor: selectedIndex == 1
                                //         ? transparent
                                //         : white),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              );
  }

  Widget _buildServiceCustomTabPhotoAndVideo(
      {void Function()? onTap, Color? backgroundColor, String? text}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
          child: Text(
            text ?? "",
            style: TextStyle(
              fontSize: 12,
              color: blackFont,
              fontWeight: FontWeight.w600,
              fontFamily: 'Inter',
            ),
          ),
        ),
      ),
    );
  }

  void _onServiceTabSelected(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  Widget _buildHorizontalServiceImageList() {
    return Container(
      height: 50,
      alignment: Alignment.center,
      child: ListView.builder(
        shrinkWrap: true,
        scrollDirection: Axis.horizontal,
        itemCount: displayServiceImage?.length ?? 0,
        itemBuilder: (context, index) {
          final String? imageUrl = displayServiceImage?[index];
          isSelected = selectedIndex == index;

          return GestureDetector(
            onTap: () {
              setState(() {
                selectedIndex = index;
                _current = index;
              });
            },
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 5.0),
              foregroundDecoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                border:
                    isSelected ? Border.all(color: black, width: 1.2) : null,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(3),
                child: CachedNetworkImage(
                  placeholder: (context, url) =>
                      Center(child: CircularLoadingIndicator()),
                  imageUrl: imageUrl ?? "",
                  height: 50,
                  width: 50,
                  fit: BoxFit.cover,
                  errorWidget: productAndServiceBigErrorWidget,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget serviceStockAndDetailTag() {
    if (service?.availableFrom?.isAfter(DateTime.now()) ?? false) {
      return SizedBox(
        width: double.infinity,
        height: 30,
        child: showColoredLabeledWidgetService(
          date: formatDate1(service?.availableFrom),
          service: service,
          text: AppLocalization.of(context)!.comingSoon,
          color: lightYellow,
          fontSize: 14,
          verticalPadding: 8,
        ),
      );
    } else if (service?.isAvailable == false) {
      return SizedBox(
        width: double.infinity,
        height: 30,
        child: showColoredLabeledWidgetService(
          service: service,
          text: AppLocalization.of(context)!.outOfStock,
          color: lightRed,
          fontSize: 14,
          verticalPadding: 8,
        ),
      );
    } else if ((service?.discountedPrice != null &&
            service?.discountedPrice != 0) ||
        (service?.pricePercentageChange != null &&
            service?.pricePercentageChange != 0.0)) {
      return buildServiceDiscountPrice();
    } else {
      return const SizedBox();
    }
  }

  Widget buildServiceDiscountPrice() {
    if (service?.discountedPrice != null && service?.discountedPrice != 0) {
      if (service?.checkServiceDiscount() ?? false) {
        return SizedBox(
          width: double.infinity,
          height: 30,
          child: showDiscountValue(
            service?.discountType ?? "",
            service?.discountValue ?? 0,
            service?.currency,
            verticalPadding: 8,
            fontSize: 14,
          ),
        );
      } else {
        return const SizedBox();
      }
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
                  fontSize: 18,
                  color: blackFont,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Inter',
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    worldCurrencies[service?.currency!]!,
                    style: TextStyle(
                      fontFamily: "Inter",
                      fontSize: 16.0,
                      color: navyBlue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    moneyDisplayNormalizer(
                        int.parse(service?.price.toString() ?? "")),
                    style: TextStyle(
                      fontSize: 16.0,
                      color: navyBlue,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Inter',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  getRating(
                    numberOfRating: service?.rating?.toInt(),
                    starSize: 14,
                  ),
                  const SizedBox(width: 5),
                  _getServiceReviews(),
                ],
              ),
            ],
          ),
        ),
        qrCodeIcon(
            context, service!.getNavigationData(), service!.getQRCodeInfo()),
      ],
    );
  }

  Widget _getServiceReviews() {
    if ((service?.reviewScore ?? 0) != 0) {
      return Text(
        "(${service?.reviewScore} ${(service?.reviewScore ?? 0) <= 1 ? 'review' : 'reviews'})",
        style: TextStyle(
          fontWeight: FontWeight.w400,
          fontSize: 12,
          fontFamily: 'Inter',
          color: fontLightGrey,
        ),
      );
    } else {
      return const SizedBox.shrink();
    }
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
            Clipboard.setData(ClipboardData(text: service?.qrCode ?? ""));
            showToast(message: AppLocalization.of(context)!.copied);
          },
        ),
      ),
    );
  }

  Widget _buildShortInfoWidget() {
    return Text(
      messageDecoderWithEmoji(service!.shortDescription)!,
      style: TextStyle(
        color: fontLightGrey,
        fontSize: 14,
        fontFamily: "Inter",
        fontWeight: FontWeight.w400,
      ),
      softWrap: true,
      textAlign: TextAlign.justify,
    );
  }

  Widget getHorizontalDivider() {
    return Divider(
      height: 0,
      color: dividerColor,
      thickness: 1,
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(
              AppLocalization.of(context)!.providersOtherService,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: blackFont,
                fontFamily: "Inter",
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
                Navigator.pushNamed(context, Routes.USER_PROFILE, arguments: {
                  "searchedUserName": service!.provider,
                  "index": 3
                });
              },
            ),
          ],
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const AlwaysScrollableScrollPhysics(),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: sellersOtherItems
                .map(
                  (element) => Padding(
                    padding: const EdgeInsets.only(right: 7.0),
                    child: DisplayService(
                      service: element,
                    ),
                  ),
                )
                .toList(),
          ),
        ),
      ],
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
    displayServiceImage!.clear();
    _scrollController.dispose();
    super.dispose();
  }
}
