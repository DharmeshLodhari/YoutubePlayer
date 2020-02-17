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
  bool isCalled = false;

  @override
  void initState() {
    _scrollController.addListener(() {
      if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
        // CircularProgressIndicator();
        getList();
      }
    });
    super.initState();
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
        body: FutureBuilder(
          future: getList(),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (!snapshot.hasData) {
              return LoadingIndicator();
            } else {
              return ListView.builder(
                controller: _scrollController,
                itemCount: transactionList.length,
                itemBuilder: (BuildContext context, int index) {
                  var item = transactionList[index];

                  return TransactionTile(transaction: item);
                },
              );
            }
          },
        ),
      ),
    );
  }

  getList() {
    if (next != null) {
      Future<Map<String, dynamic>> result = _auth.getTransactions(next, previous);

      result.then((value) {
        count = value['count'];
        next = value['next'];
        previous = value['previous'];
        var tempList = value['results'];
        print(count);
        print(next);
        print(previous);
        print(transactionList);

        transactionList.addAll(tempList);
        print(transactionList.length);
        setState(() {});
        print(transactionList);
      });
      return result;
    } else {
      Scaffold.of(context).showSnackBar(SnackBar(
        content: Text("End Of The List"),
      ));
    }
  }
}
