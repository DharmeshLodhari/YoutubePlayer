import 'package:Slydo/screens/user_profile/models/OpeningHour.dart';
import 'package:Slydo/screens/user_profile/models/user.dart';
import 'package:Slydo/screens/user_profile/models/user_about.dart';
import 'package:Slydo/utils/colors.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/custom_box_shadow.dart';
import 'package:Slydo/widget/loading_indicator.dart';
import 'package:flutter/material.dart';

class UserAboutScreen extends StatefulWidget {
  CustomerProfile? user;

  UserAboutScreen({super.key, required this.user});

  @override
  State<UserAboutScreen> createState() => _UserAboutScreenState();
}

class _UserAboutScreenState extends State<UserAboutScreen> {
  UserAbout? userAbout;

  _UserAboutScreenState();

  bool isLoading = false;

  final GlobalKey<ScaffoldState> _scaffoldUserAboutKey =
      GlobalKey<ScaffoldState>();

  List<OpeningHourForDay> showOpeningHours = [
    OpeningHourForDay(day: "Monday", time: "Closed"),
    OpeningHourForDay(day: "Tuesday", time: "Closed"),
    OpeningHourForDay(day: "Wednesday", time: "Closed"),
    OpeningHourForDay(day: "Thursday", time: "Closed"),
    OpeningHourForDay(day: "Friday", time: "Closed"),
    OpeningHourForDay(day: "Saturday", time: "Closed"),
    OpeningHourForDay(day: "Sunday", time: "Closed"),
  ];

  void formatOpeningHour() {
    final List<int> updatedIndex = [];

    for (int i = 0; i < showOpeningHours.length; i++) {
      for (int j = 0; j < userAbout!.openingHours.length; j++) {
        if (showOpeningHours[i].day == userAbout!.openingHours[j].day) {
          showOpeningHours[i].time = userAbout!.openingHours[j].time;
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
    userAbout = widget.user!.userAbout;
    formatOpeningHour();
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              if (userAbout!.openingHours.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Center(
                      child: Text(
                    "No Opening hours added yet.",
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: blackFont),
                  )),
                )
              else
                Column(
                  children: [
                    Text(
                      "Opening hours",
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: navyBlue),
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    Divider(
                      height: 0,
                      color: dividerColor,
                      thickness: 1,
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    Column(
                      children: showOpeningHours
                          .map((e) => Container(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      e.day!,
                                      style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w400),
                                    ),
                                    Text(
                                      e.time!,
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
