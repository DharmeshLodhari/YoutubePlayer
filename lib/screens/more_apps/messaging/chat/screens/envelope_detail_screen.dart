import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/screens/more_apps/messaging/chat/models/models_for_db/ChatMessage.dart';
import 'package:Slydo/screens/more_apps/messaging/message_auth.dart';
import 'package:Slydo/screens/more_apps/payment_and_banking/models/Envelope.dart';
import 'package:Slydo/screens/more_apps/user_profile/models/user.dart';
import 'package:Slydo/screens/more_apps/user_profile/user_auth.dart';
import 'package:Slydo/utils/colors.dart';
import 'package:Slydo/utils/common.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/LoadingIndicator.dart';
import 'package:Slydo/widget/curved_btn.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:colorful_safe_area/colorful_safe_area.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// ignore: must_be_immutable
class EnvelopeDetailScreen extends StatefulWidget {
  final arguments;
  EnvelopeDetailScreen({required this.arguments});

  @override
  _EnvelopeDetailScreenState createState() =>
      _EnvelopeDetailScreenState(arguments: arguments);
}

class _EnvelopeDetailScreenState extends State<EnvelopeDetailScreen>
    with SingleTickerProviderStateMixin {
  var arguments;

  bool isLoading = true;

  _EnvelopeDetailScreenState({this.arguments});

  CustomerProfile? senderCustomer;

  // this variable will responsible for is the user is owner of the products and add
  // edit button on the product if user is owner
  bool isAuthor = false;
  late UserBloc userBloc;

  bool isUserIsSimpleUser = false;

  Map<String, dynamic>? data;

  Envelope? envelope;

  bool isEmptyEnvelope = false;

  @override
  void initState() {
    getEnvelopeAndUserData();

    super.initState();
  }

  void getEnvelopeAndUserData() async {
    envelope = arguments['envelope'];
    data = arguments['data'];
    isLoading = true;
    if (mounted) setState(() {});

    debugPrint("envelope ${envelope!.toJson()}");
    await getSearchedUser();
    if (envelope!.type != "empty-envelop") {
      Envelope envelopeFromServer = await MessageAuth()
          .getEnvelope(envelope: envelope!, id: data!['id'])
          .catchError((error) {
        deleteChatMessage();
        if (mounted) {
          Navigator.pop(context);
        }
      });

      if (envelopeFromServer != null) {
        envelope = envelopeFromServer;
      }
    } else {
      isEmptyEnvelope = true;
    }

    isLoading = false;
    if (mounted) setState(() {});
  }

  Future<void> getSearchedUser() async {
    CustomerProfile user = await UserAuth()
        .fetchCustomerProfileWithAuth(envelope!.fromCustomer)
        .catchError((error) {
      debugPrint("ERROR2:- $error");
      showToast(message: "ERROR2:- $error");
    });
    senderCustomer = user;

    if (senderCustomer!.type!.toLowerCase() == "user") {
      isUserIsSimpleUser = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    userBloc = Provider.of<UserBloc>(context);

    if (isLoading) {
      return Scaffold(
        appBar: appBar() as PreferredSizeWidget?,
        body: Center(
          child: CircularLoadingIndicator(),
        ),
      );
    }

    if (userBloc.user.userName == envelope!.fromCustomer) {
      isAuthor = true;
    }

    return WillPopScope(
      onWillPop: () async {
        return await Future.value(true);
      },
      child: ColorfulSafeArea(
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
      "Envelope from ${isAuthor ? "you" : senderCustomer!.displayName()}",
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
          isEmptyEnvelope
              ? Container()
              : Row(
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
                      "${moneyDisplayNormalizer(int.parse(envelope!.amount!))}",
                      style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w700,
                          color: navyBlue),
                    ),
                  ],
                ),
          SizedBox(
            height: 12,
          ),
          Text(
            messageDecoderWithEmoji("${envelope!.title ?? ""}")!,
            style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.w700, color: blackFont),
          ),
          SizedBox(
            height: 12,
          ),
          Text(
            messageDecoderWithEmoji("${envelope!.message ?? ""}")!,
            style: TextStyle(
                fontSize: 14, fontWeight: FontWeight.w400, color: blackFont),
          ),
        ],
      ),
    );
  }

  Widget getEnvelopeActions() {
    return isAuthor && envelope!.type == "empty-envelop" ||
            isAuthor && !envelope!.isOpen
        ? Container(
            child: CurvedButton(
              backgroundColor: mateRed,
              onPressed: cancelEnvelope,
              text: "Cancel",
              textColor: Colors.white,
            ),
          )
        : Container();
  }

  void cancelEnvelope() async {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(child: CircularLoadingIndicator()));

    var result = await MessageAuth()
        .cancelEnvelope(envelope: envelope!, data: data!)
        .catchError((error) {});

    if (result != null) {
      if (result == true) {
        Navigator.popUntil(context, ModalRoute.withName("/chat-screen"));
        return;
      } else {
        Navigator.pop(context);
        showToast(message: "Failed to cancel Envelope");
      }
    } else {
      deleteChatMessage();
      Navigator.pop(context);
    }
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
              senderCustomer = null;
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
          : senderCustomer == null
              ? Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation(Colors.white),
                    backgroundColor: Colors.transparent,
                  ),
                )
              : senderCustomer!.userAbout == null
                  ? Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation(Colors.white),
                        backgroundColor: Colors.transparent,
                      ),
                    )
                  : senderCustomer!.userAbout!.wallpaper == ""
                      ? Image.asset(
                          "assets/images/home_screen_background.png",
                          width: double.infinity,
                          fit: BoxFit.cover,
                        )
                      : GestureDetector(
                          onTap: () {
                            Navigator.of(context).pushNamed("/photo-viewer",
                                arguments:
                                    senderCustomer!.userAbout!.wallpaper);
                          },
                          child: CachedNetworkImage(
                            width: double.infinity,
                            height: double.infinity,
                            errorWidget: imageErrorWidget,
                            imageUrl: senderCustomer!.userAbout!.wallpaper,
                            fit: BoxFit.cover,
                            placeholder: (context, url) =>
                                Center(child: CircularLoadingIndicator()),
                            color: blackFont.withOpacity(0.4),
                            colorBlendMode: BlendMode.darken,
                            filterQuality: FilterQuality.high,
                          ),
                        ),
    );
  }

  Widget getProfilePhoto() {
    if (senderCustomer != null) {
      Color borderColor = getUserTypeColor(user: senderCustomer!);

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
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(context).pushNamed("/photo-viewer",
                        arguments: senderCustomer!.avatar);
                  },
                  child: Container(
                    color: Colors.white,
                    child: CachedNetworkImage(
                      height: 88,
                      width: 88,
                      fit: BoxFit.fill,
                      filterQuality: FilterQuality.high,
                      imageUrl: senderCustomer!.avatar!,
                      errorWidget: imageErrorWidget,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }
    return Container(
      height: 1,
      width: 1,
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
          senderCustomer = null;
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

  void deleteChatMessage() async {
    ChatMessage chatMessage = ChatMessage.fromJson(data!);

    Map<String, dynamic> deleteMessage = Map<String, dynamic>();

    deleteMessage["check_id"] = chatMessage.checkId;
    deleteMessage["conversation_id"] = chatMessage.conversationId;
    deleteMessage["type"] = "delete_message";
    deleteMessage["text"] = "delete_message";

    FocusScope.of(context).unfocus();

    await sendDataToSocket(deleteMessage);
  }
}
