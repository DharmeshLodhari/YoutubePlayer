import 'dart:io';

import 'package:Slydo/constant.dart';
import 'package:Slydo/data/currency.dart';
import 'package:Slydo/data/database_helper.dart';
import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/screens/more_apps/payment_and_banking/models/transactions.dart';
import 'package:Slydo/screens/more_apps/payment_and_banking/models/virtual_account.dart';
import 'package:Slydo/screens/more_apps/payment_and_banking/payment_and_banking_auth.dart';
import 'package:Slydo/screens/more_apps/payment_loading_screen.dart';
import 'package:Slydo/screens/more_apps/user_profile/models/user.dart';
import 'package:Slydo/screens/more_apps/user_profile/screens/user_profile_module_new/profile_template/utils.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/curved_btn.dart';
import 'package:Slydo/widget/customized_passcode_sheet/bottomsheet_passcode.dart';
import 'package:Slydo/widget/customized_textform_field.dart';
import 'package:Slydo/widget/loading_indicator.dart';
import 'package:Slydo/widget/no_item_in_list.dart';
import 'package:Slydo/widget/permission_protection_widget.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class PayoutScreen extends StatefulWidget {
  const PayoutScreen({super.key});

  @override
  State<PayoutScreen> createState() => _PayoutScreenState();
}

class _PayoutScreenState extends State<PayoutScreen> {
  late http.Response response;

  final _auth = PaymentAndBankingAuth();
  final _formKey = GlobalKey<FormState>();

  late UserBloc userBloc;
  late BankAccountBloc bankAccountBloc;

  int? amount = 0;
  String errorMessage = "";
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
  bool noItemInList = false;
  BankAccount? selectedBank;

  @override
  void initState() {
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
              _scrollController.position.maxScrollExtent &&
          _scrollController.position.pixels != 0) {
        getList();
      }
    });

    getBankAccountDetail();

    super.initState();
  }

  void getBankAccountDetail() async {
    isLoading = true;
    setState(() {});
    await getAccountBalance();
    getList();
    virtualAccount = await DatabaseHelper().getVirtualAccount();
    virtualAccount ??= await PaymentAndBankingAuth().getVirtualAccountDetail();
    if (virtualAccount != null) {
      isAccountFound = true;
    }
    isLoading = false;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    userBloc = Provider.of<UserBloc>(context);
    bankAccountBloc = Provider.of<BankAccountBloc>(context);

    return WillPopScope(
      onWillPop: () async {
        return true;
      },
      child: Scaffold(
        backgroundColor: lightGrey,
        resizeToAvoidBottomInset: true,
        appBar: appBar() as PreferredSizeWidget?,
        body: scaffoldBody(),
      ),
    );
  }

  Widget appBar() {
    return AppBar(
      surfaceTintColor: Colors.transparent,
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
          if (isLoading == true) {
            return;
          }
          Navigator.pop(context);
        },
      ),
      title: Text(
        "Cashout",
        style: TextStyle(
            color: blackFont, fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget scaffoldBody() {
    return isLoading
        ? Center(
            child: CircularLoadingIndicator(),
          )
        : SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Column(
                children: [
                  if (isAccountFound)
                    Form(
                      key: _formKey,
                      child: Column(
                        children: <Widget>[
                          getUserBankAccount(),
                          const SizedBox(
                            height: 20,
                          ),
                          displayAmountField(),
                          const SizedBox(
                            height: 20,
                          ),
                          noteForUser(),
                          const SizedBox(
                            height: 40,
                          ),
                          if (canCashOut(amount!, accountBalance!))
                            getSubmitButton()
                          else
                            Center(
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
                                                fontFamily: "Inter",
                                                fontWeight: FontWeight.w600),
                                          )
                                        ])))),
                          const SizedBox(
                            height: 20,
                          ),
                        ],
                      ),
                    )
                  else
                    Center(
                        child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: Text(
                        "Please add Bank Account for cashout.",
                        style: TextStyle(
                            fontSize: 14,
                            color: blackFont,
                            fontWeight: FontWeight.w600),
                      ),
                    )),
                ],
              ),
            ),
          );
  }

  Widget showBackArrow() {
    return IconButton(
      icon: const Icon(Icons.arrow_back_ios),
      onPressed: () {
        Navigator.pop(context);
      },
    );
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
            showAllBankAccount(context);
          },
          child: ListTile(
            dense: true,
            title: Text(
              bankAccountBloc.bankAccount!.bankName!,
              style: TextStyle(
                  color: blackFont, fontWeight: FontWeight.w600, fontSize: 14),
            ),
            subtitle: Text(
              getFormattedAccountNumber(
                  accountNumber:
                      bankAccountBloc.bankAccount!.accountNumber.toString()),
              style: TextStyle(color: darkGrey, fontSize: 12),
            ),
            leading: GestureDetector(
              onTap: () {
                showAllBankAccount(context);
              },
              child: checkBankImage(bankAccountBloc.bankAccount!),
            ),
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
          } catch (e) {}
        }
        return AppLocalization.of(context)!.invalidAmount;
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
      //for closing the keypad if it is open
      FocusScope.of(context).unfocus();

      // duration for close keyboard and open passcode bottomsheet
      await Future.delayed(const Duration(milliseconds: 500));

      if (_formKey.currentState!.validate()) {
        debugPrint(
            "virtualAccount?.accountTier?.dailyCumulativeTransactionLimit! ${virtualAccount?.accountTier?.dailyCumulativeTransactionLimit!}");

        if (amount! <=
            int.parse(
                virtualAccount?.accountTier?.dailyCumulativeTransactionLimit! ??
                    "0")) {
          try {
            final data = {
              "amount": moneyInputNormalizer(amount.toString()),
              "currency": userBloc.user.currency,
              "customer_bank_account":
                  int.tryParse(bankAccountBloc.bankAccount!.uuid!),
            };
            BottomSheetPassCode(
                context: context,
                isValidCallback: () {
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
                              text: 'Payout Processing...',
                              imagePath: 'assets/images/app_logo.png',
                            )),
                  );

                  _auth.accountPayout(data).then((value) {
                    response = value;

                    Navigator.pop(context);

                    if (response.statusCode == 200 ||
                        response.statusCode == 201) {
                      Navigator.pop(context);
                      Navigator.of(context).popAndPushNamed('/payout-list');
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
                        child: Text(
                          'Change Bank Account',
                          style: TextStyle(
                              color: blackFont,
                              fontWeight: FontWeight.bold,
                              fontSize: 15),
                        ),
                      ),
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
                getList();
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
                getList();
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
    return buildBankList();
    // return pullToRefresh();
  }

  void getList() async {
    final Map<String, dynamic>? result =
        await _auth.getBankAccountsPagination(next, previous, "");
    if (result == null) {
      isLoading = false;
      return;
    }
    count = result['count'];
    next = result['next'];
    previous = result['previous'];
    final tempList = result['results'];

    if (mounted) {
      setState(() {
        bankAccountList.addAll(tempList);

        for (BankAccount item in bankAccountList) {
          if (item.isDefault == true) {
            bankAccountBloc.bankAccount = item;
          }
        }
      });
    }

    if (bankAccountList.isEmpty) {
      if (mounted) {
        setState(() {
          noItemInList = true;
        });
      }
    }
  }

  Widget buildBankList() {
    return noItemInList
        ? NoItemInList(
            msg: AppLocalization.of(context)!.noResultFound,
            isResult: true,
          )
        : ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 4),
            //+1 for progressbar
            shrinkWrap: true,
            itemCount: bankAccountList.length + 1,
            itemBuilder: (BuildContext context, int index) {
              if (index == bankAccountList.length) {
                return _buildIndicatorForBankList();
              } else {
                return GestureDetector(
                  onTap: () {
                    selectedBank = bankAccountList[index];
                    bankAccountBloc.bankAccount = bankAccountList[index];

                    if (mounted) setState(() {});
                    Navigator.pop(context);

                    FocusScope.of(context).requestFocus();
                  },
                  child: bankAccountTile(
                    account: bankAccountList[index],
                  ),
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

    return Card(
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
      account.bankName!,
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
          trimString(account.accountName!),
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
}
