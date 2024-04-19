import 'package:Slydo/data/currency.dart';
import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/utils/date_time_and_money_converter.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/loading_indicator.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// ignore: must_be_immutable
class BarChart extends StatefulWidget {
  final dynamic arguments;

  BarChart({this.arguments});

  @override
  _BarChartState createState() => _BarChartState(arguments: arguments);
}

class _BarChartState extends State<BarChart> {
  Map<String, dynamic> arguments;

  _BarChartState({required this.arguments});

  late UserBloc userBloc;
  List<dynamic>? expenses;
  late DateTime start;
  late DateTime end;
  late int week;
  double? mostExpensive;
  bool isLoading = true;
  List<double> barData = [0, 0, 0, 0, 0, 0, 0];
  bool isDataIsZero = false;

  @override
  void initState() {
    final DateTime date = DateTime.now();
    week = weekNumber(date);
    start = getStartingOfWeek(date);
    end = getEndingOfWeek(date);
    fetchData(week.toString());
    super.initState();
  }

  void fetchData(String week) async {
    setState(() {
      isLoading = true;
    });

    setState(() {
      expenses = arguments["week"];
      isLoading = false;
      mostExpensive = 0;
      barData = [0, 0, 0, 0, 0, 0, 0];

      expenses!.forEach((dynamic data) {
        if (data["amount"] > mostExpensive) {
          mostExpensive = double.parse(data["amount"].toString());
        }
      });
      getData(expenses!);
    });
  }

  void getData(List<dynamic> expenses) {
    expenses.forEach((data) {
      final amount = double.parse(data["amount"].toString());
      if (amount >= 0.01) {
        setState(() {
          isDataIsZero = true;
        });
      }
      barData[data["day"] - 1] = double.parse(data["amount"].toString());
    });
  }

  @override
  Widget build(BuildContext context) {
    userBloc = Provider.of<UserBloc>(context);
    return isLoading
        ? Container(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Center(
                child: Column(
                  children: <Widget>[
                    const SizedBox(height: 125.0),
                    CircularLoadingIndicator(),
                    const SizedBox(height: 125.0),
                  ],
                ),
              ),
            ),
          )
        : isDataIsZero
            ? barChart()
            : noDataPresent();
  }

  Widget barChart() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Text(
                AppLocalization.of(context)!.expenditure,
                style: TextStyle(
                    fontSize: 14.0,
                    fontWeight: FontWeight.w600,
                    color: blackFont),
              ),
              Text(
                ' (${worldCurrencies[userBloc.user.currency!]})',
                style: TextStyle(
                    fontFamily: "Inter",
                    fontSize: 14.0,
                    fontWeight: FontWeight.w600,
                    color: blackFont),
              ),
            ],
          ),
          const SizedBox(height: 15.0),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Bar(
                label: "S",
                amountSpent: barData[0],
                mostExpensive: mostExpensive,
              ),
              flexibleSpace(),
              Bar(
                label: "M",
                amountSpent: barData[1],
                mostExpensive: mostExpensive,
              ),
              flexibleSpace(),
              Bar(
                label: "T",
                amountSpent: barData[2],
                mostExpensive: mostExpensive,
              ),
              flexibleSpace(),
              Bar(
                label: "W",
                amountSpent: barData[3],
                mostExpensive: mostExpensive,
              ),
              flexibleSpace(),
              Bar(
                label: "T",
                amountSpent: barData[4],
                mostExpensive: mostExpensive,
              ),
              flexibleSpace(),
              Bar(
                label: "F",
                amountSpent: barData[5],
                mostExpensive: mostExpensive,
              ),
              flexibleSpace(),
              Bar(
                label: "S",
                amountSpent: barData[6],
                mostExpensive: mostExpensive,
              ),
            ],
          ),
        ],
      ),
    );
  }

  void fetchPrevious() {
    week = week - 1;
    start = start.subtract(const Duration(days: 7));
    end = end.subtract(const Duration(days: 7));
    fetchData(week.toString());
  }

  void fetchNext() {
    week = week + 1;
    start = start.add(const Duration(days: 7));
    end = end.add(const Duration(days: 7));
    fetchData(week.toString());
  }

  Widget noDataPresent() {
    return Padding(
        padding: const EdgeInsets.all(20.0),
        child: Container(
          height: 200,
          child: Center(
            child: Text(
              AppLocalization.of(context)!.noTransactionDoneThisWeek,
              style: const TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ));
  }
}

class Bar extends StatefulWidget {
  final String? label;
  final double? amountSpent;
  final double? mostExpensive;

  Bar({this.label, this.amountSpent, this.mostExpensive});

  @override
  _BarState createState() => _BarState();
}

class _BarState extends State<Bar> {
  final double _maxBarHeight = 200.0;
  bool showAmount = false;

  @override
  Widget build(BuildContext context) {
    final barHeight = getBarHeight();
    return GestureDetector(
      onTapDown: (tap) {
        showAmount = !showAmount;
        setState(() {});
      },
      onTapUp: (tap) {
        showAmount = !showAmount;
        setState(() {});
      },
      child: Column(
        children: <Widget>[
          if (showAmount)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8), color: blackFont),
              child: Text(
                moneyConverter(widget.amountSpent.toString()),
                style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
            )
          else
            Container(height: 20),
          const SizedBox(height: 6.0),
          Container(
            height: barHeight,
            width: 22.0,
            decoration: BoxDecoration(
              color: naturalGreen,
              borderRadius: BorderRadius.circular(30.0),
            ),
          ),
          const SizedBox(height: 8.0),
          Text(
            widget.label!,
            style: TextStyle(fontSize: 12.0, color: darkGrey),
          ),
        ],
      ),
    );
  }

  double getBarHeight() {
    if (widget.amountSpent != 0 && widget.mostExpensive != 0) {
      return widget.amountSpent! / widget.mostExpensive! * _maxBarHeight;
    }
    return 1.0;
  }
}
