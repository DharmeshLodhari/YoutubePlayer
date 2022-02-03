import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/screens/more_apps/payment_and_banking/payment_and_banking_auth.dart';
import 'package:Slydo/screens/more_apps/payment_and_banking/tiles/spend_on_categoty.dart';
import 'package:Slydo/utils/date_time_and_money_converter.dart';
import 'package:Slydo/utils/slydo_app_icon_icons.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/LoadingIndicator.dart';
import 'package:Slydo/widget/bar_chart.dart';
import 'package:Slydo/widget/rounded_background_icon.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flip_card/flip_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../utils/colors.dart';

class TransactionGraph extends StatefulWidget {
  @override
  _TransactionGraphState createState() => _TransactionGraphState();
}

class _TransactionGraphState extends State<TransactionGraph> {
  final transactionGraphKey = GlobalKey<ScaffoldState>();
  GlobalKey<FlipCardState> cardKey = GlobalKey<FlipCardState>();
  UserBloc? userBloc;

  //variables for category tile
  dynamic categoryAndSpend = [];
  bool isLoading = true;
  final _auth = PaymentAndBankingAuth();

  // variable for flipping state management
  bool isFlipped = false;

  bool isLineGraph = false;

  // for to hide and show graph lines
  bool showIncome = true;
  bool showExpenditure = true;

  //variable for week
  late int week;
  late DateTime start;
  late DateTime end;
  var barChartData;
  Map<String?, num?>? _measures;
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
        categoryAndSpend = result!["results"]["categories"];
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
          backgroundColor: lightGrey,
          appBar: appBar() as PreferredSizeWidget?,
          body: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Column(
                children: <Widget>[
                  Card(
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
                              ? Container(
                                  height: 240,
                                  child: Center(
                                    child: CircularLoadingIndicator(),
                                  ),
                                )
                              : Container(
                                  child:
                                      !isLineGraph ? firstSide() : secondSide(),
                                ),
                        ],
                      ),
                    ),
                  ),
                  !isLineGraph
                      ? SizedBox(
                          height: 10,
                        )
                      : Container(),
                  !isLineGraph
                      ? Column(
                          children: categoryAndSpend
                              .map<Widget>((category) =>
                                  getSpendOnCategoryTile(category))
                              .toList(),
                        )
                      : Container(),
                ],
              ),
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
        isLineGraph ? SlydoAppIcon.graph : SlydoAppIcon.line_graph,
        size: 16,
        color: blackFont,
      ),
      onTap: () {
        // cardKey.currentState.toggleCard();
        isLineGraph = !isLineGraph;
        setState(() {});
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
      front: firstSide(),
      back: secondSide(),
    );
  }

  Widget firstSide() {
    return Container(
      child: BarChart(
        arguments: {"week": barChartData},
      ),
    );
  }

  Widget secondSide() {
    return Container(
        height: MediaQuery.of(context).size.height / 1.35,
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: lineGraph());
  }

  Widget lineGraph() {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            AppLocalization.of(context)!.incomeExpenditure,
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
              GestureDetector(
                child: Row(
                  children: <Widget>[
                    Container(
                      height: 10,
                      width: 10,
                      child: ClipOval(
                        child: Container(
                          color: mateRed,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 8,
                    ),
                    Text(
                      AppLocalization.of(context)!.expenditure,
                      style: TextStyle(fontSize: 12, color: darkGrey),
                    )
                  ],
                ),
                onTap: () {
                  showExpenditure = !showExpenditure;
                  setState(() {});
                },
              ),
              flexibleSpace(),
              GestureDetector(
                child: Row(
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
                      AppLocalization.of(context)!.income,
                      style: TextStyle(fontSize: 12, color: darkGrey),
                    )
                  ],
                ),
                onTap: () {
                  showIncome = !showIncome;
                  setState(() {});
                },
              ),
              flexibleSpace(),
            ],
          )
        ]);
  }

  Widget chartBuilder() {
    List<charts.Series<dynamic, num>> series = [
      charts.Series<GraphData, num>(
          id: "income",
          colorFn: (_, __) => charts.Color.fromHex(code: "#3F61DB"),
          domainFn: (GraphData data, _) => data.day!,
          measureFn: (GraphData data, _) => data.amount,
          displayName: AppLocalization.of(context)!.income,
          data: firstData),
      charts.Series<GraphData, int>(
          id: "expenditure",
          colorFn: (_, __) => charts.Color.fromHex(code: "#F35B46"),
          domainFn: (GraphData data, _) => data.day!,
          measureFn: (GraphData data, _) => data.amount,
          displayName: AppLocalization.of(context)!.expenditure,
          data: secondData)
    ];

    if (showIncome && showExpenditure) {
      series = [
        charts.Series<GraphData, int>(
            id: "income",
            colorFn: (_, __) => charts.Color.fromHex(code: "#3F61DB"),
            domainFn: (GraphData data, _) => data.day!,
            measureFn: (GraphData data, _) => data.amount,
            displayName: AppLocalization.of(context)!.income,
            data: firstData),
        charts.Series<GraphData, int>(
            id: "expenditure",
            colorFn: (_, __) => charts.Color.fromHex(code: "#F35B46"),
            domainFn: (GraphData data, _) => data.day!,
            measureFn: (GraphData data, _) => data.amount,
            displayName: AppLocalization.of(context)!.expenditure,
            data: secondData)
      ];
    } else if (!showIncome && showExpenditure) {
      series = [
        charts.Series<GraphData, int>(
            id: "expenditure",
            colorFn: (_, __) => charts.Color.fromHex(code: "#F35B46"),
            domainFn: (GraphData data, _) => data.day!,
            measureFn: (GraphData data, _) => data.amount,
            displayName: AppLocalization.of(context)!.expenditure,
            data: secondData)
      ];
    } else if (!showExpenditure && showIncome) {
      series = [
        charts.Series<GraphData, int>(
            id: "income",
            colorFn: (_, __) => charts.Color.fromHex(code: "#3F61DB"),
            domainFn: (GraphData data, _) => data.day!,
            measureFn: (GraphData data, _) => data.amount,
            displayName: AppLocalization.of(context)!.income,
            data: firstData),
      ];
    } else {
      series = [];
    }

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
                fontSize: 10, // size in Pts.
                color: charts.Color.fromHex(code: "#485465")),
            labelOffsetFromAxisPx: -2,
            // Change the line colors to match text color.
            lineStyle: new charts.LineStyleSpec(
              color: charts.Color.fromHex(code: "#EBEDFC"),
            ),
          ),
        ),
        animate: true,
        layoutConfig: charts.LayoutConfig(
          leftMarginSpec:
              charts.MarginSpec.fromPixel(minPixel: 36, maxPixel: 36),
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
        ]);
  }

  Widget getSelectedData() {
    List<Widget> widgets = [];
    if (_measures != null) {
      _measures!.forEach((String? series, num? value) {
        if (series == "Income") {
          widgets.add(Text(
            "$series : $value",
            style: TextStyle(fontSize: 12, color: navyBlue),
          ));
        } else {
          widgets.add(Text(
            "$series : $value",
            style: TextStyle(fontSize: 12, color: mateRed),
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

  String formatDay(num? day) {
    switch (day) {
      case 0:
        return "S";

      case 1:
        return "M";

      case 2:
        return "T";

      case 3:
        return "W";

      case 4:
        return "T";

      case 5:
        return "F";

      case 6:
        return "S";
    }
    return AppLocalization.of(context)!.day;
  }

  _onSelectionChanged(charts.SelectionModel model) {
    final selectedDatum = model.selectedDatum;
    final measures = <String?, num?>{};
    if (selectedDatum.isNotEmpty) {
      selectedDatum.forEach((charts.SeriesDatum datumPair) {
        measures[datumPair.series.displayName] =
            datumPair.datum.referenceNumber;
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
        amount: categoryAndSpend["amount"],
        icon: getCategoryIcon(categoryAndSpend["category"]),
        color: getCategoryIconColor(categoryAndSpend["category"]));
  }

  IconData getCategoryIcon(String? category) {
    switch (category) {
      case "Bills":
        return SlydoAppIcon.bills_category;

      case "Charity":
        return SlydoAppIcon.charity_category;

      case "Eat out":
        return SlydoAppIcon.eatingout_category;

      case "Entertainment":
        return SlydoAppIcon.entertainment_category;

      case "Family":
        return SlydoAppIcon.family_category;

      case "Finance":
        return SlydoAppIcon.finances_category;

      case "General":
        return SlydoAppIcon.general_category;

      case "Groceries":
        return SlydoAppIcon.gorceries_category;

      case "Holidays":
        return SlydoAppIcon.holidays_category;

      case "Personal Care":
        return SlydoAppIcon.personalcare_category;

      case "Shopping":
        return SlydoAppIcon.shopping_category;

      case "Transportation":
        return SlydoAppIcon.transport_category;

      default:
        return SlydoAppIcon.shopping_category;
    }
  }

  Color getCategoryIconColor(String? category) {
    switch (category) {
      case "Bills":
        return HexColor("#3F61DB");

      case "Charity":
        return HexColor("#F07097");

      case "Eat out":
        return HexColor("#9B51E0");

      case "Entertainment":
        return HexColor("#FFAB00");

      case "Family":
        return HexColor("#F35B46");

      case "Finance":
        return HexColor("#5218E9");

      case "General":
        return HexColor("#EE78BF");

      case "Groceries":
        return HexColor("#46CE7C");

      case "Holidays":
        return HexColor("#3F61DB");

      case "Personal Care":
        return HexColor("#FFAB00");

      case "Shopping":
        return HexColor("#F07097");

      case "Transportation":
        return HexColor("#374677");

      default:
        return HexColor("#3F61DB");
    }
  }

  Widget dateChanger() {
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
              AppLocalization.of(context)!.weekRange,
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
    // isLineGraph = false;
    // setState(() {});
  }

  void fetchNext() {
    week = week + 1;
    start = start.add(Duration(days: 7));
    end = end.add(Duration(days: 7));
    fetchData(week.toString());
    // isLineGraph = false;
    // setState(() {});
  }

  Widget flipCardButton() {
    return IconButton(
      icon: Icon(Icons.flip),
      onPressed: () {
        cardKey.currentState!.toggleCard();
        isLineGraph = !isLineGraph;
        setState(() {});
      },
    );
  }
}

class GraphData {
  int? day;
  int? amount;

  GraphData({required int? day, required int? amount}) {
    this.day = day;
    this.amount = moneyDisplayNormalizerForGraph(amount);
  }
}
