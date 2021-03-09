import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/screens/more_apps/user_profile/models/OpeningHour.dart';
import 'package:Slydo/screens/more_apps/user_profile/models/UserAbout.dart';
import 'package:Slydo/screens/more_apps/user_profile/models/user.dart';
import 'package:Slydo/utils/colors.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/CustomBoxShadow.dart';
import 'package:Slydo/widget/LoadingIndicator.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// ignore: must_be_immutable
class UserAboutScreen extends StatefulWidget {
  CustomerProfile user;

  UserAboutScreen({@required this.user});

  @override
  _UserAboutScreenState createState() => _UserAboutScreenState(user: user);
}

class _UserAboutScreenState extends State<UserAboutScreen> {
  CustomerProfile user;

  UserAbout userAbout;

  _UserAboutScreenState({this.user});

  bool isLoading = false;

  final GlobalKey<ScaffoldState> _scaffoldUserAboutKey =
      new GlobalKey<ScaffoldState>();

  UserBloc userBloc;

  List<OpeningHour> showOpeningHours = [
    OpeningHour(day: "Monday", time: "Closed"),
    OpeningHour(day: "Tuesday", time: "Closed"),
    OpeningHour(day: "Wednesday", time: "Closed"),
    OpeningHour(day: "Thursday", time: "Closed"),
    OpeningHour(day: "Friday", time: "Closed"),
    OpeningHour(day: "Saturday", time: "Closed"),
    OpeningHour(day: "Sunday", time: "Closed"),
  ];

  @override
  void initState() {
    super.initState();
  }

  void formatOpeningHour() {
    List<int> updatedIndex = [];

    for (int i = 0; i < showOpeningHours.length; i++) {
      for (int j = 0; j < userAbout.openingHours.length; j++) {
        if (showOpeningHours[i].day == userAbout.openingHours[j].day) {
          showOpeningHours[i].time = userAbout.openingHours[j].time;
          updatedIndex.add(i);
        }
      }
    }

    for (int i = 0; i < showOpeningHours.length; i++) {
      if (!updatedIndex.contains(i)) showOpeningHours[i].time = "Closed";
    }

    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    userAbout = widget.user.userAbout;
    formatOpeningHour();
    userBloc = Provider.of<UserBloc>(context);
    return WillPopScope(
      onWillPop: () async {
        return true;
      },
      child: isLoading
          ? Center(
              child: CircularLoadingIndicator(),
            )
          : Scaffold(
              key: _scaffoldUserAboutKey,
              resizeToAvoidBottomInset: true,
              backgroundColor: lightGrey,
              body: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                  child: Column(
                    children: <Widget>[
                      displayUserBio(),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget displayUserBio() {
    return CustomBoxShadow(
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: EdgeInsets.zero,
        shadowColor: boxShadowTwo,
        borderOnForeground: true,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              userAbout.openingHours.isEmpty
                  ? Container()
                  : Column(
                      children: [
                        Text(
                          "Opening hour",
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: navyBlue),
                        ),
                        SizedBox(
                          height: 16,
                        ),
                        Divider(
                          height: 0,
                          color: dividerColor,
                          thickness: 1,
                        ),
                        SizedBox(
                          height: 16,
                        ),
                        Column(
                          children: showOpeningHours
                              .map((e) => Container(
                                    padding: EdgeInsets.only(bottom: 16),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          e.day,
                                          style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w400),
                                        ),
                                        Text(
                                          e.time,
                                          style: TextStyle(
                                              fontSize: 14,
                                              color: e.time == "Closed"
                                                  ? darkGrey
                                                  : blackFont,
                                              fontWeight: FontWeight.w600),
                                        )
                                      ],
                                    ),
                                  ))
                              .toList(),
                        ),
                      ],
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
