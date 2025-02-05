import 'dart:io';

import 'package:Slydo/constant.dart';
import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/screens/more_apps/payment_loading_screen.dart';
import 'package:Slydo/screens/payment_and_banking/models/payout.dart';
import 'package:Slydo/screens/user_profile/models/user.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/curved_btn.dart';
import 'package:Slydo/widget/customized_textform_field.dart';
import 'package:Slydo/widget/permission_protection_widget.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../../../../../data/currency.dart';
import '../../../../../../data/database_helper.dart';
import '../../../../../../routes/route_constants.dart';
import '../../../../../../utils/slydo_app_icon_icons.dart';
import '../../../../../../widget/customized_passcode_sheet/bottomsheet_passcode.dart';
import '../../../../../../widget/loading_indicator.dart';
import '../../../../../../widget/no_item_in_list.dart';
import '../../../../../../widget/slide_action_button.dart';
import '../../../../../../widget/vertical_list_item.dart';
import '../../../../user_profile/screens/user_profile_module_new/profile_template/utils.dart';
import '../../../models/transactions.dart';
import '../../../models/virtual_account.dart';
import '../../../payment_and_banking_auth.dart';

// ignore: must_be_immutable
class BeneficiaryTransfer extends StatefulWidget {
  final dynamic arguments;
  final Function(bool)? callback;

  const BeneficiaryTransfer({super.key, this.arguments, this.callback});

  // Declare a field that holds the userData.
  @override
  State<BeneficiaryTransfer> createState() => _BeneficiaryTransferState();
}

class _BeneficiaryTransferState extends State<BeneficiaryTransfer>
    with SingleTickerProviderStateMixin {
  late http.Response response;

  final _auth = PaymentAndBankingAuth();
  final _formKey = GlobalKey<FormState>();

  late UserBloc userBloc;
  late BankAccountBloc bankAccountBloc;

  int? amount = 0;
  String errorMessage = "";
  String description = "";
  String searchText = '';
  int? accountBalance = 0;

  VirtualAccount? virtualAccount;
  bool isAccountFound = false;
  bool isLoading = false;
  StateSetter? bottomSheetStateSetterGlobal;
  bool bottomSheetMounted = false;
  int bottomSheetSearchIndex = 0;
  final ScrollController _scrollController = ScrollController();
  String? next = "", previous = "";
  int count = 0;
  bool noList = false;
  List bankAccountList = [];
  List bankAccountListStore = [];
  bool noItemInList = false;
  BankAccount? selectedBank;
  final searchItemTextController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _referenceController = TextEditingController();
  GlobalKey searchItemTextFormField = GlobalKey();
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  bool isBalanceHidden = true;
  bool isBalanceLoading = true;
  Payout? payout;

  @override
  void initState() {
    payout = widget.arguments != null ? widget.arguments['payout'] : null;

    if (payout != null) {
      getBankAccountDetail(loadBanks: false);
      getList(payout?.accountNumber ?? "");
      _amountController.text = moneyDisplayNormalizer(payout?.amount);
      amount =
          int.parse(_amountController.text.replaceAll(",", "").split(".")[0]);
      _referenceController.text = payout?.description ?? "";
      description = _referenceController.text;
    } else {
      getBankAccountDetail(loadBanks: true);
      _scrollController.addListener(() {
        if (_scrollController.position.pixels ==
                _scrollController.position.maxScrollExtent &&
            _scrollController.position.pixels != 0) {
          getList("");
        }
      });

      searchItemTextController.addListener(() {
        if (searchItemTextController.text.length >= 3) {
          searchText = searchItemTextController.text;

          if (bottomSheetStateSetterGlobal != null && bottomSheetMounted) {
            bottomSheetStateSetterGlobal!(() {});
          }
          if (mounted) setState(() {});

          // Call your search function here
          searchBankList();
        } else if (searchItemTextController.text.isEmpty) {
          if (bottomSheetStateSetterGlobal != null && bottomSheetMounted) {
            bottomSheetStateSetterGlobal!(() {});
          }
          if (mounted) setState(() {});

          clearSearchAndAllBanks();
          searchBankList();
        }
      });
    }

    super.initState();
  }

  void getBankAccountDetail({bool loadBanks = true}) async {
    isBalanceLoading = true;
    setState(() {});
    await getAccountBalance();
    if (loadBanks) {
      getList("");
    }

    virtualAccount = await DatabaseHelper().getVirtualAccount();
    virtualAccount ??= await PaymentAndBankingAuth().getVirtualAccountDetail();
    if (virtualAccount != null) {
      isAccountFound = true;
    }
    isBalanceLoading = false;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    userBloc = Provider.of<UserBloc>(context);
    bankAccountBloc = Provider.of<BankAccountBloc>(context);

    return Scaffold(
      backgroundColor: lightGrey,
      resizeToAvoidBottomInset: true,
      body: scaffoldBody(),
    );
  }

  Widget scaffoldBody() {
    final bool isScreenIsSmall = MediaQuery.of(context).size.height < 600;

    if (!isLoading && bankAccountBloc.bankAccount!.accountName == null) {
      return NoItemInList(
        msg: AppLocalization.of(context)!.emptyBeneficiary,
      );
    }

    return isLoading
        ? Center(
            child: CircularLoadingIndicator(),
          )
        : noItemInList
            ? NoItemInList(
                msg: AppLocalization.of(context)!.emptyBeneficiary,
              )
            : SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: 16, vertical: isScreenIsSmall ? 8 : 16),
                  child: Column(
                    children: [
                      _buildTransferForm(),
                      _buildFormFields(),
                      _buildSendPayment(),
                    ],
                  ),
                ),
              );
  }

  Widget _buildTransferForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Transfer From",
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: darkGrey,
            fontFamily: "Inter",
          ),
        ),
        const SizedBox(
          height: 8,
        ),
        SizedBox(
          width: MediaQuery.of(context).size.width,
          child: Card(
            elevation: 0,
            margin: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(7),
            ),
            shadowColor: iconBtnGrey,
            color: greyDarkBackground,
            child: Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(7),
                  border: Border.all(color: iconBtnGrey, width: 1)),
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "@${userBloc.user.userName}",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: blackFont,
                        fontFamily: "Inter",
                      ),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (isBalanceLoading == true)
                          SizedBox(
                            width: 20,
                            height: 20,
                            child:
                                CircularLoadingIndicator(color: naturalGreen),
                          )
                        else
                          Row(
                            children: [
                              Text(
                                "Transferable Balance : ",
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                  color: navyBlue,
                                  fontFamily: "Inter",
                                ),
                              ),
                              if (isBalanceHidden)
                                Container()
                              else
                                Text(
                                  worldCurrencies[userBloc.user.currency] ?? "",
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w400,
                                    color: navyBlue,
                                    fontFamily: "Inter",
                                  ),
                                ),
                              Text(
                                isBalanceHidden
                                    ? generateAsteriskMask(
                                        moneyDisplayNormalizer(accountBalance))
                                    : moneyDisplayNormalizer(accountBalance),
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                  color: navyBlue,
                                  fontFamily: "Inter",
                                ),
                              ),
                            ],
                          ),
                        InkWell(
                          onTap: () {
                            toggleBalanceVisibility();
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10.0, vertical: 5.0),
                            child: Icon(
                              isBalanceHidden
                                  ? SlydoAppIcon.eye
                                  : SlydoAppIcon.eyeClose,
                              color: navyBlue,
                              size: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(
          height: 15,
        ),
      ],
    );
  }

  String generateAsteriskMask(String amount) {
    // Determine the length of the amount
    final int amountLength = amount.length;

    // Generate a string of asterisks of the same length as the amount
    final String asteriskMask = '*' * amountLength;

    // Trim the trailing space and return the asterisk mask
    return asteriskMask.trim();
  }

  void toggleBalanceVisibility() {
    if (isBalanceHidden) {
      if (userBloc.chatMessageSettings.accountBalanceVisibility == false) {
        BottomSheetPassCode(
          context: context,
          isValidCallback: () {
            getAccountBalance();
            isBalanceHidden = false;
            setState(() {});
          },
          cancelCallBack: () {
            Navigator.pop(context);
          },
        );
      } else {
        getAccountBalance();
        isBalanceHidden = false;
        setState(() {});
      }
    } else {
      isBalanceHidden = !isBalanceHidden;
      setState(() {});
    }
  }

  Widget _buildFormFields() {
    return Card(
      elevation: 2,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      shadowColor: boxShadowTwo,
      child: Container(
        decoration: decorateBox(),
        child: Form(
          key: _formKey,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: <Widget>[
                const SizedBox(
                  height: 20,
                ),
                getUserBankAccount(),
                const SizedBox(
                  height: 20,
                ),
                displayAmountField(),
                const SizedBox(
                  height: 20,
                ),
                getDescription(),
                const SizedBox(
                  height: 20,
                ),
                noteForUser(),
                const SizedBox(
                  height: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSendPayment() {
    return Column(
      children: [
        const SizedBox(
          height: 40,
        ),
        if (canCashOut(amount!, accountBalance!))
          getSubmitButton()
        else
          Center(
              child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Text.rich(TextSpan(
                      text: AppLocalization.of(context)!.minimumTransfer,
                      style: TextStyle(
                          fontSize: 12,
                          color: blackFont,
                          fontWeight: FontWeight.w600),
                      children: <InlineSpan>[
                        TextSpan(
                          text: getAccountBalanceDisplay(),
                          style: TextStyle(
                              fontSize: 12,
                              color: blackFont,
                              fontFamily: "Inter",
                              fontWeight: FontWeight.w600),
                        )
                      ])))),
        const SizedBox(
          height: 20,
        ),
      ],
    );
  }

  String getAccountBalanceDisplay() {
    final int balanceAmount = displayPossibleCashOutAmount(accountBalance ?? 0);
    final allowedPayoutAsString = balanceAmount / 100;
    final double allowedPayout = double.parse(allowedPayoutAsString.toString());

    if (allowedPayout >= 35.00) {
      return worldCurrencies[userBloc.user.currency!]! +
          moneyDisplayNormalizer(amount);
    } else {
      return '${worldCurrencies[userBloc.user.currency!]!}0.00';
    }
  }

  Widget getUserBankAccount() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: EdgeInsets.zero,
      shadowColor: boxShadowTwo,
      elevation: 0,
      child: Container(
        decoration: decorateBox(),
        child: GestureDetector(
          onTap: () {
            clearSearchAndAllBanks();
            showAllBankAccount(context);
          },
          child: ListTile(
            dense: true,
            title: Text(
              appendStringDot(bankAccountBloc.bankAccount!.accountName!, 17),
              maxLines: 1,
              style: TextStyle(
                  color: blackFont, fontWeight: FontWeight.w600, fontSize: 14),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  getFormattedAccountNumber(
                      accountNumber: bankAccountBloc.bankAccount!.accountNumber
                          .toString()),
                  style: TextStyle(color: darkGrey, fontSize: 12),
                ),
                Text(
                  appendStringDot(bankAccountBloc.bankAccount!.bankName!, 15),
                  style: TextStyle(color: darkGrey, fontSize: 12),
                ),
              ],
            ),
            leading: GestureDetector(
              onTap: () {
                clearSearchAndAllBanks();
                showAllBankAccount(context);
              },
              child: checkBankImage(bankAccountBloc.bankAccount!),
            ),
            trailing: const Icon(Icons.keyboard_arrow_down),
          ),
        ),
      ),
    );
  }

  Widget displayAmountField() {
    return CustomizedTextFormField(
      labelText: "Amount",
      isAmountField: true,
      keyboardType: Platform.isIOS
          ? const TextInputType.numberWithOptions(decimal: true)
          : TextInputType.number,
      controller: _amountController,
      onChanged: (val) {
        if (mounted) {
          setState(() {
            if (val.isNotEmpty) {
              amount = int.parse(val.replaceAll(",", "").split(".")[0]);
            } else {
              amount = 0;
            }
          });
        }
      },
      validator: (val) {
        if (val.isNotEmpty) {
          try {
            double.parse(val.replaceAll(',', ''));
            return null;
          } catch (e) {
            debugPrint('Error : $e');
          }
        }
        return AppLocalization.of(context)!.invalidAmount;
      },
    );
  }

  Widget getDescription() {
    return CustomizedTextFormField(
      labelText: AppLocalization.of(context)!.reference,
      keyboardType: TextInputType.text,
      controller: _referenceController,
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

  Widget getSubmitButton() {
    return PermissionProtectionWidget(
      permissionName: ProtectionPermission.transaction,
      isLockForRead: '1',
      child: CurvedButton(
        onPressed: onSubmit,
        backgroundColor: navyBlue,
        textColor: Colors.white,
        text: AppLocalization.of(context)!.submit,
      ),
    );
  }

  void onSubmit() async {
    final PermissionType? hasPermission =
        userBloc.user.hasWritePermission(ProtectionPermission.transaction);
    if (hasPermission == PermissionType.WRITE) {
      FocusScope.of(context).unfocus();

      // duration for close keyboard and open passcode bottomsheet
      await Future.delayed(const Duration(milliseconds: 500));

      if (_formKey.currentState!.validate()) {
        // debugPrint(
        //     "virtualAccount?.accountTier?.dailyCumulativeTransactionLimit! ${virtualAccount?.accountTier?.dailyCumulativeTransactionLimit!}");

        if (canSendMoney(amount,
            virtualAccount?.accountTier?.dailyCumulativeTransactionLimit!)) {
          try {
            final data = {
              "amount": moneyInputNormalizer(amount.toString()),
              "currency": userBloc.user.currency,
              "customer_bank_account":
                  int.tryParse(bankAccountBloc.bankAccount!.uuid!),
              "description": description,
            };
            BottomSheetPassCode(
                context: context,
                isValidCallback: () async {
                  showDialog(
                      context: context,
                      builder: (context) =>
                          // Center(child: CircularLoadingIndicator()));
                          const Center(child: SizedBox()));
                  //show loading screen
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const PaymentLoadingScreen(
                              text: 'Bank Transfer Processing...',
                              imagePath: 'assets/images/app_logo.png',
                            )),
                  );

                  await _auth.accountPayout(data).then((value) {
                    response = value;

                    Navigator.pop(context);

                    if (response.statusCode == 200 ||
                        response.statusCode == 201) {
                      Navigator.pop(context);
                      Navigator.of(context).pushNamed(Routes.TRANSACTIONS,
                          arguments: {'page': 1});
                    } else if (response.statusCode == 500) {
                      Navigator.pop(context);
                      if (mounted) {
                        setState(() {
                          errorMessage =
                              AppLocalization.of(context)!.serverError;
                          showToast(message: errorMessage);
                        });
                      }
                    }
                    // else if (response.statusCode == 800) {
                    //   Navigator.pop(context);
                    //   Navigator.pushNamed(context, "/add-document");
                    // }
                    else {
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
    } else {
      showSnackbar(context,
          message: AppLocalization.of(context)?.doNotPermission ?? "");
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
                  fontFamily: "Inter",
                  fontWeight: FontWeight.w600),
            )
          ])),
    );
  }

  Future<void> getAccountBalance() async {
    await _auth.getAccountBalance().then((value) {
      final data = value!;
      final spendableBalance = data["spendable_balance"];
      if (mounted) {
        setState(() {
          accountBalance = spendableBalance;
        });
      }
    });
  }

  Future<void> showAllBankAccount(BuildContext context) async {
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
                        child: searchBox(),
                      ),
                      const SizedBox(height: 8),
                      Expanded(child: bottomSheetTabBar())
                    ],
                  ),
                ));
          });
        });
    bottomSheetMounted = false;
    if (result == null) {}
  }

  Widget searchBox() {
    return Theme(
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
          hintText: 'Search Beneficiary',
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
          searchText = val;

          // Call your search function here
          searchBankList();
        },
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
        // searchBankList();
      },
    );
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

  Widget bottomSheetTabBars() {
    return PreferredSize(
        preferredSize: const Size.fromHeight(50.0),
        child: Row(
          children: [
            GestureDetector(
              onTap: () {
                bottomSheetSearchIndex = 0;
                // clearSearchedListItems();
                bottomSheetStateSetterGlobal!(() {});

                if (mounted) setState(() {});
                getList("");
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 8),
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
                // clearSearchedListItems();
                bottomSheetStateSetterGlobal!(() {});
                setState(() {});
                getList("");
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 8),
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
    return SlidableAutoCloseBehavior(
      closeWhenOpened: true,
      child: SmartRefresher(
          enablePullDown: true,
          header: WaterDropHeader(
            complete: Container(),
            waterDropColor: navyBlue,
          ),
          controller: _refreshController,
          onRefresh: _onRefresh,
          child: buildBankList(context)),
    );
  }

  void getList(String searchText) async {
    isLoading = true;
    if (mounted) setState(() {});
    final Map<String, dynamic>? result =
        await _auth.getBankAccountsPagination(next, previous, searchText);
    if (result == null) {
      isLoading = false;
      if (mounted) setState(() {});
      return;
    }
    count = result['count'];
    next = result['next'];
    previous = result['previous'];
    final tempList = result['results'];

    if (tempList != null) {
      bankAccountList = [];
      bankAccountListStore = [];
      noItemInList = false;
      if (bottomSheetStateSetterGlobal != null && bottomSheetMounted) {
        bottomSheetStateSetterGlobal!(() {});
      }
      bankAccountList.addAll(tempList);
      bankAccountListStore.addAll(tempList);

      for (BankAccount item in bankAccountList) {
        if (searchText == null || searchText.isEmpty) {
          if (item.isDefault == true) {
            bankAccountBloc.bankAccount = item;
          }
        } else if ((item.accountNumber?.contains(searchText) ?? false) ||
            (item.accountName?.contains(searchText) ?? false)) {
          bankAccountBloc.bankAccount = item;
        }
      }

      //if there is no default set as true the pick first account
      if (bankAccountBloc.bankAccount!.accountName == null &&
          bankAccountList.isNotEmpty) {
        bankAccountBloc.bankAccount =
            bankAccountList[0]; // Pick the first item in the list
      }
      isLoading = false;
      if (mounted) setState(() {});
    }

    if (bankAccountList.isEmpty) {
      if (mounted) {
        setState(() {
          noItemInList = true;
        });
      }
    }
  }

  Widget buildBankList(BuildContext context) {
    return noItemInList
        ? NoItemInList(
            msg: AppLocalization.of(context)!.noResultFound,
            isResult: true,
          )
        : ListView.builder(
            padding: const EdgeInsets.all(4),
            shrinkWrap: true,
            itemCount: bankAccountList.length + 1,
            itemBuilder: (BuildContext context, int index) {
              if (index == bankAccountList.length) {
                return _buildIndicatorForBankList();
              } else {
                return _getSlidableWithLists(
                  context,
                  bankAccountTile(account: bankAccountList[index]),
                  bankAccountList[index],
                );
              }
            },
            controller: _scrollController,
          );
  }

  Widget _buildIndicatorForBankList() {
    return Center(
      child: isLoading
          ? CircularProgressIndicator(
              strokeWidth: 2.5,
              valueColor: AlwaysStoppedAnimation(navyBlue),
              backgroundColor: Colors.transparent,
            )
          : Container(),
    );
  }

  Widget bankAccountTile({required BankAccount account}) {
    String? imageUrl;
    if (account.bankAvatar == "") {
      imageUrl = getInitials(account.bankName.toString()).toUpperCase();
    } else {
      final String? url = account.bankAvatar;

      imageUrl = url!.replaceAll('https//', 'https://');
    }

    return GestureDetector(
      onTap: () {
        selectedBank = account;
        bankAccountBloc.bankAccount = account;
        if (mounted) setState(() {});
        Navigator.pop(context);
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
        shadowColor: boxShadowTwo,
        elevation: 0,
        child: Container(
          decoration: decorateBox(),
          child: ListTile(
            dense: account.isDefault! ? true : false,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                getAccountName(account: account),
                getAccountNumber(account: account)
              ],
            ),
            subtitle: getBankName(account: account),
            leading: GestureDetector(
              onTap: () {
                Navigator.of(context)
                    .pushNamed("/photo-viewer", arguments: imageUrl);
              },
              child: checkBankImage(account),
            ),
          ),
        ),
      ),
    );
  }

  Widget getBankName({required BankAccount account}) {
    if (account.isDefault!) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            trimString(account.bankName!),
            maxLines: 1,
            style: TextStyle(
                color: darkGrey, fontWeight: FontWeight.normal, fontSize: 15),
          ),
        ],
      );
    }
    return Text(
      appendStringDot(account.bankName!, 15),
      style: TextStyle(
          color: darkGrey, fontWeight: FontWeight.normal, fontSize: 15),
    );
  }

  Widget getAccountName({required BankAccount account}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const SizedBox(
          height: 8,
        ),
        Text(
          appendStringDot(account.accountName!, 20),
          maxLines: 1,
          style: TextStyle(
              color: blackFont, fontWeight: FontWeight.bold, fontSize: 15),
        ),
      ],
    );
  }

  Widget getAccountNumber({required BankAccount account}) {
    if (account.isDefault!) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const SizedBox(
            height: 4,
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                getFormattedAccountNumber(
                    accountNumber: account.accountNumber!.toString()),
                style: TextStyle(color: darkGrey, fontSize: 12),
              ),
              Text(
                AppLocalization.of(context)!.defaultMsg,
                style: TextStyle(color: darkGrey, fontSize: 12),
              ),
            ],
          ),
          // SizedBox(
          //   height: 2,
          // ),
        ],
      );
    }
    return Column(
      children: [
        const SizedBox(
          height: 8,
        ),
        Text(
          getFormattedAccountNumber(
              accountNumber: account.accountNumber!.toString()),
          style: TextStyle(color: darkGrey, fontSize: 12),
        ),
      ],
    );
  }

  Widget checkBankImage(BankAccount account) {
    final String? url = account.bankAvatar;

    final String imageUrl = url!.replaceAll('https//', 'https://');
    if (account.bankAvatar == "") {
      return CircleAvatar(
        backgroundColor: navyBlue,
        radius: 25,
        child: Text(
          getInitials(account.bankName!).toUpperCase(),
          style: TextStyle(color: white, fontWeight: FontWeight.w700),
        ),
      );
    } else {
      return ClipOval(
        child: CachedNetworkImage(
          imageUrl: imageUrl,
          height: 48,
          width: 48,
          colorBlendMode: BlendMode.darken,
          fit: BoxFit.cover,
          filterQuality: FilterQuality.high,
          placeholder: (context, url) => imageUrl == ""
              ? Icon(
                  Icons.account_balance,
                  size: 45,
                  color: navyBlue,
                )
              : CircularLoadingIndicator(),
          errorWidget: imageErrorWidget,
        ),
      );
    }
  }

  void searchBankList() {
    // Perform the search and update the bankAccountList
    count = 0;
    next = "";
    previous = "";
    bankAccountList = [];
    if (mounted) setState(() {});
    getList(searchText);
  }

  void clearSearchAndAllBanks() {
    bankAccountList = bankAccountListStore;
    searchText = '';
    searchItemTextController.text = '';
  }

  // refresh the list when lifecycle called onResume method
  void _onRefresh() async {
    //check network connectivity and if true then refresh the list
    if (await checkConnection(context)) {
      count = 0;
      next = "";
      previous = "";
      bankAccountList = [];
      getList(searchText);
      _refreshController.refreshCompleted();
    } else {
      _refreshController.refreshCompleted();
    }
  }

  Widget _getSlidableWithLists(
      BuildContext context, Widget bankAccountTile, BankAccount account) {
    return Slidable(
      startActionPane: ActionPane(
        motion: const BehindMotion(),
        extentRatio: 0.25,
        children: listActionSlideActions(account: account),
      ),
      endActionPane: ActionPane(
        motion: const BehindMotion(),
        extentRatio: 0.25,
        children: listSecondaryActions(account: account),
      ),
      child: VerticalListItem(bankAccountTile),
    );
  }

  List<Widget> listSecondaryActions({required BankAccount account}) {
    return [
      SlideActionButton(
        borderRadius: BorderRadius.circular(5),
        padding: EdgeInsets.zero,
        backgroundColor: naturalGreen,
        icon: Icons.device_hub,
        onPressed: account.isDefault!
            ? (context) {
                showToast(
                    message: AppLocalization.of(context)!
                        .thisAccountIsAlreadyDefaultAccount);
              }
            : (context) {
                updateBankAccount(account);
              },
        label: account.isDefault!
            ? AppLocalization.of(context)!.defaultMsg
            : AppLocalization.of(context)!.makeDefault,
      ),
    ];
  }

  List<Widget> listActionSlideActions({BankAccount? account}) {
    return [
      SlideActionButton(
        borderRadius: BorderRadius.circular(5),
        padding: EdgeInsets.zero,
        backgroundColor: mateRed,
        icon: SlydoAppIcon.remove,
        onPressed: (con) {
          deleteBankAccount(account);
        },
        label: AppLocalization.of(context)!.delete,
      ),
    ];
  }

  void deleteBankAccount(BankAccount? account) {
    {
      if (bankAccountList.length == 1) {
        showToast(
            message:
                AppLocalization.of(context)!.youCanNotDeleteOnlyBankAccount);
      } else {
        _auth.deleteBankAccount(account!.uuid!).then((value) {
          if (value) {
            showToast(
                message:
                    AppLocalization.of(context)!.accountDeletedSuccessfully);
            if (bottomSheetStateSetterGlobal != null && bottomSheetMounted) {
              bottomSheetStateSetterGlobal!(() {});
            }
            if (mounted) setState(() {});
            _onRefresh();
          } else {
            showToast(
                message: AppLocalization.of(context)!.accountIsNotDeleted);
          }
        }).catchError((error) {
          showToast(message: error.toString());
        });
      }
    }
  }

  void updateBankAccount(BankAccount account) {
    final Map data = {
      "uuid": account.uuid,
      "customer_username": userBloc.user.userName,
      "bank": account.bankName,
      "account_name": account.accountName,
      "account_number": account.accountNumber,
      "is_default": true,
    };
    _auth.updateBankAccount(data).then((value) {
      if (value) {
        showToast(
            message: AppLocalization.of(context)!.accountUpdatedSuccessfully);
        _auth.getBankAccounts().then((accounts) {
          final BankAccountBloc bankAccountBloc =
              Provider.of<BankAccountBloc>(context, listen: false);
          bankAccountBloc.bankAccount = accounts[0];
          if (bottomSheetStateSetterGlobal != null && bottomSheetMounted) {
            bottomSheetStateSetterGlobal!(() {});
          }
          if (mounted) setState(() {});
        });
        _onRefresh();
      } else {
        showToast(message: AppLocalization.of(context)!.accountIsNotUpdated);
      }
    }).catchError((error) {
      showToast(message: error.toString());
    });
    _onRefresh();
  }
}
