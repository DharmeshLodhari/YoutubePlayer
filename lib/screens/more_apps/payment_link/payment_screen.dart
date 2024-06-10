import 'dart:convert';
import 'dart:io';

import 'package:Slydo/data/currency.dart';
import 'package:Slydo/data/database_helper.dart';
import 'package:Slydo/data/state_notifiers/user_bloc.dart';
import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/routes/route_constants.dart';
import 'package:Slydo/screens/more_apps/payment_and_banking/models/virtual_account.dart';
import 'package:Slydo/screens/more_apps/payment_and_banking/payment_and_banking_auth.dart';
import 'package:Slydo/screens/more_apps/payment_link/payment_link.dart';
import 'package:Slydo/screens/more_apps/payment_loading_screen.dart';
import 'package:Slydo/screens/more_apps/shopping/models/store.dart';
import 'package:Slydo/services/app_tutorial_controller.dart';
import 'package:Slydo/utils/extensions.dart';
import 'package:Slydo/utils/navigation_util.dart';
import 'package:Slydo/utils/slydo_app_icon_icons.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/curved_btn.dart';
import 'package:Slydo/widget/customized_passcode_sheet/bottomsheet_passcode.dart';
import 'package:Slydo/widget/customized_textform_field.dart';
import 'package:Slydo/widget/dialog.dart';
import 'package:Slydo/widget/rounded_background_icon.dart';
import 'package:custom_qr_generator/custom_qr_generator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class PaymentLinkScreen extends StatefulWidget {
  const PaymentLinkScreen({Key? key});

  @override
  State<PaymentLinkScreen> createState() => _PaymentLinkScreenState();
}

class _PaymentLinkScreenState extends State<PaymentLinkScreen> {
  final TextEditingController _amountController = TextEditingController();
  late final TextEditingController _referenceController =
      TextEditingController();

  final _sendPaymentScaffold = GlobalKey<ScaffoldState>();
  final _sendPaymentScaffoldMessenger = GlobalKey<ScaffoldMessengerState>();

  late UserBloc userBloc;
  final _auth = PaymentAndBankingAuth();
  late http.Response response;

  bool isBalanceHidden = true;

  bool? isFromProfile = false;
  String? recipient;

  String reference = "";
  String? selectedCategory;
  String errorMessage = "";
  List? addList = [];

  // bool isValidPayee = false;

  final DateTime now = DateTime.now();
  final DateFormat formatter = DateFormat('yyyy/MM/dd');
  String tdata = DateFormat("hh:mm a").format(DateTime.now());
  String? formatted;
  List<String?> paymentCategories = [];

  //for Product payment
  Product? product;

  //for Service payment
  Service? service;

  double? amount = 0.0;
  bool isLoading = true;

  final _formKey = GlobalKey<FormState>();

  VirtualAccount? virtualAccount;
  double? currentBalance = 0.0;

  void fetchCategory() async {
    _auth.getPaymentCategory().then((result) {
      if (mounted) {
        setState(() {
          final List categoriesList = result["results"]["data"];
          for (var data in categoriesList) {
            paymentCategories.add(data["name"]);
          }
          isLoading = false;
        });
      }
    });
  }

  Widget getCategoryDropDown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          AppLocalization.of(context)!.category,
          style: TextStyle(color: darkGrey, fontSize: 14),
        ),
        const SizedBox(
          height: 6,
        ),
        Card(
          elevation: 0,
          color: Colors.white,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: BorderSide(color: greyBorderColor)),
          margin: const EdgeInsets.all(0),
          borderOnForeground: true,
          child: IgnorePointer(
            ignoring: product != null || service != null,
            child: ListTile(
              dense: true,
              title: Text(
                selectedCategory != null ? selectedCategory! : "",
                softWrap: false,
                overflow: TextOverflow.fade,
                style: TextStyle(
                    color: blackFont,
                    fontSize: 16,
                    fontWeight: FontWeight.w600),
              ),
              trailing: Icon(
                Icons.keyboard_arrow_down,
                color: darkGrey,
              ),
              onTap: () {
                selectCategory();
              },
            ),
          ),
        ),
      ],
    );
  }

  void selectCategory() async {
    final pressedCategory = await showDialog<String>(
        barrierDismissible: false,
        context: context,
        builder: (context) => AlertDialog(
              insetPadding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
              contentPadding: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              content: SizedBox(
                width: MediaQuery.of(context).size.width - 40,
                child: Card(
                  elevation: 2,
                  shadowColor: Colors.transparent,
                  margin: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: SingleChildScrollView(
                      child: Column(
                        children: paymentCategories.map<Widget>((category) {
                          if (selectedCategory == category) {
                            return Container(
                              color: selectedListItemBackgroundBlue,
                              child: ListTile(
                                dense: true,
                                title: Text(
                                  category!,
                                  overflow: TextOverflow.fade,
                                  softWrap: false,
                                  style: TextStyle(
                                      color: navyBlue,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600),
                                ),
                                trailing: Icon(
                                  SlydoAppIcon.checked,
                                  color: navyBlue,
                                  size: 12,
                                ),
                                onTap: () {
                                  Navigator.pop(context, category);
                                },
                              ),
                            );
                          }
                          return ListTile(
                            title: Text(
                              category!,
                              softWrap: false,
                              overflow: TextOverflow.fade,
                              style: TextStyle(
                                  color: blackFont,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400),
                            ),
                            dense: true,
                            onTap: () {
                              Navigator.pop(context, category);
                            },
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
              ),
            ));
    if (pressedCategory != null) {
      selectedCategory = pressedCategory;
      debugPrint("selected category $selectedCategory");
      setState(() {});
    }
  }

  void showDataAlert(link) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(
                  20.0,
                ),
              ),
            ),
            contentPadding: const EdgeInsets.only(
              top: 10.0,
            ),
            content: SizedBox(
              height: 540,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(22.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        "Payment Link",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    const Text(
                      "Your payment link has been generated.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    _displayBarcodeInfo(link),
                    const SizedBox(
                      height: 30,
                    ),
                    GestureDetector(
                      onTap: () =>
                          NavigationUtil.push(context, screen: PaymentLink()),
                      child: Container(
                        width: 160,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                        decoration: BoxDecoration(
                            color: navyBlue,
                            borderRadius: BorderRadius.circular(12)),
                        child: Center(
                          child: Row(
                            children: [
                              Text(
                                'Copy Link',
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: white),
                              ),
                              const SizedBox(
                                width: 15,
                              ),
                              SvgPicture.asset(
                                'copy_icon_link'.toSVG(),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          );
        });
  }

  Widget appBar() {
    return AppBar(
      elevation: 0,
      titleSpacing: 0,
      backgroundColor: Colors.white,
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
        AppLocalization.of(context)!.paymentLink,
        style: TextStyle(
            color: blackFont, fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  @override
  void initState() {
    formatted = formatter.format(now);
    getBankAccountDetail();
    fetchCategory();
    super.initState();
  }

  Widget noteForUser() {
    return Center(
      child: Text.rich(TextSpan(
          text: AppLocalization.of(context)!.noteForUserPayLink,
          style: TextStyle(
              fontSize: 12, color: blackFont, fontWeight: FontWeight.w600),
          children: <InlineSpan>[
            TextSpan(
              text: worldCurrencies[userBloc.user.currency!]! +
                  moneyDisplayNormalizer(3500),
              style: TextStyle(
                  fontSize: 12,
                  color: blackFont,
                  fontFamily: "Inter",
                  fontWeight: FontWeight.w600),
            )
          ])),
    );
  }

  Future<void> makePaymentLinkDialog() async {
    final String vString = amount!.toInt().toString();
    final int amt = int.parse(vString) + 35;
    await showDialogBox(
      context: context,
      leftButtonOnPressed: () => Navigator.pop(context),
      rightButtonOnPressed: () {
        BottomSheetPassCode(
            context: context,
            isValidCallback: () async {
              showDialog(
                  context: context,
                  builder: (context) => const Center(child: SizedBox()));

              //show loading screen
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => PaymentLoadingScreen(
                          text: 'Payment Link Processing......',
                          imagePath: 'assets/images/app_logo.png',
                        )),
              );

              await Future.delayed(const Duration(seconds: 3));

              // const String description = 'General Payment';
              final data = {
                "currency": userBloc.user.currency,
                "amount": moneyInputNormalizer(amount.toString()),
                "category": selectedCategory!.trim(),
                "reference": reference.trim(),
                "payable_from": "",
              };
              await _auth.makePaymentLink(data).then((value) async {
                debugPrint(
                    "status code:- ${value.statusCode}  body:- ${value.body}");
                final dynamic res = jsonDecode(value.body);

                response = value;

                Navigator.pop(context);

                try {
                  handleServerErrors(response);
                } catch (e) {
                  return Future.error(response.body);
                }

                if (response.statusCode == 200 || response.statusCode == 201) {
                  showDataAlert(res['link']);
                  Navigator.pop(context);
                  Navigator.pop(context);
                  Navigator.popAndPushNamed(context, Routes.PAYMENT_LINK);
                } else if (response.statusCode == 400) {
                  showDataAlert(res['link']);
                  Navigator.pop(context);
                  setState(() {
                    errorMessage = "${jsonDecode(value.body)["errors"]}";

                    showToast(message: errorMessage);
                  });
                } else if (response.statusCode == 500) {
                  Navigator.pop(context);
                  setState(() {
                    errorMessage = AppLocalization.of(context)!.serverError;
                    showToast(message: errorMessage);
                  });
                } else {
                  Navigator.pop(context);
                  if (response.statusCode == 406) {
                    errorMessage = jsonDecode(value.body)[0];
                    showToast(message: errorMessage);
                    setState(() {});
                  } else {
                    debugPrint("ERROR:- ${response.body}");
                    setState(() {
                      errorMessage =
                          AppLocalization.of(context)!.somethingWentWrong;
                      showToast(message: errorMessage);
                    });
                  }
                }
              });
            },
            cancelCallBack: () {
              Navigator.pop(context);
              _sendPaymentScaffoldMessenger.currentState?.showSnackBar(SnackBar(
                content: Text(AppLocalization.of(context)!.invalidPassword),
              ));
            });
      },
      roundedBackgroundIcon: RoundedBackgroundIcon(
        backgroundColor: navyBlue.withOpacity(0.08),
        borderRadius: 20,
        width: 43,
        height: 43,
        icon: Icon(
          Icons.check_circle_sharp,
          color: navyBlue,
          size: 16,
        ),
        enableMargin: false,
      ),
      actionOneBgColor: greyBorderColor,
      actionOneTextColor: black,
      actionTwoBgColor: navyBlue,
      actionTwoTextColor: white,
      title: "Create Payment Link",
      description: AppLocalization.of(context)!.paymentLinkConfirmationMsg +
          moneyDisplayNormalizer(amt * 100),
      actionOneText: AppLocalization.of(context)!.cancel,
      actionTwoText: AppLocalization.of(context)!.continueMsg,
    );
  }

  Widget _displayBarcodeInfo(link) {
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
                data: link,
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

  @override
  Widget build(BuildContext context) {
    userBloc = Provider.of<UserBloc>(context);
    return ScaffoldMessenger(
      key: _sendPaymentScaffoldMessenger,
      child: Scaffold(
        key: _sendPaymentScaffold,
        backgroundColor: Colors.white,
        appBar: appBar() as PreferredSizeWidget?,
        body: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 40),
        child: Column(
          children: [
            Card(
              elevation: 0.4,
              margin: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              shadowColor: iconBtnGrey,
              child: Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: iconBtnGrey, width: 1)),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: <Widget>[
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          children: [
                            const SizedBox(
                              height: 20,
                            ),
                            displayAmountField(),
                            const SizedBox(
                              height: 20,
                            ),
                            getCategoryDropDown(),
                            const SizedBox(
                              height: 20,
                            ),
                            getReferenceField(),
                            const SizedBox(
                              height: 20.0,
                            ),
                            noteForUser(),
                            const SizedBox(
                              height: 40,
                            ),
                            if (errorMessage == "")
                              Container()
                            else
                              Text(
                                errorMessage,
                                style: TextStyle(
                                    color: mateRed,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16),
                              ),
                            if (errorMessage == "")
                              Container()
                            else
                              const SizedBox(
                                height: 20,
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 30,
            ),
            getSubmitButton()
          ],
        ));
  }

  bool canDoSlydoTransfer(double amount, double balance) {
    if (balance > amount + 10.0) {
      return true;
    }
    return false;
  }

  int availableTransfer() {
    int value = 0;
    value = currentBalance!.toInt() * 100 - 1000;

    if (value < 0) {
      // debugPrint("The number is negative.");
      return 0;
    } else {
      // debugPrint("The number is non-negative.");
      return value;
    }
  }

  void hideBalance() {
    if (isBalanceHidden == false) {
      isBalanceHidden = true;
      if (mounted) setState(() {});
    }
  }

  void getBankAccountDetail() async {
    virtualAccount = await DatabaseHelper().getVirtualAccount();
    // await getAccountBalance();
    currentBalance = await getAccountBalance();
  }

  bool validateDropdown() {
    if (selectedCategory != null) {
      return true;
    } else {
      selectedCategory = "General";
      return true;
    }
  }

  void onSubmit() async {
    if (FocusScope.of(context).hasFocus) {
      FocusScope.of(context).unfocus();
    }

    await Future.delayed(const Duration(milliseconds: 500));

    if (_formKey.currentState!.validate() && validateDropdown()) {
      try {
        makePaymentLinkDialog();
      } catch (e) {
        debugPrint(e.toString());
        showToast(message: e.toString());
      }
    }
  }

  Widget getSubmitButton() {
    return CurvedButton(
      onPressed: () => onSubmit(),
      backgroundColor: navyBlue,
      textColor: Colors.white,
      text: "Generate Link",
    );
  }

  Widget getReferenceField() {
    return CustomizedTextFormField(
      maxLength: 80,
      labelText: AppLocalization.of(context)!.reference,
      textCapitalization: TextCapitalization.sentences,
      controller: _referenceController,
      enabled: product == null && service == null,
      onChanged: (val) {
        if (mounted) {
          setState(() {
            reference = val;
          });
        }
      },
    );
  }

  Widget displayAmountField() {
    return CustomizedTextFormField(
      labelText: "Amount",
      isAmountField: true,
      enabled: product == null && service == null,
      keyboardType: Platform.isIOS
          ? const TextInputType.numberWithOptions(decimal: true)
          : TextInputType.number,
      controller: _amountController,
      onChanged: (val) {
        if (mounted) {
          debugPrint(val);
          setState(() {
            amount = double.parse(val.replaceAll(',', ''));
          });
        }
      },
      validator: (val) {
        if (val.isNotEmpty) {
          try {
            final double amount = double.parse(val.replaceAll(',', ''));
            if (amount <= 200000.0) {
              return null;
            }
            if (amount > 200000.0) {
              return AppLocalization.of(context)!.dailyPaymentLinkLimit;
            }
            if (amount > 0.0 && amount <= 200000.0) {
              return null;
            } else {
              throw Exception("Invalid amount");
            }
          } catch (e) {
            return AppLocalization.of(context)!.invalidAmount;
          }
        }
        return AppLocalization.of(context)!.invalidAmount;
      },
      onTap: () async {},
    );
  }
}
