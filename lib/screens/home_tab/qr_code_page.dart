import 'dart:io';
import 'dart:typed_data';
import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/services/app_tutorial_controller.dart';
import 'package:Slydo/utils/util.dart';
import 'package:custom_qr_generator/custom_qr_generator.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share/share.dart';
import '../../routes/route_constants.dart';
import '../../utils/slydo_app_icon_icons.dart';
import '../../widget/bottom_sheet_item.dart';
import '../../widget/rounded_background_icon.dart';
import '../more_apps/user_profile/models/user.dart';

class QrCodePage extends StatefulWidget {
  var arguments;

  QrCodePage({this.arguments, Key? key}) : super(key: key);

  @override
  _QrCodePageState createState() => _QrCodePageState();
}

class _QrCodePageState extends State<QrCodePage> {
  final GlobalKey<ScaffoldState> _scaffoldQrCodeKey =
      new GlobalKey<ScaffoldState>();
  late UserBloc userBloc;

  late AppLocalization appLocalization;
  ScreenshotController screenshotController = ScreenshotController();
  String user = "";
  CustomerProfile? searchedUser;

  @override
  void initState() {

    if(widget.arguments['isProfile'] != "false"){
      searchedUser = widget.arguments['isProfile'];
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    userBloc = Provider.of<UserBloc>(context);
    appLocalization = AppLocalization.of(context)!;

    return Scaffold(
      key: _scaffoldQrCodeKey,
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white,
      appBar: appBar(),
      body: Container(
        color: Colors.white,
        child: Screenshot(
          controller: screenshotController,
          child: _foregroundScreen(),
        ),
      ),
    );
  }

  AppBar appBar() {
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
          Navigator.pop(context);
        },
      ),
      title: Text(
        "QR Code",
        style: TextStyle(
            color: blackFont, fontSize: 18, fontWeight: FontWeight.bold),
      ),
      actions: <Widget>[
        menuIcon(),
        const SizedBox(
          width: 16,
        ),
      ],
    );
  }

  Widget _foregroundScreen() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        flexibleSpace(flex: 1),
        Container(height: 5),
        _displayUserInfo(),
        const SizedBox(
          height: 10,
        ),
        _displayUserName(),
        flexibleSpace(flex: 2),
      ],
    );
  }

  Widget _displayUserInfo() {
    return Card(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Color(0xFFF3F3F3), width: 2)),
      margin: EdgeInsets.zero,
      elevation: 0.0,
      child: Container(
        decoration:
            decorateBox(borderRadius: 20, borderColor: HexColor("#F3F3F3")),
        child: Container(
          margin: const EdgeInsets.all(13),
          key: tutorialQrCodeKey,
          child: CustomPaint(
            painter: QrPainter(
                data:
                searchedUser == null ? "https://api.slydo.co/api/v1/user/customer/${userBloc.user.userName!}"
                    : "https://api.slydo.co/api/v1/user/customer/${searchedUser!.userName}",
                options: const QrOptions(
                    shapes: QrShapes(
                        darkPixel: QrPixelShapeCircle(radiusFraction: .8),
                        frame: QrFrameShapeRoundCorners(cornerFraction: .25),
                        ball: QrBallShapeRoundCorners(cornerFraction: .25)),
                    colors: QrColors(
                        light: QrColorSolid(Color.fromARGB(0, 0, 0, 0))))),
            size: Size(MediaQuery.of(context).size.width / 1.7,
                MediaQuery.of(context).size.width / 1.7),
          ),
        ),
      ),
    );
  }

  Widget _displayUserName() {
    return InkWell(
      onTap: () {
        Navigator.pushNamed(context, Routes.USER_PROFILE,
            arguments: {"searchedUserName": userBloc.user.userName});
      },
      child: Column(
        children: [
          userNameWithVerifiedIcon(
            name: searchedUser == null ? userBloc.user.displayName()! : searchedUser!.displayName(),
            isVerified: searchedUser == null ? userBloc.user.isVerified : searchedUser!.isVerified,
            verifiedIconColor: verifyGreen,
            textStyle: TextStyle(
                fontSize: 16,
                color: HexColor("#151515"),
                fontWeight: FontWeight.bold),
          ),
          Text(
            searchedUser == null ? "Scan to pay @${userBloc.user.userName!}" : "Scan to pay @${searchedUser!.userName!}",
            maxLines: 1,
            style: TextStyle(fontSize: 12, color: HexColor("#B8B6B6")),
          ),
        ],
      ),
    );
  }

  Widget menuIcon() {
    return RoundedBackgroundIcon(
      height: 34,
      width: 34,
      icon: Icon(
        SlydoAppIcon.menu,
        size: 16,
        color: blackFont,
      ),
      backgroundColor: iconBtnGrey,
      onTap: () {
        userProfileActionsSheet();
      },
      enableMargin: true,
    );
  }

  void userProfileActionsSheet() {
    showModalBottomSheet<void>(
        backgroundColor: Colors.transparent,
        context: context,
        builder: (BuildContext context) {
          return Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20)),
              ),
              color: Colors.white,
              margin: EdgeInsets.zero,
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 18, horizontal: 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: generateBottomSheetItem(),
                ),
              ));
        });
  }

  List<Widget> generateBottomSheetItem() {
    List<Widget> list = [];

      list.add(
        bottomSheetItem(
          title: AppLocalization.of(context)!.share,
          iconData: SlydoAppIcon.share,
          onTap: () {
            Navigator.pop(context);
            shareQrCode();
          },
        ),
      );


    list.add(
      bottomSheetItem(
        isLast: true,
        title: AppLocalization.of(context)!.download,
        iconData: Icons.download_rounded,
        onTap: () async {
          Navigator.pop(context);
          downloadQrCode();
        },
      ),
    );

    return list;
  }

   void shareQrCode()  async {
     await screenshotController.capture(delay: const Duration(milliseconds: 10)).then((Uint8List? image) async {
       if (image != null) {
         final directory = await getApplicationDocumentsDirectory();
         final imagePath = await File('${directory.path}/${userBloc.user.displayName()!}.png').create();
         await imagePath.writeAsBytes(image);

         /// Share Plugin
         await Share.shareFiles([imagePath.path]);
       }
     });

  }

   void downloadQrCode()  async {
     await screenshotController.capture(delay: const Duration(milliseconds: 10)).then((Uint8List? image) async {
       if (image != null) {
         final directory = await getApplicationDocumentsDirectory();
         final imagePath = await File('${directory.path}/${userBloc.user.displayName()!}.png').create();
         await imagePath.writeAsBytes(image);

         /// Share Plugin
         // await Share.shareFiles([imagePath.path]);
       }
     });

  }

  getCurrentDate() {
    return DateFormat('_yyyyMMdd_kkmmss').format(DateTime.now());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (mounted) setState(() {});
  }
}
