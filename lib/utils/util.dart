import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:Slydo/routes/route_constants.dart';
import 'package:Slydo/screens/home_tab/qr_code_page.dart';
import 'package:Slydo/screens/more_apps/payment_and_banking/models/virtual_account.dart';
import 'package:Slydo/screens/more_apps/payment_and_banking/payment_and_banking_auth.dart';
import 'package:Slydo/screens/more_apps/shopping/widget/product_detail_shimmer.dart';
import 'package:Slydo/screens/more_apps/user_profile/widgets/user_profile_shimmer.dart';
import 'package:Slydo/screens/more_apps/yarn/widgets/yarn_shimmer.dart';
import 'package:Slydo/utils/date_time_and_money_converter.dart';
import 'package:Slydo/utils/enums.dart';
import 'package:Slydo/utils/navigation_util.dart';
import 'package:Slydo/utils/slydo_app_icon_icons.dart';
import 'package:Slydo/widget/rounded_background_icon.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:crypto/crypto.dart';
import 'package:external_path/external_path.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_quill/flutter_quill.dart' as flutterQuill;
import 'package:flutter_quill_extensions/flutter_quill_embeds.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:jumping_dot/jumping_dot.dart';
import 'package:path_provider/path_provider.dart' as pathProvider;
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

import '../data/currency.dart';
import '../data/state_notifier.dart';
import '../locale/app_localization.dart';
import '../screens/more_apps/messaging/chat/utils.dart';
import '../screens/more_apps/payment_and_banking/models/transactions.dart';
import '../screens/more_apps/user_profile/models/user.dart';
import '../screens/more_apps/user_profile/screens/user_profile_module_new/profile_template/utils.dart';
import '../screens/more_apps/user_profile/user_auth.dart';
import '../widget/dialog.dart';
import '../widget/image_crop.dart';
import '../widget/loading_indicator.dart';
import 'colors.dart';
import 'common.dart';

export 'colors.dart';
export 'common.dart';

int maxVideoFileSize =
    90; // Maximum amount of MB that we accept for video files.

int amountLimit =
    10000000000; //For a given tile, if the amount is less than this, the amount will float to the right.

enum MediaType { picture, video }

Future<String?> getFile(BuildContext context,
    {MediaType fileType = MediaType.picture}) async {
  String? videoPath;
  String? croppedImage;

  final fileSource = await showDialog<ImageSource>(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      title: Text(
        fileType == MediaType.picture
            ? AppLocalization.of(context)!.selectTheImageSource
            : AppLocalization.of(context)!.selectTheVideoSource,
        style: TextStyle(fontSize: 18, color: blackFont),
      ),
      actions: <Widget>[
        MaterialButton(
          child: Text(
            AppLocalization.of(context)!.camera,
            style: TextStyle(fontSize: 16, color: blackFont),
          ),
          onPressed: () => Navigator.pop(context, ImageSource.camera),
        ),
        MaterialButton(
          child: Text(
            "Gallery",
            style: TextStyle(fontSize: 16, color: blackFont),
          ),
          onPressed: () => Navigator.pop(context, ImageSource.gallery),
        ),
      ],
    ),
  );

  if (fileSource != null) {
    if (fileType == MediaType.picture) {
      final file =
          await ImagePicker().pickImage(source: fileSource, imageQuality: 70);

      if (file != null) {
        /// for cropping the image
        croppedImage = await ImageCrop().cropImage(file.path);
        if (croppedImage == null) {
          return null;
        }
      }
    } else {
      final file = await ImagePicker().pickVideo(source: fileSource);
      if (file != null) {
        videoPath = file.path;
      }
    }
  }
  return fileType == MediaType.picture ? croppedImage : videoPath;
}

Future<String?> getCroppedImage(BuildContext context) async {
  String? croppedImage;
  final imageSource = await showDialog<ImageSource>(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      title: Text(
        AppLocalization.of(context)!.selectTheImageSource,
        style: TextStyle(fontSize: 18, color: blackFont),
      ),
      actions: <Widget>[
        MaterialButton(
          child: Text(
            AppLocalization.of(context)!.camera,
            style: TextStyle(fontSize: 16, color: blackFont),
          ),
          onPressed: () => Navigator.pop(context, ImageSource.camera),
        ),
        MaterialButton(
          child: Text(
            "Gallery",
            style: TextStyle(fontSize: 16, color: blackFont),
          ),
          onPressed: () => Navigator.pop(context, ImageSource.gallery),
        ),
      ],
    ),
  );

  if (imageSource != null) {
    final file =
        await ImagePicker().pickImage(source: imageSource, imageQuality: 70);
    if (file != null) {
      /// for cropping the image
      croppedImage = await ImageCrop().cropImage(file.path);
      if (croppedImage == null) {
        return null;
      }
    }
  }
  return croppedImage;
}

// this function will build image frame by frame and load image from opacity 0 to 1 use this function in every image
Widget imageFrameBuilder(BuildContext context, Widget child, int? frame,
    bool wasSynchronouslyLoaded) {
  if (wasSynchronouslyLoaded) {
    return child;
  }
  return AnimatedOpacity(
    opacity: frame == null ? 0 : 1,
    duration: const Duration(milliseconds: 100),
    curve: Curves.easeOut,
    child: child,
  );
}

Widget imageErrorForUserWidget(
        BuildContext context, String url, dynamic error) =>
    Image.network(
      defaultImage,
      colorBlendMode: BlendMode.darken,
      fit: BoxFit.fill,
      filterQuality: FilterQuality.high,
    );

Widget imageErrorWidget(BuildContext context, String url, dynamic error) =>
    Container(
      color: darkGrey.withOpacity(0.50),
      child: Image.asset(
        defaultProductAndServiceImage,
        width: double.infinity,
        height: double.infinity,
        colorBlendMode: BlendMode.darken,
        fit: BoxFit.cover,
        filterQuality: FilterQuality.high,
      ),
    );

Widget imageErrorWidgetForMomentTile(
        BuildContext context, String url, dynamic error) =>
    Container(
      color: darkGrey.withOpacity(0.50),
      child: Image.asset(
        defaultProductAndServiceImage,
        width: double.infinity,
        height: double.infinity,
        colorBlendMode: BlendMode.darken,
        fit: BoxFit.scaleDown,
        filterQuality: FilterQuality.high,
      ),
    );

Widget wallpaperErrorWidget(BuildContext context, String url, dynamic error) =>
    Image.asset(
      defaultWallPaper,
      width: double.infinity,
      height: double.infinity,
      colorBlendMode: BlendMode.darken,
      fit: BoxFit.cover,
      filterQuality: FilterQuality.high,
    );

String? getLoggedInUserName(BuildContext context) {
  return Provider.of<UserBloc>(context, listen: false).user.userName;
}

Widget getCircularUserAvatar(
  String imgUrl, {
  Color borderColor = Colors.black,
  double width = 27,
  double height = 27,
}) {
  return Container(
    width: width,
    height: height,
    padding: const EdgeInsets.all(6),
    decoration: BoxDecoration(
      border: Border.all(color: borderColor, width: 2),
      shape: BoxShape.circle,
      image: DecorationImage(
        fit: BoxFit.cover,
        image: CachedNetworkImageProvider(
          imgUrl,
        ),
      ),
    ),
  );
}

String getFormattedViewCount(
    {required int noOfViews,
    bool addViewText = true,
    bool showZeroViews = false}) {
  if (noOfViews == 0 && showZeroViews == true) {
    return '0${addViewText ? ' view' : ''}';
  }
  if (noOfViews == 1 || noOfViews == 0) {
    return '1${addViewText ? ' view' : ''}';
  }

  if (noOfViews < 1000) {
    return '$noOfViews ${addViewText ? 'views' : ''}';
  } else if (noOfViews >= 1000 && noOfViews < 10000) {
    return '${(noOfViews / 1000).floor()}K${addViewText ? ' views' : ''}';
  } else if (noOfViews >= 10000 && noOfViews < 1000000) {
    return '${(noOfViews / 1000).floor()}K${addViewText ? ' views' : ''}';
  } else if (noOfViews >= 1000000 && noOfViews < 1000000000) {
    return '${(noOfViews / 1000000).floor()}M${addViewText ? ' views' : ''}';
  } else if (noOfViews >= 1000000000 && noOfViews < 1000000000000) {
    return '${(noOfViews / 1000000000).floor()}B${addViewText ? ' views' : ''}';
  } else {
    return '${(noOfViews / 1000000000000).floor()}T${addViewText ? ' views' : ''}';
  }
}

Future<String?> generateThumbNailFromVideo({required String videoPath}) async {
  final videoInUnit8List = await VideoThumbnail.thumbnailData(
    video: videoPath,
    quality: 85,
    timeMs: 5,
  );

  if (videoInUnit8List != null) {
    final tempDir = await getTemporaryDirectory();
    final String uniqueId = const Uuid().v4();
    final File file = await File('${tempDir.path}/$uniqueId.jpg').create();
    //Example of file => File: '/data/user/0/com.slydo.slydo/cache/954e542e-c217-46d8-867c-cfcb8d2636ba.png'
    file.writeAsBytesSync(videoInUnit8List);
    return file.path;
  }
  return null;
}

Future<File?> generateThumbnailFromVideo({required String videoPath}) async {
  final videoInUnit8List = await VideoThumbnail.thumbnailData(
    video: videoPath,
    quality: 85,
    timeMs: 5,
  );

  if (videoInUnit8List != null) {
    final tempDir = await getTemporaryDirectory();
    final String uniqueId = const Uuid().v4();
    final File file = await File('${tempDir.path}/$uniqueId.jpg').create();
    //Example of file => File: '/data/user/0/com.slydo.slydo/cache/954e542e-c217-46d8-867c-cfcb8d2636ba.png'
    file.writeAsBytesSync(videoInUnit8List);
    return file;
  }
  return null;
}

// TagsStyler textFieldTagStyler = TagsStyler(
//   tagDecoration: BoxDecoration(
//     borderRadius: BorderRadius.circular(4),
//     color: HexColor("#F7F7F9"),
//   ),
//   tagTextStyle:
//       TextStyle(color: darkGrey, fontSize: 14, fontWeight: FontWeight.w400),
//   tagCancelIconPadding: const EdgeInsets.only(left: 12),
//   tagCancelIcon: Icon(SlydoAppIcon.close_2, color: blackFont),
// );
//
// TagsStyler productTextFieldTagStyler = TagsStyler(
//   tagDecoration: BoxDecoration(
//     borderRadius: BorderRadius.circular(15),
//     color: HexColor("#D9D9D9"),
//   ),
//   tagTextPadding: EdgeInsets.symmetric(horizontal: 6),
//   tagTextStyle:
//       TextStyle(color: black, fontSize: 14, fontWeight: FontWeight.w500),
//   tagCancelIconPadding: const EdgeInsets.only(left: 10),
//   tagCancelIcon: Icon(SlydoAppIcon.close_2, color: blackFont),
// );
// TextFieldStyler textFieldStyler = TextFieldStyler(
//   helperText: '',
//   hintText: '',
//   textFieldBorder: InputBorder.none,
// );

Widget productAndServiceErrorWidget(
        BuildContext context, String url, dynamic error) =>
    Container(
      color: darkGrey.withOpacity(0.50),
      child: Image.asset(
        defaultProductAndServiceImage,
        width: double.infinity,
        height: double.infinity,
        colorBlendMode: BlendMode.darken,
        fit: BoxFit.cover,
        filterQuality: FilterQuality.high,
      ),
    );

Widget productAndServiceBigErrorWidget(
        BuildContext context, String url, dynamic error) =>
    Container(
      color: darkGrey.withOpacity(0.50),
      child: Image.asset(
        defaultProductAndServiceImage,
        width: double.infinity,
        height: double.infinity,
        colorBlendMode: BlendMode.darken,
        fit: BoxFit.fill,
        filterQuality: FilterQuality.high,
      ),
    );

Widget customThemeBuilder(BuildContext context, Widget? child) {
  return Theme(
    data: ThemeData.light().copyWith(
      primaryColor: navyBlue,
      buttonTheme: const ButtonThemeData(textTheme: ButtonTextTheme.primary),
      colorScheme:
          ColorScheme.light(primary: navyBlue).copyWith(secondary: navyBlue),
    ),
    child: child!,
  );
}

Color colorStats(String status) {
  if (status.toLowerCase() == 'paid') {
    return Colors.green.shade400;
  }
  if (status.toLowerCase() == 'active') {
    return navyBlue;
  }
  if (status.toLowerCase() == 'suspended') {
    return Colors.yellow.shade700;
  }
  return Colors.red.shade400;
}

BoxDecoration decorateBox(
    {Color? borderColor,
    double borderRadius = 10,
    Color? shadowColor,
    Color? color}) {
  shadowColor ??= boxShadowTwo;
  return BoxDecoration(
    boxShadow: <BoxShadow>[
      BoxShadow(
        color: shadowColor,
        offset: const Offset(0.0, 0.0),
        blurRadius: 20.0,
      ),
    ],
    color: color ?? Colors.white,
    borderRadius: BorderRadius.all(
      Radius.circular(borderRadius),
    ),
    border: Border.all(
        color: borderColor ?? lightGrey, width: 1.0, style: BorderStyle.solid),
  );
}

Future<dynamic> androidBottomSheet(
    {required BuildContext context,
    required Widget child,
    bool enableDrag = true,
    bool isDismissible = true}) async {
  final result = await showModalBottomSheet(
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    context: context,
    enableDrag: enableDrag,
    isDismissible: isDismissible,
    builder: (BuildContext context) {
      return Card(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20), topRight: Radius.circular(20)),
        ),
        color: Colors.white,
        margin: EdgeInsets.zero,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
          child: child,
        ),
      );
    },
  );
  return result;
}

Widget transactionOrKycDetailTile(IconData icon, String title, String subtitle,
    {Transaction? transaction,
    Widget? trailingWidget,
    TextStyle? subtitleTextStyle}) {
  debugPrint("==>$subtitle");
  return ListTile(
    dense: true,
    leading: RoundedBackgroundIcon(
      icon: Icon(icon, color: blackFont, size: 18),
      backgroundColor: iconBtnGrey,
    ),
    title: Text(
      title,
      style: TextStyle(
        fontWeight: FontWeight.w600,
        color: blackFont,
        fontSize: 14,
      ),
    ),
    subtitle: Text(
      getCurrency(subtitle, transaction?.currency),
      style: subtitleTextStyle ??
          TextStyle(
            color: blackFont,
            fontSize: 14,
            fontFamily: "Inter",
          ),
    ),
    trailing: trailingWidget,
  );
}

Widget transactionOrPayoutTile(
    String path, String title, String subtitle, bool val,
    {Transaction? transaction,
    Widget? trailingWidget,
    TextStyle? subtitleTextStyle,
    BuildContext? context}) {
  // debugPrint("Fola ==>$subtitle");

  String? status = "";
  if (subtitle == 'Paid' || subtitle == 'Settled') {
    status = 'done';
  } else if (subtitle == 'Pending') {
    status = 'processing';
  } else if (subtitle == 'Cancelled') {
    status = 'cancel';
  }

  return ListTile(
    dense: true,
    leading: Container(
      padding: const EdgeInsets.all(10.0),
      margin: const EdgeInsets.only(top: 5.0, bottom: 5.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0),
        color: navyBlueLight.withOpacity(0.1),
      ),
      child: SvgPicture.asset(
        path,
        width: 14,
        height: 14,
        color: blackFont,
      ),
    ),
    title: Text(
      title,
      style: TextStyle(
        fontWeight: FontWeight.w600,
        color: blackFont,
        fontSize: 14,
      ),
    ),
    subtitle: Row(
      children: [
        Container(
          padding: status != ""
              ? const EdgeInsets.only(
                  left: 10.0, right: 10, top: 3.0, bottom: 3.0)
              : const EdgeInsets.all(0.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5.0),
            color: checkStatusBgColor(status),
          ),
          child: getDisplayContent(
              subtitle, transaction, subtitleTextStyle, status, context),
        ),
        Container(),
      ],
    ),
    trailing: trailingWidget,
  );
}

Widget getDisplayContent(String subtitle, Transaction? transaction,
    TextStyle? subtitleTextStyle, String status, BuildContext? context) {
  Color color = checkStatusForColor(status);
  if (subtitle.contains('Order Ref:')) {
    final String orderId =
        subtitle.replaceAll('Order Ref:', '').replaceAll(' ', '');
    color = checkStatusForColor('null');
    return GestureDetector(
      onTap: () async {
        await Navigator.pushNamed(context!, Routes.ORDER_DETAIL_PAGE,
            arguments: {"orderId": orderId});
      },
      child: Text(
        getCurrency(subtitle, transaction?.currency),
        style: subtitleTextStyle ??
            TextStyle(
              color: color,
              fontSize: 14,
              fontFamily: "Inter",
            ),
      ),
    );
  }
  return Text(
    getCurrency(subtitle, transaction?.currency),
    style: subtitleTextStyle ??
        TextStyle(
          color: color,
          fontSize: 14,
          fontFamily: "Inter",
        ),
  );
}

Color checkStatusBgColor(String status) {
  if (status == 'done') {
    return naturalGreen.withOpacity(0.1);
  } else if (status == 'processing') {
    return starYellow.withOpacity(0.1);
  } else if (status == 'cancel') {
    return mateRed.withOpacity(0.1);
  } else if (status == "") {
    return Colors.transparent;
  }
  return navyBlue;
}

//PDF Color

PdfColor checkStatusTextPdfColor(String status) {
  final PdfColor green = PdfColor.fromHex('#0F973D');
  final PdfColor yellow = PdfColor.fromHex("#F5B546");
  final PdfColor red = PdfColor.fromHex("#DD524D");
  final PdfColor navyBlue = PdfColor.fromHex("#3F61DB");

  if (status == 'done') {
    return green;
  } else if (status == 'processing') {
    return yellow;
  } else if (status == 'cancel') {
    return red;
  } else if (status == "") {
    return PdfColors.black;
  }

  return navyBlue;
}

Color checkStatusForColor(String status) {
  if (status == 'done') {
    return naturalGreen;
  } else if (status == 'processing') {
    return starYellow;
  } else if (status == 'cancel') {
    return mateRed;
  } else if (status == "") {
    return blackFont;
  }
  return navyBlue;
}

Widget getSettingTile(
    {Widget? image,
    String title = "",
    Function()? onTap,
    IconData? icon,
    Color? iconColor}) {
  iconColor ??= navyBlue;
  return Card(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    shadowColor: boxShadowTwo,
    elevation: 6,
    child: Container(
      decoration: decorateBox(),
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: ListTile(
        leading: RoundedBackgroundIcon(
          height: 50,
          width: 50,
          icon: image ??
              Icon(
                icon,
                color: iconColor,
                size: 20,
              ),
          backgroundColor: iconColor.withOpacity(0.08),
          borderRadius: 20,
          onTap: onTap,
        ),
        title: Text(
          title,
          maxLines: 1,
          style: TextStyle(
            color: blackFont,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
          overflow: TextOverflow.fade,
          softWrap: false,
        ),
        trailing: const Icon(
          Icons.keyboard_arrow_right_outlined,
          color: Color(0XFF1A399D),
        ),
        onTap: () {
          if (onTap != null) {
            onTap();
          }
        },
      ),
    ),
  );
}

Widget getChatSettingTitle() {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 20),
    child: Text(
      "How would you like to pay?",
      style:
          TextStyle(fontWeight: FontWeight.w500, fontSize: 14, color: darkGrey),
    ),
  );
}

Widget buildShimmerLoadingIndicator({required bool isLoading}) {
  return Opacity(
    opacity: isLoading ? 1.0 : 00,
    child: isLoading ? const YarnShimmer() : Container(),
  );
}

Widget buildProductShimmerLoadingIndicator({required bool isLoading}) {
  return Opacity(
    opacity: isLoading ? 1.0 : 00,
    child: isLoading ? const ProductDetailShimmer() : Container(),
  );
}

Widget buildProfileShimmerLoadingIndicator({required bool isLoading}) {
  return Opacity(
    opacity: isLoading ? 1.0 : 00,
    child: isLoading ? const UserProfileShimmer() : Container(),
  );
}

Widget buildLoadingIndicator({required bool isLoading}) {
  return Padding(
    padding: const EdgeInsets.all(8.0),
    child: Center(
      child: Opacity(
        opacity: isLoading ? 1.0 : 00,
        child: isLoading ? CircularLoadingIndicator() : Container(),
      ),
    ),
  );
}

Widget buildJumpingLoadingIndicator({required bool isLoading}) {
  return Padding(
    padding: const EdgeInsets.only(top: 15.0, bottom: 30.0),
    child: Center(
      child: Opacity(
        opacity: isLoading ? 1.0 : 00,
        child: isLoading
            ? JumpingDots(
                color: navyBlue,
                radius: 15,
                numberOfDots: 3,
              )
            : Container(),
      ),
    ),
  );
}

Widget customAppBar({required BuildContext context, required String title}) {
  return AppBar(
    surfaceTintColor: Colors.transparent,
    elevation: 0,
    titleSpacing: 0,
    backgroundColor: Colors.white,
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
    centerTitle: false,
    title: Text(
      title,
      style: TextStyle(
          color: blackFont, fontSize: 18, fontWeight: FontWeight.bold),
    ),
  );
}

Widget getColoredLabeledWidget({required String text, required Color color}) {
  return Container(
    margin: const EdgeInsets.only(left: 5.0),
    padding: const EdgeInsets.symmetric(horizontal: 5.0),
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(6),
    ),
    child: Text(
      text,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 14,
        fontWeight: FontWeight.w700,
      ),
    ),
  );
}

// for having expanded space
Widget flexibleSpace({int flex = 1}) {
  return Expanded(
    flex: flex,
    child: const SizedBox(
      height: 10,
      width: 10,
    ),
  );
}

void showSnackbar(BuildContext context,
    {required String message, int duration = 500}) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Text(message),
    duration: Duration(milliseconds: duration),
  ));
}

List monthName = [
  "January",
  "February",
  "March",
  "April",
  "May",
  "June",
  "July",
  "August",
  "September",
  "October",
  "November",
  "December"
];
List dayName = [
  "Monday",
  "Tuesday",
  "Wednesday",
  "Thursday",
  "Friday",
  "Saturday",
  "Sunday"
];

String getDayName({required int day}) {
  return dayName[day - 1];
}

String formatTime(String date) {
  final DateTime dateTime = DateTime.parse(date).toLocal();

  final String time = DateFormat("hh:mm a").format(dateTime);

  return time;
}

bool isTimeAfter(DateTime startTime, DateTime endTime) {
  final TimeOfDay start = TimeOfDay.fromDateTime(startTime);
  final TimeOfDay end = TimeOfDay.fromDateTime(endTime);

  if (start.hour < end.hour) {
    print("startTime = $startTime endTIME $endTime");
    return true;
  } else if (start.hour == end.hour && start.minute < end.minute) {
    print("startTime == $startTime endTIME == $endTime");
    return true;
  }
  return false;
}

String formatTime24hrs(DateTime? date) {
  if (date == null) {
    return '';
  }
  return DateFormat("HH:mm").format(date);
}

bool isMidnight(DateTime dateTime) {
  return dateTime.hour == 0 && dateTime.minute == 0 && dateTime.second == 0;
}

String formatDateTime(DateTime dateTime) {
  return '${formatDateForOrder(dateTime)} ${formatTime24hrs(dateTime)}';
}

String formatDate(DateTime? dateTime) {
  if (dateTime == null) {
    return '';
  }
  final String date = "${dateTime.day}/${dateTime.month}/${dateTime.year}";

  return date;
}

String formatDate1(DateTime? dateTime) {
  if (dateTime == null) {
    return '';
  }
  final DateFormat formatter = DateFormat('dd/MM/yyyy');
  return formatter.format(dateTime);
}

String formatDateForOrder(DateTime? dateTime) {
  if (dateTime == null) {
    return '';
  }
  final String date = "${dateTime.year}-${dateTime.month}-${dateTime.day}";

  return date;
}

String formatDateInTwoDigit(DateTime dateTime) {
  final String date =
      "${dateTime.day.toString().padLeft(2, '0')} ${monthName[dateTime.month - 1]}, ${dateTime.year}";

  return date;
}

String formatDateInDigit(DateTime dateTime) {
  final String date = "${dateTime.day}/${dateTime.month}/${dateTime.year}";

  return date;
}

String formatDurationInSeconds({Duration? duration}) {
  String formattedDuration = "";
  if (int.parse(duration.toString().substring(0, 1)) > 0) {
    formattedDuration = duration.toString().substring(0, 7);
  } else {
    formattedDuration = duration.toString().substring(2, 7);
  }

  return formattedDuration;
}

String dateToString(DateTime date) {
  final formatter = DateFormat('yyyy-MM-dd');
  final formatted = formatter.format(date);
  return formatted;
}

String durationToString(Duration duration) {
  String twoDigits(int n) {
    if (n >= 10) return "$n";
    return "0$n";
  }

  final String twoDigitMinutes =
      twoDigits(duration.inMinutes.remainder(Duration.minutesPerHour));
  final String twoDigitSeconds =
      twoDigits(duration.inSeconds.remainder(Duration.secondsPerMinute));
  return "$twoDigitMinutes:$twoDigitSeconds";
}

class PaymentDuration {
  String? name;
  String? value;

  PaymentDuration({this.name, this.value});
}

List<PaymentDuration> paymentDurations = [
  PaymentDuration(name: "Daily (7 days)", value: "daily"),
  PaymentDuration(name: "Business day only (5 days)", value: "weekday_only"),
  PaymentDuration(name: "Weekly", value: "weekly"),
  PaymentDuration(name: "Monthly", value: "monthly"),
  PaymentDuration(name: "Yearly", value: "yearly"),
];

List<String> errorImageList = [
  "https://slydo-assets.s3.amazonaws.com/media/customer/avatar/me_uAxOKxt.jpeg",
  "https://slydo-assets.s3.amazonaws.com/media/customer/avatar/me_DN78oka.jpeg",
  "https://slydo-assets.s3.amazonaws.com/media/customer/avatar/me.jpeg"
];

Widget getAmount(int? amount, String? currency, {double fontSize = 14}) {
  return Row(
    mainAxisSize: MainAxisSize.min,
    children: <Widget>[
      Text(
        worldCurrencies[currency!]!,
        style: TextStyle(
            fontFamily: "Inter",
            color: blackFont,
            fontWeight: FontWeight.bold,
            fontSize: fontSize),
      ),
      Text(
        moneyDisplayNormalizer(amount),
        style: TextStyle(
            color: blackFont, fontWeight: FontWeight.bold, fontSize: fontSize),
      ),
    ],
  );
}

Widget getDateTime(BuildContext context, String dateTime,
    {double fontSize = 10}) {
  final DateTime transactionTime = DateTime.parse(dateTime).toLocal();
  final String date = DateFormat("dd/MM/yyyy").format(transactionTime);
  final String time = DateFormat("hh:mm a").format(transactionTime);
  return Text(
    "$date • $time",
    softWrap: false,
    overflow: TextOverflow.visible,
    style: TextStyle(color: darkGrey, fontSize: fontSize),
  );
}

void apiErrorHandler({String? error, BuildContext? context, int duration = 1}) {
  Fluttertoast.showToast(
    msg: "$error",
    toastLength: Toast.LENGTH_LONG,
    gravity: ToastGravity.BOTTOM,
    backgroundColor: Colors.black,
    textColor: Colors.white,
  );
}

int moneyInputNormalizer(String amount) {
  final double value = double.parse(amount) * 100;
  // Format the money into integer as server store money in integer
  return value.toInt();
}

int moneyInputNormalizer2(String amount) {
  final double value = double.parse(amount) / 100;
  // Format the money into integer as server store money in integer
  return value.toInt();
}

String moneyDisplayNormalizer(int? amount) {
  // Format the money into double as server returns money in integer
  // amount = 1050500;

  if (amount.toString().length >= 3) {
    final int amountLength = amount.toString().length;

    final int getLastTwoDigit =
        int.parse(amount.toString().substring(amountLength - 2, amountLength));

    if (getLastTwoDigit > 0) {
      return moneyConverter(
          double.parse((amount! / 100).toString()).toStringAsFixed(2),
          isNotCompact: true);
    } else {
      return moneyConverter(
          double.parse((amount! / 100).toString()).toStringAsFixed(2),
          isNotCompact: true);
    }
  } else {
    return moneyConverter(
        double.parse((amount! / 100).toString()).toStringAsFixed(2),
        isNotCompact: true);
  }
}

String moneyNormalizer(int? amount) {
  // Format the money into double as server returns money in integer
  // amount = 1050500;

  return (amount! / 100).toStringAsFixed(2);
}

int moneyDisplayNormalizerForGraph(int? amount) {
  // Format the money into double as server returns money in integer
  // amount = 1050500;

  final int formattedAmount =
      (double.parse(amount.toString()) / 100).truncate();
  return formattedAmount;
}

String getSecureUrl({required String url}) {
  String secureUrl;
  if (!url.startsWith("https://")) {
    url = url.replaceFirst("http", "https");
  }
  secureUrl = url;
  return secureUrl;
}

/// For Storing notification image
Future<String> saveImage(BuildContext context, Image image) {
  final completer = Completer<String>();

  image.image
      .resolve(const ImageConfiguration())
      .addListener(ImageStreamListener((imageInfo, _) async {
    final ByteData? byteData =
        await imageInfo.image.toByteData(format: ImageByteFormat.png);
    if (byteData == null) return Future.error("ERROR while saving image");
    final pngBytes = byteData.buffer.asUint8List();

    final fileName = pngBytes.hashCode;
    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/$fileName';
    final file = File(filePath);
    await file.writeAsBytes(pngBytes);

    completer.complete(filePath);
  }));

  return completer.future;
}

///generate hash of the message
String generateHashedMessage(String input) {
  return md5.convert(utf8.encode(input)).toString();
}

Future<double> getAccountBalance() async {
  final Map<String, dynamic>? data =
      await PaymentAndBankingAuth().getAccountBalance();
  if (data == null) return 0.0;

  final int spendableBalance = data["spendable_balance"];

  final double accountBalanceConverted = spendableBalance / 100;
  debugPrint("ACCOUNT BALANCE:- $accountBalanceConverted");

  return accountBalanceConverted;
}

const String defaultImage =
    "https://slydo-assets.s3.amazonaws.com/static/images/User_Avatar.png";

const String defaultWallPaper = "assets/images/home_screen_background.png";

const String defaultProductAndServiceImage =
    "assets/images/default_image/product_and_service.png";

void showToast({BuildContext? context, String? message}) {
  Fluttertoast.showToast(
    msg: "$message",
    toastLength: Toast.LENGTH_LONG,
    gravity: ToastGravity.BOTTOM,
    backgroundColor: Colors.black,
    textColor: Colors.white,
  );
}

String? validateSlydoName(String userInput) {
  final String lowerCaseInput = userInput.toLowerCase();
  final String cleanName = lowerCaseInput
      .replaceAll(".", "")
      .replaceAll(" ", "")
      .replaceAll("_", "")
      .replaceAll("-", "");

  if (cleanName.contains('slydo')) {
    return null;
  } else {
    return 'Passed';
  }
}

Widget userNameWithVerifiedIcon({
  String? name,
  required bool? isVerified,
  int lengthToTruncateAt = 25,
  double verifiedIconSize = 18,
  TextStyle? textStyle,
  Color? verifiedIconColor,
}) {
  return RichText(
    maxLines: 1,
    text: TextSpan(
      style: textStyle ??
          TextStyle(
            color: blackFont,
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
      text: truncateString(
        str: messageDecoderWithEmoji(name)!,
        lengthToTruncateAt: lengthToTruncateAt,
      ),
      children: [
        const TextSpan(text: ' '),
        WidgetSpan(
          child: isVerified != null && isVerified == true
              ? Icon(
                  Icons.verified_rounded,
                  color: verifiedIconColor ?? verifyGreen,
                  size: verifiedIconSize,
                )
              : const SizedBox.shrink(),
        ),
      ],
    ),
  );
}

String truncateString(
    {required String str,
    required int lengthToTruncateAt,
    bool showEllipsis = true}) {
  if (str.length <= lengthToTruncateAt) {
    return str;
  }

  return showEllipsis
      ? '${str.substring(0, lengthToTruncateAt)}...'
      : str.substring(0, lengthToTruncateAt);
}

String slydoNameMsg = 'You can not use slydo in name';

String? checkSlydoName(String name) {
  String? result;

  if (name.isNotEmpty && name != "") {
    final String lowerCaseInput = name.trim().toLowerCase();

    debugPrint("ERROR lowerCaseInput:- $lowerCaseInput");

    final String cleanName = lowerCaseInput
        .replaceAll(".", "")
        .replaceAll(" ", "")
        .replaceAll("_", "")
        .replaceAll("-", "");

    debugPrint("ERROR cleanName:- $cleanName");

    if (cleanName.contains('slydo')) {
      result = slydoNameMsg;
    }

    debugPrint("ERROR:- $result");
  }
  return result;
}

String getFormattedAccountNumber({String accountNumber = "0000000000"}) {
  if (accountNumber.length != 10) {
    accountNumber = '0000$accountNumber';
  }
  return '******${accountNumber.substring(accountNumber.length - 5, accountNumber.length)}';
}

double formatRating(double rating) {
  return double.parse(rating.toStringAsFixed(1));
}

class BlogSettingsTitles extends StatefulWidget {
  final bool isEnabled;
  final Function()? onTap;
  bool? isSwitched;
  final Widget icon;
  final String title;
  final bool hasSwitch;
  final String description;
  final bool addElevation;
  final Widget? trailingWidget;
  final Function(bool isSwitched)? onChanged;

  BlogSettingsTitles(
      {super.key,
      this.isEnabled = true,
      required this.icon,
      required this.title,
      this.onChanged,
      this.onTap,
      this.isSwitched,
      required this.description,
      this.hasSwitch = true,
      this.trailingWidget,
      this.addElevation = true});

  @override
  State<BlogSettingsTitles> createState() => _BlogSettingsTitlesState();
}

class _BlogSettingsTitlesState extends State<BlogSettingsTitles> {
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: widget.addElevation ? 2 : 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 2),
      child: ListTile(
        onTap: widget.onTap,
        contentPadding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        leading: CircleAvatar(
          backgroundColor: lightGrey,
          child: widget.icon,
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.title,
              style: TextStyle(
                color: widget.isEnabled ? blackFont : greyBorderColor,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
              overflow: TextOverflow.fade,
              softWrap: false,
            ),
            Text(
              widget.description,
              style: TextStyle(
                color: widget.isEnabled ? Colors.grey : greyBorderColor,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ],
        ),
        trailing: widget.hasSwitch
            ? Switch(
                activeColor: navyBlue,
                value: widget.isSwitched!,
                onChanged: widget.onChanged,
                activeTrackColor: navyBlueLight,
                inactiveTrackColor: navyBlueLight,
              )
            : widget.trailingWidget ?? const SizedBox.shrink(),
      ),
    );
  }
}

Widget getClickableRatingBar(
    {required double initialRating,
    required Function(double) onRatingUpdate,
    required double starSize}) {
  return RatingBar.builder(
    initialRating: initialRating,
    minRating: 1,
    direction: Axis.horizontal,
    allowHalfRating: false,
    itemSize: starSize,
    itemCount: 5,
    itemPadding: const EdgeInsets.symmetric(horizontal: 8),
    itemBuilder: (context, _) => Icon(
      SlydoAppIcon.star,
      color: starYellow,
    ),
    onRatingUpdate: onRatingUpdate,
    unratedColor: greyBorderColor,
    glowColor: greyBorderColor,
  );
}

Widget getRating({required int? numberOfRating, double starSize = 12}) {
  final List<Widget> widgets = [];

  for (int i = 1; i < 6; i++) {
    widgets.add(
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 0.5),
        child: Icon(
          SlydoAppIcon.star,
          color: getRatingColor(numberOfRating, i),
          size: starSize,
        ),
      ),
    );
  }
  return Row(
    mainAxisSize: MainAxisSize.min,
    children: widgets,
  );
}

Color getRatingColor(int? numberOfRating, int i) {
  return numberOfRating != null
      ? numberOfRating >= i
          ? starYellow
          : greyBorderColor.withOpacity(0.8)
      : Colors.grey;
}

String enumToString(UtilitiesProvidersEnum mEnum) {
  //UtilitiesProvidersEnum.Electricity

  return mEnum.toString().split('.')[1].replaceAll('_', ' ');
}

Future<bool> doesFileExist(String filePath) async {
  return await File(filePath).exists();
}

// This function helps to add a string at the back of each file name IF that
// file already exists in the user's file system, so that each file name will
// be unique.
Future<String> makeFileName(String path, String fileName) async {
  final bool fileExists = await File('$path/$fileName').exists();

  if (fileExists) {
    int counter = 1;
    final List newFileExt = fileName.split('.');
    final String ext = newFileExt[1]; // refers to the file extension.

    final String fName = newFileExt[0];

    String newFileName = '$fName($counter).$ext';

    bool newFileExists = await File('$path/$newFileName').exists();

    while (newFileExists) {
      final List newFileExt = fileName.split('.');

      final String ext = newFileExt[1];

      String fName = newFileExt[0];

      /// The regex here is used to get the last occurrence of something like this: (1)
      /// (opening and closing bracket with digit(s) inside). The reason for this is that
      /// it may happen that a file name itself contains (something like this) "(1)"
      final RegExp regExp = RegExp(r'\([0-9]+\)$');
      final String? stringMatch = regExp.stringMatch(fName);

      if (stringMatch != null) {
        fName = fName.replaceAll(regExp, "(${counter + 1})");
      } else {
        fName = "$fName($counter)";
      }

      newFileName = '$fName.$ext';

      newFileExists = await File('$path/$newFileName').exists();
      counter += 1;
    }

    return newFileName;
  }

  return fileName;
}

Future<String> getLocalPathToSaveDownloads(
    {required String uniqueFileName}) async {
  if (Platform.isAndroid) {
    String path = '';

    // Directory dir = Directory('/storage/emulated/0/Download');
    // // Directory dir = await getApplicationDocumentsDirectory();
    // //
    // path = '${dir.path}/$uniqueFileName';

    path = await ExternalPath.getExternalStoragePublicDirectory(
        ExternalPath.DIRECTORY_DOWNLOADS);

    return path;
  } else {
    final directory = await pathProvider.getApplicationDocumentsDirectory();

    return '${directory.path}/$uniqueFileName';
  }
}

Future<bool> checkStoragePermission() async {
  final status = await Permission.storage.status;

  if (status.isGranted) {
    return true;
  } else if (status.isPermanentlyDenied) {
    openAppSettings();
  } else {
    final Map<Permission, PermissionStatus> permissions =
        await [Permission.storage].request();

    if (permissions[Permission.storage] == PermissionStatus.granted) {
      return true;
    }
  }

  return false;
}

String? toTimeAgoLabel({required DateTime dateTime}) {
  final now = DateTime.now();
  final durationSinceNow = now.difference(dateTime);

  final inSeconds = durationSinceNow.inSeconds;
  final inMinutes = durationSinceNow.inMinutes;
  final inHours = durationSinceNow.inHours;
  final inDays = durationSinceNow.inDays;
  int inWeeks = 0;
  int inFewMonths = 0;
  int inYears = 0;

  //check for years
  if (inDays >= 364) {
    inYears = (inDays / 364).round();

    return inYears >= 2 ? '$inYears years ago' : '$inYears year ago';
  }

  //check for months
  if (inDays > 30 && inDays < 365) {
    inFewMonths = (inDays / 12).round();

    return inFewMonths >= 2
        ? '$inFewMonths months ago'
        : '$inFewMonths month ago';
  }

  //check for weeks
  if (inDays < 30 && inDays > 7) {
    inWeeks = (inDays / 4).round();

    return inWeeks >= 2 ? '$inWeeks weeks ago' : '$inWeeks week ago';
  }

  //check for days
  if (inDays >= 1) {
    // return inDays.toString();
    final String convertedDate = DateFormat("dd/MM/yyyy").format(dateTime);
    return convertedDate;
  }

  //check for hours
  if (inHours <= 24) {
    return inHours <= 1 ? '$inHours hours ago' : 'an hour ago';
  }

  //check for minutes
  if (inMinutes >= 2) {
    return inHours >= 2
        ? '$inMinutes minutes ago'
        : '${durationSinceNow.inMinutes} minutes ago';
  }

  //check for seconds
  if (inSeconds >= 3 && inSeconds < 61) {
    return inSeconds >= 3 && inSeconds < 61
        ? '$inSeconds seconds ago'
        : 'just now';
  }

  debugPrint('IN MINUTES --> $inMinutes');
}

String elapsedTime({required DateTime dateTime}) {
  final now = DateTime.now();
  final difference = now.difference(dateTime);

  if (difference.inSeconds < 60) {
    return '${difference.inSeconds} ${(difference.inSeconds == 1 ? 'second' : 'seconds')} ago';
  } else if (difference.inMinutes < 60) {
    return '${difference.inMinutes} ${(difference.inMinutes == 1 ? 'minute' : 'minutes')} ago';
  } else if (difference.inHours < 24) {
    return '${difference.inHours} ${(difference.inHours == 1 ? 'hour' : 'hours')} ago';
  } else if (difference.inDays < 30) {
    return '${difference.inDays} ${(difference.inDays == 1 ? 'day' : 'days')} ago';
  } else if (difference.inDays < 365) {
    final months = (difference.inDays / 30).floor();
    return '$months ${(months == 1 ? 'month' : 'months')} ago';
  } else {
    final years = (difference.inDays / 365).floor();
    return '$years ${(years == 1 ? 'year' : 'years')} ago';
  }
}

String toTimeAgoLabelYarn({required DateTime dateTime}) {
  final now = DateTime.now();
  final durationSinceNow = now.difference(dateTime);

  final inDays = durationSinceNow.inDays;
  if (inDays >= 1) {
    // return inDays.toString();
    final String convertedDate = DateFormat("dd/MM/yyyy").format(dateTime);
    return convertedDate;
  }

  final inHours = durationSinceNow.inHours;
  if (inHours >= 1) {
    return inHours >= 2 ? '$inHours hours ago' : 'an hour ago';
  }

  final inMinutes = durationSinceNow.inMinutes;
  debugPrint('IN MINUTES --> $inMinutes');

  if (inMinutes >= 2) {
    return inHours >= 2
        ? '$inMinutes minutes ago'
        : '${durationSinceNow.inMinutes} minutes ago';
  }

  final inSeconds = durationSinceNow.inSeconds;
  return (inSeconds >= 3 && inSeconds < 61)
      ? '$inSeconds seconds ago'
      : 'just now';
}

List<ViolationType> violationType = [
  ViolationType(id: 1, type: "Harassment and bullying"),
  ViolationType(id: 2, type: "Harmful and dangerous content"),
  ViolationType(id: 3, type: "Threatening Violence"),
  ViolationType(id: 4, type: "Hate and vulgar language"),
  ViolationType(id: 5, type: "Nudity and sexual content"),
  ViolationType(id: 6, type: "Sharing personal information"),
  ViolationType(id: 7, type: "Prohibited transaction"),
  ViolationType(id: 8, type: "Impersonation"),
  ViolationType(id: 9, type: "Copyright violation"),
  ViolationType(id: 10, type: "Trademark violation"),
  ViolationType(id: 11, type: "Self-harm or suicide"),
  ViolationType(id: 12, type: "Spam, deceptive practices and scams"),
  ViolationType(id: 13, type: "Misinformation"),
  ViolationType(id: 14, type: "Fake engagement"),
  ViolationType(id: 15, type: "Violent and graphic content"),
];

class ViolationType {
  int? id;
  String? type;

  ViolationType({this.id, this.type});
}

List<Map<String, dynamic>> nigeriaStateAndLg = [
  {
    "state": "NationWide",
    "lgas": ["NationWide"]
  },
  {
    "state": "Abia",
    "lgas": [
      "Aba North",
      "Aba South",
      "Arochukwu",
      "Bende",
      "Ikawuno",
      "Ikwuano",
      "Isiala-Ngwa North",
      "Isiala-Ngwa South",
      "Isuikwuato",
      "Umu Nneochi",
      "Obi Ngwa",
      "Obioma Ngwa",
      "Ohafia",
      "Ohaozara",
      "Osisioma",
      "Ugwunagbo",
      "Ukwa West",
      "Ukwa East",
      "Umuahia North",
      "Umuahia South"
    ]
  },
  {
    "state": "Adamawa",
    "lgas": [
      "Demsa",
      "Fufore",
      "Ganye",
      "Girei",
      "Gombi",
      "Guyuk",
      "Hong",
      "Jada",
      "Lamurde",
      "Madagali",
      "Maiha",
      "Mayo-Belwa",
      "Michika",
      "Mubi-North",
      "Mubi-South",
      "Numan",
      "Shelleng",
      "Song",
      "Toungo",
      "Yola North",
      "Yola South"
    ]
  },
  {
    "state": "Akwa Ibom",
    "lgas": [
      "Abak",
      "Eastern-Obolo",
      "Eket",
      "Esit-Eket",
      "Essien-Udim",
      "Etim-Ekpo",
      "Etinan",
      "Ibeno",
      "Ibesikpo-Asutan",
      "Ibiono-Ibom",
      "Ika",
      "Ikono",
      "Ikot-Abasi",
      "Ikot-Ekpene",
      "Ini",
      "Itu",
      "Mbo",
      "Mkpat-Enin",
      "Nsit-Atai",
      "Nsit-Ibom",
      "Nsit-Ubium",
      "Obot-Akara",
      "Okobo",
      "Onna",
      "Oron",
      "Oruk Anam",
      "Udung-Uko",
      "Ukanafun",
      "Urue-Offong/Oruko",
      "Uruan",
      "Uyo"
    ]
  },
  {
    "state": "Anambra",
    "lgas": [
      "Aguata",
      "Anambra East",
      "Anambra West",
      "Anaocha",
      "Awka North",
      "Awka South",
      "Ayamelum",
      "Dunukofia",
      "Ekwusigo",
      "Idemili-North",
      "Idemili-South",
      "Ihiala",
      "Njikoka",
      "Nnewi-North",
      "Nnewi-South",
      "Ogbaru",
      "Onitsha-North",
      "Onitsha-South",
      "Orumba-North",
      "Orumba-South"
    ]
  },
  {
    "state": "Bauchi",
    "lgas": [
      "Alkaleri",
      "Bauchi",
      "Bogoro",
      "Damban",
      "Darazo",
      "Dass",
      "Gamawa",
      "Ganjuwa",
      "Giade",
      "Itas/Gadau",
      "Jama'Are",
      "Katagum",
      "Kirfi",
      "Misau",
      "Ningi",
      "Shira",
      "Tafawa-Balewa",
      "Toro",
      "Warji",
      "Zaki"
    ]
  },
  {
    "state": "Benue",
    "lgas": [
      "Ado",
      "Agatu",
      "Apa",
      "Buruku",
      "Gboko",
      "Guma",
      "Gwer-East",
      "Gwer-West",
      "Katsina-Ala",
      "Konshisha",
      "Kwande",
      "Logo",
      "Makurdi",
      "Ogbadibo",
      "Ohimini",
      "Oju",
      "Okpokwu",
      "Otukpo",
      "Tarka",
      "Ukum",
      "Ushongo",
      "Vandeikya"
    ]
  },
  {
    "state": "Borno",
    "lgas": [
      "Abadam",
      "Askira-Uba",
      "Bama",
      "Bayo",
      "Biu",
      "Chibok",
      "Damboa",
      "Dikwa",
      "Gubio",
      "Guzamala",
      "Gwoza",
      "Hawul",
      "Jere",
      "Kaga",
      "Kala/Balge",
      "Konduga",
      "Kukawa",
      "Kwaya-Kusar",
      "Mafa",
      "Magumeri",
      "Maiduguri",
      "Marte",
      "Mobbar",
      "Monguno",
      "Ngala",
      "Nganzai",
      "Shani"
    ]
  },
  {
    "state": "Bayelsa",
    "lgas": [
      "Brass",
      "Ekeremor",
      "Kolokuma/Opokuma",
      "Nembe",
      "Ogbia",
      "Sagbama",
      "Southern-Ijaw",
      "Yenagoa"
    ]
  },
  {
    "state": "Cross River",
    "lgas": [
      "Abi",
      "Akamkpa",
      "Akpabuyo",
      "Bakassi",
      "Bekwarra",
      "Biase",
      "Boki",
      "Calabar-Municipal",
      "Calabar-South",
      "Etung",
      "Ikom",
      "Obanliku",
      "Obubra",
      "Obudu",
      "Odukpani",
      "Ogoja",
      "Yakurr",
      "Yala"
    ]
  },
  {
    "state": "Delta",
    "lgas": [
      "Aniocha North",
      "Aniocha-North",
      "Aniocha-South",
      "Bomadi",
      "Burutu",
      "Ethiope-East",
      "Ethiope-West",
      "Ika-North-East",
      "Ika-South",
      "Isoko-North",
      "Isoko-South",
      "Ndokwa-East",
      "Ndokwa-West",
      "Okpe",
      "Oshimili-North",
      "Oshimili-South",
      "Patani",
      "Sapele",
      "Udu",
      "Ughelli-North",
      "Ughelli-South",
      "Ukwuani",
      "Uvwie",
      "Warri South-West",
      "Warri North",
      "Warri South"
    ]
  },
  {
    "state": "Ebonyi",
    "lgas": [
      "Abakaliki",
      "Afikpo-North",
      "Afikpo South (Edda)",
      "Ebonyi",
      "Ezza-North",
      "Ezza-South",
      "Ikwo",
      "Ishielu",
      "Ivo",
      "Izzi",
      "Ohaukwu",
      "Onicha"
    ]
  },
  {
    "state": "Edo",
    "lgas": [
      "Akoko Edo",
      "Egor",
      "Esan-Central",
      "Esan-North-East",
      "Esan-South-East",
      "Esan-West",
      "Etsako-Central",
      "Etsako-East",
      "Etsako-West",
      "Igueben",
      "Ikpoba-Okha",
      "Oredo",
      "Orhionmwon",
      "Ovia-North-East",
      "Ovia-South-West",
      "Owan East",
      "Owan-West",
      "Uhunmwonde"
    ]
  },
  {
    "state": "Ekiti",
    "lgas": [
      "Ado-Ekiti",
      "Efon",
      "Ekiti-East",
      "Ekiti-South-West",
      "Ekiti-West",
      "Emure",
      "Gbonyin",
      "Ido-Osi",
      "Ijero",
      "Ikere",
      "Ikole",
      "Ilejemeje",
      "Irepodun/Ifelodun",
      "Ise-Orun",
      "Moba",
      "Oye"
    ]
  },
  {
    "state": "Enugu",
    "lgas": [
      "Aninri",
      "Awgu",
      "Enugu-East",
      "Enugu-North",
      "Enugu-South",
      "Ezeagu",
      "Igbo-Etiti",
      "Igbo-Eze-North",
      "Igbo-Eze-South",
      "Isi-Uzo",
      "Nkanu-East",
      "Nkanu-West",
      "Nsukka",
      "Oji-River",
      "Udenu",
      "Udi",
      "Uzo-Uwani"
    ]
  },
  {
    "state": "Federal Capital Territory",
    "lgas": ["Abuja", "Kwali", "Kuje", "Gwagwalada", "Bwari", "Abaji"]
  },
  {
    "state": "Gombe",
    "lgas": [
      "Akko",
      "Balanga",
      "Billiri",
      "Dukku",
      "Funakaye",
      "Gombe",
      "Kaltungo",
      "Kwami",
      "Nafada",
      "Shongom",
      "Yamaltu/Deba"
    ]
  },
  {
    "state": "Imo",
    "lgas": [
      "Aboh-Mbaise",
      "Ahiazu-Mbaise",
      "Ehime-Mbano",
      "Ezinihitte",
      "Ideato-North",
      "Ideato-South",
      "Ihitte/Uboma",
      "Ikeduru",
      "Isiala-Mbano",
      "Isu",
      "Mbaitoli",
      "Ngor-Okpala",
      "Njaba",
      "Nkwerre",
      "Nwangele",
      "Obowo",
      "Oguta",
      "Ohaji-Egbema",
      "Okigwe",
      "Onuimo",
      "Orlu",
      "Orsu",
      "Oru-East",
      "Oru-West",
      "Owerri-Municipal",
      "Owerri-North",
      "Owerri-West"
    ]
  },
  {
    "state": "Jigawa",
    "lgas": [
      "Auyo",
      "Babura",
      "Biriniwa",
      "Birnin-Kudu",
      "Buji",
      "Dutse",
      "Gagarawa",
      "Garki",
      "Gumel",
      "Guri",
      "Gwaram",
      "Gwiwa",
      "Hadejia",
      "Jahun",
      "Kafin-Hausa",
      "Kaugama",
      "Kazaure",
      "Kiri kasama",
      "Maigatari",
      "Malam Madori",
      "Miga",
      "Ringim",
      "Roni",
      "Sule-Tankarkar",
      "Taura",
      "Yankwashi"
    ]
  },
  {
    "state": "Kebbi",
    "lgas": [
      "Aleiro",
      "Arewa-Dandi",
      "Argungu",
      "Augie",
      "Bagudo",
      "Birnin-Kebbi",
      "Bunza",
      "Dandi",
      "Fakai",
      "Gwandu",
      "Jega",
      "Kalgo",
      "Koko-Besse",
      "Maiyama",
      "Ngaski",
      "Sakaba",
      "Shanga",
      "Suru",
      "Wasagu/Danko",
      "Yauri",
      "Zuru"
    ]
  },
  {
    "state": "Kaduna",
    "lgas": [
      "Birnin-Gwari",
      "Chikun",
      "Giwa",
      "Igabi",
      "Ikara",
      "Jaba",
      "Jema'A",
      "Kachia",
      "Kaduna-North",
      "Kaduna-South",
      "Kagarko",
      "Kajuru",
      "Kaura",
      "Kauru",
      "Kubau",
      "Kudan",
      "Lere",
      "Makarfi",
      "Sabon-Gari",
      "Sanga",
      "Soba",
      "Zangon-Kataf",
      "Zaria"
    ]
  },
  {
    "state": "Kano",
    "lgas": [
      "Ajingi",
      "Albasu",
      "Bagwai",
      "Bebeji",
      "Bichi",
      "Bunkure",
      "Dala",
      "Dambatta",
      "Dawakin-Kudu",
      "Dawakin-Tofa",
      "Doguwa",
      "Fagge",
      "Gabasawa",
      "Garko",
      "Garun-Mallam",
      "Gaya",
      "Gezawa",
      "Gwale",
      "Gwarzo",
      "Kabo",
      "Kano-Municipal",
      "Karaye",
      "Kibiya",
      "Kiru",
      "Kumbotso",
      "Kunchi",
      "Kura",
      "Madobi",
      "Makoda",
      "Minjibir",
      "Nasarawa",
      "Rano",
      "Rimin-Gado",
      "Rogo",
      "Shanono",
      "Sumaila",
      "Takai",
      "Tarauni",
      "Tofa",
      "Tsanyawa",
      "Tudun-Wada",
      "Ungogo",
      "Warawa",
      "Wudil"
    ]
  },
  {
    "state": "Kogi",
    "lgas": [
      "Adavi",
      "Ajaokuta",
      "Ankpa",
      "Dekina",
      "Ibaji",
      "Idah",
      "Igalamela-Odolu",
      "Ijumu",
      "Kabba/Bunu",
      "Kogi",
      "Lokoja",
      "Mopa-Muro",
      "Ofu",
      "Ogori/Magongo",
      "Okehi",
      "Okene",
      "Olamaboro",
      "Omala",
      "Oyi",
      "Yagba-East",
      "Yagba-West"
    ]
  },
  {
    "state": "Katsina",
    "lgas": [
      "Bakori",
      "Batagarawa",
      "Batsari",
      "Baure",
      "Bindawa",
      "Charanchi",
      "Dan-Musa",
      "Dandume",
      "Danja",
      "Daura",
      "Dutsi",
      "Dutsin-Ma",
      "Faskari",
      "Funtua",
      "Ingawa",
      "Jibia",
      "Kafur",
      "Kaita",
      "Kankara",
      "Kankia",
      "Katsina",
      "Kurfi",
      "Kusada",
      "Mai-Adua",
      "Malumfashi",
      "Mani",
      "Mashi",
      "Matazu",
      "Musawa",
      "Rimi",
      "Sabuwa",
      "Safana",
      "Sandamu",
      "Zango"
    ]
  },
  {
    "state": "Kwara",
    "lgas": [
      "Asa",
      "Baruten",
      "Edu",
      "Ekiti (Araromi/Opin)",
      "Ilorin-East",
      "Ilorin-South",
      "Ilorin-West",
      "Isin",
      "Kaiama",
      "Moro",
      "Offa",
      "Oke-Ero",
      "Oyun",
      "Pategi"
    ]
  },
  {
    "state": "Lagos",
    "lgas": [
      "Agege",
      "Ajeromi-Ifelodun",
      "Alimosho",
      "Amuwo-Odofin",
      "Apapa",
      "Badagry",
      "Epe",
      "Eti-Osa",
      "Ibeju-Lekki",
      "Ifako-Ijaiye",
      "Ikeja",
      "Ikorodu",
      "Kosofe",
      "Lagos-Island",
      "Lagos-Mainland",
      "Mushin",
      "Ojo",
      "Oshodi-Isolo",
      "Shomolu",
      "Surulere",
      "Yewa-South"
    ]
  },
  {
    "state": "Nasarawa",
    "lgas": [
      "Akwanga",
      "Awe",
      "Doma",
      "Karu",
      "Keana",
      "Keffi",
      "Kokona",
      "Lafia",
      "Nasarawa",
      "Nasarawa-Eggon",
      "Obi",
      "Wamba",
      "Toto"
    ]
  },
  {
    "state": "Niger",
    "lgas": [
      "Agaie",
      "Agwara",
      "Bida",
      "Borgu",
      "Bosso",
      "Chanchaga",
      "Edati",
      "Gbako",
      "Gurara",
      "Katcha",
      "Kontagora",
      "Lapai",
      "Lavun",
      "Magama",
      "Mariga",
      "Mashegu",
      "Mokwa",
      "Moya",
      "Paikoro",
      "Rafi",
      "Rijau",
      "Shiroro",
      "Suleja",
      "Tafa",
      "Wushishi"
    ]
  },
  {
    "state": "Ogun",
    "lgas": [
      "Abeokuta-North",
      "Abeokuta-South",
      "Ado-Odo/Ota",
      "Ewekoro",
      "Ifo",
      "Ijebu-East",
      "Ijebu-North",
      "Ijebu-North-East",
      "Ijebu-Ode",
      "Ikenne",
      "Imeko-Afon",
      "Ipokia",
      "Obafemi-Owode",
      "Odeda",
      "Odogbolu",
      "Ogun-Waterside",
      "Remo-North",
      "Shagamu",
      "Yewa North"
    ]
  },
  {
    "state": "Ondo",
    "lgas": [
      "Akoko North-East",
      "Akoko North-West",
      "Akoko South-West",
      "Akoko South-East",
      "Akure-North",
      "Akure-South",
      "Ese-Odo",
      "Idanre",
      "Ifedore",
      "Ilaje",
      "Ile-Oluji-Okeigbo",
      "Irele",
      "Odigbo",
      "Okitipupa",
      "Ondo West",
      "Ondo-East",
      "Ose",
      "Owo"
    ]
  },
  {
    "state": "Osun",
    "lgas": [
      "Atakumosa West",
      "Atakumosa East",
      "Ayedaade",
      "Ayedire",
      "Boluwaduro",
      "Boripe",
      "Ede South",
      "Ede North",
      "Egbedore",
      "Ejigbo",
      "Ife North",
      "Ife South",
      "Ife-Central",
      "Ife-East",
      "Ifelodun",
      "Ila",
      "Ilesa-East",
      "Ilesa-West",
      "Irepodun",
      "Irewole",
      "Isokan",
      "Iwo",
      "Obokun",
      "Odo-Otin",
      "Ola Oluwa",
      "Olorunda",
      "Oriade",
      "Orolu",
      "Osogbo"
    ]
  },
  {
    "state": "Oyo",
    "lgas": [
      "Afijio",
      "Akinyele",
      "Atiba",
      "Atisbo",
      "Egbeda",
      "Ibadan North",
      "Ibadan North-East",
      "Ibadan North-West",
      "Ibadan South-East",
      "Ibadan South-West",
      "Ibarapa-Central",
      "Ibarapa-East",
      "Ibarapa-North",
      "Ido",
      "Ifedayo",
      "Irepo",
      "Iseyin",
      "Itesiwaju",
      "Iwajowa",
      "Kajola",
      "Lagelu",
      "Ogo-Oluwa",
      "Ogbomosho-North",
      "Ogbomosho-South",
      "Olorunsogo",
      "Oluyole",
      "Ona-Ara",
      "Orelope",
      "Ori-Ire",
      "Oyo-West",
      "Oyo-East",
      "Saki-East",
      "Saki-West",
      "Surulere"
    ]
  },
  {
    "state": "Plateau",
    "lgas": [
      "Barkin-Ladi",
      "Bassa",
      "Bokkos",
      "Jos-East",
      "Jos-North",
      "Jos-South",
      "Kanam",
      "Kanke",
      "Langtang-North",
      "Langtang-South",
      "Mangu",
      "Mikang",
      "Pankshin",
      "Qua'an Pan",
      "Riyom",
      "Shendam",
      "Wase"
    ]
  },
  {
    "state": "Rivers",
    "lgas": [
      "Abua/Odual",
      "Ahoada-East",
      "Ahoada-West",
      "Akuku Toru",
      "Andoni",
      "Asari-Toru",
      "Bonny",
      "Degema",
      "Eleme",
      "Emuoha",
      "Etche",
      "Gokana",
      "Ikwerre",
      "Khana",
      "Obio/Akpor",
      "Ogba-Egbema-Ndoni",
      "Ogba/Egbema/Ndoni",
      "Ogu/Bolo",
      "Okrika",
      "Omuma",
      "Opobo/Nkoro",
      "Oyigbo",
      "Port-Harcourt",
      "Tai"
    ]
  },
  {
    "state": "Sokoto",
    "lgas": [
      "Binji",
      "Bodinga",
      "Dange-Shuni",
      "Gada",
      "Goronyo",
      "Gudu",
      "Gwadabawa",
      "Illela",
      "Kebbe",
      "Kware",
      "Rabah",
      "Sabon Birni",
      "Shagari",
      "Silame",
      "Sokoto-North",
      "Sokoto-South",
      "Tambuwal",
      "Tangaza",
      "Tureta",
      "Wamako",
      "Wurno",
      "Yabo"
    ]
  },
  {
    "state": "Taraba",
    "lgas": [
      "Ardo-Kola",
      "Bali",
      "Donga",
      "Gashaka",
      "Gassol",
      "Ibi",
      "Jalingo",
      "Karim-Lamido",
      "Kurmi",
      "Lau",
      "Sardauna",
      "Takum",
      "Ussa",
      "Wukari",
      "Yorro",
      "Zing"
    ]
  },
  {
    "state": "Yobe",
    "lgas": [
      "Bade",
      "Bursari",
      "Damaturu",
      "Fika",
      "Fune",
      "Geidam",
      "Gujba",
      "Gulani",
      "Jakusko",
      "Karasuwa",
      "Machina",
      "Nangere",
      "Nguru",
      "Potiskum",
      "Tarmuwa",
      "Yunusari",
      "Yusufari"
    ]
  },
  {
    "state": "Zamfara",
    "lgas": [
      "Anka",
      "Bakura",
      "Birnin Magaji/Kiyaw",
      "Bukkuyum",
      "Bungudu",
      "Gummi",
      "Gusau",
      "Isa",
      "Kaura-Namoda",
      "Kiyawa",
      "Maradun",
      "Maru",
      "Shinkafi",
      "Talata-Mafara",
      "Tsafe",
      "Zurmi"
    ]
  }
];

List<String> expiresList = [
  "72 hours",
  "42 hours",
  "24 hours",
];

List<String> getAllStates() {
  final List<String> states = [];

  for (var element in nigeriaStateAndLg) {
    states.add(element['state']);
  }

  return states;
}

List<String> getLgs({required String? state}) {
  if (state == null) {
    return [];
  }

  final List<String> lgs = [];
  for (int i = 0; i < nigeriaStateAndLg.length; i++) {
    if (nigeriaStateAndLg[i]['state'] == state) {
      lgs.addAll(nigeriaStateAndLg[i]['lgas']);
    }
  }

  return lgs;
}

List<String> getLga({required List<String>? states}) {
  if (states == null) {
    return [];
  }

  final List<String> lgs = [];
  for (int i = 0; i < nigeriaStateAndLg.length; i++) {
    if (states.contains(nigeriaStateAndLg[i]['state'])) {
      lgs.addAll(nigeriaStateAndLg[i]['lgas']);
    }
  }

  return lgs;
}

extension StringCasingExtension on String {
  String toCapitalized() =>
      length > 0 ? '${this[0].toUpperCase()}${substring(1).toLowerCase()}' : '';

  String toTitleCase() => replaceAll(RegExp(' +'), ' ')
      .split(' ')
      .map((str) => str.toCapitalized())
      .join(' ');
}

bool canCashOut(int amount, int accountBalance) {
  const int payoutCharge = 2500; //transaction charges in kobo
  const int minimumAccountBalance =
      1000; //the minimum a user's account can have at any time in kobo
  int totalDeduction = 0;
  int balanceAfterTransaction = 0;

  totalDeduction = amount * 100 + payoutCharge;
  balanceAfterTransaction = accountBalance - totalDeduction;

  if (accountBalance >= totalDeduction &&
      balanceAfterTransaction > minimumAccountBalance) {
    return true;
  }

  return false;
}

int displayPossibleCashOutAmount(int accountBalance) {
  const int payoutCharge = 2500; //transaction charges in kobo
  const int minimumAccountBalance =
      1000; //the minimum a user's account can have at any time in kobo
  int possibleSendOutAmount = 0;

  possibleSendOutAmount =
      accountBalance - (payoutCharge + minimumAccountBalance);

  if (accountBalance == 0) {
    possibleSendOutAmount = 0;
  }

  return possibleSendOutAmount;
}

Widget userImageUserInitialsPic(
    String image, String fullName, double initialRadius, double imageWidth) {
  if (image == "" ||
      image ==
          "https://slydo-assets.s3.amazonaws.com/static/notavailable.png" ||
      image ==
          "https://slydo-assets.s3.amazonaws.com/static/images/User_Avatar.png") {
    return CircleAvatar(
      backgroundColor: navyBlue,
      radius: initialRadius,
      child: Text(
        getInitials(fullName).toUpperCase(),
        style: TextStyle(
            color: white, fontWeight: FontWeight.w600, fontSize: initialRadius),
      ),
    );
  } else {
    final String url = image;
    final String imageUrl = url.replaceAll('https//', 'https://');

    return Container(
      width: imageWidth,
      height: imageWidth,
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        // border: Border.all(color: borderColor, width: 2),
        shape: BoxShape.circle,
        image: DecorationImage(
          fit: BoxFit.cover,
          image: CachedNetworkImageProvider(
            imageUrl,
          ),
        ),
      ),
    );
  }
}

bool canSendMoney(int? amount, String? limit) {
  // virtualAccount?.accountTier?.dailyCumulativeTransactionLimit!
  return amount! <= int.parse("500000");
}

Future<bool?> blockUserAlert(BuildContext context, CustomerProfile user) async {
  final bool? result = await showDialogBox(
    context: context,
    roundedBackgroundIcon: RoundedBackgroundIcon(
      backgroundColor: mateRed.withOpacity(0.08),
      borderRadius: 20,
      width: 48,
      height: 48,
      icon: Icon(
        SlydoAppIcon.block,
        color: mateRed,
        size: 16,
      ),
      enableMargin: false,
    ),
    actionOneBgColor: mateRed,
    actionOneTextColor: Colors.white,
    actionTwoBgColor: greyBorderColor,
    actionTwoTextColor: blackFont,
    title: AppLocalization.of(context)!.block,
    description:
        "${AppLocalization.of(context)!.areYouSureWantToBlock} ${user.displayName()}",
    actionOneText: AppLocalization.of(context)!.block,
    actionTwoText: AppLocalization.of(context)!.cancel,
    // rightButtonOnPressed: Navigator.pop(context),
  );
  if (result != null && result) {
    final bool done = await UserAuth().blockUser(user);

    if (done) {
      showSnackbar(context,
          message:
              "${user.displayName()} ${AppLocalization.of(context)!.isBlockedSuccessfully}");
      return true;
    } else {
      showSnackbar(context, message: AppLocalization.of(context)!.error);
      return false;
    }
  }
  return null;
}

Future<XFile?> selectSingleImageVideo() async {
  final XFile? file = await ImagePicker().pickMedia(
    maxWidth: 1800,
    maxHeight: 1800,
  );
  return file;
}

Future<List<XFile>> selectMultipleImageVideo() async {
  final List<XFile> file = await ImagePicker().pickMultipleMedia(
    maxWidth: 1800,
    maxHeight: 1800,
  );
  return file;
}

Response handleServerErrors(dynamic response) {
  var message = "Server Error";

  if (response.statusCode >= 200 && response.statusCode < 300) {
    return response;
  } else {
    final jsonResponse = jsonDecode(response.body);
    if (jsonResponse.containsKey('error')) {
      message = jsonResponse['error'];
    } else if (jsonResponse.containsKey('detail')) {
      message = jsonResponse['detail'];
    }
    showToast(message: message);
  }
  throw message;
}

Future<bool> checkConnection(BuildContext context) async {
  final List<ConnectivityResult> connectivityResult =
      await (Connectivity().checkConnectivity());

  if (connectivityResult.contains(ConnectivityResult.wifi) ||
      connectivityResult.contains(ConnectivityResult.ethernet) ||
      connectivityResult.contains(ConnectivityResult.mobile)) {
    return true;
  } else {
    showToast(
        message: AppLocalization.of(context)!.internetConnectionNotAvailable);
    return false;
  }
}

Map<String, String> getFormattedDateTime(String? dateTimeString) {
  try {
    final parsedDateTime = DateTime.parse(dateTimeString ?? "");

    final dateTime = DateTime(
      parsedDateTime.year,
      parsedDateTime.month,
      parsedDateTime.day,
      parsedDateTime.hour,
      parsedDateTime.minute,
      parsedDateTime.second,
      parsedDateTime.millisecond,
      parsedDateTime.microsecond,
    ).add(const Duration(hours: 1));

    final DateFormat dateFormatter = DateFormat('MMMM dd, yyyy');
    final DateFormat timeFormatter = DateFormat('h:mm a');

    // Format the date and time
    final String formattedDate = dateFormatter.format(dateTime);
    final String formattedTime = timeFormatter.format(dateTime);

    return {
      'date': formattedDate,
      'time': formattedTime,
    };
  } catch (e) {
    print("Error parsing date: $e");
    return {
      'date': '-',
      'time': '-',
    };
  }
}

String formatPickupDateTime(String? pickupDateTimeString) {
  if (pickupDateTimeString == null || pickupDateTimeString.isEmpty) {
    return "";
  }

  try {
    final String cleanedDateTimeString = pickupDateTimeString.split('.').first;

    final DateTime dateTime = DateTime.parse(cleanedDateTimeString);

    final DateFormat dateFormatter = DateFormat('MMMM dd, yyyy');
    final DateFormat timeFormatter = DateFormat('h:mm a');

    final String formattedDate = dateFormatter.format(dateTime);
    final String formattedTime = timeFormatter.format(dateTime);

    return '$formattedDate, $formattedTime';
  } catch (e) {
    print("Error parsing date: $e");
    return "";
  }
}

Widget qrCodeIcon(BuildContext context, Map<String, dynamic> navigationData,
    Map<String, dynamic> accountData) {
  return GestureDetector(
    onTap: () async {
      //get the account detail of clicked user
      final VirtualAccount virtualAccount = VirtualAccount(
        accountName: accountData["accountName"],
        accountNumber: accountData["accountNumber"],
        financialInstitution: accountData["financialInstitution"],
        customerUsername: accountData["customerUsername"],
        note: accountData["note"],
      );

      navigationData["virtualAccount"] = virtualAccount;
      NavigationUtil.push(context,
          screen: QrCodePage(arguments: navigationData));
    },
    child: Container(
      padding: const EdgeInsets.all(5.0),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(5.0)),
        color: lightGrey.withOpacity(0.1),
        border: Border.all(
          color: blackFont,
          width: 1.0,
        ),
      ), //
      child: Row(
        children: [
          Icon(
            SlydoAppIcon.qr_code,
            size: 15,
            color: blackFont,
          ),
          const SizedBox(width: 7),
          Text(
            'QR',
            style: TextStyle(
              fontSize: 15,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w700,
              color: blackFont,
            ),
            textAlign: TextAlign.left,
          ),
        ],
      ),
    ),
  );
}

Widget displayQuillFormattedText(String formattedText, Color? fontColor,
    double? fontSize, FontWeight? fontWeight) {
  late flutterQuill.QuillController quillController;
  dynamic jsonDecodedText;

  try {
    jsonDecodedText = jsonDecode(messageDecoderWithEmoji(formattedText) ?? "");

    quillController = flutterQuill.QuillController(
      document: flutterQuill.Document.fromJson(jsonDecodedText),
      selection: const TextSelection.collapsed(offset: -1),
    );
  } catch (e) {
    debugPrint('CANNOT DECODE BLOG TEXT: ${e.toString()}');
  }

  if (jsonDecodedText != null) {
    return flutterQuill.QuillEditor.basic(
      configurations: flutterQuill.QuillEditorConfigurations(
        controller: quillController,
        readOnlyMouseCursor: SystemMouseCursors.basic,
        showCursor: false,
        enableInteractiveSelection: false,
        embedBuilders: FlutterQuillEmbeds.editorBuilders(),
        // customStyles: flutterQuill.DefaultStyles(color: fontColor, sizeLarge: fontSize, sizeSmall: )
      ),
    );
  } else {
    return Text(
      messageDecoderWithEmoji(formattedText) ?? "",
      style: TextStyle(
        fontWeight: fontWeight ?? FontWeight.w400,
        fontSize: fontSize ?? 14,
        color: fontColor ?? darkGrey,
      ),
      textAlign: TextAlign.justify,
    );
  }
}
