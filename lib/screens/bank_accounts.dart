import 'package:Slydo/screens/colors.dart';
import 'package:Slydo/screens/tiles/bank_account.dart';
import 'package:Slydo/services/auth.dart';
import 'package:Slydo/splash.dart';
import 'package:flutter/material.dart';
import '../widget/LoadingIndicator.dart';

class BankAccountList extends StatefulWidget {
  @override
  _BankAccountListState createState() => _BankAccountListState();
}

class _BankAccountListState extends State<BankAccountList> {
  // Get list of user bank account
  final _auth = AuthService();

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
          leading: IconButton(
            icon: const Icon(Icons.email),
            onPressed: () {},
          ),
          title: Text('Messages'),
          actions: <Widget>[
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {},
            )
          ],
        ),
        body: FutureBuilder(
          future: _auth.getBankAccounts(),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.data == null) {
              return LoadingIndicator();
            } else {
              return ListView.builder(
                itemCount: snapshot.data.length,
                itemBuilder: (BuildContext context, int index) {
                  var item = snapshot.data[index];
                  return BankAccountTile(account: item);
                },
              );
            }
          },
        ),
        floatingActionButton: addAccountButton(),
      ),
    );
  }

  Widget addAccountButton() {
    return FloatingActionButton(
      backgroundColor: darkBlue(),
      onPressed: () {
        Navigator.of(context).pushNamed('/add-account');
      },
      tooltip: 'Add Account',
      child: Icon(Icons.add),
    );
  }
}
