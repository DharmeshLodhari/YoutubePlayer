import 'package:Slydo/models/transactions.dart';
import 'package:Slydo/services/auth.dart';
import 'package:Slydo/widget/noItemInList.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:toast/toast.dart';

import 'colors.dart';

class BankAccountList extends StatefulWidget {
  @override
  _BankAccountListState createState() => _BankAccountListState();
}

class _BankAccountListState extends State<BankAccountList> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  // Get list of users bank account
  final _auth = AuthService();
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
          _scrollController.position.maxScrollExtent) {
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
        Toast.show("Internet Connection is not available", context,
            gravity: Toast.BOTTOM, backgroundColor: darkBlue());
        _refreshController.refreshCompleted();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context);
        Navigator.pushNamed(context, '/dashboard',
            arguments: {'dashboardIndex': 5});
        return false;
      },
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: lightBlue(),
        appBar: AppBar(
          backgroundColor: darkBlue(),
          title: Text('Bank Accounts'),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.add),
              onPressed: () {
                //for adding new account
                if (bankAccountList.length < 2) {
                  Navigator.of(context).pushNamed('/add-account');
                } else {
                  Toast.show("You can add maximum two bank account", context,
                      textColor: Colors.white, backgroundColor: darkBlue());
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
            msg: "You Don't have any Bank Account Please Add one",
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
          child: new CircularProgressIndicator(
            backgroundColor: Colors.white,
          ),
        ),
      ),
    );
  }

  void getList() async {
    if (!isLoading) {
      if (next != null && !isLoading) {
        setState(() {
          isLoading = true;
        });
        Map<String, dynamic> result =
            await _auth.getBankAccountsPagination(next, previous);
        count = result['count'];
        next = result['next'];
        previous = result['previous'];
        var tempList = result['results'];
        setState(() {
          isLoading = false;
          bankAccountList.addAll(tempList);
        });
      }
      if (bankAccountList.isEmpty) {
        setState(() {
          noItemInList = true;
        });
      } else if (next == null && bankAccountList.length > 6) {
        _scaffoldKey.currentState.showSnackBar(SnackBar(
          content: Text("Your have reached the end of the list"),
          duration: Duration(milliseconds: 500),
        ));
      }
    }
  }

  Widget bankAccountTile({BankAccount account}) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 40, vertical: 4),
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
                  )
                : CircularProgressIndicator(
                    backgroundColor: Colors.white,
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
            account.bankName.length >= 20
                ? account.bankName.substring(0, 20)
                : account.bankName,
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
            "Default",
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
    String caption = 'delete';
    return [
      IconSlideAction(
          caption: caption,
          color: Colors.red,
          icon: Icons.delete,
          onTap: () async {
            //TODO: CALL DELETE BANK ACCOUNT API
            _onRefresh();
          }),
    ];
  }

  List<Widget> listActionSlideActions({BankAccount account}) {
    return [
      IconSlideAction(
          caption: account.isDefault ? 'Default' : "Make default",
          color: Colors.green,
          icon: Icons.device_hub,
          onTap: account.isDefault
              ? () {
                  Toast.show(
                      "This Account is Alerady Default Account ", context,
                      textColor: Colors.white, backgroundColor: darkBlue());
                }
              : () {
                  //TODO: CALL MAKE DEFAULT BANK ACCOUNT API
                  _onRefresh();
                }),
    ];
  }

  void handleSlideAnimationChanged(Animation<double> slideAnimation) {}

  void handleSlideIsOpenChanged(bool isOpen) {}
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
