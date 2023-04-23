import 'package:Slydo/data/socket_provider.dart';
import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/screens/scan_qr_code.dart';
import 'package:Slydo/services/app_tutorial_controller.dart';
import 'package:Slydo/utils/extensions.dart';
import 'package:Slydo/utils/util.dart';
import 'package:custom_qr_generator/custom_qr_generator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../locator.dart';
import '../../routes/route_constants.dart';
import '../../services/app_config_bloc.dart';
import '../../utils/navigation_util.dart';

class QrCodePage extends StatefulWidget {
  @override
  _QrCodePageState createState() => _QrCodePageState();
}

class _QrCodePageState extends State<QrCodePage> {
  final GlobalKey<ScaffoldState> _scaffoldHomeKey =
      new GlobalKey<ScaffoldState>();
  late UserBloc userBloc;

  late MainSocketProvider socketProvider;
  bool hasMessage = true;
  // late BasketBloc basketBloc;
  late AppLocalization appLocalization;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      SharedPreferences _sharedPreferences;

      _sharedPreferences = await SharedPreferences.getInstance();
      bool isAppTutorialDone = false;
      try {
        isAppTutorialDone =
            _sharedPreferences.getBool('isAppTutorialDone') ?? false;
      } catch (error) {
        isAppTutorialDone = false;
      }

      if (!isAppTutorialDone) {
        bool result =
            await _sharedPreferences.setBool("isAppTutorialDone", true);
        debugPrint("result:- $result");
        await Future.delayed(Duration(milliseconds: 1500)).then((value) {
          AppTutorialController().showTutorial(context);
        });
      }
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    userBloc = Provider.of<UserBloc>(context);
    appLocalization = AppLocalization.of(context)!;
    socketProvider = Provider.of<MainSocketProvider>(context);

    return Scaffold(
      key: _scaffoldHomeKey,
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Container(
          color: Colors.white,
          child: _foregroundScreen(),
        ),
      ),
    );
  }

  Widget _foregroundScreen() {
    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
      ),
      child: Column(
        children: <Widget>[
          Container(height: 5),
          _displayUserInfo(),
          SizedBox(
            height: 10,
          ),
          _displayUserName(),
          _displayPaymentButtons(),
        ],
      ),
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

  Widget _displayPaymentButtons() {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 20,
        vertical: MediaQuery.of(context).size.height > 600 ? 16 : 8,
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            key: tutorialSendPaymentKey,
            child: Container(
              child: _sendPaymentButton(),
            ),
          ),
          Expanded(
            key: tutorialRequestPaymentKey,
            child: Container(
              child: _requestPaymentButton(),
            ),
          ),
          Expanded(
            key: tutorialScanQrCodeKey,
            child: Container(
              child: _scanButton(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _requestPaymentButton() {
    return Theme(
      data: Theme.of(context).copyWith(
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
      ),
      child: InkWell(
          child: Column(
            children: <Widget>[
              SizedBox(
                height: 50,
                width: 50,
                child: SvgPicture.asset(
                  "request_payment".toSVG(),
                ),
              ),
              SizedBox(
                width: 12,
              ),
              Text(
                appLocalization.request,
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          onTap: () {
            if (getIt<AppConfigurationBloc>()
                    .appConfigurationModel
                    ?.enablePayment ==
                true) {
              Navigator.of(context)
                  .pushNamed(Routes.REQUEST_PAYMENT, arguments: <String, bool>{
                'isFromProfile': true,
              });
            } else {
              showToast(message: 'Payment not available at the moment');
            }
          }),
    );
  }

  Widget _sendPaymentButton() {
    return Theme(
      data: Theme.of(context).copyWith(
        splashColor: Colors.white,
        highlightColor: Colors.white,
      ),
      child: InkWell(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SizedBox(
                  height: 50,
                  width: 50,
                  child: SvgPicture.asset(
                    "send_payment".toSVG(),
                  )),
              SizedBox(
                width: 12,
              ),
              Text(
                appLocalization.send,
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          onTap: () {
            if (getIt<AppConfigurationBloc>()
                    .appConfigurationModel
                    ?.enablePayment ==
                true) {
              Navigator.of(context).pushNamed(Routes.SEND_PAYMENT,
                  arguments: <String, bool>{'isFromProfile': true});
            } else {
              showToast(message: 'Payment not available at the moment');
            }
          }),
    );
  }

  Widget _scanButton() {
    return Theme(
      data: Theme.of(context).copyWith(
        splashColor: Colors.white,
        highlightColor: Colors.white,
      ),
      child: InkWell(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SizedBox(
                height: 50,
                width: 50,
                child: SvgPicture.asset(
                  "scan_qr".toSVG(),
                ),
              ),
              SizedBox(
                width: 12,
              ),
              Text(
                "Scan",
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          onTap: () {
            NavigationUtil.push(context,
                screen: QRCodeView(arguments: {'isRequest': false}));
          }),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (mounted) setState(() {});
  }

  String getGreetingMessage() {
    TimeOfDay currentTime = TimeOfDay.now();

    if (currentTime.hour >= 6 &&
        (currentTime.hour <= 11 && currentTime.minute <= 59)) {
      return "${appLocalization.goodMorning},";
    } else if (currentTime.hour >= 12 &&
        (currentTime.hour <= 16 && currentTime.minute <= 59)) {
      return "${appLocalization.goodAfternoon},";
    } else if (currentTime.hour >= 17 &&
        (currentTime.hour <= 19 && currentTime.minute <= 59)) {
      return "${appLocalization.goodEvening},";
    } else {
      return "${appLocalization.goodEvening},";
    }
  }
}
