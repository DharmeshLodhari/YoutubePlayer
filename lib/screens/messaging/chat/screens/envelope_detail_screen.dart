import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/routes/route_constants.dart';
import 'package:Slydo/screens/messaging/chat/models/models_for_db/ChatMessage.dart';
import 'package:Slydo/screens/messaging/message_auth.dart';
import 'package:Slydo/screens/payment_and_banking/models/envelope_model.dart';
import 'package:Slydo/screens/user_profile/models/user.dart';
import 'package:Slydo/screens/user_profile/user_auth.dart';
import 'package:Slydo/utils/my_audio_player.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/curved_btn.dart';
import 'package:Slydo/widget/dialog.dart';
import 'package:Slydo/widget/loading_indicator.dart';
import 'package:Slydo/widget/rounded_background_icon.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:colorful_safe_area/colorful_safe_area.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

class EnvelopeDetailScreen extends StatefulWidget {
  final dynamic arguments;
  const EnvelopeDetailScreen({super.key, required this.arguments});

  @override
  State<EnvelopeDetailScreen> createState() => _EnvelopeDetailScreenState();
}

class _EnvelopeDetailScreenState extends State<EnvelopeDetailScreen>
    with SingleTickerProviderStateMixin {
  bool isLoading = true;

  CustomerProfile? senderCustomer;

  // this variable will responsible for is the user is owner of the products and add
  // edit button on the product if user is owner
  bool isAuthor = false;
  late UserBloc userBloc;

  bool isUserIsSimpleUser = false;

  Map<String, dynamic>? data;

  Envelope? envelope;

  bool isEmptyEnvelope = false;
  late final AnimationController _controller;
  late final Animation<double> _animation;
  bool repeat = true;
  bool showing = false;
  MyAudioPlayer myAudioPlayer = MyAudioPlayer();

  @override
  void initState() {
    getEnvelopeAndUserData();

    // final String moneyAmount = '10000';
    final String moneyAmount = envelope!.amount!;
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 10000),
    );
    _animation =
        Tween<double>(begin: 0, end: double.tryParse(moneyAmount)).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
      ),
    );

    super.initState();
  }

  @override
  Future<void> dispose() async {
    _controller.stop();
    // Stop audio
    await myAudioPlayer.stopAudio();
    super.dispose();
  }

  void getEnvelopeAndUserData() async {
    envelope = widget.arguments['envelope'];
    data = widget.arguments['data'];
    isLoading = true;
    if (mounted) setState(() {});

    // debugPrint("envelope ${envelope!.toJson()}");
    await getSearchedUser();
    if (envelope!.type != "empty-envelop") {
      final Envelope envelopeFromServer = await MessageAuth()
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

    if (!isEmptyEnvelope) {
      Future.delayed(const Duration(seconds: 1), () async {
        _controller.forward();

        // Play audio
        // await myAudioPlayer.playAudio('assets/sounds/coin_drop.mp3');
        // await myAudioPlayer.playAudio('assets/sounds/coin_spill.mp3');
        // await myAudioPlayer.playAudio('assets/sounds/coinpour.mp3');
        await myAudioPlayer.playAudio('assets/sounds/raw.mp3');
        // await myAudioPlayer.playAudio('assets/sounds/raw_join.mp3');
        showing = true;
        if (mounted) setState(() {});
      });
      Future.delayed(const Duration(seconds: 14), () async {
        // Stop audio
        await myAudioPlayer.stopAudio();
        repeat = false;
        showing = false;
        if (mounted) setState(() {});
      });
    }

    if (mounted) setState(() {});
  }

  Future<void> getSearchedUser() async {
    final CustomerProfile user = await UserAuth()
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
        await myAudioPlayer.stopAudio();
        return await Future.value(true);
      },
      child: ColorfulSafeArea(
        bottom: false,
        child: Scaffold(
          backgroundColor: lightGrey,
          body: NestedScrollView(
              physics: const NeverScrollableScrollPhysics(),
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        color: Colors.white,
        child: Column(
          children: [
            getTitle(),
            const SizedBox(
              height: 20,
            ),
            getEnvelopeDetail(),
            const SizedBox(
              height: 60,
            ),
            getEnvelopeActions(),
          ],
        ),
      ),
    );
  }

  Widget getTitle() {
    String? name;
    if (senderCustomer != null) {
      name = senderCustomer!.displayName();
    }
    return Text(
      "Envelope from ${isAuthor ? "you" : name}",
      style: TextStyle(
          fontSize: 18, fontWeight: FontWeight.w700, color: blackFont),
    );
  }

  Widget getEnvelopeDetail() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 30),
      decoration: BoxDecoration(
        color: lightGrey,
        borderRadius: const BorderRadius.all(Radius.circular(12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (isEmptyEnvelope)
            Container()
          else
            Stack(
              children: [
                Visibility(
                  visible: showing,
                  child: Container(
                    margin: const EdgeInsets.only(top: 30.0),
                    child: Align(
                      alignment: Alignment.center,
                      child: Lottie.asset(
                        'assets/lottie/coin splash.json',
                        width: 200,
                        height: 200,
                        repeat: repeat,
                        fit: BoxFit.fill,
                      ),
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 70.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "₦ ",
                        style: TextStyle(
                            fontFamily: "Inter",
                            fontSize: 32,
                            fontWeight: FontWeight.w700,
                            color: navyBlue),
                      ),

                      AnimatedBuilder(
                        animation: _controller,
                        builder: (BuildContext context, Widget? child) {
                          final formattedMoney =
                              moneyDisplayNormalizer(_animation.value.toInt());

                          return Text(
                            formattedMoney,
                            style: TextStyle(
                              fontSize: 34.0,
                              fontWeight: FontWeight.w700,
                              color: navyBlue,
                            ),
                          );
                        },
                      ),
                      // Text(
                      //   // "${moneyDisplayNormalizer(int.parse(envelope!.amount!))}",
                      //   "${moneyDisplayNormalizer(int.parse('400000'))}",
                      //   style: TextStyle(
                      //       fontSize: 32,
                      //       fontWeight: FontWeight.w700,
                      //       color: navyBlue),
                      // ),
                    ],
                  ),
                ),
                Align(
                  alignment: Alignment.center,
                  child: Lottie.asset(
                    'assets/lottie/open_box.json',
                    width: 250,
                    height: 200,
                    repeat: false,
                    fit: BoxFit.fill,
                  ),
                ),
              ],
            ),
          const SizedBox(
            height: 12,
          ),
          Text(
            messageDecoderWithEmoji(envelope!.title ?? "")!,
            style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.w700, color: blackFont),
          ),
          const SizedBox(
            height: 12,
          ),
          Text(
            messageDecoderWithEmoji(envelope!.message ?? "")!,
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
        ? CurvedButton(
            backgroundColor: mateRed,
            onPressed: showDialogToDeleteEnvelope,
            text: AppLocalization.of(context)!.delete,
            textColor: Colors.white,
          )
        : Container();
  }

  void showDialogToDeleteEnvelope() {
    showDialogBox(
      context: context,
      actionOneTextColor: blackFont,
      actionOneBgColor: greyBorderColor,
      actionTwoTextColor: white,
      actionTwoBgColor: mateRed,
      title: 'Delete Envelope',
      actionOneText: AppLocalization.of(context)!.discard,
      actionTwoText: AppLocalization.of(context)!.continueMsg,
      description: 'Are you sure you want to delete this envelope?',
      roundedBackgroundIcon: RoundedBackgroundIcon(
        enableMargin: false,
        width: 90,
        height: 90,
        image: Image.asset('assets/images/delete_dialog_icon.png'),
      ),
      rightButtonOnPressed: () {
        deleteEnvelope();
      },
    );
  }

  void deleteEnvelope() async {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(child: CircularLoadingIndicator()));

    final result = await MessageAuth()
        .cancelEnvelope(envelope: envelope!, data: data!)
        .catchError((error) {});

    if (result != null) {
      if (result == true) {
        Navigator.popUntil(context, ModalRoute.withName(Routes.CHAT_SCREEN));
        return;
      } else {
        Navigator.pop(context);
        showToast(message: "Failed to delete Envelope");
      }
    } else {
      deleteChatMessage();
      Navigator.pop(context);
    }
  }

  Widget getAppbar(BuildContext context) {
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
            icon: const Icon(
              Icons.keyboard_arrow_left,
              color: Colors.white,
              size: 26,
            ),
            onPressed: () {
              senderCustomer = null;
              Navigator.pop(context);
            },
          ),
          title: const Text(
            "Details",
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          titleSpacing: 0,
          backgroundColor: navyBlue,
          flexibleSpace: FlexibleSpaceBar(
            stretchModes: const <StretchMode>[
              StretchMode.zoomBackground,
              StretchMode.blurBackground
            ],
            background: isLoading
                ? const SizedBox.shrink()
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
    return SizedBox(
      height: 206,
      child: isLoading
          ? const Center(
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                valueColor: AlwaysStoppedAnimation(Colors.white),
                backgroundColor: Colors.transparent,
              ),
            )
          : senderCustomer == null
              ? const Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation(Colors.white),
                    backgroundColor: Colors.transparent,
                  ),
                )
              : senderCustomer!.userAbout == null
                  ? const Center(
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
      final Color borderColor = getUserTypeColor(user: senderCustomer!);

      return Container(
        alignment: Alignment.bottomLeft,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 500),
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
    return const SizedBox(
      height: 1,
      width: 1,
    );
  }

  Widget appBar() {
    return AppBar(
      surfaceTintColor: Colors.transparent,
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
    final ChatMessage chatMessage = ChatMessage.fromJson(data!);

    final Map<String, dynamic> deleteMessage = <String, dynamic>{};

    deleteMessage["check_id"] = chatMessage.checkId;
    deleteMessage["conversation_id"] = chatMessage.conversationId;
    deleteMessage["type"] = "delete_message";
    deleteMessage["text"] = "delete_message";

    FocusScope.of(context).unfocus();

    await sendDataToSocket(deleteMessage);
  }
}
