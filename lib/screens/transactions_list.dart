import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/screens/colors.dart';
import 'package:Slydo/screens/tiles/transaction.dart';
import 'package:Slydo/services/auth.dart';
import 'package:Slydo/widget/noItemInList.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:toast/toast.dart';

class TransactionList extends StatefulWidget {
  @override
  _TransactionListState createState() => _TransactionListState();
}

class _TransactionListState extends State<TransactionList> {
  final GlobalKey<ScaffoldState> _scaffoldTransactionKey =
      new GlobalKey<ScaffoldState>();
  // Get list of users transactions
  final _auth = AuthService();
  int count = 0;
  String next = "";
  String previous = "";
  List transactionList = [];
  ScrollController _scrollController = new ScrollController();
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  bool isLoading = false;
  bool noItemInList = false;
  RefreshBlocForTransaction _refreshBloc;

  @override
  void initState() {
    getList();

    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        getList();
      }
    });
  }

  // refresh the list when lifecycle called onResume method
  void _onRefreshOnResume() {
    _refreshBloc = Provider.of<RefreshBlocForTransaction>(context);
    _refreshBloc
      ..addListener(() {
        if (_refreshBloc.isRefresh) {
          _onRefresh();
          _refreshBloc.isRefresh = false;
        }
      });
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
        transactionList = [];
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
    // refresh the list when lifecycle called onResume method
    _onRefreshOnResume();

    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context);
        Navigator.pushNamed(context, '/dashboard');
        return false;
      },
      child: Scaffold(
        key: _scaffoldTransactionKey,
        backgroundColor: lightBlue(),
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: darkBlue(),
          title: Text('Transactions'),
        ),
        body: SmartRefresher(
            enablePullDown: true,
            header: WaterDropHeader(
              complete: Container(),
              waterDropColor: darkBlue(),
            ),
            controller: _refreshController,
            onRefresh: _onRefresh,
            child: _buildTransactionList()),
      ),
    );
  }

  Widget _buildTransactionList() {
    return noItemInList
        ? NoItemInList(
            msg: "Transaction history empty",
          )
        : Container(
            padding: EdgeInsets.symmetric(vertical: 4),
            child: ListView.builder(
              //+1 for progressbar
              itemCount: transactionList.length + 1,
              itemBuilder: (BuildContext context, int index) {
                if (index == transactionList.length) {
                  return _buildIndicator();
                } else {
                  return TransactionTile(
                    transaction: transactionList[index],
                  );
                }
              },
              controller: _scrollController,
            ),
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
            await _auth.getTransactions(next, previous);
        count = result['count'];
        next = result['next'];
        previous = result['previous'];
        var tempList = result['results'];
        setState(() {
          isLoading = false;
          transactionList.addAll(tempList);
        });
      }
      if (transactionList.isEmpty) {
        setState(() {
          noItemInList = true;
        });
      } else if (next == null && transactionList.length > 6) {
        _scaffoldTransactionKey.currentState.showSnackBar(SnackBar(
          content: Text("Your have reached the end of the list"),
          duration: Duration(milliseconds: 500),
        ));
      }
    } else {
      setState(() {
        isLoading = false;
        getList();
      });
    }
  }
}
