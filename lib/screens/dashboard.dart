import 'dart:async';
import 'dart:convert';

import 'package:Slydo/data/database_helper.dart';
import 'package:Slydo/data/socket_provider.dart';
import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/screens/more_apps/messaging/chat/helpers/chat_message_synchronizer.dart';
import 'package:Slydo/screens/more_apps/messaging/chat/helpers/chat_user_manager.dart';
import 'package:Slydo/screens/more_apps/messaging/chat/helpers/main_socket_message_handler.dart';
import 'package:Slydo/screens/more_apps/messaging/chat/models/ChatConversation.dart';
import 'package:Slydo/screens/more_apps/messaging/chat/models/models_for_db/nudge_notification/NudgeNotification.dart';
import 'package:Slydo/screens/more_apps/shopping/screens/checkout_shopping_cart.dart';
import 'package:Slydo/screens/more_apps/user_profile/user_auth.dart';
import 'package:Slydo/screens/search_module.dart';
import 'package:Slydo/screens/user_dashboard.dart';
import 'package:Slydo/services/awesome_notification_service.dart';
import 'package:Slydo/services/fcm_push_notification.dart';
import 'package:Slydo/services/list_refresher.dart';
import 'package:Slydo/services/share_manager.dart';
import 'package:Slydo/utils/global_key.dart';
import 'package:Slydo/utils/slydo_app_icon_icons.dart';
import 'package:Slydo/widget/LoadingIndicator.dart';
import 'package:Slydo/widget/dialog.dart';
import 'package:Slydo/widget/keep_alive_page.dart';
import 'package:badges/badges.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../utils/colors.dart';
import 'home.dart';
import 'more_apps/messaging/chat/helpers/connection_list_synchronizer.dart';
import 'more_apps/payment_and_banking/screens/payment/request_payments_list.dart';

// ignore: must_be_immutable
class Dashboard extends StatefulWidget {
  var arguments;

  Dashboard({this.arguments});

  @override
  _DashboardState createState() => _DashboardState(arguments: arguments);
}

class _DashboardState extends State<Dashboard> {
  //newUI Variables
  DashboardBloc _dashboardBloc;

  int _currentIndex = 0;
  var arguments;
  List<Widget> screens;
  BasketBloc basketBloc;

  MainSocketProvider mainSocketProvider;
  StreamSubscription streamSubscription;

  bool isNFCPermissionAccepted;

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
          int indexFromRoute = arguments['dashboardIndex'];

          if (indexFromRoute != null) {
            setState(() {
              _currentIndex = indexFromRoute;
            });
          }
        }
      });
    }

    super.initState();

    PushNotificationService().initialize();
    ListRefresher().initialize();

    fetchConnections();

    checkNotificationToNavigate();

    listenNotificationTap();
  }

  void fetchConnections() async {
    ConnectionListBloc connectionListBloc = Provider.of<ConnectionListBloc>(
        myGlobals.navigationKey.currentContext,
        listen: false);

    BackgroundFetchBloc backgroundFetchBloc = Provider.of<BackgroundFetchBloc>(
        myGlobals.navigationKey.currentContext);

    int result = await connectionListBloc.getConnectionsCount();
    debugPrint("CONNECTION LIST LENGTH:- $result");
    if (result == 0) {
      await ConnectionSynchronizer().fetch(isRefresh: true);

      int result = await connectionListBloc.getConnectionsCount();
      debugPrint("CONNECTION LIST LENGTH:- $result");

      for (int i = 0; i < connectionListBloc.connectionUsers.length; i++) {
        if (backgroundFetchBloc.isAllowed) {
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
  }

  void initializeListener() {
    streamSubscription?.cancel();
    streamSubscription = mainSocketProvider?.socketStream?.listen((event) {
      MainSocketMessageHandler(message: event);
      if (mounted) setState(() {});
    });
  }

  void checkNotificationToNavigate() async {
    NudgeNotification nudgeNotification =
        await DatabaseHelper().getNudgeNotification();
    if (nudgeNotification != null) {
      debugPrint("NOTIFICATION FOUND :- ${nudgeNotification.toJson()}");
      showDialog(
          context: context,
          builder: (context) => Center(child: CircularLoadingIndicator()));

      UserBloc userBloc = Provider.of<UserBloc>(context, listen: false);

      await DatabaseHelper().deleteNudgeNotification();

      ChatConversation chatConversation = await UserAuth()
          .fetchContactProfile(nudgeNotification.recipientUsername);

      MainSocketMessageHandler().sendNudgeAcknowledgement(
          author: chatConversation, currentUser: userBloc, type: "Accepted");

      /// if User is not added in database
      try {
        ConnectionListBloc connectionListBloc =
            Provider.of<ConnectionListBloc>(context, listen: false);

        connectionListBloc.setConnectionUsers(users: [chatConversation]);

        ChatUserManager().addUsers([chatConversation]);
      } catch (error) {
        debugPrint("ERRORR:- $error");
      }

      if (chatConversation == null) {
        Navigator.of(context).popUntil(ModalRoute.withName('/dashboard'));
        return;
      }
      Navigator.of(context).popUntil(ModalRoute.withName('/dashboard'));
      Navigator.pushNamed(context, '/chat-screen',
          arguments: {"searchedUser": chatConversation});
      return;
    } else {
      Map<String, dynamic> notificationList =
          await DatabaseHelper().getNotification();

      if (notificationList == null) return;

      Map<String, dynamic> notification =
          jsonDecode(notificationList['notification']);

      if (notification['type'] == "chatroom_message") {
        String recipientUsername =
            notification['actions'].replaceAll("/chat-screen/", "");
        print("Recipient user name = $recipientUsername");

        if (recipientUsername != null) {
          showDialog(
              context: MyGlobals().navigationKey.currentContext,
              builder: (context) => Center(child: CircularLoadingIndicator()));

          await DatabaseHelper().deleteNotification();

          ChatConversation chatConversation =
              await UserAuth().fetchContactProfile(recipientUsername);

          if (chatConversation == null) {
            Navigator.of(MyGlobals().navigationKey.currentContext)
                .popUntil(ModalRoute.withName('/dashboard'));
            return;
          }
          Navigator.of(MyGlobals().navigationKey.currentContext)
              .popUntil(ModalRoute.withName('/dashboard'));
          Navigator.pushNamed(
              MyGlobals().navigationKey.currentContext, '/chat-screen',
              arguments: {"searchedUser": chatConversation});
        }
      } else if (notification['type'] == "request-payment") {
        await DatabaseHelper().deleteNotification();
        Navigator.of(MyGlobals().navigationKey.currentContext)
            .popUntil(ModalRoute.withName('/dashboard'));
        DashboardBloc _dashboardBloc = Provider.of<DashboardBloc>(
            MyGlobals().navigationKey.currentContext,
            listen: false);
        _dashboardBloc.index = 1;
      } else if (notification['type'] == "transaction") {
        await DatabaseHelper().deleteNotification();
        Navigator.of(MyGlobals().navigationKey.currentContext)
            .popUntil(ModalRoute.withName('/dashboard'));
        Navigator.of(MyGlobals().navigationKey.currentContext)
            .pushNamed('/transactions');
      } else if (notification['type'] == "connection-request") {
        await DatabaseHelper().deleteNotification();
        Navigator.of(MyGlobals().navigationKey.currentContext)
            .popUntil(ModalRoute.withName('/dashboard'));
        Navigator.of(MyGlobals().navigationKey.currentContext)
            .pushNamed('/friends-dashboard', arguments: {"index": 1});
      } else if (notification['type'] == "friends-dashboard") {
        await DatabaseHelper().deleteNotification();
        Navigator.of(MyGlobals().navigationKey.currentContext)
            .popUntil(ModalRoute.withName('/dashboard'));
        Navigator.of(MyGlobals().navigationKey.currentContext)
            .pushNamed('/friends-dashboard', arguments: {"index": 0});
      } else if (notification['type'] == "detail_message") {
        await DatabaseHelper().deleteNotification();
        //this variable will fetch the id of message from the response
        String idOfMessage =
            notification['actions'].replaceAll("/detail_message/", "");
        Navigator.of(context).popUntil(ModalRoute.withName('/dashboard'));
        Navigator.of(context).pushNamed('/detail_message', arguments: {
          'id': idOfMessage,
        });
      }
    }
  }

  void listenNotificationTap() {
    AwesomeNotificationService().notificationActionStream.listen((event) {
      debugPrint("<=====> $event");
    });
  }

  Widget goToBasket() {
    return Badge(
      badgeColor: Colors.green,
      animationType: BadgeAnimationType.slide,
      badgeContent: getBadgeContent(),
      padding:
          basketBloc.items.length == 0 ? EdgeInsets.all(0) : EdgeInsets.all(4),
      position: BadgePosition(end: 6, top: 6),
      // ignore: required onPressed
      child: Icon(
        Icons.shopping_cart,
        color: Colors.white,
      ),
    );
  }

  Widget getBadgeContent() {
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
      totalItem = totalItem + element['qty'];
    });
    return totalItem;
  }

  @override
  Widget build(BuildContext context) {
    basketBloc = Provider.of<BasketBloc>(context);
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
          bool result = await showDialogBox(
            context: context,
            actionOneBgColor: mateRed,
            actionOneTextColor: Colors.white,
            actionTwoBgColor: greyBorderColor,
            actionTwoTextColor: blackFont,
            title: "Exit app",
            description: "Are you sure want to exit app?",
            actionOne: AppLocalization.of(context).exit,
            actionTwo: AppLocalization.of(context).cancel,
          );
          if (result) {
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
          controller: _dashboardBloc.pageController,
          onPageChanged: (index) {
            _dashboardBloc.index = index;
            FocusScope.of(context).unfocus();
          },
          children: <Widget>[
            KeepAlivePage(child: Home()),
            KeepAlivePage(child: PaymentRequestList()),
            KeepAlivePage(child: SearchModule()),
            KeepAlivePage(child: ShoppingCart()),
            KeepAlivePage(child: UserDashboard()),
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
        },
        items: [
          bottomNavigationBarItem(
            icon: SlydoAppIcon.home,
            title: AppLocalization.of(context).home,
          ),
          bottomNavigationBarItem(
            icon: SlydoAppIcon.receive,
            title: AppLocalization.of(context).requests,
          ),
          bottomNavigationBarItem(
            icon: SlydoAppIcon.search,
            title: AppLocalization.of(context).search,
          ),
          bottomNavigationBarItem(
            icon: SlydoAppIcon.cart,
            title: AppLocalization.of(context).basket,
          ),
          bottomNavigationBarItem(
            icon: SlydoAppIcon.user,
            title: AppLocalization.of(context).explore,
          ),
        ],
      ),
    );
  }

  // to create BottomNavigationBarItem
  BottomNavigationBarItem bottomNavigationBarItem(
      {IconData icon, String title}) {
    return BottomNavigationBarItem(
      icon: Container(
        height: 50,
        width: 60,
        child: Icon(
          icon,
          color: blackFont,
          size: 16,
        ),
      ),
      label: "",
      activeIcon: activeIcon(icon: icon, title: title),
    );
  }

  // How BottomNavigationBarItem will look when active
  Widget activeIcon({IconData icon, String title}) {
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
