import 'package:Slydo/data/currency.dart';
import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/screens/tiles/spend_on_categoty.dart';
import 'package:Slydo/services/auth.dart';
import 'package:Slydo/services/date_time_and_money_converter.dart';
import 'package:Slydo/widget/bar_chart.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flip_card/flip_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../utils/colors.dart';

class TransactionGraph extends StatefulWidget {
  @override
  _TransactionGraphState createState() => _TransactionGraphState();
}

class _TransactionGraphState extends State<TransactionGraph> {
  final transactionGraphKey = GlobalKey<ScaffoldState>();
  GlobalKey<FlipCardState> cardKey = GlobalKey<FlipCardState>();
  UserBloc userBloc;

  //variables for category tile
  dynamic categoryAndSpend;
  bool isLoading = true;
  final _auth = AuthService();

  // variable for flipping state management
  bool isFlipped = false;

  //variable for week
  int week;
  DateTime start;
  DateTime end;
  var barChartData;
  Map<String, num> _measures;
  var income;
  var expenditure;
  var firstData = [
    GraphData(day: 0, amount: 0),
    GraphData(day: 1, amount: 0),
    GraphData(day: 2, amount: 0),
    GraphData(day: 3, amount: 0),
    GraphData(day: 4, amount: 0),
    GraphData(day: 5, amount: 0),
    GraphData(day: 6, amount: 0),
  ];
  var secondData = [
    GraphData(day: 0, amount: 0),
    GraphData(day: 1, amount: 0),
    GraphData(day: 2, amount: 0),
    GraphData(day: 3, amount: 0),
    GraphData(day: 4, amount: 0),
    GraphData(day: 5, amount: 0),
    GraphData(day: 6, amount: 0),
  ];

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
        income = result["results"]["income"];
        expenditure = result["results"]["expenditure"];
        isLoading = false;
        loadDataIntoGraph();
      });
    });
  }

  void loadDataIntoGraph() {
    cleanData();

    income.forEach((data) {
      firstData[data["day"] - 1] =
          GraphData(day: data["day"] - 1, amount: data["amount"]);
    });

    expenditure.forEach((data) {
      secondData[data["day"] - 1] =
          GraphData(day: data["day"] - 1, amount: data["amount"]);
    });
  }

  //for cleaning all data from previous fetch
  void cleanData() {
    firstData = [
      GraphData(day: 0, amount: 0),
      GraphData(day: 1, amount: 0),
      GraphData(day: 2, amount: 0),
      GraphData(day: 3, amount: 0),
      GraphData(day: 4, amount: 0),
      GraphData(day: 5, amount: 0),
      GraphData(day: 6, amount: 0),
    ];
    secondData = [
      GraphData(day: 0, amount: 0),
      GraphData(day: 1, amount: 0),
      GraphData(day: 2, amount: 0),
      GraphData(day: 3, amount: 0),
      GraphData(day: 4, amount: 0),
      GraphData(day: 5, amount: 0),
      GraphData(day: 6, amount: 0),
    ];
  }

  @override
  Widget build(BuildContext context) {
    userBloc = Provider.of<UserBloc>(context);
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
              title: Text(AppLocalization.of(context).transactionGraph)),
          body: Column(
            children: <Widget>[
              Container(
                margin: EdgeInsets.fromLTRB(10.0, 8.0, 10.0, 0.0),
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
              ),
              isLoading
                  ? Expanded(
                      child: Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor: AlwaysStoppedAnimation(Colors.white),
                          backgroundColor: lightBlue(),
                        ),
                      ),
                    )
                  : Expanded(
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
      front: isFlipped ? secondSide() : firstSide(),
      back: isFlipped ? firstSide() : secondSide(),
    );
  }

  Widget firstSide() {
    return ListView.builder(
        itemCount: categoryAndSpend.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return Container(
              margin: EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 5),
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
          return getSpendOnCategoryTile(categoryAndSpend[index - 1]);
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
        AppLocalization.of(context).incomeExpenditure,
        style: TextStyle(
          fontSize: 16.0,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
      Expanded(child: chartBuilder()),
      Padding(
        padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            getSelectedData(),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Container(
                      height: 10,
                      width: 10,
                      color: Colors.red,
                    ),
                    SizedBox(
                      width: 2,
                    ),
                    Text(
                      AppLocalization.of(context).expenditure,
                      style: TextStyle(fontSize: 11),
                    )
                  ],
                ),
                Row(
                  children: <Widget>[
                    Container(
                      height: 10,
                      width: 10,
                      color: Colors.blue,
                    ),
                    SizedBox(
                      width: 2,
                    ),
                    Text(
                      AppLocalization.of(context).income,
                      style: TextStyle(fontSize: 11),
                    )
                  ],
                )
              ],
            )
          ],
        ),
      )
    ]);
  }

  charts.LineChart chartBuilder() {
    var series = [
      charts.Series<GraphData, int>(
          id: "income",
          colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
          domainFn: (GraphData data, _) => data.day,
          measureFn: (GraphData data, _) => data.amount,
          displayName: AppLocalization.of(context).income,
          data: firstData),
      charts.Series<GraphData, int>(
          id: "expenditure",
          colorFn: (_, __) => charts.MaterialPalette.red.shadeDefault,
          domainFn: (GraphData data, _) => data.day,
          measureFn: (GraphData data, _) => data.amount,
          displayName: AppLocalization.of(context).expenditure,
          data: secondData)
    ];

    return charts.LineChart(series,
        domainAxis: new charts.NumericAxisSpec(
          tickFormatterSpec: charts.BasicNumericTickFormatterSpec(
            formatDay,
          ),
        ),
        animate: true,
        defaultRenderer: new charts.LineRendererConfig(includePoints: true),
        selectionModels: [
          new charts.SelectionModelConfig(
              type: charts.SelectionModelType.info,
              changedListener: _onSelectionChanged)
        ],
        behaviors: [
          new charts.SelectNearest(
              eventTrigger: charts.SelectionTrigger.tapAndDrag),
          new charts.LinePointHighlighter(
              showHorizontalFollowLine:
                  charts.LinePointHighlighterFollowLineType.none,
              showVerticalFollowLine:
                  charts.LinePointHighlighterFollowLineType.nearest),
          new charts.ChartTitle(AppLocalization.of(context).days,
              titleStyleSpec: charts.TextStyleSpec(
                  lineHeight: 0,
                  color: charts.MaterialPalette.black,
                  fontFamily: 'Georgia',
                  fontSize: 11),
              behaviorPosition: charts.BehaviorPosition.bottom,
              titleOutsideJustification:
                  charts.OutsideJustification.middleDrawArea),
          new charts.ChartTitle(
              AppLocalization.of(context).amount +
                  ' (${worldCurrencies[userBloc.user.currency]})',
              titleStyleSpec: charts.TextStyleSpec(
                  lineHeight: 0,
                  color: charts.MaterialPalette.black,
                  fontFamily: 'Georgia',
                  fontSize: 11),
              behaviorPosition: charts.BehaviorPosition.start,
              titleOutsideJustification:
                  charts.OutsideJustification.middleDrawArea),
        ]);
  }

  Widget getSelectedData() {
    List<Widget> widgets = new List();
    if (_measures != null) {
      _measures.forEach((String series, num value) {
        if (series == "Income") {
          widgets.add(Text(
            "$series : $value",
            style: TextStyle(fontSize: 11, color: Colors.blue),
          ));
        } else {
          widgets.add(Text(
            "$series : $value",
            style: TextStyle(fontSize: 11, color: Colors.red),
          ));
        }
      });
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: widgets,
      );
    }
    return Container();
  }

  String formatDay(num day) {
    switch (day) {
      case 0:
        return AppLocalization.of(context).sundayAbb;
        break;
      case 1:
        return AppLocalization.of(context).mondayAbb;
        break;
      case 2:
        return AppLocalization.of(context).tuesdayAbb;
        break;
      case 3:
        return AppLocalization.of(context).wednesdayAbb;
        break;
      case 4:
        return AppLocalization.of(context).thursdayAbb;
        break;
      case 5:
        return AppLocalization.of(context).fridayAbb;
        break;
      case 6:
        return AppLocalization.of(context).saturdayAbb;
        break;
    }
    return AppLocalization.of(context).day;
  }

  _onSelectionChanged(charts.SelectionModel model) {
    final selectedDatum = model.selectedDatum;
    final measures = <String, num>{};
    if (selectedDatum.isNotEmpty) {
      selectedDatum.forEach((charts.SeriesDatum datumPair) {
        measures[datumPair.series.displayName] = datumPair.datum.amount;
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
      padding: EdgeInsets.fromLTRB(8, 8, 8, 0),
      child: Column(children: <Widget>[
        Text(
          AppLocalization.of(context).weekRange,
          style: TextStyle(
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            Expanded(
              flex: 1,
              child: Center(
                child: IconButton(
                  icon: Icon(Icons.arrow_back),
                  iconSize: 25.0,
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
                  iconSize: 25.0,
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
    start = start.subtract(Duration(days: 7));
    end = end.subtract(Duration(days: 7));
    fetchData(week.toString());
  }

  void fetchNext() {
    week = week + 1;
    start = start.add(Duration(days: 7));
    end = end.add(Duration(days: 7));
    fetchData(week.toString());
  }

  flipCardButton() {
    return IconButton(
      icon: Icon(Icons.flip),
      onPressed: () {
        cardKey.currentState.toggleCard();
        if (!cardKey.currentState.isFront && !isFlipped) {
          isFlipped = true;
        } else {
          isFlipped = false;
        }
      },
    );
  }
}

class GraphData {
  int day;
  int amount;
  GraphData({this.day, this.amount});
}
