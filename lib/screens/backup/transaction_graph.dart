import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/screens/tiles/spend_on_categoty.dart';
import 'package:Slydo/services/auth.dart';
import 'package:Slydo/services/date_time_and_money_converter.dart';
import 'package:Slydo/utils/slydo_app_icon_icons.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/LoadingIndicator.dart';
import 'package:Slydo/widget/bar_chart.dart';
import 'package:Slydo/widget/rounded_background_icon.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flip_card/flip_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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

  bool isLineGraph = false;

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
    // return WillPopScope(
    //   onWillPop: () async {
    //     return true;
    //   },
    //   child: Scaffold(
    //       key: transactionGraphKey,
    //       resizeToAvoidBottomInset: true,
    //       backgroundColor: lightGrey,
    //       appBar: appBar(),
    //       body: Column(
    //         children: <Widget>[
    //           Container(
    //             margin: EdgeInsets.fromLTRB(10.0, 8.0, 10.0, 0.0),
    //             decoration: BoxDecoration(
    //               color: Colors.white,
    //               boxShadow: [
    //                 BoxShadow(
    //                   color: Colors.black12,
    //                   offset: Offset(0, 2),
    //                   blurRadius: 6.0,
    //                 ),
    //               ],
    //               borderRadius: BorderRadius.circular(10.0),
    //             ),
    //             child: dateChanger(),
    //           ),
    //           isLoading
    //               ? Expanded(
    //                   child: Center(
    //                     child: CircularLoadingIndicator(),
    //                   ),
    //                 )
    //               : Expanded(
    //                   child: Container(child: flipGraph()),
    //                 ),
    //         ],
    //       )),
    // );
    return WillPopScope(
      onWillPop: () async {
        return true;
      },
      child: Scaffold(
          key: transactionGraphKey,
          resizeToAvoidBottomInset: true,
          backgroundColor: lightGrey,
          appBar: appBar(),
          body: Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Column(
              children: <Widget>[
                Expanded(
                  flex: 2,
                  child: Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    margin: EdgeInsets.zero,
                    shadowColor: boxShadow,
                    elevation: 2,
                    child: Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: dividerColor, width: 0.5)),
                      child: Column(
                        children: [
                          dateChanger(),
                          Divider(
                            height: 0,
                            color: dividerColor,
                            thickness: 1,
                          ),
                          isLoading
                              ? Expanded(
                                  child: Center(
                                    child: CircularLoadingIndicator(),
                                  ),
                                )
                              : Expanded(
                                  child: Container(child: flipGraph()),
                                ),
                        ],
                      ),
                    ),
                  ),
                ),
                // SizedBox(
                //   height: 10,
                // ),
                // Expanded(
                //   child: ListView.builder(
                //       itemCount: categoryAndSpend.length,
                //       itemBuilder: (context, index) {
                //         return getSpendOnCategoryTile(categoryAndSpend[index]);
                //       }),
                // )
                // isLoading
                //     ? Expanded(
                //         child: Center(
                //           child: CircularLoadingIndicator(),
                //         ),
                //       )
                //     : Expanded(
                //         child: Container(child: flipGraph()),
                //       ),
              ],
            ),
          )),
    );
  }

  Widget appBar() {
    return AppBar(
      elevation: 0,
      titleSpacing: 0,
      backgroundColor: Colors.white,
      leading: IconButton(
        icon: Icon(
          Icons.keyboard_arrow_left,
          color: navyBlue,
          size: 24,
        ),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
      centerTitle: false,
      title: Text(
        "Transaction graph",
        style: TextStyle(
            color: blackFont, fontSize: 18, fontWeight: FontWeight.bold),
      ),
      actions: <Widget>[
        flipGraphButton(),
        SizedBox(
          width: 16,
        ),
      ],
    );
  }

  Widget flipGraphButton() {
    return RoundedBackgroundIcon(
      height: 34,
      width: 34,
      icon: Icon(
        SlydoAppIcon.line_graph,
        size: 16,
        color: blackFont,
      ),
      onTap: () {
        cardKey.currentState.toggleCard();

        if (!cardKey.currentState.isFront && !isFlipped) {
          isFlipped = true;
        } else {
          isFlipped = false;
        }
      },
      backgroundColor: iconBtnGrey,
      enableMargin: true,
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
    // return ListView.builder(
    //     itemCount: categoryAndSpend.length + 1,
    //     itemBuilder: (context, index) {
    //       if (index == 0) {
    //         return Container(
    //           margin: EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 5),
    //           decoration: BoxDecoration(
    //             color: Colors.white,
    //             boxShadow: [
    //               BoxShadow(
    //                 color: Colors.black12,
    //                 offset: Offset(0, 2),
    //                 blurRadius: 6.0,
    //               ),
    //             ],
    //             borderRadius: BorderRadius.circular(10.0),
    //           ),
    //           child: BarChart(arguments: {"week": barChartData}),
    //         );
    //       }
    //       return getSpendOnCategoryTile(categoryAndSpend[index - 1]);
    //     });

    return Column(
      children: [
        Container(
          child: BarChart(
            arguments: {"week": barChartData},
          ),
        ),
        SizedBox(
          height: 10,
        ),
        Expanded(
          child: ListView.builder(
              itemCount: categoryAndSpend.length,
              itemBuilder: (context, index) {
                return getSpendOnCategoryTile(categoryAndSpend[index]);
              }),
        )
      ],
    );
  }

  Widget secondSide() {
    // return Container(
    //     margin: EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 10),
    //     decoration: BoxDecoration(
    //       color: Colors.white,
    //       boxShadow: [
    //         BoxShadow(
    //           color: Colors.black12,
    //           offset: Offset(0, 2),
    //           blurRadius: 6.0,
    //         ),
    //       ],
    //       borderRadius: BorderRadius.circular(10.0),
    //     ),
    //     child: lineGraph());
    return Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: lineGraph());
  }

  Widget lineGraph() {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            AppLocalization.of(context).incomeExpenditure,
            style: TextStyle(
                fontSize: 14.0, fontWeight: FontWeight.w600, color: blackFont),
          ),
          SizedBox(
            height: 20,
          ),
          Expanded(child: chartBuilder()),
          SizedBox(
            height: 8,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              getSelectedData(),
              flexibleSpace(),
              Row(
                children: <Widget>[
                  Container(
                    height: 10,
                    width: 10,
                    child: ClipOval(
                      child: Container(
                        color: mateRad,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 8,
                  ),
                  Text(
                    AppLocalization.of(context).expenditure,
                    style: TextStyle(fontSize: 12, color: darkGrey),
                  )
                ],
              ),
              flexibleSpace(),
              Row(
                children: <Widget>[
                  Container(
                    height: 10,
                    width: 10,
                    child: ClipOval(
                      child: Container(
                        color: navyBlue,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 8,
                  ),
                  Text(
                    AppLocalization.of(context).income,
                    style: TextStyle(fontSize: 12, color: darkGrey),
                  )
                ],
              ),
              flexibleSpace(),
            ],
          )
        ]);
  }

  charts.LineChart chartBuilder() {
    // var series = [
    //   charts.Series<GraphData, int>(
    //       id: "income",
    //       colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
    //       domainFn: (GraphData data, _) => data.day,
    //       measureFn: (GraphData data, _) => data.amount,
    //       displayName: AppLocalization.of(context).income,
    //       data: firstData),
    //   charts.Series<GraphData, int>(
    //       id: "expenditure",
    //       colorFn: (_, __) => charts.MaterialPalette.red.shadeDefault,
    //       domainFn: (GraphData data, _) => data.day,
    //       measureFn: (GraphData data, _) => data.amount,
    //       displayName: AppLocalization.of(context).expenditure,
    //       data: secondData)
    // ];
    //
    // return charts.LineChart(series,
    //     domainAxis: new charts.NumericAxisSpec(
    //       tickFormatterSpec: charts.BasicNumericTickFormatterSpec(
    //         formatDay,
    //       ),
    //     ),
    //     animate: true,
    //     defaultRenderer: new charts.LineRendererConfig(includePoints: true),
    //     selectionModels: [
    //       new charts.SelectionModelConfig(
    //           type: charts.SelectionModelType.info,
    //           changedListener: _onSelectionChanged)
    //     ],
    //     behaviors: [
    //       new charts.SelectNearest(
    //           eventTrigger: charts.SelectionTrigger.tapAndDrag),
    //       new charts.LinePointHighlighter(
    //           showHorizontalFollowLine:
    //               charts.LinePointHighlighterFollowLineType.none,
    //           showVerticalFollowLine:
    //               charts.LinePointHighlighterFollowLineType.nearest),
    //       new charts.ChartTitle(AppLocalization.of(context).days,
    //           titleStyleSpec: charts.TextStyleSpec(
    //               lineHeight: 0,
    //               color: charts.MaterialPalette.black,
    //               fontFamily: 'Georgia',
    //               fontSize: 11),
    //           behaviorPosition: charts.BehaviorPosition.bottom,
    //           titleOutsideJustification:
    //               charts.OutsideJustification.middleDrawArea),
    //       new charts.ChartTitle(
    //           AppLocalization.of(context).amount +
    //               ' (${worldCurrencies[userBloc.user.currency]})',
    //           titleStyleSpec: charts.TextStyleSpec(
    //               lineHeight: 0,
    //               color: charts.MaterialPalette.black,
    //               fontFamily: 'Georgia',
    //               fontSize: 11),
    //           behaviorPosition: charts.BehaviorPosition.start,
    //           titleOutsideJustification:
    //               charts.OutsideJustification.middleDrawArea),
    //     ]);
    var series = [
      charts.Series<GraphData, int>(
          id: "income",
          colorFn: (_, __) => charts.Color.fromHex(code: "#3F61DB"),
          domainFn: (GraphData data, _) => data.day,
          measureFn: (GraphData data, _) => data.amount,
          displayName: AppLocalization.of(context).income,
          data: firstData),
      charts.Series<GraphData, int>(
          id: "expenditure",
          colorFn: (_, __) => charts.Color.fromHex(code: "#F35B46"),
          domainFn: (GraphData data, _) => data.day,
          measureFn: (GraphData data, _) => data.amount,
          displayName: AppLocalization.of(context).expenditure,
          data: secondData)
    ];

    return charts.LineChart(series,
        domainAxis: new charts.NumericAxisSpec(
          renderSpec: new charts.SmallTickRendererSpec(
            // Tick and Label styling here.
            labelStyle: new charts.TextStyleSpec(
                fontSize: 12, // size in Pts.
                color: charts.Color.fromHex(code: "#75818F")),

            // Change the line colors to match text color.
            lineStyle: new charts.LineStyleSpec(
              color: charts.Color.fromHex(code: "#EBEDFC"),
            ),
          ),
          tickFormatterSpec: charts.BasicNumericTickFormatterSpec(
            formatDay,
          ),
        ),
        primaryMeasureAxis: new charts.NumericAxisSpec(
          renderSpec: new charts.GridlineRendererSpec(
            // Tick and Label styling here.
            labelStyle: new charts.TextStyleSpec(
                fontSize: 12, // size in Pts.
                color: charts.Color.fromHex(code: "#485465")),

            // Change the line colors to match text color.
            lineStyle: new charts.LineStyleSpec(
              color: charts.Color.fromHex(code: "#EBEDFC"),
            ),
          ),
        ),
        animate: true,
        layoutConfig: charts.LayoutConfig(
          leftMarginSpec:
              charts.MarginSpec.fromPixel(minPixel: 16, maxPixel: 16),
          topMarginSpec: charts.MarginSpec.defaultSpec,
          bottomMarginSpec: charts.MarginSpec.defaultSpec,
          rightMarginSpec:
              charts.MarginSpec.fromPixel(minPixel: 4, maxPixel: 8),
        ),
        defaultRenderer:
            new charts.LineRendererConfig(includePoints: true, radiusPx: 4),
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
          // new charts.ChartTitle(AppLocalization.of(context).days,
          //     titleStyleSpec: charts.TextStyleSpec(
          //         lineHeight: 0,
          //         color: charts.MaterialPalette.black,
          //         fontFamily: 'Georgia',
          //         fontSize: 11),
          //     behaviorPosition: charts.BehaviorPosition.bottom,
          //     titleOutsideJustification:
          //         charts.OutsideJustification.middleDrawArea),
          // new charts.ChartTitle(
          //     AppLocalization.of(context).amount +
          //         ' (${worldCurrencies[userBloc.user.currency]})',
          //     titleStyleSpec: charts.TextStyleSpec(
          //         lineHeight: 0,
          //         color: charts.MaterialPalette.black,
          //         fontFamily: 'Georgia',
          //         fontSize: 11),
          //     behaviorPosition: charts.BehaviorPosition.start,
          //     titleOutsideJustification:
          //         charts.OutsideJustification.middleDrawArea),
        ]);
  }

  Widget getSelectedData() {
    List<Widget> widgets = new List();
    if (_measures != null) {
      _measures.forEach((String series, num value) {
        if (series == "Income") {
          widgets.add(Text(
            "$series : $value",
            style: TextStyle(fontSize: 12, color: navyBlue),
          ));
        } else {
          widgets.add(Text(
            "$series : $value",
            style: TextStyle(fontSize: 12, color: mateRad),
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
        return "S";
        break;
      case 1:
        return "M";
        break;
      case 2:
        return "T";
        break;
      case 3:
        return "W";
        break;
      case 4:
        return "T";
        break;
      case 5:
        return "F";
        break;
      case 6:
        return "S";
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
      icon: SlydoAppIcon.shopping_category,
    );
  }

  Widget dateChanger() {
    // return Column(children: <Widget>[
    //   Text(
    //     AppLocalization.of(context).weekRange,
    //     style: TextStyle(
    //       fontSize: 18.0,
    //       fontWeight: FontWeight.bold,
    //       letterSpacing: 1.2,
    //     ),
    //   ),
    //   Row(
    //     mainAxisAlignment: MainAxisAlignment.spaceAround,
    //     children: <Widget>[
    //       Expanded(
    //         flex: 1,
    //         child: Center(
    //           child: IconButton(
    //             icon: Icon(Icons.arrow_back),
    //             iconSize: 25.0,
    //             onPressed: fetchPrevious,
    //           ),
    //         ),
    //       ),
    //       Expanded(
    //         flex: 3,
    //         child: Center(
    //           child: Text(
    //             '${start.day}/${start.month}/${start.year} - ${end.day}/${end.month}/${end.year}',
    //             style: TextStyle(
    //               fontSize: 14.0,
    //               fontWeight: FontWeight.w600,
    //             ),
    //           ),
    //         ),
    //       ),
    //       Expanded(
    //         flex: 1,
    //         child: Center(
    //           child: IconButton(
    //             icon: Icon(Icons.arrow_forward),
    //             iconSize: 25.0,
    //             onPressed: fetchNext,
    //           ),
    //         ),
    //       ),
    //     ],
    //   ),
    // ]);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          RoundedBackgroundIcon(
            height: 34,
            width: 34,
            icon: Icon(
              Icons.keyboard_arrow_left,
              size: 24,
              color: blackFont,
            ),
            onTap: fetchPrevious,
            backgroundColor: iconBtnGrey,
            enableMargin: false,
          ),
          Column(children: <Widget>[
            Text(
              AppLocalization.of(context).weekRange,
              style: TextStyle(
                  fontSize: 14.0,
                  fontWeight: FontWeight.bold,
                  color: blackFont),
            ),
            SizedBox(
              height: 2,
            ),
            Text(
              '${start.day}/${start.month}/${start.year} - ${end.day}/${end.month}/${end.year}',
              style: TextStyle(fontSize: 12.0, color: blackFont),
            ),
          ]),
          RoundedBackgroundIcon(
            height: 34,
            width: 34,
            icon: Icon(
              Icons.keyboard_arrow_right,
              size: 24,
              color: blackFont,
            ),
            onTap: fetchNext,
            backgroundColor: iconBtnGrey,
            enableMargin: false,
          ),
        ],
      ),
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

  Widget flipCardButton() {
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
