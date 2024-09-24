import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/dialog.dart';
import 'package:flutter/material.dart';

class SetCurrency extends StatefulWidget {
  const SetCurrency({super.key});

  @override
  State<SetCurrency> createState() => _SetCurrencyState();
}

class _SetCurrencyState extends State<SetCurrency> {
  final List<Map<String, String>> currencyList = [
    {'name': 'USD', 'flag': 'assets/images/flags/us.png'},
    {'name': 'GBP', 'flag': 'assets/images/flags/sh.png'},
    {'name': 'EUR', 'flag': 'assets/images/flags/eu.png'},
    {'name': 'KHR', 'flag': 'assets/images/flags/kh.png'},
    {'name': 'CAD', 'flag': 'assets/images/flags/ca.png'},
  ];
  int selectedCurrencyIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightGrey,
      appBar: _buildAppBar(context: context) as PreferredSizeWidget,
      body: _buildBody(context),
    );
  }

  Widget _buildAppBar({required BuildContext context}) {
    return AppBar(
      surfaceTintColor: Colors.transparent,
      backgroundColor: Colors.white,
      title: Text(
        'Set Currency',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: yarnBlack,
          height: 1.3,
        ),
      ),
      centerTitle: false,
      titleSpacing: 16,
      leading: IconButton(
        icon: Icon(
          Icons.keyboard_arrow_left,
          color: navyBlue,
          size: 24,
        ),
        onPressed: () {
          Navigator.pop(context, "back pressed");
        },
      ),
      shadowColor: greySecondaryYarn,
      elevation: 0.5,
    );
  }

  Widget _buildBody(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: ListView.builder(
        itemCount: currencyList.length,
        itemBuilder: (BuildContext context, int index) {
          return Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
            shadowColor: boxShadowTwo,
            elevation: 0,
            child: Container(
              decoration: decorateBox(),
              child: ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 15.0, vertical: 5.0),
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(25),
                  child: Image.asset(
                    currencyList[index]['flag']!,
                    height: 40.0,
                    width: 40.0,
                    fit: BoxFit.fill,
                  ),
                ),
                title: Text(
                  currencyNameAndSymbol(currencyList[index]['name']),
                  maxLines: 1,
                  style: TextStyle(
                    color: blackFont,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    fontFamily: "Inter",
                  ),
                  overflow: TextOverflow.fade,
                  softWrap: false,
                ),
                trailing: selectedCurrencyIndex == index
                    ? Icon(Icons.check, color: navyBlue)
                    : null,
                onTap: () {
                  setState(() {
                    selectedCurrencyIndex = index;
                  });
                  _showReminderDialog(context);
                },
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _showReminderDialog(BuildContext context) async {
    await showDialogBoxWithTitle(
      context: context,
      actionBgColor: navyBlue,
      actionTextColor: Colors.white,
      title: 'Reminder',
      description:
          'You are free to browse in different currencies but will always pay in NGN (Naira) at checkout',
      descriptionPadding: 25,
      actionText: "Got it",
      buttonOnPressed: () {
        setState(() {});
      },
    );
  }
}
