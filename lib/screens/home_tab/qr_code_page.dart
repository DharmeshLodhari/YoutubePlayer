import 'dart:io';
import 'dart:typed_data';

import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/utils/util.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:custom_qr_generator/custom_qr_generator.dart';
import 'package:disk_space/disk_space.dart';
import 'package:external_path/external_path.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';

import '../../routes/route_constants.dart';
import '../../utils/slydo_app_icon_icons.dart';
import '../../widget/bottom_sheet_item.dart';
import '../../widget/curved_btn.dart';
import '../../widget/rounded_background_icon.dart';
import '../more_apps/payment_and_banking/models/VirtualAccount.dart';
import '../more_apps/user_profile/models/user.dart';
import '../more_apps/user_profile/screens/user_profile_module_new/profile_template/utils.dart';

class QrCodePage extends StatefulWidget {
  final dynamic arguments;

  const QrCodePage({this.arguments, Key? key}) : super(key: key);

  @override
  State<QrCodePage> createState() => _QrCodePageState();
}

class _QrCodePageState extends State<QrCodePage> {
  final GlobalKey<ScaffoldState> _scaffoldQrCodeKey =
      GlobalKey<ScaffoldState>();
  late UserBloc userBloc;

  late AppLocalization appLocalization;
  ScreenshotController screenshotController = ScreenshotController();
  String user = "";
  CustomerProfile? searchedUser;
  VirtualAccount? virtualAccount;
  int _currentIndex = 0;
  bool noFinancialInfo = false;

  @override
  void initState() {
    if (widget.arguments['isProfile'] != "false") {
      searchedUser = widget.arguments['isProfile'];
    }

    virtualAccount = widget.arguments['virtualAccount'];

    if (virtualAccount!.accountNumber!.isNotEmpty) {
      noFinancialInfo = true;
    }
    super.initState();
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
        child: Container(color: white, child: _foregroundScreen()),
      ),
    );
  }

  Widget _foregroundScreen() {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 40),
          Screenshot(
            controller: screenshotController,
            child: SizedBox(
              height: 550,
              child: CarouselSlider(
                options: CarouselOptions(
                  height: 550,
                  autoPlay: false,
                  enableInfiniteScroll: false,
                  viewportFraction: 1.0,
                  onPageChanged: (index, reason) {
                    setState(() {
                      _currentIndex = index;
                    });
                  },
                ),
                items: [
                  _buildCarouselItem(),
                  _buildCarouselItemBlue(),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              2, // Number of items in the CarouselSlider
              (index) {
                return Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentIndex == index ? navyBlue : Colors.grey,
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 20),
          _scanQrButtonWidget(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildCarouselItem() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/union_white.png'),
          fit: BoxFit.contain,
        ),
      ),
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          Positioned(
            child: Column(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.transparent,
                  radius: 40.0,
                  child: SvgPicture.asset(
                    'assets/images/slydo.svg',
                    width: 50,
                    height: 50,
                    color: blackFont,
                  ),
                ),
                _bankDetails(),
                const SizedBox(
                  height: 10,
                ),
                _displayUserInfo(),
                const SizedBox(
                  height: 10,
                ),
                _displayUserName(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCarouselItemBlue() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/union_blue.png'),
          fit: BoxFit.contain,
        ),
      ),
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          Positioned(
            child: Column(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.transparent,
                  radius: 40.0,
                  child: SvgPicture.asset(
                    'assets/images/slydo.svg',
                    width: 50,
                    height: 50,
                    color: white,
                  ),
                ),
                _financialInfo(),
                const SizedBox(
                  height: 10,
                ),
                _displayUserInfo(),
                const SizedBox(
                  height: 10,
                ),
                _scanToPayInfo()
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _bankDetails() {
    return InkWell(
      onTap: () {
        Navigator.pushNamed(context, Routes.USER_PROFILE,
            arguments: {"searchedUserName": userBloc.user.userName});
      },
      child: Column(
        children: [
          const SizedBox(
            height: 10.0,
          ),
          if (virtualAccount!.financialInstitution!.name != null)
            Text(
              appendStringDot(virtualAccount!.financialInstitution!.name!, 25),
              maxLines: 1,
              style: TextStyle(
                  fontSize: 16,
                  color: HexColor("#151515"),
                  fontWeight: FontWeight.w600),
            )
          else
            const SizedBox.shrink(),
          Text(
            appendStringDot(virtualAccount!.accountNumber!, 15),
            maxLines: 1,
            style: TextStyle(
                fontSize: 30,
                color: HexColor("#151515"),
                fontWeight: FontWeight.w700),
          ),
          Text(
            appendStringDot(virtualAccount!.accountName!, 25),
            maxLines: 1,
            style: TextStyle(
                fontSize: 16,
                color: HexColor("#151515"),
                fontWeight: FontWeight.w600),
          ),
        ],
      ),
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
          child: CustomPaint(
            painter: QrPainter(
                data: getUserProfileLink(userBloc.user, searchedUser),
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

  String getUserProfileLink(User user, CustomerProfile? searchUser) {
    var userObject;
    userObject = searchUser ?? user;
    var path = userObject.type!;

    if (widget.arguments['product'] != null) {
      return widget.arguments['productUrl'];
    }

    if (path == 'User' || path == null) {
      path = 'user';
    } else {
      path = 'store';
    }
    final String url = "https://slydo.co/$path/${userObject.userName}";
    return url;
  }

  Widget _financialInfo() {
    return InkWell(
      onTap: () {
        Navigator.pushNamed(context, Routes.USER_PROFILE,
            arguments: {"searchedUserName": virtualAccount!.customerUsername!});
      },
      child: Column(
        children: [
          const SizedBox(
            height: 10.0,
          ),
          if (virtualAccount!.financialInstitution!.name != null)
            Text(
              appendStringDot(virtualAccount!.financialInstitution!.name!, 25),
              maxLines: 1,
              style: TextStyle(
                  fontSize: 16, color: white, fontWeight: FontWeight.w600),
            )
          else
            const SizedBox.shrink(),
          Text(
            appendStringDot(virtualAccount!.accountNumber!, 15),
            maxLines: 1,
            style: TextStyle(
                fontSize: 30, color: white, fontWeight: FontWeight.w700),
          ),
          Text(
            appendStringDot(virtualAccount!.accountName!, 25),
            maxLines: 1,
            style: TextStyle(
                fontSize: 16, color: white, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _scanToPayInfo() {
    return InkWell(
      onTap: () {
        Navigator.pushNamed(context, Routes.USER_PROFILE,
            arguments: {"searchedUserName": virtualAccount!.customerUsername!});
      },
      child: Column(
        children: [
          const SizedBox(
            height: 10.0,
          ),
          Text(
            appendStringDot(
                virtualAccount == null
                    ? '@${virtualAccount!.customerUsername!}'
                    : getGroupUsername('@${virtualAccount!.customerUsername!}'),
                25),
            maxLines: 1,
            style: TextStyle(
                fontSize: 14, color: white, fontWeight: FontWeight.w600),
          ),
          // userNameWithVerifiedIcon(
          //   name: searchedUser == null ? '@${userBloc.user.userName}' : '@${searchedUser!.userName!}',
          //   isVerified: searchedUser == null ? userBloc.user.isVerified : searchedUser!.isVerified,
          //   verifiedIconColor: verifyGreen,
          //   textStyle: TextStyle(
          //       fontSize: 14,
          //       color: white,
          //       fontWeight: FontWeight.w600),
          // ),
          const SizedBox(
            height: 10.0,
          ),
          Text(
            "SCAN TO PAY",
            maxLines: 1,
            style: TextStyle(
                fontSize: 22, color: white, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }

  Widget _displayUserName() {
    return InkWell(
      onTap: () {
        Navigator.pushNamed(context, Routes.USER_PROFILE,
            arguments: {"searchedUserName": virtualAccount!.customerUsername!});
      },
      child: Column(
        children: [
          const SizedBox(
            height: 10.0,
          ),
          Text(
            appendStringDot(
                virtualAccount == null
                    ? '@${virtualAccount!.customerUsername!}'
                    : getGroupUsername('@${virtualAccount!.customerUsername!}'),
                25),
            maxLines: 1,
            style: TextStyle(
                fontSize: 14,
                color: HexColor("#151515"),
                fontWeight: FontWeight.w600),
          ),
          const SizedBox(
            height: 10.0,
          ),
          Text(
            "SCAN TO PAY",
            maxLines: 1,
            style: TextStyle(
                fontSize: 22,
                color: HexColor("#151515"),
                fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }

  Widget _scanQrButtonWidget() {
    return Padding(
      padding: const EdgeInsets.only(left: 25.0, right: 25.0),
      child: SizedBox(
        height: 50,
        child: CurvedButton(
          isPaymentBtn: true,
          backgroundColor: navyBlue,
          textColor: Colors.white,
          text: "SCAN QR",
          onPressed: () async {
            Navigator.of(context)
                .pushNamed(Routes.SCAN_QR, arguments: {'isRequest': false});
          },
        ),
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
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20)),
              ),
              color: Colors.white,
              margin: EdgeInsets.zero,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: generateBottomSheetItem(),
                ),
              ));
        });
  }

  List<Widget> generateBottomSheetItem() {
    final List<Widget> list = [];

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

  void shareQrCode() async {
    await screenshotController
        .capture(delay: const Duration(milliseconds: 10))
        .then((Uint8List? image) async {
      if (image != null) {
        final directory = await getApplicationDocumentsDirectory();
        final imagePath = searchedUser == null
            ? await File(
                    '${directory.path}/${userBloc.user.displayName()!}.png')
                .create()
            : await File(
                    '${directory.path}/${searchedUser!.displayName()!}.png')
                .create();
        await imagePath.writeAsBytes(image);

        /// Share Plugin
        await Share.shareXFiles([XFile(imagePath.path)]);
      }
    });
  }

  void downloadQrCode() async {
    // Request external storage permission
    final status = await Permission.storage.request();

    if (status.isGranted) {
      showToast(message: 'Downloading QR Code');

      final freeSpace = await DiskSpace.getFreeDiskSpace;

      if (freeSpace != null && freeSpace > 10.00) {
        await screenshotController
            .capture(delay: const Duration(milliseconds: 10))
            .then((Uint8List? image) async {
          if (image != null) {
            //download image
            final path = await ExternalPath.getExternalStoragePublicDirectory(
                ExternalPath.DIRECTORY_DOWNLOADS);

            final imagePath = searchedUser == null
                ? await File(
                        '$path/${userBloc.user.displayName()!} + ${getCurrentDate()}.png')
                    .create()
                : await File(
                        '$path/${searchedUser!.displayName()!} + ${getCurrentDate()}.png')
                    .create();

            await imagePath.writeAsBytes(image);

            await Future.delayed(Duration.zero);

            showToast(
                message:
                    'Image downloaded to Download Folder on device storage');
          }
        });
      } else {
        showToast(
            message:
                'The device\'s internal memory is full or the available space is unknown.');
      }
    } else if (status.isPermanentlyDenied) {
      showToast(
          message:
              'Please grant permission from device settings to access storage.');
    }
  }

  String getCurrentDate() {
    return DateFormat('_yyyyMMdd_kkmmss').format(DateTime.now());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (mounted) setState(() {});
  }
}
