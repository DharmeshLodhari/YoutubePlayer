import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/routes/route_constants.dart';
import 'package:Slydo/screens/more_apps/payment_and_banking/models/transactions.dart';
import 'package:Slydo/screens/more_apps/payment_and_banking/payment_and_banking_auth.dart';
import 'package:Slydo/utils/slydo_app_icon_icons.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/noItemInList.dart';
import 'package:Slydo/widget/rounded_background_icon.dart';
import 'package:Slydo/widget/slide_action_button.dart';
import 'package:Slydo/widget/vertical_list_item.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class CreditCardList extends StatefulWidget {
  final arguments;

  CreditCardList({this.arguments});

  @override
  _CreditCardListState createState() => _CreditCardListState();
}

class _CreditCardListState extends State<CreditCardList> {
  int? count = 0;
  String? next = "";
  String? previous = "";
  bool isLoading = false;
  bool noItemInList = false;
  List<CreditCard> creditCardList = [];
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  PaymentAndBankingAuth _auth = PaymentAndBankingAuth();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  // //slidable tile
  SlidableController? _slideController;

  @override
  void initState() {
    this.getList();
    _slideController = SlidableController(
      onSlideAnimationChanged: handleSlideAnimationChanged,
      onSlideIsOpenChanged: handleSlideIsOpenChanged,
    );

    super.initState();
  }

  void _onRefresh() async {
    //check network connectivity and if true then refresh the list
    Connectivity().checkConnectivity().then((value) {
      var connectionResult = value;
      if (connectionResult == ConnectivityResult.wifi ||
          connectionResult == ConnectivityResult.mobile) {
        count = 0;
        next = "";
        previous = "";
        creditCardList = [];
        getList();
        _refreshController.refreshCompleted();
      } else {
        showToast(
            message:
                AppLocalization.of(context)!.internetConnectionNotAvailable);
        _refreshController.refreshCompleted();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (widget.arguments != null) {
          Navigator.pop(context);
          Navigator.pop(context);
        }
        return true;
      },
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: Colors.white,
        appBar: appBar() as PreferredSizeWidget?,
        body: SmartRefresher(
            enablePullDown: true,
            header: WaterDropHeader(
              complete: Container(),
              waterDropColor: navyBlue,
            ),
            controller: _refreshController,
            onRefresh: _onRefresh,
            child: _buildCreditCardList()),
      ),
    );
  }

  Widget appBar() {
    return AppBar(
      elevation: 0,
      titleSpacing: 0,
      backgroundColor: Colors.white,
      leading: IconButton(
        icon: Icon(
          Icons.keyboard_arrow_left,
          color: navyBlue,
          size: 24,
        ),
        onPressed: () {
          if (widget.arguments != null) {
            Navigator.pop(context);
            Navigator.pop(context);
          } else {
            Navigator.pop(context);
          }
        },
      ),
      centerTitle: false,
      title: Text(
        AppLocalization.of(context)!.creditCards,
        style: TextStyle(
            color: blackFont, fontSize: 18, fontWeight: FontWeight.bold),
      ),
      actions: <Widget>[
        creditCardList.isEmpty ? SizedBox.shrink() : openGraphBtn(),
        SizedBox(width: 16),
      ],
    );
  }

  Widget openGraphBtn() {
    return RoundedBackgroundIcon(
      height: 34,
      width: 34,
      icon: Icon(
        SlydoAppIcon.add,
        size: 16,
        color:
            creditCardList.length == 2 ? blackFont.withOpacity(0.3) : blackFont,
      ),
      onTap: () {
        //for adding new account
        creditCardList.length == 2
            ? showToast(message: "You cannot add more than two credit cards")
            : Navigator.of(context).pushNamed(Routes.CARD_PAYMENT_PAGE);
      },
      backgroundColor: iconBtnGrey,
      enableMargin: true,
    );
  }

  void getList() async {
    if (!isLoading) {
      if (next != null && !isLoading) {
        if (mounted) {
          setState(() {
            isLoading = true;
          });
        }
        Map<String, dynamic>? result =
            await _auth.getCreditCardPagination(next, previous);
        if (result == null) {
          isLoading = false;
          return;
        }
        count = result['count'];
        next = result['next'];
        previous = result['previous'];
        var tempList = result['results'];
        if (mounted) {
          setState(() {
            isLoading = false;
            creditCardList.addAll(tempList);
          });
        }
      }
      if (creditCardList.isEmpty) {
        if (mounted) {
          setState(() {
            noItemInList = true;
          });
        }
      } else if (next == null && creditCardList.length > 6) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content:
              Text(AppLocalization.of(context)!.youHaveReachedBottomOfTheList),
          duration: Duration(milliseconds: 500),
        ));
      }
    }
  }

  Widget _buildCreditCardList() {
    return noItemInList
        ? NoItemInList(
            msg: AppLocalization.of(context)!
                .youDontHaveAnyCreditCardPleaseAddOne,
          )
        : ListView.builder(
            padding: EdgeInsets.symmetric(vertical: 16),
            //+1 for progressbar
            itemCount: creditCardList.length + 1,
            itemBuilder: (BuildContext context, int index) {
              if (index == creditCardList.length) {
                return buildIndicator(isLoading: isLoading);
              } else {
                return _getSlidableWithLists(
                  context,
                  creditCardTile(
                    creditCard: creditCardList[index],
                  ),
                  creditCardList[index],
                );
              }
            },
          );
  }

  Widget creditCardTile({required CreditCard creditCard}) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      shadowColor: boxShadowTwo,
      elevation: 0,
      child: Container(
        decoration: decorateBox(),
        child: ListTile(
          dense: creditCard.isDefault! ? true : false,
          title: getTitle(creditCard: creditCard),
          leading: GestureDetector(
            onTap: () {
              Navigator.of(context)
                  .pushNamed("/photo-viewer", arguments: creditCard.icon);
            },
            child: Image.asset(
              creditCard.icon!,
              height: 48,
              width: 48,
              colorBlendMode: BlendMode.darken,
              fit: BoxFit.cover,
              filterQuality: FilterQuality.high,
            ),
          ),
        ),
      ),
    );
  }

  Widget getTitle({required CreditCard creditCard}) {
    if (creditCard.isDefault!) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            height: 4,
          ),
          Text(
            getFormattedAccountNumber(
                accountNumber: creditCard.cardNumber!.toString()),
            style: TextStyle(color: darkGrey, fontSize: 12),
          ),
          SizedBox(height: 2),
          Text(
            AppLocalization.of(context)!.defaultMsg,
            style: TextStyle(color: darkGrey, fontSize: 12),
          ),
          SizedBox(
            height: 4,
          ),
        ],
      );
    }
    return Text(
      getFormattedAccountNumber(
          accountNumber: creditCard.cardNumber.toString()),
      style: TextStyle(color: darkGrey, fontSize: 12),
    );
  }

  Widget _getSlidableWithLists(
      BuildContext context, Widget creditCardTile, CreditCard creditCard) {
    return Slidable(
      controller: _slideController,
      direction: Axis.horizontal,
      actionPane: SlidableBehindActionPane(),
      actionExtentRatio: 0.25,
      child: VerticalListItem(creditCardTile),
      actions: listActionSlideActions(creditCard: creditCard),
      secondaryActions: listSecondaryActions(creditCard: creditCard),
    );
  }

  List<Widget> listSecondaryActions({required CreditCard creditCard}) {
    return [
      SlideActionButton(
          backgroundColor: naturalGreen,
          icon: Icons.device_hub,
          onTap: creditCard.isDefault!
              ? () {
                  showToast(
                      message: AppLocalization.of(context)!
                          .thisCardIsAlreadyDefaultCard);
                }
              : () {
                  updateCreditCard(creditCard);
                },
          title: creditCard.isDefault!
              ? AppLocalization.of(context)!.defaultMsg
              : AppLocalization.of(context)!.makeDefault,
          slideController: _slideController),
    ];
  }

  List<Widget> listActionSlideActions({CreditCard? creditCard}) {
    return [
      SlideActionButton(
          backgroundColor: mateRed,
          icon: SlydoAppIcon.remove,
          onTap: () {
            deleteCreditCard(creditCard);
          },
          title: AppLocalization.of(context)!.delete,
          slideController: _slideController),
    ];
  }

  void deleteCreditCard(CreditCard? creditCard) {
    {
      if (creditCardList.length == 1) {
        showToast(
            message:
                AppLocalization.of(context)!.youCanNotDeleteOnlyCreditAccount);
      } else {
        _auth.deleteCreditCard(creditCard!.cardId!).then((value) {
          if (value) {
            showToast(
                message: AppLocalization.of(context)!.cardDeletedSuccessfully);
            _onRefresh();
          } else {
            showToast(message: AppLocalization.of(context)!.cardIsNotDeleted);
          }
        }).catchError((error) {
          showToast(message: error.toString());
        });
      }
    }
  }

  void updateCreditCard(CreditCard creditCard) {
    _auth.updateCreditCard(creditCard.cardId!).then((value) {
      if (value) {
        showToast(
            message:
                AppLocalization.of(context)!.creditCardUpdatedSuccessfully);

        _onRefresh();
      } else {
        showToast(message: AppLocalization.of(context)!.cardNotUpdated);
      }
    }).catchError((error) {
      showToast(message: error.toString());
    });
    _onRefresh();
  }

  void handleSlideAnimationChanged(Animation<double>? slideAnimation) {}

  void handleSlideIsOpenChanged(bool? isOpen) {}

  @override
  void dispose() {
    super.dispose();
  }
}
