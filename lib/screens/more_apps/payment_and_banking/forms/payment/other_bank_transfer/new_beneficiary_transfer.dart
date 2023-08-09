import 'dart:convert';
import 'dart:io';
import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/utils/slydo_app_icon_icons.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/curved_btn.dart';
import 'package:Slydo/widget/customized_textform_field.dart';
import 'package:Slydo/widget/rounded_background_icon.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:http/http.dart' as http;

import '../../../../../../data/currency.dart';
import '../../../../../../data/database_helper.dart';
import '../../../../../../data/environment.dart';
import '../../../../../../routes/route_constants.dart';
import '../../../../../../widget/customized_passcode_sheet/bottomsheet_passcode.dart';
import '../../../../../../widget/dialog.dart';
import '../../../../../../widget/noItemInList.dart';
import '../../../../payment_loading_screen.dart';
import '../../../../user_profile/screens/user_profile_module_new/profile_template/utils.dart';
import '../../../models/VirtualAccount.dart';
import '../../../models/bank.dart';
import '../../../models/bank_list.dart';
import '../../../payment_and_banking_auth.dart';

// ignore: must_be_immutable
class NewBeneficiaryTransfer extends StatefulWidget {
  var arguments;
  final Function(bool)? callback;

  NewBeneficiaryTransfer({this.arguments, this.callback});

  // Declare a field that holds the userData.
  @override
  _NewBeneficiaryTransferState createState() => _NewBeneficiaryTransferState();
}

class _NewBeneficiaryTransferState extends State<NewBeneficiaryTransfer> {
  final _auth = PaymentAndBankingAuth();
  late UserBloc userBloc;
  final _formKey = GlobalKey<FormState>();
  String errorMessage = "";

  String bankName = '';
  String accountName = "";
  String accountNumber = "";
  String description = "";
  String bankId = "";
  bool isDefault = false;
  List<Bank> banks = getBanks();
  bool isUserAgree = false;
  String? next = "", previous = "";
  int count = 0;
  bool noList = false;
  bool isLoading = false;
  List<BankModel> bankList = [];
  List searchedProductAndService = [];
  BankModel? selectedBank;
  final bankController = TextEditingController();

  StateSetter? bottomSheetStateSetterGlobal;
  bool bottomSheetMounted = false;
  bool isItemLoading = false;
  final searchItemTextController = TextEditingController();
  final accountNameTextController = TextEditingController();
  final amountTextController = TextEditingController();
  final accountNumberController = TextEditingController();
  GlobalKey searchItemTextFormField = GlobalKey();
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  int bottomSheetSearchIndex = 0;
  bool noSearchedItem = false;
  ScrollController _scrollController = new ScrollController();
  int? amount = 0;
  late http.Response response;
  VirtualAccount? virtualAccount;
  bool isAccountFound = false;
  int? accountBalance = 0;

  @override
  void initState() {
    getBankAccountDetail();

    super.initState();
  }

  void getBankAccountDetail() async {
    isLoading = true;
    setState(() {});
    await getAccountBalance();
    virtualAccount = await DatabaseHelper().getVirtualAccount();
    if (virtualAccount == null) {
      virtualAccount = await PaymentAndBankingAuth().getVirtualAccountDetail();
    }
    if (virtualAccount != null) {
      isAccountFound = true;
    }
    isLoading = false;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    userBloc = Provider.of<UserBloc>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: scaffoldBody(),
    );
  }

  Widget scaffoldBody() {
    if (isLoading) {
      return _buildLoadingIndicator();
    }

    bool isScreenIsSmall = MediaQuery.of(context).size.height < 600;

    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Container(
        padding: EdgeInsets.symmetric(
            horizontal: 16, vertical: isScreenIsSmall ? 8 : 16),
        child: Column(
          children: [
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
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: <Widget>[
                        SizedBox(
                          height: 30,
                        ),
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
                              fillColor: greyBorderColor,
                              contentPadding: const EdgeInsets.only(
                                  left: 8, bottom: 0, top: 0, right: 15),
                              hintText: 'Select Bank',
                              hintStyle: TextStyle(
                                fontSize: 18,
                                color: blackFont,
                                fontWeight: FontWeight.w600),
                              suffixIcon: Icon(
                                Icons.arrow_drop_down_outlined,
                                color: blackFont,
                              ),
                              border: const OutlineInputBorder(
                                borderSide: BorderSide(
                                  width: 0,
                                  style: BorderStyle.none,
                                ),
                                borderRadius: BorderRadius.all(
                                  Radius.circular(8.0),
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        getAccountNumber(),
                        SizedBox(
                          height: 20,
                        ),
                        getAccountName(),
                        SizedBox(
                          height: 20,
                        ),
                        displayAmountField(),
                        SizedBox(
                          height: 20,
                        ),
                        getDescription(),
                        SizedBox(
                          height: 20,
                        ),
                        noteForUser(),
                        SizedBox(
                          height: 20,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Container(
              child: Column(
                children: [
                  SizedBox(
                    height: 40,
                  ),
                  canCashOut(amount!, accountBalance!)
                      ? getSubmitButton()
                      : Container(
                          child: Center(
                              child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 16.0),
                                  child: Text.rich(TextSpan(
                                      text: AppLocalization.of(context)!
                                          .minimumTransfer,
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: blackFont,
                                          fontWeight: FontWeight.w600),
                                      children: <InlineSpan>[
                                        TextSpan(
                                          text: worldCurrencies[
                                                  userBloc.user.currency!]! +
                                              moneyDisplayNormalizer(
                                                  displayPossibleCashOutAmount(
                                                      accountBalance!)),
                                          style: TextStyle(
                                              fontSize: 12,
                                              color: blackFont,
                                              fontFamily: "Roboto",
                                              fontWeight: FontWeight.w600),
                                        )
                                      ])))),
                        ),
                  SizedBox(
                    height: 20,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget getBankNameDropDownMenu() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalization.of(context)!.bank,
          style: TextStyle(color: darkGrey, fontSize: 14),
        ),
        SizedBox(
          height: 6,
        ),
        Card(
          elevation: 0,
          color: Colors.white,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: BorderSide(color: greyBorderColor)),
          margin: EdgeInsets.all(0),
          borderOnForeground: true,
          child: DropdownButton<String>(
            isExpanded: true,
            value: bankName,
            icon: Padding(
              padding: EdgeInsets.only(right: 8.0),
              child: Icon(
                Icons.keyboard_arrow_down,
                color: darkGrey,
                size: 20,
              ),
            ),
            underline: Divider(
              color: Colors.transparent,
            ),
            hint: Padding(
              padding: const EdgeInsets.only(left: 16.0),
              child: Text(AppLocalization.of(context)!.bank),
            ),
            iconSize: 24,
            elevation: 16,
            style: TextStyle(color: Colors.black),
            onChanged: (String? val) {
              if (mounted) {
                setState(() {
                  bankName = val!.trim();
                });
              }
            },
            items: banks.map((bank) {
              return DropdownMenuItem(
                value: bank.slug!.trim(),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16.0, 0, 0, 0),
                  child: Text(
                    bank.name!,
                    style: TextStyle(
                        color: blackFont,
                        fontSize: 16,
                        fontWeight: FontWeight.w600),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget getAccountNumber() {
    return CustomizedTextFormField(
      labelText: AppLocalization.of(context)!.accountNumber,
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
          accountNameTextController.text = '';
          bankId = '';
        }
        if (mounted) setState(() {});
      },
    );
  }

  Widget getAccountName() {
    return CustomizedTextFormField(
      labelText: AppLocalization.of(context)!.accountNameHint,
      enabled: false,
      controller: accountNameTextController,
    );
  }

  Widget getDescription() {
    return CustomizedTextFormField(
      labelText: AppLocalization.of(context)!.reference,
      keyboardType: TextInputType.text,
      enabled: true,
      onChanged: (val) {
        if (mounted) {
          setState(() {
            description = val;
          });
        }
      },
    );
  }

  Widget displayAmountField() {
    return CustomizedTextFormField(
      labelText: "Amount",
      isAmountField: true,
      enabled: true,
      keyboardType: Platform.isIOS
          ? TextInputType.numberWithOptions(decimal: true)
          : TextInputType.number,
      // inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      controller: amountTextController,
      onChanged: (val) {
        if (mounted) {
          setState(() {
            amount = int.parse(val.replaceAll(",", "").split(".")[0]);
          });
        }
      },
      validator: (val) {
        if (val.isNotEmpty) {
          try {
            double amount = double.parse(val.replaceAll(',', ''));
            if (amount > 0.0) {
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
      onTap: () async {
        if (mounted) setState(() {});
      },
    );
  }

  Widget getSubmitButton() {
    return CurvedButton(
      onPressed: onSubmit,
      backgroundColor: navyBlue,
      textColor: Colors.white,
      text: "Send Payment",
    );
  }

  void onSubmit() async {
    if (FocusScope.of(context).hasFocus) {
      FocusScope.of(context).unfocus();
    }

    if (bankId == "") {
      showToast(message: "Bank Account not added yet");
      return;
    }

    await Future.delayed(Duration(milliseconds: 500));

    isLoading = true;
    if (mounted) setState(() {});

    if (canSendMoney(amount,
        virtualAccount?.accountTier?.dailyCumulativeTransactionLimit!)) {
      try {
        var data = {
          "amount": moneyInputNormalizer(amount.toString()),
          "currency": userBloc.user.currency,
          "customer_bank_account": int.tryParse(bankId),
          "description": description,
        };
        BottomSheetPassCode(
            context: context,
            isValidCallback: () {
              showDialog(
                  context: context,
                  builder: (context) =>
                      // Center(child: CircularLoadingIndicator()));
                      Center(child: SizedBox()));
              //show loading screen
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => PaymentLoadingScreen(
                          text: 'Bank Transfer Processing...',
                          imagePath: 'assets/images/app_logo.png',
                        )),
              );

              _auth.accountPayout(data).then((value) {
                response = value;

                Navigator.pop(context);

                if (response.statusCode == 201) {
                  Navigator.pop(context);
                  Navigator.of(context).pushNamed(Routes.TRANSACTIONS,
                      arguments: {'page': 1});
                } else if (response.statusCode == 500) {
                  Navigator.pop(context);
                  if (mounted) {
                    setState(() {
                      errorMessage = AppLocalization.of(context)!.serverError;
                      showToast(message: errorMessage);
                    });
                  }
                } else {
                  Navigator.pop(context);
                  if (mounted) {
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
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(AppLocalization.of(context)!.invalidPassword),
              ));
            });
      } catch (e) {
        debugPrint(e.toString());
        showToast(message: e.toString());
      }
    } else {
      showToast(
          message:
              "Please Upgrade your account tier to make bigger transactions.");
    }
  }

  void onAddAccount(String? userName, Map tempList) async {
    isLoading = true;
    if (mounted) setState(() {});

    Map data = {
      "customer_username": userName,
      "bank": selectedBank!.slug,
      "account_name": tempList['account_name'],
      "account_number": tempList['account_number'],
      "is_default": false,
    };

    Map<String, dynamic>? result = await _auth.addBankAccount(data);

    isLoading = false;
    if (mounted) setState(() {});

    if (result == null) {
      showToast(message: 'Unable to add account');
      return;
    }

    if (result['status'] == 201) {
      //get the id
      var tempList = result['results'];
      bankId = tempList['id'].toString();
    } else {
      dynamic jsonObject = jsonDecode(result['results']);

      if (jsonObject.containsKey("non_field_errors")) {
        showToast(message: jsonObject['non_field_errors'][0].toString());
      } else if (jsonObject.containsKey("bank")) {
        showToast(message: jsonObject['bank'][0].toString());
      }

      isLoading = false;
      if (mounted) {
        setState(() {
          errorMessage = AppLocalization.of(context)!.errorMsg1;
        });
      }
    }
  }

  void verifyAccount() async {
    isLoading = true;
    if (mounted) setState(() {});

    Map data = {
      "bank_code": selectedBank!.providerCode,
      "account_number": accountNumber,
    };

    try {
      Map<String, dynamic>? result = await _auth.verifyBankAccount(data);

      isLoading = false;
      if (mounted) setState(() {});

      if (result == null) {
        showToast(message: 'Unable to validate account');
        return;
      }

      var tempList = result['results'];
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
          accountNameTextController.text = tempList['account_name'];
          accountNumberController.text = tempList['account_number'];
          onAddAccount(userBloc.user.userName, tempList);
          if (mounted) setState(() {});
        },
      );
    } catch (error) {
      isLoading = false;
      if (mounted) setState(() {});
      // showToast(message: error.toString());
    }
  }

  Widget _buildLoadingIndicator() {
    return Opacity(
      opacity: isLoading ? 1.0 : 00,
      child: isLoading
          ? Center(
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                valueColor: AlwaysStoppedAnimation(navyBlue),
                backgroundColor: Colors.transparent,
              ),
            )
          : Container(),
    );
  }

  void showSearchBankBottomSheet() async {
    var result = await showModalBottomSheet<String>(
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
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20)),
                ),
                color: Colors.white,
                margin: EdgeInsets.zero,
                child: Container(
                  height: MediaQuery.of(context).size.height * 0.88,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          child: searchBox()),
                      SizedBox(height: 8),
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
          textSelectionTheme:
              TextSelectionThemeData().copyWith(selectionHandleColor: navyBlue),
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
            contentPadding: EdgeInsets.symmetric(vertical: 10),
            // prefixIcon: searchTypeSelection(),
            prefix: Padding(
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

  Widget bottomSheetTabBar() {
    return Column(
      children: [
        SizedBox(
          height: 8,
        ),
        Expanded(child: bottomSheetTabViews())
      ],
    );
  }

  Widget bottomSheetTabBars() {
    return PreferredSize(
        preferredSize: Size.fromHeight(50.0),
        child: Row(
          children: [
            GestureDetector(
              onTap: () {
                bottomSheetSearchIndex = 0;
                // clearSearchedListItems();
                bottomSheetStateSetterGlobal!(() {});

                if (mounted) setState(() {});
                searchBankList();
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  shape: BoxShape.rectangle,
                  color: bottomSheetSearchIndex == 0
                      ? navyBlue.withOpacity(0.1)
                      : Colors.white,
                ),
                child: Text(
                  "From partner",
                  style: TextStyle(
                    color: bottomSheetSearchIndex == 0 ? navyBlue : blackFont,
                    fontSize: 14,
                    fontWeight: bottomSheetSearchIndex == 0
                        ? FontWeight.w600
                        : FontWeight.w400,
                  ),
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                bottomSheetSearchIndex = 1;
                clearSearchedListItems();
                bottomSheetStateSetterGlobal!(() {});
                setState(() {});
                searchBankList();
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  shape: BoxShape.rectangle,
                  color: bottomSheetSearchIndex == 1
                      ? navyBlue.withOpacity(0.1)
                      : Colors.white,
                ),
                child: Text(
                  "From Mine",
                  style: TextStyle(
                    color: bottomSheetSearchIndex == 1 ? navyBlue : blackFont,
                    fontSize: 14,
                    fontWeight: bottomSheetSearchIndex == 1
                        ? FontWeight.w600
                        : FontWeight.w400,
                  ),
                ),
              ),
            ),
          ],
        ));
  }

  Widget bottomSheetTabViews() {
    return pullToRefresh();
  }

  void _onRefresh() async {
    Connectivity().checkConnectivity().then((value) {
      var connectionResult = value;
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

  Widget pullToRefresh() {
    return searchItemTextController!.text.isEmpty
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

  Widget searchTypeSelection() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(10), bottomLeft: Radius.circular(10)),
        color: navyBlue,
      ),
      child: IconButton(
        // key: _key,
        icon: Icon(
          SlydoAppIcon.payout_list,
          color: Colors.white,
          size: 16,
        ),
        onPressed: () {},
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

  void clearSearchedListItems() {
    bankList.clear();
    count = 0;
    next = "";
    previous = "";
    searchItemTextController.text = "";
    if (bottomSheetStateSetterGlobal != null) if (bottomSheetMounted) {}
  }

  Widget buildBankList() {
    return noSearchedItem
        ? NoItemInList(
            msg: AppLocalization.of(context)!.noResultFound,
            isResult: true,
          )
        : ListView.builder(
            padding: EdgeInsets.symmetric(vertical: 4),
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

                      if (mounted) setState(() {});
                      Navigator.pop(context);

                      FocusScope.of(context).requestFocus();
                    },
                    child: Column(
                      children: [
                        if (bankList.length >= 1) ...[
                          getResultTile(bankList[index]),
                        ] else ...[
                          // print('The array does not have a second element.');
                        ]
                      ],
                    ));
              }
            },
            controller: _scrollController,
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

  void getBankListSearched() async {
    String url = AppConfig.baseUrl +
        "/api/v1/transactions/get-bank-info/?search=" +
        searchItemTextController.text;

    if (!isItemLoading) {
      if (next != null && !isItemLoading) {
        isItemLoading = true;

        if (bottomSheetStateSetterGlobal != null) if (bottomSheetMounted)
          bottomSheetStateSetterGlobal!(() {});
        if (mounted) setState(() {});

        Map<String, dynamic>? result =
            await _auth.searchBankList(url, next, previous);
        if (result == null) {
          isItemLoading = false;
          return;
        }
        count = result['count'];
        next = result['next'];
        previous = result['previous'];
        List tempList = result['results'];

        isItemLoading = false;
        if (bottomSheetStateSetterGlobal != null) if (bottomSheetMounted)
          bottomSheetStateSetterGlobal!(() {});
        bankList!.clear();
        if (mounted) setState(() {});

        tempList.forEach((item) {
          bankList!.add(BankModel.fromJson(item));
        });

        if (bottomSheetStateSetterGlobal != null) if (bottomSheetMounted)
          bottomSheetStateSetterGlobal!(() {});
        if (mounted) setState(() {});
      }
      if (bankList!.isEmpty) {
        noSearchedItem = true;
        if (bottomSheetStateSetterGlobal != null) if (bottomSheetMounted)
          bottomSheetStateSetterGlobal!(() {});
        if (mounted) setState(() {});
      }
    }
  }

  Widget getResultTile(var result) {
    if (result is BankModel) {
      return bankCardDisplay(result);
    }
    return Container();
  }

  Widget bankCardDisplay(BankModel bankModel) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 4, horizontal: 16),
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
                padding: EdgeInsets.symmetric(vertical: 8),
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
    String? bankUrl = bankModel.logoUrl == ""
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

  Widget noteForUser() {
    return Center(
      child: Text.rich(TextSpan(
          text: AppLocalization.of(context)!.noteForUser2,
          style: TextStyle(
              fontSize: 12, color: blackFont, fontWeight: FontWeight.w600),
          children: <InlineSpan>[
            TextSpan(
              text: worldCurrencies[userBloc.user.currency!]! +
                  moneyDisplayNormalizer(2500),
              style: TextStyle(
                  fontSize: 12,
                  color: blackFont,
                  fontFamily: "Roboto",
                  fontWeight: FontWeight.w600),
            )
          ])),
    );
  }

  Future<void> getAccountBalance() async {
    await _auth.getAccountBalance().then((value) {
      var data = value!;
      var spendableBalance = data["spendable_balance"];
      if (mounted) {
        setState(() {
          accountBalance = spendableBalance;
        });
      }
    });
  }

}
