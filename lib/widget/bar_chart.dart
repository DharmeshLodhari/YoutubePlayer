//TODO: APP LOCALIZATION FOR THIS PAGE

import 'package:Slydo/data/currency.dart';
import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/services/auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BarChart extends StatefulWidget {
  @override
  _BarChartState createState() => _BarChartState();
}

class _BarChartState extends State<BarChart> {
  List<double> expenses;
  int start;
  int end;
  String next = "";
  String previous = "";
  double mostExpensive;
  bool isLoading = true;
  final _auth = AuthService();

  @override
  void initState() {
    fetchData();
    super.initState();
  }

  void fetchData() async {
    setState(() {
      isLoading = true;
    });
    _auth
        .getTransactionWeeklyReport(
            baseUrl + "/api/v1/search/use/", next, previous)
        .then((result) {
      setState(() {
        next = result["next"];
        previous = result["previos"];
        start = result["results"]["start"];
        end = result["results"]["end"];
        expenses = result["results"]["expenses"];
        isLoading = false;
        mostExpensive = 0;
        expenses.forEach((double price) {
          if (price > mostExpensive) {
            mostExpensive = price;
          }
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
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
                          'Nov $start, 2019 - Nov $end, 2019',
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
                SizedBox(height: 30.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    Expanded(
                      child: Bar(
                        label: 'Su',
                        amountSpent: expenses[0],
                        mostExpensive: mostExpensive,
                      ),
                    ),
                    Expanded(
                      child: Bar(
                        label: 'Mo',
                        amountSpent: expenses[1],
                        mostExpensive: mostExpensive,
                      ),
                    ),
                    Expanded(
                      child: Bar(
                        label: 'Tu',
                        amountSpent: expenses[2],
                        mostExpensive: mostExpensive,
                      ),
                    ),
                    Expanded(
                      child: Bar(
                        label: 'We',
                        amountSpent: expenses[3],
                        mostExpensive: mostExpensive,
                      ),
                    ),
                    Expanded(
                      child: Bar(
                        label: 'Th',
                        amountSpent: expenses[4],
                        mostExpensive: mostExpensive,
                      ),
                    ),
                    Expanded(
                      child: Bar(
                        label: 'Fr',
                        amountSpent: expenses[5],
                        mostExpensive: mostExpensive,
                      ),
                    ),
                    Expanded(
                      child: Bar(
                        label: 'Sa',
                        amountSpent: expenses[6],
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
    fetchData();
  }

  void fetchNext() {
    fetchData();
  }
}

class Bar extends StatelessWidget {
  final String label;
  final double amountSpent;
  final double mostExpensive;

  final double _maxBarHeight = 150.0;
  UserBloc userBloc;
  Bar({this.label, this.amountSpent, this.mostExpensive});

  @override
  Widget build(BuildContext context) {
    userBloc = Provider.of<UserBloc>(context);
    final barHeight = amountSpent / mostExpensive * _maxBarHeight;
    return Column(
      children: <Widget>[
        Text(
          '${worldCurrencies[userBloc.user.currency]} ${amountSpent.toStringAsFixed(2)}',
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
}
