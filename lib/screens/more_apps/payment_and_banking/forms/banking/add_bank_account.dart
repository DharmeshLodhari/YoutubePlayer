import 'dart:convert';

import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/screens/more_apps/payment_and_banking/models/bank.dart';
import 'package:Slydo/screens/more_apps/payment_and_banking/models/bank_list.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/curved_btn.dart';
import 'package:Slydo/widget/customized_textform_field.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import '../../../../../data/environment.dart';
import '../../../../../locale/app_localization.dart';
import '../../../../../routes/route_constants.dart';
import '../../../../../utils/slydo_app_icon_icons.dart';
import '../../../../../widget/dialog.dart';
import '../../../../../widget/noItemInList.dart';
import '../../../../../widget/rounded_background_icon.dart';
import '../../../user_profile/screens/user_profile_module_new/profile_template/utils.dart';
import '../../models/transactions.dart';
import '../../payment_and_banking_auth.dart';

class AddAccount extends StatefulWidget {
  @override
  _AddAccountState createState() => _AddAccountState();
}

class _AddAccountState extends State<AddAccount> {
  final _auth = PaymentAndBankingAuth();
  late UserBloc userBloc;
  final _formKey = GlobalKey<FormState>();
  String errorMessage = "";

  String bankName = 'first-bank-nigeria-limited';
  String accountName = "";
  String accountNumber = "";
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
  GlobalKey searchItemTextFormField = GlobalKey();
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  int bottomSheetSearchIndex = 0;
  bool noSearchedItem = false;
  ScrollController _scrollController = new ScrollController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    userBloc = Provider.of<UserBloc>(context);

    return WillPopScope(
      onWillPop: () async {
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        resizeToAvoidBottomInset: true,
        appBar: appBar() as PreferredSizeWidget?,
        body: scaffoldBody(),
      ),
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
          if (isLoading) {
            return;
          }
          Navigator.pop(context);
        },
      ),
      title: Text(
        "Add a bank account",
        style: TextStyle(
            color: blackFont, fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget scaffoldBody() {
    if (isLoading) {
      return _buildLoadingIndicator();
    }

    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Column(
        children: [
          Form(
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
                          // fontSize: 20,
                          color: blackFont),
                      decoration: InputDecoration(
                        filled: true,
                        // fillColor: blackFont,
                        contentPadding: const EdgeInsets.only(
                            left: 8, bottom: 0, top: 0, right: 15),
                        hintText: 'Select Bank',
                        hintStyle: TextStyle(
                            // fontSize: 20,
                            color: blackFont),
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
                  checkButton(),
                  SizedBox(
                    height: 20,
                  ),
                  errorMessage != ""
                      ? Column(
                          children: [
                            Text(
                              errorMessage,
                              style: TextStyle(color: mateRed, fontSize: 14),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                          ],
                        )
                      : Container(),
                  getUserAgreeCheckBoxWidget(),
                  SizedBox(
                    height: 40,
                  ),
                  isUserAgree
                      ? getSubmitButton(userBloc.user.userName)
                      : Container(
                          height: 42,
                        ),
                ],
              ),
            ),
          ),
        ],
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
      validator: (val) => val.length < 10
          ? AppLocalization.of(context)!.validationTextMessage1
          : null,
      onChanged: (val) {
        if (mounted) {
          setState(() {
            accountNumber = val;
          });
        }
      },
    );
  }

  Widget checkButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          AppLocalization.of(context)!.setDefaultAccountMsg,
          style: TextStyle(
              color: blackFont, fontSize: 14, fontWeight: FontWeight.w600),
        ),
        Switch(
          value: isDefault,
          onChanged: (value) {
            if (mounted) {
              setState(() {
                isDefault = value;
              });
            }
          },
          activeTrackColor: navyBlue,
          activeColor: Colors.white,
          inactiveTrackColor: dividerColor,
        ),
      ],
    );
  }

  Widget getSubmitButton(String? userName) {
    return CurvedButton(
      onPressed: () {
        onSubmit(userName);
      },
      backgroundColor: navyBlue,
      textColor: Colors.white,
      text: AppLocalization.of(context)!.submit,
    );
  }

  void onSubmit(String? userName) async {
    if (_formKey.currentState!.validate()) {
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
            onAddAccount(userName, tempList);
          },
        );
      } catch (error) {
        isLoading = false;
        if (mounted) setState(() {});
        // showToast(message: error.toString());
      }
    }
  }

  void onAddAccount(String? userName, Map tempList) async {
    final BankAccountBloc bankAccountBloc =
        Provider.of<BankAccountBloc>(context, listen: false);

    isLoading = true;
    if (mounted) setState(() {});

    Map data = {
      "customer_username": userName,
      "bank": selectedBank!.slug,
      "account_name": tempList['account_name'],
      "account_number": tempList['account_number'],
      "is_default": isDefault,
    };

    Map<String, dynamic>? result = await _auth.addBankAccount(data);

    isLoading = false;
    if (mounted) setState(() {});

    if (result == null) {
      showToast(message: 'Unable to add account');
      return;
    }

    if (result['status'] == 201) {
      BankAccount _bankAccount;
      await _auth.getBankAccounts().then((accounts) {
        try {
          _bankAccount = accounts[0];
          if (_bankAccount != null) {
            bankAccountBloc.bankAccount = _bankAccount;
          }
        } catch (e) {
          isLoading = false;
          if (mounted) {
            setState(() {
              errorMessage = AppLocalization.of(context)!.errorMsg1;
            });
          }
        }
      });
      Navigator.pop(context);
      Navigator.of(context).popAndPushNamed('/bank-account-list');
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

  Widget getUserAgreeCheckBoxWidget() {
    return InkWell(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          ClipRRect(
            clipBehavior: Clip.antiAliasWithSaveLayer,
            borderRadius: BorderRadius.all(Radius.circular(5)),
            child: SizedBox(
              width: Checkbox.width - 1.5,
              height: Checkbox.width - 1.5,
              child: Container(
                decoration: new BoxDecoration(
                  border: Border.all(
                    color: greyBorderColor,
                    width: 1,
                  ),
                  borderRadius: new BorderRadius.circular(5),
                ),
                child: Theme(
                  data: ThemeData(
                    unselectedWidgetColor: Colors.transparent,
                  ),
                  child: Checkbox(
                    value: isUserAgree,
                    activeColor: navyBlue,
                    checkColor: Colors.white,
                    materialTapTargetSize: MaterialTapTargetSize.padded,
                    onChanged: (value) {
                      // if (mounted) {
                      //   setState(() {
                      //     isUserAgree = value;
                      //   });
                      // }
                    },
                  ),
                ),
              ),
            ),
          ),
          SizedBox(
            width: 12,
          ),
          Expanded(
              child: Text(
            AppLocalization.of(context)!.bankAccountUserAgreeTerm,
            style: TextStyle(color: blackFont, fontSize: 14),
          ))
        ],
      ),
      onTap: () {
        if (mounted) {
          isUserAgree = !isUserAgree;
          setState(() {});
        }
      },
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
}
