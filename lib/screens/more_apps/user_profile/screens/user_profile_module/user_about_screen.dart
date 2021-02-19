import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/screens/more_apps/user_profile/models/UserAbout.dart';
import 'package:Slydo/screens/more_apps/user_profile/models/user.dart';
import 'package:Slydo/utils/colors.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/CustomBoxShadow.dart';
import 'package:Slydo/widget/LoadingIndicator.dart';
import 'package:cached_network_image/cached_network_image.dart';
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
  UserBloc _userBloc;

  UserAbout userAbout;

  _UserAboutScreenState({this.user});

  bool isLoading = true;

  final GlobalKey<ScaffoldState> _scaffoldUserAboutKey =
      new GlobalKey<ScaffoldState>();

  CustomerProfileBloc customerProfileBloc;

  @override
  void initState() {
    UserAuth().fetchUserAboutInfo().then((value) {
      userAbout = value;
      isLoading = false;
      if (mounted) setState(() {});
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _userBloc = Provider.of<UserBloc>(context);

    return WillPopScope(
      onWillPop: () async {
        customerProfileBloc.customer = null;
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
                      displayUserInfo(),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget displayUserNameAndContect() {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 0, horizontal: 8),
      child: ListTile(
          leading: ClipOval(
            child: Container(
              height: 45,
              width: 45,
              child: CachedNetworkImage(
                imageUrl: user.avatar,
                fit: BoxFit.fill,
                errorWidget: imageErrorWidget,
              ),
            ),
          ),
          title: Text(user.fullName),
          subtitle: Text(user.userName),
          trailing: getTrailing()),
    );
  }

  Widget getTrailing() {
    if (_userBloc.user.userName == user.userName) {
      return null;
    }
    return IconButton(
      icon: Icon(
        Icons.message,
        color: darkBlue(),
      ),
      onPressed: () {
        UserAuth().fetchCustomerProfile(user.userName).then((fetchedUser) {
          Navigator.of(context).pushNamed('/compose_message', arguments: {
            'recipient': fetchedUser.userName,
            'subject': "",
          });
        });
      },
    );
  }

  Widget displayUserInfo() {
    return CustomBoxShadow(
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: EdgeInsets.zero,
        shadowColor: boxShadowTwo,
        borderOnForeground: true,
        child: Column(
          children: <Widget>[
            SizedBox(
              height: 16,
            ),
            Text(
              "Bio",
              style: TextStyle(
                  fontSize: 20, fontWeight: FontWeight.w600, color: blackFont),
            ),
            SizedBox(
              height: 8,
            ),
            Container(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text(userAbout.bio)),
            SizedBox(
              height: 16,
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Column(
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
                          textAlign: TextAlign.justify,
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
            ),
            SizedBox(
              height: 16,
            ),
            Text(
              "Opening hour",
              style: TextStyle(
                  fontSize: 20, fontWeight: FontWeight.w600, color: blackFont),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: userAbout.openingHours
                    .map((e) => Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [Text(e.day), Text(e.time)],
                        ))
                    .toList(),
              ),
            ),
            SizedBox(
              height: 16,
            ),
          ],
        ),
      ),
    );
  }
}
