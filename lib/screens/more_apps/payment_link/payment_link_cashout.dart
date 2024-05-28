// ignore_for_file: must_be_immutable, curly_braces_in_flow_control_structures

import 'dart:developer';

import 'package:Slydo/screens/more_apps/payment_link/payment_link_model.dart';
import 'package:Slydo/utils/util.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pinput/pin_put/pin_put.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../../data/currency.dart';
import '../../../data/environment.dart';
import '../../../locale/app_localization.dart';
import '../../../routes/route_constants.dart';
import '../../../utils/global_key.dart';
import '../../../utils/slydo_app_icon_icons.dart';
import '../../../widget/curved_btn.dart';
import '../../../widget/customized_textform_field.dart';
import '../../../widget/dialog.dart';
import '../../../widget/no_item_in_list.dart';
import '../../../widget/rounded_background_icon.dart';
import '../payment_and_banking/models/bank_list.dart';
import '../payment_and_banking/payment_and_banking_auth.dart';
import '../payment_loading_screen.dart';
import '../user_profile/screens/user_profile_module_new/profile_template/utils.dart';

class PaymentLinkCashOut extends StatefulWidget {
  PaymentLinkCashOut({Key? key, this.id}) : super(key: key);
  String? id;

  @override
  State<PaymentLinkCashOut> createState() => _PaymentLinkCashOutState();
}

class _PaymentLinkCashOutState extends State<PaymentLinkCashOut> {
  final _auth = PaymentAndBankingAuth();
  final _formKey = GlobalKey<FormState>();
  final accountNumberController = TextEditingController();
  TextEditingController accountNameController = TextEditingController();
  TextEditingController bankController = TextEditingController();
  final pinController = TextEditingController();
  String? accountNumber;
  PaymentLinkModel? _paymentLinkModel;
  bool loading = false;
  late http.Response response;
  String bankId = "";
  String bankPaymentLinkSlug = "";
  List<BankModel> bankList = [];
  String? next = "", previous = "";
  int count = 0;
  bool noSearchedItem = false;
  bool isItemLoading = false;
  StateSetter? bottomSheetStateSetterGlobal;
  bool bottomSheetMounted = false;
  final searchItemTextController = TextEditingController();
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  GlobalKey searchItemTextFormField = GlobalKey();
  BankModel? selectedBank;
  ScrollController _scrollController = ScrollController();
  bool isLoading = false;
  final FocusNode _pinPutFocusNode = FocusNode();

  @override
  void initState() {
    getPaymentLinkData();
    super.initState();
  }

  Widget getMessage(amount, currency, {double fontSize = 18}) {
    return SizedBox(
      width: 200,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            'A sum of ',
            style: TextStyle(
                color: blackFont,
                fontWeight: FontWeight.w400,
                fontSize: fontSize),
          ),
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
                color: blackFont,
                fontWeight: FontWeight.bold,
                fontSize: fontSize),
          ),
          Text(
            ' was sent to you, enter details to cashout.',
            style: TextStyle(
                color: blackFont,
                fontWeight: FontWeight.w400,
                fontSize: fontSize),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, "back pressed");
        return true;
      },
      child: Scaffold(
          backgroundColor: white,
          appBar: AppBar(
            backgroundColor: white,
            centerTitle: false,
            elevation: 0,
            title: Text(
              'Cashout',
              style: TextStyle(
                  color: black, fontSize: 20, fontWeight: FontWeight.w700),
            ),
            leading: IconButton(
              onPressed: () => Navigator.pop(context, "back pressed"),
              icon: Icon(
                Icons.arrow_back_ios,
                size: 20,
                color: navyBlue,
              ),
            ),
          ),
          body: _paymentLinkModel == null
              ? Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: Center(
                      child: CircularProgressIndicator(
                    color: navyBlue,
                  )),
                )
              : body(_paymentLinkModel!.status!)),
    );
  }

  body(String isStatusState) {
    if (isStatusState.toLowerCase() == 'active') {
      return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 30),
          child: Column(
            children: [
              const SizedBox(
                height: 10,
              ),
              if (loading && _paymentLinkModel == null)
                const SizedBox.shrink()
              else
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    text: 'A sum of ',
                    style: TextStyle(
                        color: blackFont,
                        fontWeight: FontWeight.w500,
                        fontSize: 18),
                    children: <TextSpan>[
                      TextSpan(
                          text:
                              '${worldCurrencies[_paymentLinkModel?.currency]}${moneyDisplayNormalizer(_paymentLinkModel?.amount)}',
                          style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: navyBlue,
                              fontSize: 18)),
                      TextSpan(
                          text: ' was sent to you, enter details to cashout.',
                          style: TextStyle(
                              color: blackFont,
                              fontWeight: FontWeight.w500,
                              fontSize: 18)),
                    ],
                  ),
                ),
              const SizedBox(
                height: 24,
              ),
              if (loading)
                Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: Center(
                      child: CircularProgressIndicator(
                    color: navyBlue,
                  )),
                )
              else
                Card(
                  elevation: 2,
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
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          children: <Widget>[
                            const SizedBox(
                              height: 30,
                            ),
                            const SizedBox(
                              height: 30,
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Recipient\'s Bank Name',
                                  style: TextStyle(
                                      fontSize: 16,
                                      color: blackFont,
                                      fontWeight: FontWeight.w600),
                                ),
                                const SizedBox(height: 5),
                                InkWell(
                                  onTap: () {
                                    FocusScope.of(context).unfocus();
                                    clearSearchedListItems();
                                    showSearchBankBottomSheet();
                                  },
                                  child: TextFormField(
                                    controller: bankController,
                                    enabled: false,
                                    style: TextStyle(
                                        fontSize: 18,
                                        color: blackFont,
                                        fontWeight: FontWeight.w600),
                                    decoration: InputDecoration(
                                      filled: true,
                                      fillColor: transparent,
                                      contentPadding: const EdgeInsets.only(
                                          left: 8,
                                          bottom: 0,
                                          top: 0,
                                          right: 15),
                                      suffixIcon: Icon(
                                        Icons.arrow_drop_down_outlined,
                                        color: blackFont,
                                      ),
                                      border: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          width: 0.7,
                                          color: greyBorderColor,
                                          style: BorderStyle.none,
                                        ),
                                        borderRadius: const BorderRadius.all(
                                          Radius.circular(8.0),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            getAccountNumber(),
                            const SizedBox(
                              height: 20,
                            ),
                            getAccountName(),
                            const SizedBox(
                              height: 20,
                            ),
                            passwordPinFiled(),
                            const SizedBox(
                              height: 60,
                            ),
                            CurvedButton(
                              onPressed: () => cashOut(),
                              backgroundColor: navyBlue,
                              textColor: Colors.white,
                              text: "Cash Out",
                            ),
                            const SizedBox(
                              height: 60,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ));
    } else if (isStatusState.toLowerCase() == 'paid') {
      return successfulPopUp();
    }
    return WidgetsBinding.instance.addPostFrameCallback((_) async {
      await showDialog(
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
              content: Container(
                height: 250,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(22.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          "Link ${_paymentLinkModel!.status.toString()}",
                          style: TextStyle(
                            fontSize: 20,
                            color: red,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      const Text(
                        "We recommend checking the link that was shared with you or contacting the person who sent you this link.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(
                        height: 30,
                      ),
                      CurvedButton(
                        onPressed: () => Navigator.of(
                                MyGlobals().navigationKey.currentContext!)
                            .pushNamedAndRemoveUntil(
                          "/dashboard",
                          (Route<dynamic> route) => false,
                        ),
                        backgroundColor: navyBlue,
                        textColor: Colors.white,
                        text: "Go back",
                      ),
                    ],
                  ),
                ),
              ),
            );
          });
    });
  }

  void verifyAccount() async {
    loading = true;
    if (mounted) setState(() {});

    final Map data = {
      "bank_code": selectedBank!.providerCode,
      "account_number": accountNumber,
    };

    try {
      final Map<String, dynamic>? result = await _auth.verifyBankAccount(data);

      loading = false;
      if (mounted) setState(() {});

      if (result == null) {
        showToast(message: 'Unable to validate account');
        return;
      }

      final tempList = result['results'];
      // debugPrint('Fola verify::: ${tempList}');

      showDialogBox(
        context: context,
        actionOneTextColor: white,
        actionOneBgColor: naturalGreen,
        actionTwoTextColor: blackFont,
        actionTwoBgColor: greyBorderColor,
        title: AppLocalization.of(context)!.addAccount,
        actionTwoText: AppLocalization.of(context)!.cancel,
        actionOneText: AppLocalization.of(context)!.continueMsg,
        description:
            "Add this account details: \nAccount Number: ${tempList['account_number']} \nAccount Name: ${tempList['account_name']} \nBank Name: ${tempList['bank_name']}",
        roundedBackgroundIcon: RoundedBackgroundIcon(
          width: 90,
          height: 90,
          enableMargin: false,
          image: Image.asset('assets/images/accept_dialog_icon.png'),
        ),
        leftButtonOnPressed: () {
          isLoading = true;
          accountNameController.text = tempList['account_name'];
          accountNumberController.text = tempList['account_number'];
          // onAddAccount(userBloc.user.userName, tempList);
          if (mounted) setState(() {});
        },
      );
    } catch (error) {
      loading = false;
      if (mounted) setState(() {});
      // showToast(message: error.toString());
    }
  }

  Widget getAccountNumber() {
    return CustomizedTextFormField(
      labelText: 'Recipient\'s Account Number',
      fontWeight: FontWeight.w600,
      labelColor: blackFont,
      keyboardType: TextInputType.number,
      controller: accountNumberController,
      validator: (val) => val.length < 10
          ? AppLocalization.of(context)!.validationTextMessage1
          : null,
      onChanged: (val) {
        if (mounted) {
          setState(() {
            accountNumber = val;
          });
        }
        if (val.toString().length == 10) {
          verifyAccount();
        } else {
          accountNameController.text = '';
          bankId = '';
        }
        if (mounted) setState(() {});
      },
    );
  }

  Widget getAccountName() {
    return CustomizedTextFormField(
      labelText: 'Recipient\'s Account Name',
      keyboardType: TextInputType.text,
      controller: accountNameController,
      fontWeight: FontWeight.w600,
      labelColor: blackFont,
      enabled: true,
      isReadOnly: true,
    );
  }

  void clearSearchedListItems() {
    bankList.clear();
    count = 0;
    next = "";
    previous = "";
    searchItemTextController.text = "";
    if (bottomSheetStateSetterGlobal != null) if (bottomSheetMounted) {}
  }

  void _onRefresh() async {
    Connectivity().checkConnectivity().then((value) {
      final connectionResult = value;
      if (connectionResult == ConnectivityResult.wifi ||
          connectionResult == ConnectivityResult.mobile) {
        count = 0;
        next = "";
        previous = "";
        bankList = [];
        noSearchedItem = false;
        getBankListSearched();
        _refreshController.refreshCompleted();
      } else {
        showToast(
            message:
                AppLocalization.of(context)!.internetConnectionNotAvailable);

        _refreshController.refreshCompleted();
      }
    });
  }

  void getBankListSearched() async {
    final String url =
        "${AppConfig.baseUrl}/api/v1/transactions/get-bank-info/?search=${searchItemTextController.text}";

    if (!isItemLoading) {
      if (next != null && !isItemLoading) {
        isItemLoading = true;

        if (bottomSheetStateSetterGlobal != null) if (bottomSheetMounted) {
          bottomSheetStateSetterGlobal!(() {});
        }
        if (mounted) setState(() {});

        final Map<String, dynamic>? result =
            await _auth.searchBankList(url, next, previous);
        if (result == null) {
          isItemLoading = false;
          return;
        }
        count = result['count'];
        next = result['next'];
        previous = result['previous'];
        final List tempList = result['results'];

        isItemLoading = false;
        if (bottomSheetStateSetterGlobal != null) if (bottomSheetMounted) {
          bottomSheetStateSetterGlobal!(() {});
        }
        bankList.clear();
        if (mounted) setState(() {});

        tempList.forEach((item) {
          bankList.add(BankModel.fromJson(item));
        });

        if (bottomSheetStateSetterGlobal != null) if (bottomSheetMounted) {
          bottomSheetStateSetterGlobal!(() {});
        }
        if (mounted) setState(() {});
      }
      if (bankList.isEmpty) {
        noSearchedItem = true;
        if (bottomSheetStateSetterGlobal != null) if (bottomSheetMounted) {
          bottomSheetStateSetterGlobal!(() {});
        }
        if (mounted) setState(() {});
      }
    }
  }

  void showSearchBankBottomSheet() async {
    final result = await showModalBottomSheet<String>(
        backgroundColor: Colors.transparent,
        context: context,
        useRootNavigator: true,
        barrierColor: Colors.black54,
        isScrollControlled: true,
        builder: (BuildContext context) {
          return StatefulBuilder(
              builder: (context, StateSetter bottomSheetStateSetter) {
            bottomSheetStateSetterGlobal = bottomSheetStateSetter;
            bottomSheetMounted = true;

            searchItemTextController.addListener(() {
              if (searchItemTextController.text.length >= 3) {
                _onRefresh();
              }
            });

            return Card(
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20)),
                ),
                color: Colors.white,
                margin: EdgeInsets.zero,
                child: Container(
                  height: MediaQuery.of(context).size.height * 0.88,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: searchBox()),
                      const SizedBox(height: 8),
                      Expanded(child: bottomSheetTabBar())
                    ],
                  ),
                ));
          });
        });
    bottomSheetMounted = false;
    if (result == null) {
      // if (itemSearchTypeSelectionMenu!.isMenuOpen) {
      //   itemSearchTypeSelectionMenu!.closeMenu();
      // }
    }
  }

  Widget searchBox() {
    return Container(
      child: Theme(
        data: Theme.of(context).copyWith(
          textSelectionTheme: const TextSelectionThemeData()
              .copyWith(selectionHandleColor: navyBlue),
        ),
        child: TextFormField(
          key: searchItemTextFormField,
          controller: searchItemTextController,
          style: TextStyle(
            fontSize: 16,
            color: blackFont,
            fontWeight: FontWeight.w600,
          ),
          cursorWidth: 1.5,
          cursorColor: navyBlue,
          decoration: InputDecoration(
            hintText: 'Search Bank Name',
            fillColor: Colors.white,
            filled: true,
            contentPadding: const EdgeInsets.symmetric(vertical: 10),
            // prefixIcon: searchTypeSelection(),
            prefix: const Padding(
              padding: EdgeInsets.only(left: 12),
            ),
            suffixIcon: searchIcon(),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: dividerColor,
                width: 1.0,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: navyBlue,
                width: 1.0,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: dividerColor,
                width: 1.0,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: dividerColor,
                width: 1.0,
              ),
            ),
          ),
          onFieldSubmitted: (val) {
            if (mounted) setState(() {});
            FocusScope.of(context).unfocus();
            _onRefresh();
          },
        ),
      ),
    );
  }

  Widget searchIcon() {
    return IconButton(
      icon: Icon(
        SlydoAppIcon.search,
        color: darkGrey,
        size: 16,
      ),
      onPressed: () {
        FocusScope.of(context).unfocus();
        searchBankList();
      },
    );
  }

  void searchBankList() {
    clearSearchedListItems();
    getBankListSearched();
  }

  Widget bottomSheetTabBar() {
    return Column(
      children: [
        const SizedBox(
          height: 8,
        ),
        Expanded(child: bottomSheetTabViews())
      ],
    );
  }

  Widget bottomSheetTabViews() {
    return pullToRefresh();
  }

  Widget pullToRefresh() {
    return searchItemTextController.text.isEmpty
        ? NoItemInList(
            msg: AppLocalization.of(context)!.pleaseTypeSomethingToGetResult,
            isResult: false,
          )
        : SmartRefresher(
            enablePullDown: true,
            header: WaterDropHeader(
              complete: Container(),
              waterDropColor: navyBlue,
            ),
            controller: _refreshController,
            onRefresh: _onRefresh,
            child: buildBankList(),
          );
  }

  Widget _buildIndicatorForBankList() {
    return Center(
      child: isItemLoading
          ? CircularProgressIndicator(
              strokeWidth: 2.5,
              valueColor: AlwaysStoppedAnimation(navyBlue),
              backgroundColor: Colors.transparent,
            )
          : Container(),
    );
  }

  Widget buildBankList() {
    return noSearchedItem
        ? NoItemInList(
            msg: AppLocalization.of(context)!.noResultFound,
            isResult: true,
          )
        : ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 4),
            //+1 for progressbar
            shrinkWrap: true,
            itemCount: bankList.length + 1,
            itemBuilder: (BuildContext context, int index) {
              if (index == bankList.length) {
                return _buildIndicatorForBankList();
              } else {
                return GestureDetector(
                    onTap: () {
                      selectedBank = bankList[index];

                      bankController.text = selectedBank!.name!;
                      bankPaymentLinkSlug = selectedBank!.slug!;

                      if (mounted) setState(() {});
                      Navigator.pop(context);

                      FocusScope.of(context).requestFocus();
                    },
                    child: Column(
                      children: [
                        if (bankList.length >= 1) ...[
                          getResultTile(bankList[index]),
                        ] else ...[
                          // debugPrint('The array does not have a second element.');
                        ]
                      ],
                    ));
              }
            },
            controller: _scrollController,
          );
  }

  Widget getResultTile(var result) {
    if (result is BankModel) {
      return bankCardDisplay(result);
    }
    return Container();
  }

  Widget bankCardDisplay(BankModel bankModel) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: EdgeInsets.zero,
        shadowColor: boxShadowTwo,
        elevation: 0,
        child: Container(
          decoration: decorateBox(),
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  dense: true,
                  title: Text(
                    bankModel.name!,
                    maxLines: 1,
                    style: TextStyle(color: darkGrey, fontSize: 12),
                  ),
                  subtitle: Text(
                    bankModel.name!,
                    maxLines: 1,
                    style: TextStyle(color: darkGrey, fontSize: 12),
                  ),
                  leading: getBankLogoLeading(bankModel),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget getBankLogoLeading(BankModel bankModel) {
    final String? bankUrl = bankModel.logoUrl == ""
        ? getInitials(bankModel.name!).toUpperCase()
        : bankModel.logoUrl;

    return GestureDetector(
      onTap: () {
        Navigator.of(context)
            .pushNamed(Routes.PHOTO_VIEWER, arguments: bankUrl);
      },
      child: checkBankUrl(bankModel),
    );
  }

  checkBankUrl(BankModel bankModel) {
    if (bankModel.logoUrl == "") {
      return CircleAvatar(
        backgroundColor: navyBlue,
        radius: 25,
        child: Text(
          getInitials(bankModel.name!).toUpperCase(),
          style: TextStyle(color: white, fontWeight: FontWeight.w700),
        ),
      );
    } else {
      return Container(
        height: 48,
        width: 48,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(
              25,
            ),
            border: Border.all(color: greyBorderColor, width: 2)),
        child: ClipOval(
          child: CachedNetworkImage(
            imageUrl:
                bankModel.logoUrl == "" ? '' : bankModel.logoUrl.toString(),
            colorBlendMode: BlendMode.darken,
            fit: BoxFit.cover,
            errorWidget: imageErrorWidget,
            height: double.infinity,
            filterQuality: FilterQuality.high,
            placeholder: (context, _) => CachedNetworkImage(
              imageUrl: defaultImage,
              colorBlendMode: BlendMode.darken,
              fit: BoxFit.fitWidth,
              filterQuality: FilterQuality.high,
            ),
          ),
        ),
      );
    }
  }

  bool obscureChange = true;

  obscureTextWidget() {
    if (obscureChange) {
      return IconButton(
          onPressed: () => setState(() => obscureChange = !obscureChange),
          icon: const Icon(
            Icons.visibility,
            size: 20,
          ));
    } else {
      return IconButton(
          onPressed: () => setState(() => obscureChange = !obscureChange),
          icon: const Icon(
            Icons.visibility_off,
            size: 20,
          ));
    }
  }

  Widget passwordPinFiled() {
    final BoxDecoration pinPutDecoration = BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: greyBorderColor));
    final BoxDecoration selectedDecoration = BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: navyBlue));
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            AppLocalization.of(context)!.pincode,
            style: TextStyle(
                fontSize: 16, color: blackFont, fontWeight: FontWeight.w600),
          ),
          const SizedBox(
            height: 6.0,
          ),
          PinPut(
            eachFieldWidth: 45,
            eachFieldHeight: 45,
            obscureText: '•',
            validator: (val) => val!.length < 4
                ? AppLocalization.of(context)!.invalidPassword
                : null,
            fieldsCount: 6,
            focusNode: _pinPutFocusNode,
            controller: pinController,
            submittedFieldDecoration: pinPutDecoration,
            selectedFieldDecoration: selectedDecoration,
            followingFieldDecoration: pinPutDecoration,
            pinAnimationType: PinAnimationType.scale,
            textInputAction: TextInputAction.done,
            keyboardType: TextInputType.number,
            textStyle: TextStyle(color: blackFont, fontSize: 35),
          ),
        ],
      ),
    );
  }

  void getPaymentLinkData() async {
    try {
      loading = true;
      final res = await _auth.getSinglePaymentLinkDetails(widget.id);
      _paymentLinkModel = PaymentLinkModel.fromJson(res);
      loading = false;
      setState(() {});
      log('$res');
    } catch (e) {
      rethrow;
    }
  }

  cashOut() {
    if (_formKey.currentState!.validate()) {
      final dynamic data = {
        "bank": bankPaymentLinkSlug,
        "pin": pinController.text,
        "recipient_account_name": accountNameController.text,
        "recipient_account_number": accountNumberController.text,
      };
      cashOutPaymentLink(data);
      if (loading != false) {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => PaymentLoadingScreen(
                    text: 'Cashout Payment link Processing...',
                    imagePath: 'assets/images/app_logo.png',
                  )),
        );
      } else {
        Navigator.pop(context);
      }
    }
    setState(() {});
  }

  successfulPopUp() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await showDialog(
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
              content: Container(
                height: 250,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(22.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      RoundedBackgroundIcon(
                        backgroundColor: navyBlue.withOpacity(.2),
                        enableMargin: false,
                        image: Icon(
                          Icons.check,
                          size: 18.0,
                          color: navyBlue,
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
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
                        "Payment has been received successfully.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(
                        height: 30,
                      ),
                      CurvedButton(
                        onPressed: () => Navigator.of(
                                MyGlobals().navigationKey.currentContext!)
                            .pushNamedAndRemoveUntil(
                          "/dashboard",
                          (Route<dynamic> route) => false,
                        ),
                        backgroundColor: navyBlue,
                        textColor: Colors.white,
                        text: "Go back",
                      ),
                    ],
                  ),
                ),
              ),
            );
          });
    });
  }

  Future<void> cashOutPaymentLink(Map map) async {
    try {
      loading = true;
      await _auth
          .cashoutPaymentLink(map, _paymentLinkModel!.id!)
          .then((value) async {
        debugPrint("status code:- ${value.statusCode}  body:- ${value.body}");
        loading = false;

        response = value;

        try {
          handleServerErrors(response);
        } catch (e) {
          return Future.error(response.body);
        }

        if (response.statusCode == 200 || response.statusCode == 201) {
          showSnackbar(context,
              message: 'Payment link successfully cashed out..',
              duration: 2000);
          loading = false;
          successfulPopUp();
        } else if (response.statusCode == 400 || response.statusCode == 404) {
          loading = false;

          Navigator.pop(context);
          showSnackbar(context, message: 'Failed..!');
        } else if (response.statusCode == 500) {
          loading = false;

          Navigator.pop(context);
          showSnackbar(context, message: 'Failed..!');
        } else {
          loading = false;

          Navigator.pop(context);
          showSnackbar(context, message: 'Failed..!');
          loading = false;
        }
      });
    } catch (e) {
      log("$e");
    }
    setState(() {});
  }
}
