import 'dart:convert';

import 'package:PayBay/models/transactions.dart';
import 'package:PayBay/screens/tiles/bank_account.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;


class BankAccountList extends StatefulWidget {
  @override
  _BankAccountListState createState() => _BankAccountListState();
}


class _BankAccountListState extends State<BankAccountList> {
  // Get list of user bank account
  int _currentIndex = 1;

  Future<List<BankAccount>> _getBankAccounts() async {
    final String accountsURL = "https://api.mockaroo.com/api/dc0e65c0?count=4&key=b81ba250";
    var response = await http.get(accountsURL);

    List<BankAccount> accounts = [];
    if (response.statusCode == 200) {
      var jsonData = json.decode(response.body);

      for(var item in jsonData) {
        BankAccount account = BankAccount(
            bankAvatar: item['bankAvatar'],
            uuid: item['uuid'],
            bankName: item['bankName'],
            accountName: item['accountName'],
            accountNumber: int.parse(item['accountNumber']));
        accounts.add(account);
      }

      return accounts;
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
        title: Text('My Bank Accounts'),
      ),
      body: FutureBuilder(
        future: _getBankAccounts(),
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
                return BankAccountTile(account: item);
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
      ),

    );
  }
}
