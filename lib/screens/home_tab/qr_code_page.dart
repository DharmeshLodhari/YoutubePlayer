import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/services/app_tutorial_controller.dart';
import 'package:Slydo/utils/util.dart';
import 'package:custom_qr_generator/custom_qr_generator.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../routes/route_constants.dart';

class QrCodePage extends StatefulWidget {
  @override
  _QrCodePageState createState() => _QrCodePageState();
}

class _QrCodePageState extends State<QrCodePage> {
  final GlobalKey<ScaffoldState> _scaffoldQrCodeKey =
      new GlobalKey<ScaffoldState>();
  late UserBloc userBloc;

  late AppLocalization appLocalization;

  @override
  void initState() {
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
        child: _foregroundScreen(),
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
        // widget.postType == PostType.blog ? menuIcon() : shareBtn(),
        SizedBox(
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
        SizedBox(
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
          side: BorderSide(color: Color(0xFFF3F3F3), width: 2)),
      margin: EdgeInsets.zero,
      elevation: 0.0,
      child: Container(
        decoration:
            decorateBox(borderRadius: 20, borderColor: HexColor("#F3F3F3")),
        child: Container(
          margin: EdgeInsets.all(13),
          key: tutorialQrCodeKey,
          child: CustomPaint(
            painter: QrPainter(
                data:
                    "https://api.slydo.co/api/v1/user/customer/${userBloc.user.userName!}",
                options: QrOptions(
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
            name: userBloc.user.displayName()!,
            isVerified: userBloc.user.isVerified,
            verifiedIconColor: verifyGreen,
            textStyle: TextStyle(
                fontSize: 16,
                color: HexColor("#151515"),
                fontWeight: FontWeight.bold),
          ),
          Text(
            "Scan to pay @${userBloc.user.userName!}",
            maxLines: 1,
            style: TextStyle(fontSize: 12, color: HexColor("#B8B6B6")),
          ),
        ],
      ),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (mounted) setState(() {});
  }
}
