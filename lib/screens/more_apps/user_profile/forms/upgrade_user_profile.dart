import 'package:Slydo/data/currency.dart';
import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/screens/more_apps/payment_and_banking/payment_and_banking_auth.dart';
import 'package:Slydo/services/auth.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/LoadingIndicator.dart';
import 'package:Slydo/widget/curved_btn.dart';
import 'package:Slydo/widget/customized_dropdown_field.dart';
import 'package:Slydo/widget/customized_passcode_sheet/bottomsheet_passcode.dart';
import 'package:Slydo/widget/customized_textform_field.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:toast/toast.dart';

import '../../../../utils/colors.dart';
import '../user_auth.dart';

class UpgradeUserProfile extends StatefulWidget {
  @override
  _UpgradeUserProfileState createState() => _UpgradeUserProfileState();
}

class _UpgradeUserProfileState extends State<UpgradeUserProfile> {
  final _formKey = GlobalKey<FormState>();

  var type = List();
  var selectedType;
  var price = "0";
  List<String> paymentCategories = List();
  bool isLoading = true;
  var selectedCategory;

  String businessName;

  final _auth = AuthService();

  final _upgradeProfileScaffold = GlobalKey<ScaffoldState>();

  UserBloc userBloc;

  @override
  void initState() {
    fetchCategory();
    setState(() {
      isLoading = true;
    });
    fetchUserProfileUpgradeTypeAndPrice();
    super.initState();
  }

  void fetchCategory() async {
    PaymentAndBankingAuth().getPaymentCategory().then((result) {
      if (mounted) {
        setState(() {
          List categoriesList = result["results"]["data"];
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
          List profileUpgradeTypeAndPrice = result;
          profileUpgradeTypeAndPrice.forEach((data) {
            type.add({"name": data["account_type"], "price": data["price"]});
          });
          isLoading = false;
        });
      }
    });
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
        appBar: appBar(),
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
              height: MediaQuery.of(context).size.height -
                  (AppBar().preferredSize.height +
                      MediaQuery.of(context).padding.top),
              width: MediaQuery.of(context).size.width,
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Column(
                children: [
                  Expanded(
                    flex: 8,
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: <Widget>[
                          getUpgradeProfileType(),
                          flexibleSpace(),
                          getBusinessName(),
                          flexibleSpace(),
                          getCategoryField(),
                          flexibleSpace(),
                          getAmount(),
                          flexibleSpace(),
                          submitButton(),
                          flexibleSpace(),
                        ],
                      ),
                    ),
                  ),
                  flexibleSpace(flex: 2)
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
        underline: Divider(
          color: Colors.transparent,
        ),
        icon: Padding(
          padding: EdgeInsets.only(right: 8.0),
          child: Icon(
            Icons.keyboard_arrow_down,
            color: darkGrey,
            size: 20,
          ),
        ),
        hint: Padding(
          padding: const EdgeInsets.only(left: 8.0),
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
      validator: (val) => val == "" ? "Please enter business name" : null,
      onChanged: (val) {
        if (mounted) {
          setState(() {
            businessName = val;
          });
        }
      },
    );
  }

  Widget getCategoryField() {
    return CustomizedDropDownField(
      title: "Default payment type",
      child: DropdownButton<String>(
        isExpanded: true,
        underline: Divider(
          color: Colors.transparent,
        ),
        icon: Padding(
          padding: EdgeInsets.only(right: 8.0),
          child: Icon(
            Icons.keyboard_arrow_down,
            color: darkGrey,
            size: 20,
          ),
        ),
        hint: Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: Text(AppLocalization.of(context).category),
        ),
        value: selectedCategory,
        onChanged: (String value) {
          setState(() {
            selectedCategory = value;
          });
        },
        items: paymentCategories.map((String category) {
          return DropdownMenuItem<String>(
            value: category,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8.0, 0, 0, 0),
              child: Text(
                category,
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

  void onSubmit() {
    var data = {
      "account_type": selectedType.toString().trim(),
      "business_name": businessName.toString().trim(),
      "default_payment_type": selectedCategory.toString().trim(),
    };
    if (validateDropdown()) {
      if (_formKey.currentState.validate()) {
        BottomSheetPassCode(
            context: context,
            isValidCallback: () {
              showDialog(
                  context: context,
                  builder: (context) =>
                      Center(child: CircularLoadingIndicator()));
              UserAuth().upgradeUserProfile(data).then((result) {
                if (result) {
                  Toast.show(
                      "Request sent !! Your Profile Will Be Updated Soon !!",
                      context,
                      textColor: Colors.white,
                      backgroundColor: darkBlue());

                  _auth
                      .authenticate(
                          userBloc.user.phoneNumber, userBloc.user.password)
                      .then((newUser) {
                    if (mounted) {
                      setState(() {
                        userBloc.user = newUser;
                      });
                    }

                    UserAuth()
                        .fetchCustomerProfile(userBloc.user.userName)
                        .then((user) {
                      Navigator.pop(context);
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/profile',
                          arguments: {"searchedUser": user});
                    });
                  });
                } else {
                  Toast.show("Something Went Wrong !!", context,
                      textColor: Colors.white, backgroundColor: darkBlue());
                }
              });
            },
            cancelCallBack: () {
              Navigator.pop(context);
              _upgradeProfileScaffold.currentState.showSnackBar(SnackBar(
                content: Text(AppLocalization.of(context).invalidPassword),
              ));
            });
      }
    }
  }

  bool validateDropdown() {
    if (selectedType == null) {
      Toast.show("Please select account type", context,
          backgroundColor: blackFont,
          textColor: Colors.white,
          gravity: Toast.BOTTOM);
      return false;
    } else if (selectedCategory == null) {
      Toast.show("Please select default payment type", context,
          backgroundColor: blackFont,
          textColor: Colors.white,
          gravity: Toast.BOTTOM);
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
        SizedBox(
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
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                SizedBox(
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
                          worldCurrencies[userBloc.user.currency],
                          style: TextStyle(
                              fontFamily: "Roboto",
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: blackFont),
                        ),
                        Text(
                          price.toString(),
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: blackFont),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(
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
