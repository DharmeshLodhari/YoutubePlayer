import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/screens/more_apps/user_profile/models/OpeningHour.dart';
import 'package:Slydo/screens/more_apps/user_profile/models/UserAbout.dart';
import 'package:Slydo/screens/more_apps/user_profile/models/user.dart';
import 'package:Slydo/utils/colors.dart';
import 'package:Slydo/utils/slydo_app_icon_icons.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/CustomBoxShadow.dart';
import 'package:Slydo/widget/LoadingIndicator.dart';
import 'package:Slydo/widget/rounded_background_icon.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../user_auth.dart';

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

  bool isLoading = true;

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
    fetchUserAboutDetail();
    super.initState();
  }

  void fetchUserAboutDetail() {
    UserAuth().fetchUserAboutInfo().then((value) {
      userAbout = value;
      isLoading = false;
      if (mounted) setState(() {});
      formatOpeningHour();
    });
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Bio",
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: blackFont),
                  ),
                  widget.user.userName == userBloc.user.userName
                      ? RoundedBackgroundIcon(
                          height: 28,
                          width: 28,
                          backgroundColor: iconBtnGrey,
                          icon: Icon(
                            SlydoAppIcon.edit,
                            color: blackFont,
                            size: 12,
                          ),
                          onTap: () async {
                            var result = await Navigator.of(context).pushNamed(
                                '/add-edit-user-bio',
                                arguments: {"userAbout": userAbout});

                            if (result != null) {
                              if (result is UserAbout) {
                                userAbout = result;

                                if (mounted) setState(() {});
                                formatOpeningHour();
                              }
                            }
                          })
                      : Container()
                ],
              ),
              SizedBox(
                height: 8,
              ),
              Text(userAbout.bio),
              SizedBox(
                height: 16,
              ),
              Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Address:-",
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      SizedBox(
                        width: 8,
                      ),
                      Expanded(
                        child: Text(
                          userAbout.address,
                          // textAlign: TextAlign.justify,
                        ),
                      )
                    ],
                  ),
                  SizedBox(
                    height: 8,
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Contact:-",
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      SizedBox(
                        width: 8,
                      ),
                      Expanded(child: Text(userAbout.contact))
                    ],
                  ),
                ],
              ),
              userAbout.openingHours.isEmpty
                  ? Container()
                  : Column(
                      children: [
                        SizedBox(
                          height: 16,
                        ),
                        Text(
                          "Opening hour",
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: blackFont),
                        ),
                        SizedBox(
                          height: 8,
                        ),
                        Column(
                          children: showOpeningHours
                              .map((e) => Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(e.day),
                                      Text(
                                        e.time,
                                        style: TextStyle(
                                            fontWeight: e.time == "Closed"
                                                ? FontWeight.w600
                                                : FontWeight.w500),
                                      )
                                    ],
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
