import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/screens/more_apps/messaging/message_auth.dart';
import 'package:Slydo/screens/more_apps/payment_and_banking/models/Envelope.dart';
import 'package:Slydo/screens/more_apps/user_profile/models/user.dart';
import 'package:Slydo/screens/more_apps/user_profile/user_auth.dart';
import 'package:Slydo/utils/colors.dart';
import 'package:Slydo/utils/common.dart';
import 'package:Slydo/widget/LoadingIndicator.dart';
import 'package:Slydo/widget/curved_btn.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:toast/toast.dart';

// ignore: must_be_immutable
class EnvelopeDetailScreen extends StatefulWidget {
  final arguments;
  EnvelopeDetailScreen({@required this.arguments});

  @override
  _EnvelopeDetailScreenState createState() =>
      _EnvelopeDetailScreenState(arguments: arguments);
}

class _EnvelopeDetailScreenState extends State<EnvelopeDetailScreen>
    with SingleTickerProviderStateMixin {
  var arguments;

  bool isLoading = true;

  _EnvelopeDetailScreenState({this.arguments});

  CustomerProfile searchedUser;
  String searchedUserName;

  // this variable will responsible for is the user is owner of the products and add
  // edit button on the product if user is owner
  bool isAuthor = false;
  UserBloc userBloc;

  CustomerProfileBloc customerProfileBloc;

  bool isUserIsSimpleUser = false;

  Map<String, dynamic> data;

  Envelope envelope;

  @override
  void initState() {
    openEnvelope();
    initializeVariables();

    super.initState();
  }

  void openEnvelope() async {
    envelope = arguments['envelope'];

    await MessageAuth().openEnvelope(envelope: envelope).catchError((error) {
      Toast.show("ERROR:- $error", context);
    });
  }

  void initializeVariables() async {
    data = arguments['data'];

    debugPrint("DATA FOR ENVELOPE:===> $data");
    await getSearchedUser();

    if (mounted) {
      setState(() {});
    }
  }

  Future<void> getSearchedUser() async {
    searchedUserName = arguments['searchedUserName'];
    isLoading = true;
    if (mounted) setState(() {});

    CustomerProfile user =
        await UserAuth().fetchCustomerProfileWithAuth(searchedUserName);
    searchedUser = user;
    isLoading = false;
    if (searchedUser.type.toLowerCase() == "user") {
      isUserIsSimpleUser = true;
    }

    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    userBloc = Provider.of<UserBloc>(context);
    customerProfileBloc = Provider.of<CustomerProfileBloc>(context);

    if (isLoading) {
      return Scaffold(
        appBar: appBar(),
        body: Center(
          child: CircularLoadingIndicator(),
        ),
      );
    }

    if (userBloc.user.userName == searchedUser.userName) {
      isAuthor = true;
    }

    return WillPopScope(
      onWillPop: () async {
        return await Future.value(true);
      },
      child: SafeArea(
        bottom: false,
        child: Scaffold(
          backgroundColor: Colors.white,
          body: NestedScrollView(
              physics: NeverScrollableScrollPhysics(),
              headerSliverBuilder: (BuildContext context, bool boxIsScrolled) {
                return <Widget>[
                  getAppbar(context),
                ];
              },
              body: SafeArea(bottom: false, top: true, child: scaffoldBody())),
        ),
      ),
    );
  }

  Widget scaffoldBody() {
    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        color: Colors.white,
        child: Column(
          children: [
            getTitle(),
            SizedBox(
              height: 20,
            ),
            getEnvelopeDetail(),
            SizedBox(
              height: 60,
            ),
            getEnvelopeActions(),
          ],
        ),
      ),
    );
  }

  Widget getTitle() {
    return Text(
      "Envelope from ${isAuthor ? "you" : searchedUser.fullName}",
      style: TextStyle(
          fontSize: 18, fontWeight: FontWeight.w700, color: blackFont),
    );
  }

  Widget getEnvelopeDetail() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 30),
      decoration: BoxDecoration(
        color: lightGrey,
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "₦ ",
                style: TextStyle(
                    fontFamily: "Roberto",
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    color: navyBlue),
              ),
              Text(
                data['amount'] ?? "",
                style: TextStyle(
                    fontSize: 32, fontWeight: FontWeight.w700, color: navyBlue),
              ),
            ],
          ),
          SizedBox(
            height: 12,
          ),
          Text(
            "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries.",
            style: TextStyle(
                fontSize: 14, fontWeight: FontWeight.w400, color: blackFont),
          ),
        ],
      ),
    );
  }

  Widget getEnvelopeActions() {
    return isAuthor
        ? Container()
        : Container(
            child: Row(
              children: <Widget>[
                Expanded(
                  child: CurvedButton(
                    backgroundColor: mateRed,
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    text: "Reject",
                    textColor: Colors.white,
                  ),
                ),
                SizedBox(
                  width: 16,
                ),
                Expanded(
                  child: CurvedButton(
                    backgroundColor: navyBlue,
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    text: "Accept",
                    textColor: Colors.white,
                  ),
                ),
              ],
            ),
          );
  }

  Widget getAppbar(var context) {
    return SliverOverlapAbsorber(
      handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
      sliver: SliverSafeArea(
        top: false,
        bottom: false,
        sliver: SliverAppBar(
          forceElevated: true,
          expandedHeight: 250,
          elevation: 0,
          stretch: true,
          pinned: true,
          snap: false,
          floating: true,
          leading: IconButton(
            icon: Icon(
              Icons.keyboard_arrow_left,
              color: Colors.white,
              size: 26,
            ),
            onPressed: () {
              searchedUser = null;
              Navigator.pop(context);
            },
          ),
          title: Container(
            child: Text(
              "Details",
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          titleSpacing: 0,
          backgroundColor: navyBlue,
          flexibleSpace: FlexibleSpaceBar(
            stretchModes: <StretchMode>[
              StretchMode.zoomBackground,
              StretchMode.blurBackground
            ],
            background: isLoading
                ? SizedBox.shrink()
                : Stack(
                    alignment: Alignment.topCenter,
                    children: <Widget>[
                      SizedBox.expand(
                        child: Container(
                          padding: EdgeInsets.only(
                              top: MediaQuery.of(context).padding.top),
                          height: 30,
                          color: Colors.white,
                        ),
                      ),
                      // Container(height: 50, color: Colors.black),

                      /// Banner image
                      getProfileCover(),

                      /// UserModel avatar, message icon, profile edit
                      getProfilePhoto(),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Widget getProfileCover() {
    return Container(
      height: 206,
      child: isLoading
          ? Center(
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                valueColor: AlwaysStoppedAnimation(Colors.white),
                backgroundColor: Colors.transparent,
              ),
            )
          : searchedUser.userAbout == null
              ? Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation(Colors.white),
                    backgroundColor: Colors.transparent,
                  ),
                )
              : searchedUser.userAbout.wallpaper == ""
                  ? Image.asset(
                      "assets/images/home_screen_background.png",
                      width: double.infinity,
                      fit: BoxFit.cover,
                    )
                  : CachedNetworkImage(
                      width: double.infinity,
                      height: double.infinity,
                      imageUrl: searchedUser.userAbout.wallpaper,
                      fit: BoxFit.cover,
                      placeholder: (context, url) =>
                          Center(child: CircularLoadingIndicator()),
                      color: blackFont.withOpacity(0.4),
                      colorBlendMode: BlendMode.darken,
                      filterQuality: FilterQuality.high,
                    ),
    );
  }

  Widget getProfilePhoto() {
    Color borderColor = getUserTypeColor(user: searchedUser);

    return Container(
      alignment: Alignment.bottomLeft,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedContainer(
            duration: Duration(milliseconds: 500),
            decoration: BoxDecoration(
                border: Border.all(color: borderColor, width: 3),
                shape: BoxShape.circle),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(50),
              child: Container(
                color: Colors.white,
                child: CachedNetworkImage(
                  height: 88,
                  width: 88,
                  fit: BoxFit.fill,
                  filterQuality: FilterQuality.high,
                  imageUrl: searchedUser.avatar,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget appBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.white,
      titleSpacing: 0,
      automaticallyImplyLeading: false,
      leading: IconButton(
        icon: Icon(
          Icons.keyboard_arrow_left,
          color: navyBlue,
          size: 24,
        ),
        onPressed: () {
          searchedUser = null;
          Navigator.pop(context);
        },
      ),
      title: Text(
        "Details",
        style: TextStyle(
            color: blackFont, fontSize: 22, fontWeight: FontWeight.bold),
        overflow: TextOverflow.fade,
        softWrap: false,
        maxLines: 1,
      ),
    );
  }
}
