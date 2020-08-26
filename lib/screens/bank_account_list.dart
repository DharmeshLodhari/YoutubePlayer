import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/models/transactions.dart';
import 'package:Slydo/services/auth.dart';
import 'package:Slydo/widget/noItemInList.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:toast/toast.dart';

import '../utils/colors.dart';

class BankAccountList extends StatefulWidget {
  @override
  _BankAccountListState createState() => _BankAccountListState();
}

class _BankAccountListState extends State<BankAccountList> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  // Get list of users bank account
  final _auth = AuthService();
  UserBloc userBloc;
  int count = 0;
  String next = "";
  String previous = "";
  List bankAccountList = [];
  ScrollController _scrollController = new ScrollController();
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  bool isLoading = false;
  bool noItemInList = false;

  //slidable tile
  SlidableController slidableController;

  @override
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

    slidableController = SlidableController(
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
        Toast.show(
            AppLocalization.of(context).internetConnectionNotAvailable, context,
            gravity: Toast.BOTTOM, backgroundColor: darkBlue());
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
        backgroundColor: lightBlue(),
        appBar: AppBar(
          backgroundColor: darkBlue(),
          title: Text(AppLocalization.of(context).bankAccount),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.add),
              onPressed: () {
                //for adding new account
                if (bankAccountList.length < 2) {
                  Navigator.of(context).pushNamed('/add-account');
                } else {
                  Toast.show(
                      AppLocalization.of(context).youCanAddMaximumTwoAccount,
                      context,
                      textColor: Colors.white,
                      backgroundColor: darkBlue());
                }
              },
            )
          ],
        ),
        body: SmartRefresher(
            enablePullDown: true,
            header: WaterDropHeader(
              complete: Container(),
              waterDropColor: darkBlue(),
            ),
            controller: _refreshController,
            onRefresh: _onRefresh,
            child: _buildBankAccountList()),
      ),
    );
  }

  Widget _buildBankAccountList() {
    return noItemInList
        ? NoItemInList(
            msg: AppLocalization.of(context).youDontHaveAnyAccountPleaseAddOne,
          )
        : ListView.builder(
            padding: EdgeInsets.symmetric(vertical: 16),
            //+1 for progressbar
            itemCount: bankAccountList.length + 1,
            itemBuilder: (BuildContext context, int index) {
              if (index == bankAccountList.length) {
                return _buildIndicator();
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

  Widget _buildIndicator() {
    return new Padding(
      padding: const EdgeInsets.all(8.0),
      child: new Center(
        child: new Opacity(
          opacity: isLoading ? 1.0 : 00,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            valueColor: AlwaysStoppedAnimation(Colors.white),
            backgroundColor: lightBlue(),
          ),
        ),
      ),
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
        Map<String, dynamic> result =
            await _auth.getBankAccountsPagination(next, previous);
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
        _scaffoldKey.currentState.showSnackBar(SnackBar(
          content:
              Text(AppLocalization.of(context).youHaveReachedBottomOfTheList),
          duration: Duration(milliseconds: 500),
        ));
      }
    }
  }

  Widget bankAccountTile({BankAccount account}) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      child: ListTile(
        dense: true,
        title: getTitle(account: account),
        subtitle: getSubtitle(account: account),
        leading: ClipOval(
          child: CachedNetworkImage(
            imageUrl: account.bankAvatar,
            height: 45,
            width: 45,
            colorBlendMode: BlendMode.darken,
            fit: BoxFit.cover,
            filterQuality: FilterQuality.high,
            placeholder: (context, url) => account.bankAvatar == ""
                ? Icon(
                    Icons.account_balance,
                    size: 45,
                    color: darkBlue(),
                  )
                : CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation(Colors.white),
                    backgroundColor: lightBlue(),
                  ),
          ),
        ),
      ),
    );
  }

  Widget getTitle({BankAccount account}) {
    if (account.isDefault) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            height: 8,
          ),
          Text(
            account.bankName,
            maxLines: 1,
            style: TextStyle(
                color: Colors.black, fontWeight: FontWeight.bold, fontSize: 15),
          ),
        ],
      );
    }
    return Text(
      account.bankName,
      style: TextStyle(
          color: Colors.black, fontWeight: FontWeight.bold, fontSize: 15),
    );
  }

  Widget getSubtitle({BankAccount account}) {
    if (account.isDefault) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            height: 4,
          ),
          Text(
            '******' + account.accountNumber.toString().substring(5, 9),
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
          SizedBox(
            height: 2,
          ),
          Text(
            AppLocalization.of(context).defaultMsg,
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
          SizedBox(
            height: 4,
          ),
        ],
      );
    }
    return Text('******' + account.accountNumber.toString().substring(5, 9));
  }

  Widget _getSlidableWithLists(
      BuildContext context, Widget bankAccountTile, BankAccount account) {
    return Slidable(
      controller: slidableController,
      direction: Axis.horizontal,
      actionPane: SlidableBehindActionPane(),
      actionExtentRatio: 0.25,
      child: VerticalListItem(bankAccountTile),
      actions: listActionSlideActions(account: account),
      secondaryActions: listSecondaryActions(account: account),
    );
  }

  List<Widget> listSecondaryActions({BankAccount account}) {
    String caption = AppLocalization.of(context).delete;
    return [
      IconSlideAction(
          caption: caption,
          color: Colors.red,
          icon: Icons.delete,
          onTap: () {
            deleteBankAccount(account);
          }),
    ];
  }

  void deleteBankAccount(BankAccount account) {
    {
      if (bankAccountList.length == 1) {
        Toast.show(
          AppLocalization.of(context).youCanNotDeleteOnlyBankAccount,
          context,
          backgroundColor: darkBlue(),
          textColor: Colors.white,
        );
      } else {
        _auth.deleteBankAccount(account.uuid).then((value) {
          if (value) {
            Toast.show(
              AppLocalization.of(context).accountDeletedSuccessfully,
              context,
              backgroundColor: darkBlue(),
              textColor: Colors.white,
            );
            _onRefresh();
          } else {
            Toast.show(
              AppLocalization.of(context).accountIsNotDeleted,
              context,
              backgroundColor: darkBlue(),
              textColor: Colors.white,
            );
          }
        }).catchError((error) {
          Toast.show(
            error.toString(),
            context,
            backgroundColor: darkBlue(),
            textColor: Colors.white,
          );
        });
      }
    }
  }

  List<Widget> listActionSlideActions({BankAccount account}) {
    return [
      IconSlideAction(
        caption: account.isDefault
            ? AppLocalization.of(context).defaultMsg
            : AppLocalization.of(context).makeDefault,
        color: Colors.green,
        icon: Icons.device_hub,
        onTap: account.isDefault
            ? () {
                Toast.show(
                    AppLocalization.of(context)
                        .thisAccountIsAlreadyDefaultAccount,
                    context,
                    textColor: Colors.white,
                    backgroundColor: darkBlue());
              }
            : () {
                updateBankAccount(account);
              },
      ),
    ];
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
        Toast.show(
          AppLocalization.of(context).accountUpdatedSuccessfully,
          context,
          backgroundColor: darkBlue(),
          textColor: Colors.white,
        );
        _auth.getBankAccounts().then((accounts) {
          BankAccountBloc bankAccountBloc =
              Provider.of<BankAccountBloc>(context, listen: false);
          bankAccountBloc.bankAccount = accounts[0];
        });
        _onRefresh();
      } else {
        Toast.show(
          AppLocalization.of(context).accountIsNotUpdated,
          context,
          backgroundColor: darkBlue(),
          textColor: Colors.white,
        );
      }
    }).catchError((error) {
      Toast.show(
        error.toString(),
        context,
        backgroundColor: darkBlue(),
        textColor: Colors.white,
      );
    });
    _onRefresh();
  }

  void handleSlideAnimationChanged(Animation<double> slideAnimation) {}

  void handleSlideIsOpenChanged(bool isOpen) {}

  @override
  void dispose() {
    _scrollController.dispose();
    _refreshController.dispose();
    super.dispose();
  }
}

class VerticalListItem extends StatelessWidget {
  VerticalListItem(this.child);
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () =>
          Slidable.of(context)?.renderingMode == SlidableRenderingMode.none
              ? Slidable.of(context)?.open()
              : Slidable.of(context)?.close(),
      child: Container(
        color: lightBlue(),
        child: child,
      ),
    );
  }
}
