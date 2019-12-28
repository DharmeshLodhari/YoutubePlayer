import 'package:PayBay/screens/tiles/bank_account.dart';
import 'package:flutter/material.dart';



class BankAccountList extends StatefulWidget {
  @override
  _BankAccountListState createState() => _BankAccountListState();
}

class _BankAccountListState extends State<BankAccountList> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: Text('My Bank Accounts'),
      ),
      body: ListView.builder(
        itemBuilder: (context, index) {
          return BankAccountTile();
        },
        itemCount: 10,
      ),
    );
  }
}

