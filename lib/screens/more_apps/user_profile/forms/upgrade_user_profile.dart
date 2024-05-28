import 'package:Slydo/data/currency.dart';
import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/screens/more_apps/payment_and_banking/payment_and_banking_auth.dart';
import 'package:Slydo/services/auth.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/curved_btn.dart';
import 'package:Slydo/widget/customized_dropdown_field.dart';
import 'package:Slydo/widget/customized_passcode_sheet/bottomsheet_passcode.dart';
import 'package:Slydo/widget/customized_textform_field.dart';
import 'package:Slydo/widget/loading_indicator.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../user_auth.dart';

class UpgradeUserProfile extends StatefulWidget {
  @override
  _UpgradeUserProfileState createState() => _UpgradeUserProfileState();
}

class _UpgradeUserProfileState extends State<UpgradeUserProfile> {
  final _formKey = GlobalKey<FormState>();

  List type = [];
  String? selectedType;
  String? price = "0";
  List<String?> paymentCategories = [];
  bool isLoading = true;
  String? selectedCategory;

  String? businessName;

  final _auth = AuthService();

  final _upgradeProfileScaffold = GlobalKey<ScaffoldState>();
  final _upgradeMessengerProfileScaffold = GlobalKey<ScaffoldMessengerState>();

  late UserBloc userBloc;
  bool hideAmountDropDown = false;
  double? accountBalance;

  @override
  void initState() {
    getAccountBalance();
    fetchCategory();
    setState(() {
      isLoading = true;
    });
    fetchUserProfileUpgradeTypeAndPrice();
    super.initState();
  }

  Future<void> getAccountBalance() async {
    await PaymentAndBankingAuth().getAccountBalance().then((value) {
      final data = value!;
      final spendableBalance = data["spendable_balance"];

      debugPrint("spendableBalance $spendableBalance");
      accountBalance = spendableBalance / 100;
      if (mounted) setState(() {});
    });
  }

  void fetchCategory() async {
    await PaymentAndBankingAuth().getPaymentCategory().then((result) {
      if (mounted) {
        setState(() {
          final List categoriesList = result["results"]["data"];
          categoriesList.forEach((data) {
            paymentCategories.add(data["name"]);
          });
          isLoading = false;
        });
      }
    });
  }

  void fetchUserProfileUpgradeTypeAndPrice() async {
    UserAuth().getUserProfileUpgradeDetails().then((result) {
      if (mounted) {
        setState(() {
          final List profileUpgradeTypeAndPrice = result!;
          profileUpgradeTypeAndPrice.forEach((data) {
            type.add({"name": data["account_type"], "price": data["price"]});
          });
          isLoading = false;

          hideAmountTobePaidDropDown();
        });
      }
    });
  }

  void hideAmountTobePaidDropDown() {
    hideAmountDropDown = false;
    type.forEach((element) {
      if (element["price"].toString() == "0") {
        hideAmountDropDown = true;
      }
    });
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    userBloc = Provider.of<UserBloc>(context);
    return WillPopScope(
      onWillPop: () async {
        return true;
      },
      child: Scaffold(
        key: _upgradeProfileScaffold,
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
          Navigator.pop(context);
        },
      ),
      title: Text(
        "Upgrade profile",
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
            scrollDirection: Axis.vertical,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Column(
                children: [
                  Form(
                    key: _formKey,
                    child: Column(
                      children: <Widget>[
                        getUpgradeProfileType(),
                        const SizedBox(
                          height: 16,
                        ),
                        getBusinessName(),
                        const SizedBox(
                          height: 16,
                        ),
                        getCategoryField(),
                        if (!hideAmountDropDown)
                          Column(
                            children: [
                              const SizedBox(
                                height: 16,
                              ),
                              getAmount(),
                            ],
                          )
                        else
                          Container(),
                        const SizedBox(
                          height: 48,
                        ),
                        submitButton(),
                        const SizedBox(
                          height: 16,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
  }

  Widget getUpgradeProfileType() {
    return CustomizedDropDownField(
      title: "Account type",
      child: DropdownButton<String>(
        isExpanded: true,
        underline: const Divider(
          color: Colors.transparent,
        ),
        icon: Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: Icon(
            Icons.keyboard_arrow_down,
            color: darkGrey,
            size: 20,
          ),
        ),
        hint: const Padding(
          padding: EdgeInsets.only(left: 8.0),
          child: Text("Profile type"),
        ),
        value: selectedType,
        onChanged: (value) {
          setState(() {
            selectedType = value;
            type.forEach((element) {
              if (element["name"] == selectedType) {
                price = element["price"].toString();
              }
            });
          });
        },
        items: type.map((type) {
          return DropdownMenuItem<String>(
            value: type["name"],
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8.0, 0, 0, 0),
              child: Text(
                type["name"],
                style: TextStyle(
                    color: blackFont,
                    fontSize: 16,
                    fontWeight: FontWeight.w600),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget getBusinessName() {
    return CustomizedTextFormField(
      keyboardType: TextInputType.text,
      labelText: "Business name",
      validator: businessNameValidator,
      onChanged: (val) {
        if (mounted) {
          setState(() {
            businessName = val;
          });
        }
      },
    );
  }

  String? businessNameValidator(String data) {
    if (data == "") {
      return "Please enter business name";
    }

    return checkSlydoName(data);
  }

  Widget getCategoryField() {
    return CustomizedDropDownField(
      title: "Default payment type",
      child: DropdownButton<String>(
        isExpanded: true,
        underline: const Divider(
          color: Colors.transparent,
        ),
        icon: Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: Icon(
            Icons.keyboard_arrow_down,
            color: darkGrey,
            size: 20,
          ),
        ),
        hint: Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: Text(AppLocalization.of(context)!.category),
        ),
        value: selectedCategory,
        onChanged: (String? value) {
          setState(() {
            selectedCategory = value;
          });
        },
        items: paymentCategories.map((String? category) {
          return DropdownMenuItem<String>(
            value: category,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8.0, 0, 0, 0),
              child: Text(
                category!,
                style: TextStyle(
                    color: blackFont,
                    fontSize: 16,
                    fontWeight: FontWeight.w600),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget submitButton() {
    return CurvedButton(
      onPressed: onSubmit,
      backgroundColor: navyBlue,
      textColor: Colors.white,
      text: "Submit",
    );
  }

  void onSubmit() async {
    if (FocusScope.of(context).hasFocus) {
      FocusScope.of(context).unfocus();
    }

    await Future.delayed(const Duration(milliseconds: 500));

    final data = {
      "account_type": selectedType.toString().trim(),
      "business_name": businessName.toString().trim(),
      "default_payment_type": selectedCategory.toString().trim(),
    };

    if (validateDropdown()) {
      if (_formKey.currentState!.validate()) {
        debugPrint("==> ${(int.parse(price ?? "0") / 100)}");
        if (accountBalance != null &&
            accountBalance! > (int.parse(price ?? "0") / 100)) {
          BottomSheetPassCode(
              context: context,
              isValidCallback: () async {
                showDialog(
                    context: context,
                    builder: (context) =>
                        Center(child: CircularLoadingIndicator()));
                await UserAuth().upgradeUserProfile(data).then((result) async {
                  if (result) {
                    await _auth
                        .authenticate(
                            userBloc.user.phoneNumber, userBloc.user.password)
                        .then((newUser) async {
                      userBloc.user = newUser;
                      if (mounted) setState(() {});

                      await UserAuth()
                          .fetchCustomerProfile(userBloc.user.userName)
                          .then((user) {
                        showToast(
                            message: "Your profile upgrade was successful.");

                        Navigator.pop(context);
                        Navigator.pop(context);
                        Navigator.pushNamed(context, '/profile', arguments: {
                          "searchedUserName": user.userName,
                          "index": 0
                        });
                      });
                    });
                  } else {
                    Navigator.pop(context);
                    showToast(message: "Something Went Wrong !!");
                  }
                });
              },
              cancelCallBack: () {
                Navigator.pop(context);
                _upgradeMessengerProfileScaffold.currentState
                    ?.showSnackBar(SnackBar(
                  content: Text(AppLocalization.of(context)!.invalidPassword),
                ));
              });
        } else {
          showToast(
              message:
                  "Your slydo wallet does not have enough amount to update your profile !!");
        }
      }
    }
  }

  bool validateDropdown() {
    if (selectedType == null) {
      showToast(message: "Please select account type");
      return false;
    } else if (selectedCategory == null) {
      showToast(message: "Please select default payment type");
      return false;
    }

    return true;
  }

  Widget getAmount() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Amount to be paid",
          style: TextStyle(color: darkGrey, fontSize: 14),
        ),
        const SizedBox(
          height: 8,
        ),
        Card(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          color: Colors.white,
          elevation: 1,
          margin: EdgeInsets.zero,
          shadowColor: boxShadow,
          child: Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: boxShadow)),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const SizedBox(
                  height: 18,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      "Price:",
                      style: TextStyle(fontSize: 14, color: blackFont),
                    ),
                    Row(
                      children: [
                        Text(
                          worldCurrencies[userBloc.user.currency!]!,
                          style: TextStyle(
                              fontFamily: "Inter",
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: blackFont),
                        ),
                        Text(
                          moneyDisplayNormalizer(int.parse(price ?? "0")),
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: blackFont),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(
                  height: 18,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
