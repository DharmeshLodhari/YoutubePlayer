import 'package:Slydo/screens/tiles/spend_on_categoty.dart';
import 'package:Slydo/services/auth.dart';
import 'package:Slydo/widget/bar_chart.dart';
import 'package:flutter/material.dart';

import 'colors.dart';

class TransactionGraph extends StatefulWidget {
  @override
  _TransactionGraphState createState() => _TransactionGraphState();
}

class _TransactionGraphState extends State<TransactionGraph> {
  final transactionGraphKey = GlobalKey<ScaffoldState>();

  //variables for category tile

  List<Map<String, String>> categoryAndSpend = List<Map<String, String>>();
  bool isLoading = true;
  final _auth = AuthService();

  @override
  void initState() {
    fetchData();
    super.initState();
  }

  void fetchData() {
    String weekNumber = "18";
    _auth.getCategorySpend(weekNumber).then((result) {
      setState(() {
        categoryAndSpend = result["results"]["data"];
        isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return true;
      },
      child: Scaffold(
          key: transactionGraphKey,
          resizeToAvoidBottomInset: true,
          backgroundColor: lightBlue(),
          appBar: AppBar(
              backgroundColor: darkBlue(), title: Text("Transacions Graph")),
          body: isLoading
              ? Center(
                  child: CircularProgressIndicator(
                    backgroundColor: Colors.white,
                  ),
                )
              : Column(
                  children: <Widget>[
                    Expanded(
                      child: Container(
                        child: ListView.builder(
                            itemCount: categoryAndSpend.length + 1,
                            itemBuilder: (context, index) {
                              if (index == 0) {
                                return Container(
                                  margin: EdgeInsets.fromLTRB(
                                      20.0, 20.0, 20.0, 10.0),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black12,
                                        offset: Offset(0, 2),
                                        blurRadius: 6.0,
                                      ),
                                    ],
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                  child: BarChart(),
                                );
                              }
                              return getSpendOnCategoryTile(categoryAndSpend[index - 1]);
                            }),
                      ),
                    ),
                  ],
                )),
    );
  }

  Widget getSpendOnCategoryTile(Map<String, String> categoryAndSpend) {
    return SpendOnCategoryTile(
      name: categoryAndSpend["name"],
      amount: categoryAndSpend["amount"],
      url: categoryAndSpend["url"],
    );
  }
}
