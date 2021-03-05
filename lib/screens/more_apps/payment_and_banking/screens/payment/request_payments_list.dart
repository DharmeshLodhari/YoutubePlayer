import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/screens/more_apps/payment_and_banking/models/transactions.dart';
import 'package:Slydo/screens/more_apps/payment_and_banking/tiles/transaction.dart';
import 'package:Slydo/screens/more_apps/user_profile/user_auth.dart';
import 'package:Slydo/utils/colors.dart';
import 'package:Slydo/utils/slydo_app_icon_icons.dart';
import 'package:Slydo/widget/LoadingIndicator.dart';
import 'package:Slydo/widget/customized_passcode_sheet/bottomsheet_passcode.dart';
import 'package:Slydo/widget/customized_popup_menu.dart';
import 'package:Slydo/widget/dialog.dart';
import 'package:Slydo/widget/noItemInList.dart';
import 'package:Slydo/widget/rounded_background_icon.dart';
import 'package:Slydo/widget/slide_action_button.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:toast/toast.dart';

import '../../payment_and_banking_auth.dart';

class PaymentRequestList extends StatefulWidget {
  @override
  _PaymentRequestListState createState() => _PaymentRequestListState();
}

class _PaymentRequestListState extends State<PaymentRequestList> {
  final GlobalKey<ScaffoldState> _scaffoldPaymentListKey =
      new GlobalKey<ScaffoldState>();
  final _auth = PaymentAndBankingAuth();
  SlidableController _slideController;
  int count = 0;
  String next = "";
  String previous = "";
  List requestPaymentList = [];
  ScrollController _scrollController = new ScrollController();
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  bool isLoading = false;
  bool noItemInList = false;
  RefreshBlocForRequestPayment _refreshBloc;

  // variables for to getting filter requestPaymentList
  String filterValue = "all";
  bool fromMe = false;
  bool toMe = false;

  GlobalKey _key = LabeledGlobalKey("paymentRequestListPopUpMenu");
  CustomizedPopUpMenu menu;
  int selectedMenuItemIndex = 0;
  bool isPopMenuOpen = false;

  @protected
  void initState() {
    this.getList();
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
              _scrollController.position.maxScrollExtent &&
          _scrollController.position.pixels != 0) {
        getList();
      }
    });
    _slideController = SlidableController(
      onSlideAnimationChanged: handleSlideAnimationChanged,
      onSlideIsOpenChanged: handleSlideIsOpenChanged,
    );

    super.initState();
  }

  // refresh the list when lifecycle called onResume method
  void _onRefreshOnResume() {
    _refreshBloc = Provider.of<RefreshBlocForRequestPayment>(context);
    _refreshBloc
      ..addListener(() {
        if (_refreshBloc.isRefresh) {
          debugPrint("refreshing !!");
          if (mounted) {
            _onRefresh();
            _refreshBloc.isRefresh = false;
          }
        }
      });
  }

  void _onRefresh() async {
    Connectivity().checkConnectivity().then((value) {
      var connectionResult = value;
      if (connectionResult == ConnectivityResult.wifi ||
          connectionResult == ConnectivityResult.mobile) {
        count = 0;
        next = "";
        previous = "";
        requestPaymentList = [];
        noItemInList = false;
        getList();
        _refreshController.refreshCompleted();
      } else {
        Toast.show(
            AppLocalization.of(context).internetConnectionNotAvailable, context,
            gravity: Toast.BOTTOM, backgroundColor: darkBlue());
        _refreshController.refreshCompleted();
      }
    });
  }

  void menuItemSelectionChange(String value, int index) {
    selectedMenuItemIndex = index;
    setState(() {});
    switch (value) {
      case "received":
        toMe = true;
        fromMe = false;
        break;
      case "sent":
        toMe = false;
        fromMe = true;
        break;
      default:
        toMe = false;
        fromMe = false;
        break;
    }
    _onRefresh();
  }

  void menuStateChange(bool isOpen) {
    isPopMenuOpen = isOpen;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    menu = CustomizedPopUpMenu(
      buttonKey: _key,
      context: context,
      children: [
        CustomizedPopUpMenuItem(title: "All", value: "all"),
        CustomizedPopUpMenuItem(title: "Received", value: "received"),
        CustomizedPopUpMenuItem(title: "Sent", value: "sent"),
      ],
      selectedIndex: selectedMenuItemIndex,
      right: 16,
    );
    menu.onChange = menuItemSelectionChange;
    menu.menuState = menuStateChange;

    // refresh the list when lifecycle called onResume method\
    _onRefreshOnResume();

    return Scaffold(
      key: _scaffoldPaymentListKey,
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white,
      appBar: appBar(),
      body: SmartRefresher(
        enablePullDown: true,
        header: WaterDropHeader(
          complete: Container(),
          waterDropColor: navyBlue,
        ),
        controller: _refreshController,
        onRefresh: _onRefresh,
        child: _buildRequestPaymentList(),
      ),
    );
  }

  Widget appBar() {
    return AppBar(
      elevation: 0,
      titleSpacing: 16,
      backgroundColor: Colors.white,
      automaticallyImplyLeading: false,
      centerTitle: false,
      title: Text(
        "Payment request",
        style: TextStyle(
            color: blackFont, fontSize: 22, fontWeight: FontWeight.w700),
      ),
      actions: <Widget>[
        paymentRequestBtn(),
        SizedBox(
          width: 10.0,
        ),
        popUpMenuButton(),
        SizedBox(
          width: 16,
        ),
      ],
    );
  }

  Widget paymentRequestBtn() {
    return RoundedBackgroundIcon(
      height: 34,
      width: 34,
      icon: Icon(
        SlydoAppIcon.add,
        size: 16,
        color: blackFont,
      ),
      onTap: () async {
        Navigator.of(context).pushNamed('/request-payment',
            arguments: <String, bool>{
              'isRequest': true,
              'isFromProfile': true
            });
      },
      backgroundColor: iconBtnGrey,
      enableMargin: true,
    );
  }

  Widget menuBtn() {
    return SizedBox(
      height: 34,
      width: 34,
      child: Card(
        color: lightGrey,
        elevation: 0,
        margin: EdgeInsets.symmetric(vertical: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: _threeItemPopup(),
      ),
    );
  }

  Widget popUpMenuButton() {
    return SizedBox(
      key: _key,
      height: 34,
      width: 34,
      child: Card(
        color: isPopMenuOpen ? navyBlue : iconBtnGrey,
        elevation: 0,
        margin: EdgeInsets.symmetric(vertical: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: IconButton(
          icon: Icon(
            Icons.more_vert,
            color: isPopMenuOpen ? Colors.white : Colors.black,
            size: 20,
          ),
          onPressed: () {
            if (menu.isMenuOpen) {
              menu.closeMenu();
            } else {
              menu.openMenu();
            }
          },
        ),
      ),
    );
  }

  Widget _threeItemPopup() => PopupMenuButton(
        padding: EdgeInsets.all(0),
        captureInheritedThemes: true,
        icon: Icon(
          SlydoAppIcon.menu,
          size: 16,
          color: blackFont,
        ),
        itemBuilder: (context) {
          var list = List<PopupMenuEntry<Object>>();
          list.add(
            PopupMenuItem(
              child: Text(
                AppLocalization.of(context).filter,
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: blackFont),
              ),
              value: 1,
            ),
          );
          list.add(
            PopupMenuDivider(
              height: 10,
            ),
          );
          list.add(
            CheckedPopupMenuItem(
              child: Text(
                AppLocalization.of(context).all,
                style: TextStyle(color: Colors.black),
              ),
              value: "all",
              checked: filterValue == "all" ? true : false,
            ),
          );
          list.add(
            CheckedPopupMenuItem(
              child: Text(
                AppLocalization.of(context).received,
                style: TextStyle(color: Colors.black),
              ),
              value: "received",
              checked: filterValue == "received" ? true : false,
            ),
          );

          list.add(
            CheckedPopupMenuItem(
              child: Text(
                AppLocalization.of(context).sent,
                style: TextStyle(color: Colors.black),
              ),
              value: "sent",
              checked: filterValue == "sent" ? true : false,
            ),
          );
          return list;
        },
        onSelected: (Object object) {
          if (mounted) {
            setState(() {
              if (object != 1) {
                filterValue = object;
                filterValue = object;
                switch (filterValue) {
                  case "received":
                    toMe = true;
                    fromMe = false;
                    break;
                  case "sent":
                    toMe = false;
                    fromMe = true;
                    break;
                  default:
                    toMe = false;
                    fromMe = false;
                    break;
                }
                _onRefresh();
              }
            });
          }
        },
      );

  Widget _buildRequestPaymentList() {
    return noItemInList
        ? NoItemInList(
            msg: AppLocalization.of(context).noPendingPaymentRequest,
          )
        : ListView.builder(
            padding: EdgeInsets.symmetric(vertical: 4),
            //+1 for progressbar
            itemCount: requestPaymentList.length + 1,
            itemBuilder: (BuildContext context, int index) {
              if (index == requestPaymentList.length) {
                return _buildIndicator();
              } else {
                return _getSlideLists(
                    context, requestPaymentList[index], index);
              }
            },
            controller: _scrollController,
          );
  }

  Widget _buildIndicator() {
    return new Padding(
      padding: const EdgeInsets.all(8.0),
      child: new Center(
        child: new Opacity(
            opacity: isLoading ? 1.0 : 00,
            child: isLoading ? CircularLoadingIndicator() : Container()),
      ),
    );
  }

  void getList() async {
    if (!isLoading) {
      if (next != null && !isLoading) {
        isLoading = true;

        if (mounted) setState(() {});

        Map<String, dynamic> result =
            await _auth.listPaymentRequests(next, previous, toMe, fromMe);
        count = result['count'];
        next = result['next'];
        previous = result['previous'];
        var tempList = result['results'];

        isLoading = false;
        requestPaymentList.addAll(tempList);

        if (mounted) setState(() {});

        getList();
      }
      if (requestPaymentList.isEmpty) {
        noItemInList = true;

        if (mounted) setState(() {});
      } else if (next == null && requestPaymentList.length > 6) {
        if (mounted) {
          _scaffoldPaymentListKey.currentState.showSnackBar(SnackBar(
            content:
                Text(AppLocalization.of(context).youHaveReachedBottomOfTheList),
            duration: Duration(milliseconds: 500),
          ));
        }
      }
    }
  }

  Widget sendRequestButton() {
    return Padding(
      padding: const EdgeInsets.only(right: 4.0),
      child: InkWell(
        onTap: () {
          Connectivity().checkConnectivity().then((value) {
            var connectionResult = value;
            if (connectionResult == ConnectivityResult.wifi ||
                connectionResult == ConnectivityResult.mobile) {
              Navigator.of(context).pushNamed('/request-payment',
                  arguments: <String, bool>{
                    'isRequest': true,
                    'isFromProfile': true
                  });
            } else {
              Toast.show(
                  AppLocalization.of(context).internetConnectionNotAvailable,
                  context,
                  gravity: Toast.BOTTOM,
                  backgroundColor: darkBlue());
            }
          });
        },
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void handleSlideAnimationChanged(Animation<double> slideAnimation) {}

  void handleSlideIsOpenChanged(bool isOpen) {}

  void _showSnackBar(BuildContext context, String text) {
    _scaffoldPaymentListKey.currentState
        .showSnackBar(SnackBar(content: Text(text)));
  }

  List<Widget> listSecondaryActions(PaymentRequest paymentRequest, int index) {
    if (!paymentRequest.isCredit) {
      return [];
    } else {
      return [
        SlideActionButton(
            backgroundColor: naturalGreen,
            icon: SlydoAppIcon.send,
            onTap: () {
              acceptPaymentRequestAlert(paymentRequest, index);
            },
            title: "Pay",
            slideController: _slideController)
      ];
    }
  }

  List<Widget> listActionSlideActions(
      PaymentRequest paymentRequest, int index) {
    String caption = !paymentRequest.isCredit
        ? AppLocalization.of(context).cancel
        : AppLocalization.of(context).reject;
    return [
      SlideActionButton(
          backgroundColor: mateRed,
          icon: SlydoAppIcon.remove,
          onTap: () {
            if (!paymentRequest.isCredit) {
              cancelPaymentRequestAlert(paymentRequest, index);
            } else {
              rejectPaymentRequestAlert(paymentRequest, index);
            }
          },
          title: caption,
          slideController: _slideController),
    ];
  }

  void acceptPaymentRequestAlert(
      PaymentRequest paymentRequest, int index) async {
    bool result = await showDialogBox(
      context: context,
      roundedBackgroundIcon: RoundedBackgroundIcon(
        backgroundColor: navyBlue.withOpacity(0.08),
        borderRadius: 20,
        width: 48,
        height: 48,
        icon: Icon(
          SlydoAppIcon.true_icon,
          color: navyBlue,
          size: 16,
        ),
        enableMargin: false,
      ),
      actionOneBgColor: navyBlue,
      actionOneTextColor: Colors.white,
      actionTwoBgColor: mateRed,
      actionTwoTextColor: Colors.white,
      firstActionPrimary: true,
      title: "Pay",
      description:
          AppLocalization.of(context).areYouSureWantToAcceptThisRequest,
      actionOne: "Pay",
      actionTwo: AppLocalization.of(context).cancel,
    );
    if (result) {
      BottomSheetPassCode(
          context: context,
          isValidCallback: () async {
            var response = await _auth.acceptPaymentRequests(paymentRequest);
            if (response.statusCode == 200) {
              _showSnackBar(
                  context, AppLocalization.of(context).paymentRequestAccepted);
              if (mounted) {
                setState(() {
                  requestPaymentList.removeAt(index);
                  if (requestPaymentList.length <= 9) {
                    getList();
                  }
                });
              }
            } else if (response.statusCode == 500) {
              Toast.show(AppLocalization.of(context).serverError, context,
                  gravity: Toast.TOP,
                  backgroundColor: darkBlue(),
                  textColor: Colors.white);
            } else if (response.statusCode == 700) {
              Navigator.pushNamed(context, "/bvn-verification");
            } else if (response.statusCode == 800) {
              Navigator.pushNamed(context, "/add-document");
            } else {
              _showSnackBar(context, AppLocalization.of(context).error);
            }
          },
          cancelCallBack: () {
            Navigator.pop(context);
          });
    }
  }

  Future<void> rejectPaymentRequestAlert(
      PaymentRequest paymentRequest, int index) async {
    bool result = await showDialogBox(
      context: context,
      roundedBackgroundIcon: RoundedBackgroundIcon(
        backgroundColor: mateRed.withOpacity(0.08),
        borderRadius: 20,
        width: 48,
        height: 48,
        icon: Icon(
          SlydoAppIcon.false_icon,
          color: mateRed,
          size: 16,
        ),
        enableMargin: false,
      ),
      actionOneBgColor: mateRed,
      actionOneTextColor: Colors.white,
      actionTwoBgColor: greyBorderColor,
      actionTwoTextColor: blackFont,
      title: AppLocalization.of(context).reject,
      description:
          AppLocalization.of(context).areYouSureWantToRejectThisPayment,
      actionOne: AppLocalization.of(context).reject,
      actionTwo: AppLocalization.of(context).cancel,
    );
    if (result) {
      bool done = await _auth.rejectPaymentRequests(paymentRequest);
      if (done) {
        _showSnackBar(
            context, AppLocalization.of(context).paymentRequestRejected);
        if (mounted) {
          setState(() {
            requestPaymentList.removeAt(index);
            if (requestPaymentList.length <= 9) {
              getList();
            }
          });
        }
      } else {
        _showSnackBar(context, AppLocalization.of(context).error);
      }
    }
  }

  Future<void> cancelPaymentRequestAlert(
      PaymentRequest paymentRequest, int index) async {
    bool result = await showDialogBox(
      context: context,
      roundedBackgroundIcon: RoundedBackgroundIcon(
        backgroundColor: mateRed.withOpacity(0.08),
        borderRadius: 20,
        width: 48,
        height: 48,
        icon: Icon(
          SlydoAppIcon.false_icon,
          color: mateRed,
          size: 16,
        ),
        enableMargin: false,
      ),
      actionOneBgColor: mateRed,
      actionOneTextColor: Colors.white,
      actionTwoBgColor: greyBorderColor,
      actionTwoTextColor: blackFont,
      title: AppLocalization.of(context).cancel,
      description: "Are you sure want to cancel this request?",
      actionOne: AppLocalization.of(context).cancel,
      actionTwo: "Close",
    );
    if (result) {
      bool done = await _auth.rejectPaymentRequests(paymentRequest);
      if (done) {
        _showSnackBar(
            context, AppLocalization.of(context).paymentRequestRejected);
        if (mounted) {
          setState(() {
            requestPaymentList.removeAt(index);
            if (requestPaymentList.length <= 9) {
              getList();
            }
          });
        }
      } else {
        _showSnackBar(context, AppLocalization.of(context).error);
      }
    }
  }

  Widget _getSlideLists(
      BuildContext context, PaymentRequest paymentRequest, int index) {
    return Slidable(
      key: UniqueKey(),
      controller: _slideController,
      direction: Axis.horizontal,
      actionPane: SlidableBehindActionPane(),
      actionExtentRatio: 0.25,
      child: VerticalListItem(paymentRequest),
      actions: listActionSlideActions(paymentRequest, index),
      secondaryActions: listSecondaryActions(paymentRequest, index),
    );
  }

  @override
  void dispose() {
    _refreshController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}

class VerticalListItem extends StatefulWidget {
  VerticalListItem(this.paymentRequest);

  final PaymentRequest paymentRequest;

  @override
  _VerticalListItemState createState() => _VerticalListItemState();
}

class _VerticalListItemState extends State<VerticalListItem> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () =>
          Slidable.of(context)?.renderingMode == SlidableRenderingMode.none
              ? Slidable.of(context)?.open()
              : Slidable.of(context)?.close(),
      onDoubleTap: () {
        Navigator.pushNamed(context, '/profile',
            arguments: {"searchedUserName": widget.paymentRequest.payee});

      },
      onLongPress: () {
        if (mounted) {
          setState(() {
            if (isExpanded) {
              isExpanded = false;
            } else {
              isExpanded = true;
            }
          });
        }
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 2),
        child: PaymentRequestTile(
            paymentRequest: widget.paymentRequest,
            expandedWidget: expandedWidget()),
      ),
    );
  }

  Widget expandedWidget() {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      height: isExpanded ? 48 : 0,
      curve: Curves.fastOutSlowIn,
      child: isExpanded
          ? Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Container(
                  height: 1,
                  color: dividerColor,
                ),
                Expanded(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Expanded(child: sendMessageButton()),
                      Container(
                        width: 1,
                        color: dividerColor,
                        height: 48,
                      ),
                      Expanded(child: blockUserButton()),
                    ],
                  ),
                ),
              ],
            )
          : Container(),
    );
  }

  Widget sendMessageButton() {
    return Theme(
      data: Theme.of(context).copyWith(
        splashColor: Colors.white,
        highlightColor: Colors.white,
      ),
      child: InkWell(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            RoundedBackgroundIcon(
              backgroundColor: navyBlue.withOpacity(0.1),
              icon: Icon(
                SlydoAppIcon.message,
                color: navyBlue,
                size: 14,
              ),
              width: 32,
              height: 32,
            ),
            SizedBox(
              width: 10,
            ),
            Text(
              AppLocalization.of(context).message,
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black),
            )
          ],
        ),
        onTap: () {
          UserAuth()
              .fetchCustomerProfile(widget.paymentRequest.payee)
              .then((user) {
            if (mounted) {
              setState(() {
                isExpanded = false;
              });
            }
            Navigator.of(context).pushNamed('/compose_message', arguments: {
              'recipient': user.userName,
              'subject': "",
            });
          });
        },
      ),
    );
  }

  Widget blockUserButton() {
    return Theme(
      data: Theme.of(context).copyWith(
        splashColor: Colors.white,
        highlightColor: Colors.white,
      ),
      child: InkWell(
        onTap: () {
          UserAuth()
              .fetchCustomerProfile(widget.paymentRequest.payee)
              .then((user) {
            UserAuth().blockUser(user).then((result) {
              if (mounted) {
                setState(() {
                  isExpanded = false;
                });
              }
              if (result) {
                Toast.show(
                    "${widget.paymentRequest.payee} " +
                        AppLocalization.of(context).isBlocked,
                    context);
              } else {
                Toast.show(AppLocalization.of(context).error, context);
              }
            });
          });
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            RoundedBackgroundIcon(
              backgroundColor: mateRed.withOpacity(0.1),
              icon: Icon(
                SlydoAppIcon.remove,
                color: mateRed,
                size: 14,
              ),
              width: 32,
              height: 32,
            ),
            SizedBox(
              width: 10,
            ),
            Text(
              AppLocalization.of(context).blockUser,
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black),
            )
          ],
        ),
      ),
    );
  }
}
