import 'package:Slydo/screens/tiles/spend_on_categoty.dart';
import 'package:Slydo/services/auth.dart';
import 'package:Slydo/services/date_time_info.dart';
import 'package:Slydo/widget/bar_chart.dart';
import 'package:flip_card/flip_card.dart';
import 'package:flutter/material.dart';

import 'colors.dart';

class TransactionGraph extends StatefulWidget {
  @override
  _TransactionGraphState createState() => _TransactionGraphState();
}

class _TransactionGraphState extends State<TransactionGraph> {
  final transactionGraphKey = GlobalKey<ScaffoldState>();
  GlobalKey<FlipCardState> cardKey = GlobalKey<FlipCardState>();

  //variables for category tile
  dynamic categoryAndSpend;
  bool isLoading = true;
  final _auth = AuthService();

  //variable for week
  int week;
  DateTime start;
  DateTime end;
  var barChartData;

  @override
  void initState() {
    DateTime date = DateTime.now();
    week = weekNumber(date);
    start = getStartingOfWeek(date);
    end = getEndingOfWeek(date);
    fetchData(week.toString());
    super.initState();
  }

  void fetchData(String week) {
    setState(() {
      isLoading = true;
    });
    _auth.getTransactionWeeklyReport(week).then((result) {
      setState(() {
        categoryAndSpend = result["results"]["categories"];
        barChartData = result["results"]["week"];
        debugPrint("$categoryAndSpend");
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
                      child: Container(child: flipGraph()),
                    ),
                  ],
                )),
    );
  }

  Widget flipGraph() {
    return FlipCard(
      front: firstSide(),
      back: Container(),
    );
  }

  Widget firstSide() {
    return ListView.builder(
        itemCount: categoryAndSpend.length + 2,
        itemBuilder: (context, index) {
          if (index == 0) {
            return Container(
              margin: EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 0.0),
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
              child: dateChanger(),
            );
          }
          if (index == 1) {
            return Container(
              margin: EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 10.0),
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
              child: BarChart(arguments: {"week": barChartData}),
            );
          }
          return getSpendOnCategoryTile(categoryAndSpend[index - 2]);
        });
  }

  Widget getSpendOnCategoryTile(Map<String, dynamic> categoryAndSpend) {
    return SpendOnCategoryTile(
      name: categoryAndSpend["category"],
      amount: categoryAndSpend["amount"].toString(),
//      url: categoryAndSpend["url"],
      url: "assets/images/category/bills.png",
    );
  }

  Widget dateChanger() {
    return Padding(
      padding: EdgeInsets.all(12.0),
      child: Column(children: <Widget>[
        Text(
          'Weekly Spending',
          style: TextStyle(
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        SizedBox(height: 5.0),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            Expanded(
              flex: 1,
              child: Center(
                child: IconButton(
                  icon: Icon(Icons.arrow_back),
                  iconSize: 30.0,
                  onPressed: fetchPrevious,
                ),
              ),
            ),
            Expanded(
              flex: 3,
              child: Center(
                child: Text(
                  '${start.day}/${start.month}/${start.year} - ${end.day}/${end.month}/${end.year}',
                  style: TextStyle(
                    fontSize: 14.0,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Center(
                child: IconButton(
                  icon: Icon(Icons.arrow_forward),
                  iconSize: 30.0,
                  onPressed: fetchNext,
                ),
              ),
            ),
          ],
        ),
      ]),
    );
  }

  void fetchPrevious() {
    week = week - 1;
    debugPrint("privious: " + week.toString());
    start = start.subtract(Duration(days: 7));
    end = end.subtract(Duration(days: 7));
    fetchData(week.toString());
  }

  void fetchNext() {
    week = week + 1;
    debugPrint("next: " + week.toString());
    start = start.add(Duration(days: 7));
    end = end.add(Duration(days: 7));
    fetchData(week.toString());
  }
}
