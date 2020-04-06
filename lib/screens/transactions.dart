import 'package:Slydo/screens/request_payments_list.dart';
import 'package:Slydo/screens/transactions_list.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:toast/toast.dart';

import 'colors.dart';

class Transactions extends StatefulWidget {
  @override
  _TransactionsState createState() => _TransactionsState();
}

class _TransactionsState extends State<Transactions>
    with SingleTickerProviderStateMixin {
  TabController _tabController;
  int currentIndex = 0;
  @override
  void initState() {
    _tabController = new TabController(length: 2, vsync: this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: currentIndex == 0
          ? AppBar(
              automaticallyImplyLeading: false,
              backgroundColor: darkBlue(),
              title: Text('Transactions'),
            )
          : AppBar(
              automaticallyImplyLeading: false,
              backgroundColor: darkBlue(),
              title: Text('Payment Requests'),
              actions: <Widget>[
                sendRequestButton(),
              ],
            ),
//        bottomNavigationBar: TabBar(
//          unselectedLabelColor: Colors.white,
//          labelColor: Colors.amber,
//          tabs: [
//            Tab(icon: Icon(Icons.call)),
//            Tab(
//              icon: Icon(Icons.chat),
//            ),
//          ],
//          controller: _tabController,
//        ),
      body: Column(
        children: <Widget>[
          TabBar(
            onTap: (index) {
              setState(() {
                currentIndex = index;
              });
            },
            controller: _tabController,
            tabs: <Widget>[
              Material(
                  child: Container(
                      height: 50, child: Text("Request Payement list"))),
              Material(child: Text("Send Payement list"))
            ],
          ),
          Expanded(
            child: Container(
              child: TabBarView(
                children: [
                  PaymentRequestList(),
                  TransactionList(),
                ],
                controller: _tabController,
              ),
            ),
          ),
        ],
      ),
    );
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
              Toast.show("Internet Connection is not available", context,
                  gravity: Toast.BOTTOM, backgroundColor: darkBlue());
            }
          });
        },
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
