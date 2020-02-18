import 'package:Slydo/screens/colors.dart';
import 'package:Slydo/screens/tiles/transaction.dart';
import 'package:Slydo/services/auth.dart';
import 'package:Slydo/widget/LoadingIndicator.dart';
import 'package:flutter/material.dart';

class TransactionList extends StatefulWidget {
  @override
  _TransactionListState createState() => _TransactionListState();
}

class _TransactionListState extends State<TransactionList> {
  // Get list of users transactions
  final _auth = AuthService();
  int count = 0;
  String next = "";
  String previous = "";
  List transactionList = [];
  ScrollController _scrollController = new ScrollController();
  bool isLoading = false;

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
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context);
        Navigator.pushNamed(context, '/dashboard');
        return false;
      },
      child: Scaffold(
        backgroundColor: lightBlue(),
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: darkBlue(),
          title: Text('Transactions'),
        ),
        body: _buildTransactionList(),
      ),
    );
  }

  Widget _buildTransactionList() {
    return ListView.builder(
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
      if (next == null) {
        Scaffold.of(context).showSnackBar(SnackBar(
          content: Text("Your have reached at bottom of the list"),
        ));
      }
    }
  }
}
