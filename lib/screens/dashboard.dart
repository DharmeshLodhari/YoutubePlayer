import 'dart:async';
import 'dart:convert';

import 'package:Slydo/data/database_helper.dart';
import 'package:Slydo/data/socket_provider.dart';
import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/routes/route_constants.dart';
import 'package:Slydo/screens/more_apps/messaging/chat/helpers/chat_message_synchronizer.dart';
import 'package:Slydo/screens/more_apps/messaging/chat/helpers/main_socket_message_handler.dart';
import 'package:Slydo/screens/more_apps/messaging/chat/models/ChatConversation.dart';
import 'package:Slydo/screens/more_apps/messaging/message_auth.dart';
import 'package:Slydo/screens/more_apps/payment_and_banking/payment_and_banking_auth.dart';
import 'package:Slydo/screens/more_apps/shopping/models/store.dart';
import 'package:Slydo/screens/more_apps/user_profile/user_auth.dart';
import 'package:Slydo/services/awesome_notification_service.dart';
import 'package:Slydo/services/fcm_push_notification.dart';
import 'package:Slydo/services/list_refresher.dart';
import 'package:Slydo/services/share_manager.dart';
import 'package:Slydo/utils/global_key.dart';
import 'package:Slydo/utils/slydo_app_icon_new_icons.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/LoadingIndicator.dart';
import 'package:Slydo/widget/dialog.dart';
import 'package:Slydo/widget/keep_alive_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:badges/badges.dart' as badges;
import '../services/app_tutorial_controller.dart';
import '../utils/navigation_util.dart';
import 'connection_module/connections_dashboard.dart';
import 'home.dart';
import 'moments/screens/moment_detail/moment_detail_page.dart';
import 'moments/screens/moments_screen.dart';
import 'moments/screens/moments_service.dart';
import 'more_apps/messaging/chat/helpers/chat_user_manager.dart';
import 'more_apps/messaging/chat/helpers/connection_list_synchronizer.dart';
import 'more_apps/yarn/yarn_auth.dart';
import 'more_apps/yarn/yarn_dashboard.dart';
import 'more_apps/yarn/yarn_dashboard_bloc.dart';
import 'super_store/super_store.dart';

// ignore: must_be_immutable
class Dashboard extends StatefulWidget {
  var arguments;

  Dashboard({this.arguments});

  @override
  _DashboardState createState() => _DashboardState(arguments: arguments);
}

class _DashboardState extends State<Dashboard> {
  //newUI Variables
  late DashboardBloc _dashboardBloc;
  DatabaseHelper _db = DatabaseHelper();

  int _currentIndex = 0;
  var arguments;
  List<Widget>? screens;
  late BasketBloc basketBloc;
  late YarnDashboardBloc yarnDashboardBloc;

  MainSocketProvider? mainSocketProvider;
  StreamSubscription? streamSubscription;

  bool? isNFCPermissionAccepted;
  late AppLocalization appLocalization;

  _DashboardState({this.arguments});

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      ShareManager().initializeShareManager();
    });
    if (mounted) MainSocketMessageHandler().dispose();
    if (mounted) {
      setState(() {
        if (arguments != null) {
          int? indexFromRoute = arguments['dashboardIndex'];

          if (indexFromRoute != null) {
            setState(() {
              _currentIndex = indexFromRoute;
            });
          }
        }
      });
    }
    super.initState();

    getAllCategories();

    PushNotificationService().initialize();
    ListRefresher().initialize();
    getFeeStructureData();

    fetchConnections();

    // checkNotificationToNavigate();
    MyGlobals.notificationStream?.cancel();
    listenNotificationTap();
  }

  /// Handles fetching of all categories
  void getAllCategories() async {
    Map<String, dynamic>? result = await YarnAuth().getAllCategories("", "");

    if (result != null && mounted) {
      yarnDashboardBloc.addCategories(result['results']);
    }
  }

  void fetchConnections() async {
    ConnectionListBloc connectionListBloc = Provider.of<ConnectionListBloc>(
        myGlobals.navigationKey.currentContext!,
        listen: false);

    BackgroundFetchStopBloc backgroundFetchStopBloc =
        Provider.of<BackgroundFetchStopBloc>(
            myGlobals.navigationKey.currentContext!);

    /// to show updating Messaging in connection list
    ChatMessageSynchronizer().updateFetchStream(isFetching: true);

    int result = await connectionListBloc.getConnectionsCount();
    debugPrint("CONNECTION LIST LENGTH:- $result");
    if (result == 0) {
      await ConnectionSynchronizer().fetch(isRefresh: true);

      int result = await connectionListBloc.getConnectionsCount();
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

      Map<String, dynamic>? payload = receivedNotification.payload;

      if (receivedNotification.buttonKeyPressed == "reject_nudge") {
        Map<String, dynamic> data = {
          "check_id": Uuid().v4(),
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

    Map<String, dynamic> notification = data['payload'] is String
        ? jsonDecode(data['payload'])
        : data['payload'];

    debugPrint('NOTIFICAITON TYPE --> ${notification['type']}');

    if (notification['type'] == "chatroom_message" ||
        notification['type'] == "nudge_user") {
      String? recipientUsername =
          notification['actions'].replaceAll("/chat-screen/", "");
      print("Recipient user name = $recipientUsername");

      if (recipientUsername != null) {
        showDialog(
            context: MyGlobals().navigationKey.currentContext!,
            builder: (context) => Center(child: CircularLoadingIndicator()));

        ChatConversation chatConversation =
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
          .pushNamed(Routes.TRANSACTIONS);
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
      String? idOfMessage =
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
      Order order = Order.fromJson(notification["data"] is String
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
      badgeAnimation: badges.BadgeAnimation.rotation(
        animationDuration: Duration(seconds: 1),
        colorChangeAnimationDuration: Duration(seconds: 1),
        loopAnimation: false,
        curve: Curves.fastOutSlowIn,
        colorChangeAnimationCurve: Curves.easeInCubic,
      ),
      badgeStyle: badges.BadgeStyle(
        shape: badges.BadgeShape.circle,
        badgeColor: naturalGreen,
        padding: basketBloc.items.length == 0
            ? EdgeInsets.all(0)
            : EdgeInsets.all(4),
        elevation: 0,
      ),
      // ignore: required onPressed
      child: Center(
        child: Icon(
          Icons.shopping_cart,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget? getBadgeContent() {
    if (basketBloc.items.length == 0) {
      return null;
    }
    return Text(
      getBadgeCount().toString(),
      style: TextStyle(
          fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold),
    );
  }

  int getBadgeCount() {
    int totalItem = 0;
    basketBloc.items.forEach((element) {
      totalItem = totalItem + element['qty'] as int;
    });
    return totalItem;
  }

  @override
  Widget build(BuildContext context) {
    yarnDashboardBloc = Provider.of<YarnDashboardBloc>(context);
    basketBloc = Provider.of<BasketBloc>(context);
    appLocalization = AppLocalization.of(context)!;
    _dashboardBloc = Provider.of<DashboardBloc>(context);
    mainSocketProvider = Provider.of<MainSocketProvider>(context);
    initializeListener();

    if (_currentIndex != 0) {
      _dashboardBloc.index = _currentIndex;
      _currentIndex = 0;
    }

    return WillPopScope(
      onWillPop: () async {
        if (_dashboardBloc.index == 0) {
          bool? result = await showDialogBox(
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
        return false;
      },
      child: Scaffold(
        key: myGlobals.scaffoldKey,
        backgroundColor: whiteBackground,
        body: PageView(
          physics: NeverScrollableScrollPhysics(),
          controller: _dashboardBloc.pageController,
          onPageChanged: (index) {
            _dashboardBloc.index = index;
            FocusScope.of(context).unfocus();
          },
          children: <Widget>[
            KeepAlivePage(child: Home(), wantKeepAlive: false),
            KeepAlivePage(child: YarnDashboard(), wantKeepAlive: true),
            KeepAlivePage(child: SuperStore(), wantKeepAlive: true),
            KeepAlivePage(child: MomentsScreen(), wantKeepAlive: true),
            KeepAlivePage(child: ConnectionDashboard()),
          ],
        ),
        bottomNavigationBar: bottomNavigationBar(),
      ),
    );
  }

  Widget bottomNavigationBar() {
    return Theme(
      data: Theme.of(context).copyWith(
        splashColor: Colors.white,
        highlightColor: Colors.white,
      ),
      child: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedFontSize: 0,
        iconSize: 0,
        unselectedFontSize: 10,
        showSelectedLabels: false,
        backgroundColor: Colors.white,
        elevation: 10,
        currentIndex: _dashboardBloc.index,
        onTap: (index) {
          _dashboardBloc.index = index;
          FocusScope.of(context).unfocus();
          if (index == 1) {
            _dashboardBloc.topYarn = true;
            // debugPrint('Dashboard Yarn clicked:::: ${_dashboardBloc.top}');
          }
        },
        items: [
          bottomNavigationBarItem(
            iconData: SlydoAppIconNew.home,
            title: AppLocalization.of(context)!.home,
          ),

          bottomNavigationBarItem(
            iconSize: 20,
            key: tutorialYarnKey,
            iconData: SlydoAppIconNew.dashboard_yarn,
            title: "Yarn",
          ),
          bottomNavigationBarItem(
            key: tutorialSuperStoreKey,
            iconSize: 20,
            iconData: SlydoAppIconNew.super_store,
            title: AppLocalization.of(context)!.store,
          ),
          bottomNavigationBarItem(
            key: tutorialMomentKey,
            iconData: SlydoAppIconNew.moment,
            title: AppLocalization.of(context)!.moments,
          ),
          // bottomNavigationBarItem(
          //   isChatIcon: true,
          //   icon: SlydoAppIcon.more,
          //   title: AppLocalization.of(context)!.chat,
          // ),

          bottomNavigationBarItem(
            isChatIcon: true,
            key: tutorialChatMessageKey,
            iconData: SlydoAppIconNew.chat,
            title: AppLocalization.of(context)!.chat,
          ),

          // BottomNavigationBarItem(
          //   icon: Container(
          //     key: tutorialExploreKey,
          //     height: 50,
          //     child: Icon(
          //       Icons.explore,
          //       color: blackFont,
          //       size: 18,
          //     ),
          //   ),
          //   label: "Explore",
          //   activeIcon: activeIcon(
          //       title: AppLocalization.of(context)!.explore,
          //       icon: Icons.explore),
          // ),
        ],
      ),
    );
  }

  // to create BottomNavigationBarItem
  BottomNavigationBarItem bottomNavigationBarItem(
      {Widget? icon,
      IconData? iconData,
      required String title,
      double? iconSize,
      bool isChatIcon = false,
      Key? key}) {
    return BottomNavigationBarItem(
      icon: isChatIcon
          ? Stack(
              children: [
                Container(
                  key: key,
                  height: 50,
                  width: 60,
                  child: Icon(
                    iconData,
                    color: blackFont,
                    size: iconSize ?? 16,
                  ),
                ),
                StreamBuilder(
                    stream: ChatMessageSynchronizer().getChatMessageCountStream,
                    builder: (context, snapshot) {
                      return FutureBuilder(
                          future: ChatUserManager().checkForChatMessagesCount(),
                          initialData: false,
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              if (snapshot.data == true) {
                                return Positioned(
                                  top: 14,
                                  right: 18,
                                  child: ClipOval(
                                    child: Container(
                                      height: 8,
                                      width: 8,
                                      color: naturalGreen,
                                    ),
                                  ),
                                );
                              }
                              return Container();
                            }
                            return Container();
                          });
                    }),
              ],
            )
          : Container(
              key: key,
              height: 50,
              width: 60,
              child: icon ??
                  Icon(
                    iconData,
                    color: blackFont,
                    size: iconSize ?? 16,
                  ),
            ),
      label: "",
      activeIcon:
          activeIcon(icon: iconData, title: title, isChatIcon: isChatIcon),
    );
  }

  // How BottomNavigationBarItem will look when active
  Widget activeIcon(
      {IconData? icon, required String title, bool isChatIcon = false}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Container(
        height: 50,
        width: 60,
        color: navyBlue,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(
              height: 4,
            ),

            // TODO: Add icon here.
            Expanded(
              child: Icon(
                icon,
                color: Colors.white,
                size: 16,
              ),
            ),
            SizedBox(
              height: 4,
            ),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w700),
              ),
            ),
          ],
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
