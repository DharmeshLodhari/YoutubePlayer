//TODO: APP LOCALIZATION FOR THIS PAGE

import 'package:Slydo/data/currency.dart';
import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/services/date_time_info.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BarChart extends StatefulWidget {
  var arguments;
  BarChart({this.arguments});
  @override
  _BarChartState createState() => _BarChartState(arguments: arguments);
}

class _BarChartState extends State<BarChart> {
  var arguments;
  _BarChartState({this.arguments});
  UserBloc userBloc;
  List<dynamic> expenses;
  DateTime start;
  DateTime end;
  int week;
  double mostExpensive;
  bool isLoading = true;
  List<double> barData = [0, 0, 0, 0, 0, 0, 0];

  @override
  void initState() {
    DateTime date = DateTime.now();
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

      expenses.forEach((dynamic data) {
        if (data["amount"] > mostExpensive) {
          mostExpensive = double.parse(data["amount"].toString());
        }
      });
      getData(expenses);
    });
  }

  void getData(List<dynamic> expenses) {
    expenses.forEach((data) {
      barData[data["day"] - 1] = double.parse(data["amount"].toString());
    });
  }

  @override
  Widget build(BuildContext context) {
    userBloc = Provider.of<UserBloc>(context);
    return isLoading
        ? Container(
            child: Padding(
              padding: EdgeInsets.all(12.0),
              child: Center(
                child: Column(
                  children: <Widget>[
                    SizedBox(height: 125.0),
                    CircularProgressIndicator(
                      backgroundColor: Colors.white,
                    ),
                    SizedBox(height: 125.0),
                  ],
                ),
              ),
            ),
          )
        : Padding(
            padding: EdgeInsets.all(12.0),
            child: Column(
              children: <Widget>[
                Text(
                  'Weekly Spending Chart (${worldCurrencies[userBloc.user.currency]})',
                  style: TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
                SizedBox(height: 15.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    Expanded(
                      child: Bar(
                        label: 'Su',
                        amountSpent: barData[0],
                        mostExpensive: mostExpensive,
                      ),
                    ),
                    Expanded(
                      child: Bar(
                        label: 'Mo',
                        amountSpent: barData[1],
                        mostExpensive: mostExpensive,
                      ),
                    ),
                    Expanded(
                      child: Bar(
                        label: 'Tu',
                        amountSpent: barData[2],
                        mostExpensive: mostExpensive,
                      ),
                    ),
                    Expanded(
                      child: Bar(
                        label: 'We',
                        amountSpent: barData[3],
                        mostExpensive: mostExpensive,
                      ),
                    ),
                    Expanded(
                      child: Bar(
                        label: 'Th',
                        amountSpent: barData[4],
                        mostExpensive: mostExpensive,
                      ),
                    ),
                    Expanded(
                      child: Bar(
                        label: 'Fr',
                        amountSpent: barData[5],
                        mostExpensive: mostExpensive,
                      ),
                    ),
                    Expanded(
                      child: Bar(
                        label: 'Sa',
                        amountSpent: barData[6],
                        mostExpensive: mostExpensive,
                      ),
                    ),
                  ],
                ),
              ],
            ),
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

class Bar extends StatelessWidget {
  final String label;
  final double amountSpent;
  final double mostExpensive;

  final double _maxBarHeight = 150.0;

  Bar({this.label, this.amountSpent, this.mostExpensive});

  @override
  Widget build(BuildContext context) {
    final barHeight = amountSpent / mostExpensive * _maxBarHeight;
    return Column(
      children: <Widget>[
        Text(
          getAmount(),
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 6.0),
        Container(
          height: barHeight,
          width: 18.0,
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor,
            borderRadius: BorderRadius.circular(6.0),
          ),
        ),
        SizedBox(height: 8.0),
        Text(
          label,
          style: TextStyle(
            fontSize: 16.0,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  String getAmount() {
    //TODO: round of all amount to nearest whole number
    //TODO: enable this function to shorting amount 50000000 == 5M
    //TODO: enable this function to shorting amount 500000 == 500k
    //TODO: enable this function to shorting amount 5.00 == 5
    return amountSpent.toStringAsFixed(2).toString();
  }
}
