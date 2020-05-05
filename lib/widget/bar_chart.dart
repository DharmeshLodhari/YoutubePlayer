import 'package:Slydo/data/currency.dart';
import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/services/date_time_and_money_converter.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// ignore: must_be_immutable
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
  bool isDataIsZero = false;

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
      var amount = double.parse(data["amount"].toString());
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
        : isDataIsZero ? barChart() : noDataPresent();
  }

  Widget barChart() {
    return Padding(
      padding: EdgeInsets.all(12.0),
      child: Column(
        children: <Widget>[
          Text(
            AppLocalization.of(context).weeklySpendingChart +
                ' (${worldCurrencies[userBloc.user.currency]})',
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
                  label: AppLocalization.of(context).sundayAbb,
                  amountSpent: barData[0],
                  mostExpensive: mostExpensive,
                ),
              ),
              Expanded(
                child: Bar(
                  label: AppLocalization.of(context).mondayAbb,
                  amountSpent: barData[1],
                  mostExpensive: mostExpensive,
                ),
              ),
              Expanded(
                child: Bar(
                  label: AppLocalization.of(context).tuesdayAbb,
                  amountSpent: barData[2],
                  mostExpensive: mostExpensive,
                ),
              ),
              Expanded(
                child: Bar(
                  label: AppLocalization.of(context).wednesdayAbb,
                  amountSpent: barData[3],
                  mostExpensive: mostExpensive,
                ),
              ),
              Expanded(
                child: Bar(
                  label: AppLocalization.of(context).thursdayAbb,
                  amountSpent: barData[4],
                  mostExpensive: mostExpensive,
                ),
              ),
              Expanded(
                child: Bar(
                  label: AppLocalization.of(context).fridayAbb,
                  amountSpent: barData[5],
                  mostExpensive: mostExpensive,
                ),
              ),
              Expanded(
                child: Bar(
                  label: AppLocalization.of(context).saturdayAbb,
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

  Widget noDataPresent() {
    return Padding(
        padding: EdgeInsets.all(20.0),
        child: Container(
          height: 200,
          child: Center(
            child: Text(
              AppLocalization.of(context).noTransactionIsDoneInThisWeek,
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
          ),
        ));
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
    final barHeight = getBarHeight();
    return Column(
      children: <Widget>[
        Text(
          moneyConverter(amountSpent),
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

  double getBarHeight() {
    if (amountSpent != 0 && mostExpensive != 0) {
      return amountSpent / mostExpensive * _maxBarHeight;
    }
    return 1.0;
  }
}
