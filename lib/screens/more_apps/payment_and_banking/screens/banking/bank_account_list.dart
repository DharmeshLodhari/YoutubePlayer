import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/screens/more_apps/payment_and_banking/models/transactions.dart';
import 'package:Slydo/utils/slydo_app_icon_icons.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/LoadingIndicator.dart';
import 'package:Slydo/widget/noItemInList.dart';
import 'package:Slydo/widget/rounded_background_icon.dart';
import 'package:Slydo/widget/slide_action_button.dart';
import 'package:Slydo/widget/vertical_list_item.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../payment_and_banking_auth.dart';

class BankAccountList extends StatefulWidget {
  @override
  _BankAccountListState createState() => _BankAccountListState();
}

class _BankAccountListState extends State<BankAccountList> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  // Get list of users bank account
  final _auth = PaymentAndBankingAuth();
  late UserBloc userBloc;
  int? count = 0;
  String? next = "";
  String? previous = "";
  List bankAccountList = [];
  ScrollController _scrollController = new ScrollController();
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  bool isLoading = false;
  bool noItemInList = false;

  //slidable tile
  SlidableController? _slideController;

  @override
  void initState() {
    // secureScreen();
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
  }

  // refresh the list when lifecycle called onResume method

  void _onRefresh() async {
    //check network connectivity and if true then refresh the list
    Connectivity().checkConnectivity().then((value) {
      var connectionResult = value;
      if (connectionResult == ConnectivityResult.wifi ||
          connectionResult == ConnectivityResult.mobile) {
        count = 0;
        next = "";
        previous = "";
        bankAccountList = [];
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
    userBloc = Provider.of<UserBloc>(context);

    return WillPopScope(
      onWillPop: () async {
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
            child: _buildBankAccountList()),
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
          Navigator.pop(context);
        },
      ),
      centerTitle: false,
      title: Text(
        AppLocalization.of(context)!.bankAccount,
        style: TextStyle(
            color: blackFont, fontSize: 18, fontWeight: FontWeight.bold),
      ),
      actions: <Widget>[
        openGraphBtn(),
        SizedBox(
          width: 16,
        ),
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
        color: blackFont,
      ),
      onTap: () {
        //for adding new account
        if (bankAccountList.length < 2) {
          Navigator.of(context).pushNamed('/add-account');
        } else {
          showToast(
              message: AppLocalization.of(context)!.youCanAddMaximumTwoAccount);
        }
      },
      backgroundColor: iconBtnGrey,
      enableMargin: true,
    );
  }

  Widget _buildBankAccountList() {
    return noItemInList
        ? NoItemInList(
            msg: AppLocalization.of(context)!.youDontHaveAnyAccountPleaseAddOne,
          )
        : ListView.builder(
            padding: EdgeInsets.symmetric(vertical: 16),
            //+1 for progressbar
            itemCount: bankAccountList.length + 1,
            itemBuilder: (BuildContext context, int index) {
              if (index == bankAccountList.length) {
                return buildLoadingIndicator(isLoading: isLoading);
              } else {
                return _getSlidableWithLists(
                    context,
                    bankAccountTile(
                      account: bankAccountList[index],
                    ),
                    bankAccountList[index]);
              }
            },
            controller: _scrollController,
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
            await _auth.getBankAccountsPagination(next, previous);
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
            bankAccountList.addAll(tempList);
          });
        }
      }
      if (bankAccountList.isEmpty) {
        if (mounted) {
          setState(() {
            noItemInList = true;
          });
        }
      } else if (next == null && bankAccountList.length > 6) {
        _scaffoldKey.currentState!.showSnackBar(SnackBar(
          content:
              Text(AppLocalization.of(context)!.youHaveReachedBottomOfTheList),
          duration: Duration(milliseconds: 500),
        ));
      }
    }
  }

  Widget bankAccountTile({required BankAccount account}) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      shadowColor: boxShadowTwo,
      elevation: 0,
      child: Container(
        decoration: decorateBox(),
        child: ListTile(
          dense: account.isDefault! ? true : false,
          title: getTitle(account: account),
          subtitle: getSubtitle(account: account),
          leading: GestureDetector(
            onTap: () {
              Navigator.of(context)
                  .pushNamed("/photo-viewer", arguments: account.bankAvatar);
            },
            child: ClipOval(
              child: CachedNetworkImage(
                imageUrl: account.bankAvatar!,
                height: 48,
                width: 48,
                colorBlendMode: BlendMode.darken,
                fit: BoxFit.cover,
                filterQuality: FilterQuality.high,
                placeholder: (context, url) => account.bankAvatar == ""
                    ? Icon(
                        Icons.account_balance,
                        size: 45,
                        color: navyBlue,
                      )
                    : CircularLoadingIndicator(),
                errorWidget: imageErrorWidget,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget getTitle({required BankAccount account}) {
    if (account.isDefault!) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            height: 8,
          ),
          Text(
            account.bankName!,
            maxLines: 1,
            style: TextStyle(
                color: blackFont, fontWeight: FontWeight.bold, fontSize: 15),
          ),
        ],
      );
    }
    return Text(
      account.bankName!,
      style: TextStyle(
          color: blackFont, fontWeight: FontWeight.bold, fontSize: 15),
    );
  }

  Widget getSubtitle({required BankAccount account}) {
    if (account.isDefault!) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            height: 4,
          ),
          Text(
            getFormattedAccountNumber(
                accountNumber: account.accountNumber!.toString()),
            style: TextStyle(color: darkGrey, fontSize: 12),
          ),
          SizedBox(
            height: 2,
          ),
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
          accountNumber: account.accountNumber!.toString()),
      style: TextStyle(color: darkGrey, fontSize: 12),
    );
  }

  Widget _getSlidableWithLists(
      BuildContext context, Widget bankAccountTile, BankAccount account) {
    return Slidable(
      controller: _slideController,
      direction: Axis.horizontal,
      actionPane: SlidableBehindActionPane(),
      actionExtentRatio: 0.25,
      child: VerticalListItem(bankAccountTile),
      actions: listActionSlideActions(account: account),
      secondaryActions: listSecondaryActions(account: account),
    );
  }

  List<Widget> listSecondaryActions({required BankAccount account}) {
    return [
      SlideActionButton(
          backgroundColor: naturalGreen,
          icon: Icons.device_hub,
          onTap: account.isDefault!
              ? () {
                  showToast(
                      message: AppLocalization.of(context)!
                          .thisAccountIsAlreadyDefaultAccount);
                }
              : () {
                  updateBankAccount(account);
                },
          title: account.isDefault!
              ? AppLocalization.of(context)!.defaultMsg
              : AppLocalization.of(context)!.makeDefault,
          slideController: _slideController),
    ];
  }

  List<Widget> listActionSlideActions({BankAccount? account}) {
    return [
      SlideActionButton(
          backgroundColor: mateRed,
          icon: SlydoAppIcon.remove,
          onTap: () {
            deleteBankAccount(account);
          },
          title: AppLocalization.of(context)!.delete,
          slideController: _slideController),
    ];
  }

  void deleteBankAccount(BankAccount? account) {
    {
      if (bankAccountList.length == 1) {
        showToast(
            message:
                AppLocalization.of(context)!.youCanNotDeleteOnlyBankAccount);
      } else {
        _auth.deleteBankAccount(account!.uuid!).then((value) {
          if (value) {
            showToast(
                message:
                    AppLocalization.of(context)!.accountDeletedSuccessfully);
            _onRefresh();
          } else {
            showToast(
                message: AppLocalization.of(context)!.accountIsNotDeleted);
          }
        }).catchError((error) {
          showToast(message: error.toString());
        });
      }
    }
  }

  void updateBankAccount(BankAccount account) {
    Map data = {
      "uuid": account.uuid,
      "customer_username": userBloc.user.userName,
      "bank": account.bankName,
      "account_name": account.accountName,
      "account_number": account.accountNumber,
      "is_default": true,
    };
    _auth.updateBankAccount(data).then((value) {
      if (value) {
        showToast(
            message: AppLocalization.of(context)!.accountUpdatedSuccessfully);
        _auth.getBankAccounts().then((accounts) {
          BankAccountBloc bankAccountBloc =
              Provider.of<BankAccountBloc>(context, listen: false);
          bankAccountBloc.bankAccount = accounts[0];
        });
        _onRefresh();
      } else {
        showToast(message: AppLocalization.of(context)!.accountIsNotUpdated);
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
    // unsecureScreen();
    _scrollController.dispose();
    _refreshController.dispose();
    super.dispose();
  }
}
