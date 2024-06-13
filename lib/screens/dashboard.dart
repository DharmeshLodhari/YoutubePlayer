import 'dart:async';
import 'dart:convert';

import 'package:Slydo/data/database_helper.dart';
import 'package:Slydo/data/socket_provider.dart';
import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/routes/route_constants.dart';
import 'package:Slydo/screens/more_apps/messaging/chat/helpers/chat_message_synchronizer.dart';
import 'package:Slydo/screens/more_apps/messaging/chat/helpers/main_socket_message_handler.dart';
import 'package:Slydo/screens/more_apps/messaging/chat/models/chat_conversation.dart';
import 'package:Slydo/screens/more_apps/messaging/message_auth.dart';
import 'package:Slydo/screens/more_apps/payment_and_banking/payment_and_banking_auth.dart';
import 'package:Slydo/screens/more_apps/shopping/models/store.dart';
import 'package:Slydo/screens/more_apps/user_profile/user_auth.dart';
import 'package:Slydo/screens/super_store/super_store_home.dart';
import 'package:Slydo/services/awesome_notification_service.dart';
import 'package:Slydo/services/fcm_push_notification.dart';
import 'package:Slydo/services/list_refresher.dart';
import 'package:Slydo/services/logout_helper.dart';
import 'package:Slydo/services/share_manager.dart';
import 'package:Slydo/services/uni_links_service.dart';
import 'package:Slydo/utils/extensions.dart';
import 'package:Slydo/utils/global_key.dart';
import 'package:Slydo/utils/navigation_util.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/dialog.dart';
import 'package:Slydo/widget/keep_alive_page.dart';
import 'package:Slydo/widget/loading_indicator.dart';
import 'package:Slydo/widget/rounded_background_icon.dart';
import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:badges/badges.dart' as badges;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import 'connection_module/connections_dashboard.dart';
import 'home.dart';
import 'moments/screens/moment_detail/moment_detail_page.dart';
import 'moments/screens/moments_service.dart';
import 'more_apps/messaging/chat/helpers/chat_user_manager.dart';
import 'more_apps/messaging/chat/helpers/connection_list_synchronizer.dart';
import 'more_apps/settings/general_setting.dart';
import 'more_apps/yarn/yarn_auth.dart';
import 'more_apps/yarn/yarn_dashboard_bloc.dart';

// ignore: must_be_immutable
class Dashboard extends StatefulWidget {
  final dynamic arguments;

  const Dashboard({super.key, this.arguments});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  //newUI Variables
  late DashboardBloc _dashboardBloc;
  final DatabaseHelper _db = DatabaseHelper();

  int _currentIndex = 0;
  List<Widget>? screens;
  late UserBloc userBloc;
  late BasketBloc basketBloc;
  late YarnDashboardBloc yarnDashboardBloc;

  MainSocketProvider? mainSocketProvider;
  StreamSubscription? streamSubscription;

  bool? isNFCPermissionAccepted;
  late AppLocalization appLocalization;
  var _bottomNavIndex = 0; //default index of a first screen

  final iconList = [
    'home/home',
    'home/super_store',
    'home/chat_one',
    'home/settings',
  ];

  var list = ['Home', 'Store', 'Chat', 'Settings'];
  List<Widget> _pages = [Container(), Container(), Container(), Container()];

  @override
  void initState() {
    UniLinksService.init();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      // ShareManager().initializeShareManager();

      _pages = const [
        KeepAlivePage(wantKeepAlive: false, child: Home()),
        SuperStoreHome(),
        KeepAlivePage(wantKeepAlive: true, child: ConnectionDashboard()),
        GeneralSettingScreen(),
      ];
      setState(() {});
    });

    if (mounted) MainSocketMessageHandler().dispose();
    if (mounted) {
      setState(() {
        if (widget.arguments != null) {
          final int? indexFromRoute = widget.arguments['dashboardIndex'];

          if (indexFromRoute != null) {
            setState(() {
              _currentIndex = indexFromRoute;
            });
          }
        }
      });
    }

    getAllCategories();
    // getProductCategories(); // not in use

    PushNotificationService().initialize();
    ListRefresher().initialize();
    getFeeStructureData();

    fetchConnections();

    // checkNotificationToNavigate();
    MyGlobals.notificationStream?.cancel();
    listenNotificationTap();

    super.initState();
  }

  /// Handles fetching of all categories
  void getAllCategories() async {
    final Map<String, dynamic>? result =
        await YarnAuth().getAllCategories("", "");

    if (result != null && mounted) {
      yarnDashboardBloc.addCategories(result['results']);
    }
  }

  void getProductCategories() async {
    final Map<String, dynamic>? result =
        await YarnAuth().getProductCategories("", "");
    if (result != null && mounted) {
      yarnDashboardBloc.addProductCategories(result['results']);
    }
  }

  void fetchConnections() async {
    final ConnectionListBloc connectionListBloc =
        Provider.of<ConnectionListBloc>(myGlobals.navigationKey.currentContext!,
            listen: false);

    final BackgroundFetchStopBloc backgroundFetchStopBloc =
        Provider.of<BackgroundFetchStopBloc>(
            myGlobals.navigationKey.currentContext!);

    /// to show updating Messaging in connection list
    ChatMessageSynchronizer().updateFetchStream(isFetching: true);

    final int result = await connectionListBloc.getConnectionsCount();
    debugPrint("CONNECTION LIST LENGTH:- $result");
    if (result == 0) {
      await ConnectionSynchronizer().fetch(isRefresh: true);

      final int result = await connectionListBloc.getConnectionsCount();
      debugPrint("CONNECTION LIST LENGTH:- $result");

      for (int i = 0; i < connectionListBloc.connectionUsers.length; i++) {
        if (backgroundFetchStopBloc.isAllowed) {
          await ChatMessageSynchronizer().getMessages(
              chatConversation: connectionListBloc.connectionUsers[i],
              isFirstTime: true);
        } else {
          break;
        }
      }
    } else {
      await ConnectionSynchronizer().update();
      await ChatMessageSynchronizer().syncMessages(fetchFresh: true);
    }
    ChatMessageSynchronizer().updateFetchStream(isFetching: false);
  }

  void initializeListener() {
    streamSubscription?.cancel();
    streamSubscription = mainSocketProvider?.socketStream?.listen((event) {
      MainSocketMessageHandler(message: event);
      if (mounted) setState(() {});
    });
  }

  void listenNotificationTap() async {
    MyGlobals.notificationStream = AwesomeNotificationService()
        .notificationActionStream!
        .listen((receivedNotification) async {
      debugPrint("action:-  ${receivedNotification.buttonKeyPressed}");
      debugPrint("data:-  ${receivedNotification.payload}");

      final Map<String, dynamic>? payload = receivedNotification.payload;

      if (receivedNotification.buttonKeyPressed == "reject_nudge") {
        final Map<String, dynamic> data = {
          "check_id": const Uuid().v4(),
          "conversation_id": payload!['conversation_id'],
          "author": payload['recipient'],
          "recipient": payload['author'],
          "created_at": DateTime.now().toUtc().toString(),
          "acknowledgement_type": "Canceled",
          "type": "stop_nudging",
        };
        try {
          MessageAuth().sendStopNudge(dataToSend: data);
        } catch (error) {
          debugPrint("ERROR:- $error");
        }
      } else if (receivedNotification.buttonKeyPressed == "accept_nudge") {
        // saveNudgeNotification(receivedNotification.payload);

        WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
          navigateToNotification(receivedNotification.toMap());
        });
      } else {
        debugPrint("===> ${receivedNotification.toMap()}");

        // saveNotification(payload);
        WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
          navigateToNotification(receivedNotification.toMap());
        });
      }
    });
  }

  /*
  * Navigation for Local Notification (e.g nudge notification), we can create our
  * custom UI with this notification. On the notification bar this shows 'accept' or
  * 'cancel'
  * */
  void navigateToNotification(Map<String, dynamic> data) async {
    /// {id: 31386,
    /// channelKey: basic_channel,
    /// title: Slydo Notification,
    /// body: test1,
    /// summary: null,
    /// showWhen: true,
    /// icon: null,
    /// payload:
    /// {image: https://slydo-assets.s3.amazonaws.com/media/customer/avatar/b1a8773527284446a45e9dd31924c5e8.jpg,
    /// notification_id: 31386,
    /// body: test1,
    /// title: Slydo Notification,
    /// priority: normal,
    /// type: chatroom_message,
    /// actions: /chat-screen/09700559-3aa6-4d71-bd4b-748322e49fdb},
    /// largeIcon: https://slydo-assets.s3.amazonaws.com/media/customer/avatar/b1a8773527284446a45e9dd31924c5e8.jpg,
    /// bigPicture: null,
    /// autoCancel: true,
    /// privacy: Private,
    /// color: null,
    /// backgroundColor: null,
    /// createdSource: Local,
    /// createdLifeCycle: Background,
    /// displayedLifeCycle: Background,
    /// createdDate: 2021-09-03 12:29:40,
    /// displayedDate: 2021-09-03 12:29:40,
    /// actionDate: 2021-09-03 12:30:51,
    /// dismissedDate: null,
    /// actionLifeCycle: AppKilled,
    /// dismissedLifeCycle: null,
    /// buttonKeyPressed: null, buttonKeyInput: null}
    ///
    debugPrint('NOTIFICAITON TYPE --> $data');

    final Map<String, dynamic> notification = data['payload'] is String
        ? jsonDecode(data['payload'])
        : data['payload'];

    debugPrint('NOTIFICAITON TYPE --> ${notification['type']}');

    if (notification['type'] == "chatroom_message" ||
        notification['type'] == "nudge_user") {
      final String? recipientUsername =
          notification['actions'].replaceAll("/chat-screen/", "");
      debugPrint("Recipient user name = $recipientUsername");

      if (recipientUsername != null) {
        showDialog(
            context: MyGlobals().navigationKey.currentContext!,
            builder: (context) => Center(child: CircularLoadingIndicator()));

        final ChatConversation chatConversation =
            await UserAuth().fetchContactProfile(recipientUsername);

        Navigator.of(MyGlobals().navigationKey.currentContext!)
            .popUntil(ModalRoute.withName(Routes.DASHBOARD));
        Navigator.pushNamed(
            MyGlobals().navigationKey.currentContext!, Routes.CHAT_SCREEN,
            arguments: {"searchedUser": chatConversation});
      }
    } else if (notification['type'] == "request-payment") {
      Navigator.of(MyGlobals().navigationKey.currentContext!)
          .popUntil(ModalRoute.withName(Routes.DASHBOARD));
      Navigator.of(context).popUntil(ModalRoute.withName(Routes.ACCOUNTS));

      // DashboardBloc _dashboardBloc = Provider.of<DashboardBloc>(
      //     MyGlobals().navigationKey.currentContext!,
      //     listen: false);
      // _dashboardBloc.index = 1;
    } else if (notification['type'] == "transaction") {
      Navigator.of(MyGlobals().navigationKey.currentContext!)
          .popUntil(ModalRoute.withName(Routes.DASHBOARD));
      Navigator.of(MyGlobals().navigationKey.currentContext!)
          .pushNamed(Routes.TRANSACTIONS, arguments: {'page': 0});
    } else if (notification['type'] == "connection-request") {
      Navigator.of(MyGlobals().navigationKey.currentContext!)
          .popUntil(ModalRoute.withName(Routes.DASHBOARD));
      Navigator.of(MyGlobals().navigationKey.currentContext!)
          .pushNamed(Routes.FRIENDS_DASHBOARD, arguments: {"index": 1});
    } else if (notification['type'] == "friends-dashboard") {
      Navigator.of(MyGlobals().navigationKey.currentContext!)
          .popUntil(ModalRoute.withName(Routes.DASHBOARD));

      Navigator.of(MyGlobals().navigationKey.currentContext!)
          .pushNamed(Routes.FRIENDS_DASHBOARD, arguments: {"index": 0});
    } else if (notification['type'] == "detail_message") {
      //this variable will fetch the id of message from the response
      final String? idOfMessage =
          notification['actions'].replaceAll("/detail_message/", "");
      Navigator.of(MyGlobals().navigationKey.currentContext!)
          .popUntil(ModalRoute.withName(Routes.DASHBOARD));
      Navigator.of(MyGlobals().navigationKey.currentContext!)
          .pushNamed(Routes.DETAIL_MESSAGE, arguments: {
        'id': idOfMessage,
      });
    } else if (notification['type'].toString().contains("orders-list")) {
      Navigator.of(context).popUntil(ModalRoute.withName(Routes.DASHBOARD));
      Navigator.of(context).pushNamed(Routes.ORDERS_LIST);
    } else if (notification['type'].toString().contains("order-detail-page")) {
      final Order order = Order.fromJson(notification["data"] is String
          ? jsonDecode(notification["data"])
          : notification["data"]);

      Navigator.of(context).pushNamed(Routes.ORDER_DETAIL_PAGE, arguments: {
        'order': order,
      });
    } else if (notification['type'].toString().contains("moment")) {
      Navigator.of(context).popUntil(ModalRoute.withName(Routes.DASHBOARD));
      showDialog(
          context: context,
          builder: (context) => Center(child: CircularLoadingIndicator()));
      MomentsService()
          .getSingleMoment(
              momentId: notification['type'].toString().split('moment/')[1])
          .then((momentsModelList) {
        Navigator.pop(context);

        NavigationUtil.push(
          context,
          screen: MomentsDetailsScreen(
            indexOfMoment: 0,
            // Wrapping it around a List ([]) because the moment detail screen requires a List<List<MomentModel>>
            momentsModelList: [momentsModelList],
          ),
        );
      }).catchError((e) {
        Navigator.pop(context);

        debugPrint('ERROR M -> $e');
        showToast(message: 'ERROR -> $e');
      });
    } else if (notification['type'].toString().contains("accounts")) {
      Navigator.of(context).popUntil(ModalRoute.withName('/dashboard'));
      Navigator.pushNamed(context, Routes.ACCOUNTS);
    } else if (notification['type'].toString().contains("shopping-cart")) {
      Navigator.of(context).popUntil(ModalRoute.withName('/dashboard'));
      Navigator.pushNamed(context, Routes.SHOPPING_CART);
    }
  }

  void getFeeStructureData() {
    PaymentAndBankingAuth().getFeeStructure().then((value) async {
      //  deleteFeeStructure();
      await DatabaseHelper().saveFeeStructure(value);
    }).catchError((dds, e) {
      debugPrint(e.toString());
      showToast(message: e.toString());
    });
  }

  Future<int> deleteFeeStructure() async {
    return await _db.deleteFeeStructure();
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
        padding: basketBloc.basketItems.isEmpty
            ? const EdgeInsets.all(0)
            : const EdgeInsets.all(4),
        elevation: 0,
      ),
      // ignore: required onPressed
      child: const Center(
        child: Icon(
          Icons.shopping_cart,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget? getBadgeContent() {
    if (basketBloc.basketItems.isEmpty) {
      return null;
    }
    return Text(
      getBadgeCount().toString(),
      style: const TextStyle(
        fontSize: 10,
        color: Colors.white,
        fontWeight: FontWeight.bold,
        fontFamily: 'Inter',
      ),
    );
  }

  String getBadgeCount() {
    int totalItem = 0;
    for (var element in basketBloc.basketItems) {
      totalItem = totalItem + int.parse(element.qty.toString());
    }
    return totalItem > 99 ? '99+' : totalItem.toString();
  }

  @override
  Widget build(BuildContext context) {
    yarnDashboardBloc = Provider.of<YarnDashboardBloc>(context);
    userBloc = Provider.of<UserBloc>(context);
    basketBloc = Provider.of<BasketBloc>(context);
    appLocalization = AppLocalization.of(context)!;
    _dashboardBloc = Provider.of<DashboardBloc>(context);
    mainSocketProvider = Provider.of<MainSocketProvider>(context);
    initializeListener();

    if (_currentIndex != 0) {
      _dashboardBloc.index = _currentIndex;
      _currentIndex = 0;
    }

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) {
          return;
        } else {
          if (_dashboardBloc.index == 0) {
            final bool? result = await showDialogBox(
              context: context,
              actionOneBgColor: mateRed,
              actionOneTextColor: Colors.white,
              actionTwoBgColor: greyBorderColor,
              actionTwoTextColor: blackFont,
              title: appLocalization.exitApp,
              description: appLocalization.youSureYouWantToExitApp,
              actionOneText: AppLocalization.of(context)!.exit,
              actionTwoText: AppLocalization.of(context)!.cancel,
            );
            if (result != null && result) {
              SystemChannels.platform.invokeMethod<void>('SystemNavigator.pop');
            }
          }

          if (_dashboardBloc.index != 0) {
            if (mounted) {
              setState(() {
                _dashboardBloc.index = 0;
              });
            }
          }
        }
      },
      child: Scaffold(
        key: myGlobals.scaffoldKey,
        backgroundColor: whiteBackground,
        extendBody: true,
        body: SafeArea(
            maintainBottomViewPadding: true, child: _pages[_bottomNavIndex]),
        floatingActionButton: SizedBox(
          width: 70,
          height: 70,
          child: GestureDetector(
            onLongPress: () {
              logoutDialog(context);
            },
            child: FloatingActionButton(
              backgroundColor: navyBlue,
              onPressed: () {
                Navigator.of(context).pushNamed(Routes.HOME_QUICK_VIEW,
                    arguments: {"view": appLocalization.create});
              },
              mini: false,
              heroTag: null,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                    50.0), // Set the border radius to create a circle
              ),
              // child: Icon(
              //   Icons.add,
              //   color: white,
              //   size: 60,
              // ),
              child: SvgPicture.asset(
                'home/slydo'.toSVG(),
                color: white,
                width: 45,
                height: 45,
              ),
            ),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        bottomNavigationBar: bottomNavigationBar(),
      ),
    );
  }

  Future<void> logoutDialog(BuildContext context) async {
    showDialogBox(
      context: context,
      actionOneTextColor: blackFont,
      actionOneBgColor: greyBorderColor,
      actionTwoTextColor: white,
      actionTwoBgColor: naturalGreen,
      title: AppLocalization.of(context)!.logout,
      actionTwoText: AppLocalization.of(context)!.yes,
      actionOneText: AppLocalization.of(context)!.cancel,
      description: AppLocalization.of(context)!.logoutMsg,
      roundedBackgroundIcon: RoundedBackgroundIcon(
        backgroundColor: navyBlue.withOpacity(0.08),
        borderRadius: 20,
        width: 43,
        height: 43,
        icon: Icon(
          Icons.question_mark,
          color: navyBlue,
          size: 16,
        ),
        enableMargin: false,
      ),
      rightButtonOnPressed: () async {
        showDialog(
            context: (context),
            builder: (context) => Center(child: CircularLoadingIndicator()),
            barrierDismissible: false);
        await LogoutHelper().logoutUser();
      },
    );
  }

  Widget bottomNavigationBar() {
    return Theme(
      data: Theme.of(context).copyWith(
        splashColor: Colors.white,
        highlightColor: Colors.white,
      ),
      child: AnimatedBottomNavigationBar.builder(
        itemCount: iconList.length,
        tabBuilder: (int index, bool isActive) {
          final color = isActive ? navyBlue : darkGreyYarn;
          return Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                children: [
                  if (iconList[index] == 'home/super_store')
                    Icon(Icons.shopping_basket, color: color)
                  else
                    SvgPicture.asset(
                      iconList[index].toSVG(),
                      color: color,
                      width: 28,
                      height: 28,
                    ),
                  if (list[index] == 'Chat') // Only show badge for Chat icon
                    Positioned(
                      top: 0, // Adjust the top value as needed
                      right: 0, // Adjust the right value as needed
                      child: StreamBuilder(
                        stream:
                            ChatMessageSynchronizer().getChatMessageCountStream,
                        builder: (context, snapshot) {
                          return FutureBuilder(
                            future:
                                ChatUserManager().checkForChatMessagesCount(),
                            initialData: false,
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                if (snapshot.data == true) {
                                  // debugPrint('fola chat:::: ${snapshot.data}');

                                  return ClipOval(
                                    child: Container(
                                      height: 16,
                                      width: 16,
                                      color: naturalGreen,
                                      // child: Center(
                                      //   child: Text(
                                      //     '410',
                                      //     style: TextStyle(
                                      //       color: Colors.white,
                                      //       fontSize: 10,
                                      //       fontWeight: FontWeight.bold,
                                      //     ),
                                      //   ),
                                      // ),
                                    ),
                                  );
                                }
                                return Container();
                              }
                              return Container();
                            },
                          );
                        },
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  list[index],
                  maxLines: 1,
                  style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                      fontFamily: "Inter"),
                  // group: autoSizeGroup,
                ),
              )
            ],
          );
        },
        backgroundColor: white,
        activeIndex: _bottomNavIndex,
        splashColor: naturalGreenLight,
        splashSpeedInMilliseconds: 300,
        notchSmoothness: NotchSmoothness.softEdge,
        gapLocation: GapLocation.center,
        leftCornerRadius: 0,
        rightCornerRadius: 0,
        height: 55,
        notchMargin: 15,
        gapWidth: 80,
        onTap: (index) {
          setState(() {
            // Unfocus the keyboard
            FocusScope.of(context).requestFocus(FocusNode());
            if (userBloc.user.staff != null && index == 2) {
              showToast(message: AppLocalization.of(context)?.doNotPermission);
              return;
            } else {
              _bottomNavIndex = index;
            }
          });
        },
        shadow: const BoxShadow(
          offset: Offset(0, 0),
          blurRadius: 0,
          spreadRadius: 0.5,
          color: Colors.transparent,
        ),
      ),
    );
  }

  @override
  void dispose() {
    debugPrint("Subscription Removed ${streamSubscription?.toString()}");
    streamSubscription?.cancel();
    ShareManager().disposeShareManager();
    super.dispose();
  }
}
