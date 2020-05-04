import 'package:Slydo/screens/tiles/spend_on_categoty.dart';
import 'package:Slydo/services/auth.dart';
import 'package:Slydo/services/date_time_info.dart';
import 'package:Slydo/widget/bar_chart.dart';
import 'package:charts_flutter/flutter.dart' as charts;
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
  Map<String, num> _measures;

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
              actions: <Widget>[flipCardButton()],
              backgroundColor: darkBlue(),
              title: Text("Transacions Graph")),
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
      key: cardKey,
      flipOnTouch: false,
      direction: FlipDirection.VERTICAL,
      front: firstSide(),
      back: secondSide(),
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
              child: BarChart(arguments: {"week": barChartData}),
            );
          }
          return getSpendOnCategoryTile(categoryAndSpend[index - 2]);
        });
  }

  Widget secondSide() {
    return Container(
        margin: EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 10),
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
        child: lineGraph());
  }

  Widget lineGraph() {
    return Column(children: <Widget>[
      Text(
        'Weekly Spending',
        style: TextStyle(
          fontSize: 16.0,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),

      Expanded(child: chartBuilder()),

//          getSelectedData()
    ]);
  }

  charts.LineChart chartBuilder() {
    List<GraphData> firstData = [
      GraphData(day: 0, amount: 10),
      GraphData(day: 1, amount: 30),
      GraphData(day: 2, amount: 15),
      GraphData(day: 3, amount: 25),
      GraphData(day: 4, amount: 45),
      GraphData(day: 5, amount: 60),
      GraphData(day: 6, amount: 60),
    ];

    List<GraphData> secondData = [
      GraphData(day: 0, amount: 100),
      GraphData(day: 1, amount: 20),
      GraphData(day: 2, amount: 40),
      GraphData(day: 3, amount: 35),
      GraphData(day: 4, amount: 45),
      GraphData(day: 5, amount: 70),
      GraphData(day: 6, amount: 10),
    ];
    var series = [
      charts.Series<GraphData, int>(
          id: "income",
          colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
          domainFn: (GraphData data, _) => data.day,
          measureFn: (GraphData data, _) => data.amount,
          displayName: "Income",
          data: firstData),
      charts.Series<GraphData, int>(
          id: "expenditure",
          colorFn: (_, __) => charts.MaterialPalette.red.shadeDefault,
          domainFn: (GraphData data, _) => data.day,
          measureFn: (GraphData data, _) => data.amount,
          displayName: "Expenditure",
          data: secondData)
    ];

    return charts.LineChart(series,
        domainAxis: new charts.NumericAxisSpec(
          tickFormatterSpec: charts.BasicNumericTickFormatterSpec(
            _formaterDay,
          ),
        ),
        animate: true,
        defaultRenderer: new charts.LineRendererConfig(),
        behaviors: [
//          new charts.SeriesLegend(
//            outsideJustification: charts.OutsideJustification.endDrawArea,
//            horizontalFirst: false,
//            desiredMaxRows: 2,
//            cellPadding: new EdgeInsets.only(right: 4.0, bottom: 4.0),
//            entryTextStyle: charts.TextStyleSpec(
//                color: charts.MaterialPalette.blue.shadeDefault,
//                fontFamily: 'Georgia',
//                fontSize: 11),
//          ),
          new charts.ChartTitle('Days',
              titleStyleSpec: charts.TextStyleSpec(
                  color: charts.MaterialPalette.black,
                  fontFamily: 'Georgia',
                  fontSize: 11),
              behaviorPosition: charts.BehaviorPosition.bottom,
              titleOutsideJustification:
                  charts.OutsideJustification.middleDrawArea),
          new charts.ChartTitle('Amount',
              behaviorPosition: charts.BehaviorPosition.start,
              titleOutsideJustification:
                  charts.OutsideJustification.middleDrawArea),
        ]);
  }

  Widget getSelectedData() {
    List<Widget> widgets = new List();
    _measures.forEach((String series, num value) => Text(""));
  }

  String _formaterDay(num day) {
    switch (day) {
      case 0:
        return "Su";
        break;
      case 1:
        return "Mo";
        break;
      case 2:
        return "Tu";
        break;
      case 3:
        return "We";
        break;
      case 4:
        return "Th";
        break;
      case 5:
        return "Fr";
        break;
      case 6:
        return "Sa";
        break;
    }
    return "Day";
  }

  _onSelectionChanged(charts.SelectionModel model) {
    final selectedDatum = model.selectedDatum;

    final measures = <String, num>{};

    if (selectedDatum.isNotEmpty) {
      selectedDatum.forEach((charts.SeriesDatum datumPair) {
        measures[datumPair.series.displayName] = datumPair.datum.sales;
      });
    }

    // Request a build.
    setState(() {
      _measures = measures;
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

  flipCardButton() {
    return IconButton(
      icon: Icon(Icons.flip),
      onPressed: () {
        cardKey.currentState.toggleCard();
      },
    );
  }
}

class GraphData {
  int day;
  int amount;
  GraphData({this.day, this.amount});
}
