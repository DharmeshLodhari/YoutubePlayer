import 'dart:convert';

import 'package:PayBay/models/transactions.dart';
import 'package:PayBay/screens/tiles/transaction.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;



class TransactionList extends StatefulWidget {
  @override
  _TransactionListState createState() => _TransactionListState();
}


class _TransactionListState extends State<TransactionList> {
  // Get list of users transactions
  int _currentIndex = 2;

  Future<List<Transaction>> _getTransactions() async {
    final String transactionsURL = "https://api.mockaroo.com/api/a2960430?count=10&key=b81ba250";
    var response = await http.get(transactionsURL);

    List<Transaction> transactions = [];
    if (response.statusCode == 200) {
      var jsonData = json.decode(response.body);

      for(var item in jsonData){
        Transaction transaction = Transaction(status: item['status'], uuid: item['uuid'],
              description: item['description'], payee: item['payee'], payeeUrl: item['payeeUrl'],
              currency: item['currency'], amount: item['amount'], isCredit: item['isCredit']);
        transactions.add(transaction);
      }

      return transactions;
    }else{
      throw "Can't get https.";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: Text('Transactions'),
      ),
      body: FutureBuilder(
        future: _getTransactions(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.data == null) {
            return Container(
              child: Text('missing'),
            );
          } else {
            return ListView.builder(
              itemCount: snapshot.data.length,
              itemBuilder: (BuildContext context, int index){
                var item = snapshot.data[index];
                return TransactionTile(transaction: item);
              },
            );
           }
        },
      ),
// TODO: Find a better way to do this without duplication
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });

          String path = _currentIndex.toString();

          switch (path) {
            case '0':
              return Navigator.of(context).pushNamed('/profile');
            case '1':
              return Navigator.of(context).pushNamed('/accounts');
            case '2':
              return Navigator.of(context).pushNamed('/transactions');
            case '3':
              return Navigator.of(context).pushNamed('/settings');
            default:
            // If there is no such named route in the switch statement, e.g. /third
              return Navigator.of(context).pushNamed('/profile');
          }
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home,
              color: Colors.grey[400],),
            title: Text('Home', style: TextStyle(color: Colors.grey[400], fontSize: 12)),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.group,
                color: Colors.grey[400]),
            title: Text('Accounts', style: TextStyle(color: Colors.grey[400], fontSize: 12)),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart,
                color: Colors.grey[400]
            ),
            title: Text('Transactions', style: TextStyle(color: Colors.grey[400], fontSize: 12)),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings,
                color: Colors.grey[400]
            ),
            title: Text('Settings', style: TextStyle(color: Colors.grey[400], fontSize: 12)),
          ),
        ],
      ),    );
  }
}

