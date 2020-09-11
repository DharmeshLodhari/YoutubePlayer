import 'package:Slydo/data/currency.dart';
import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/services/auth.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/LoadingIndicator.dart';
import 'package:Slydo/widget/customized_dropdown_field.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:toast/toast.dart';

import '../../utils/colors.dart';

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
    _auth.getPaymentCategory().then((result) {
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
    _auth.getUserProfileUpgradeDetails().then((result) {
      if (mounted) {
        setState(() {
          List profileUpgradeTypeAndPrice = result["results"]["data"];
          profileUpgradeTypeAndPrice.forEach((data) {
            type.add({"name": data["name"], "price": data["price"]});
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
    // return Column(
    //   crossAxisAlignment: CrossAxisAlignment.start,
    //   children: <Widget>[
    //     Text("Account Type"),
    //     SizedBox(
    //       height: 4,
    //     ),
    //     Card(
    //       margin: EdgeInsets.all(0),
    //       child: Container(
    //         padding: EdgeInsets.all(8),
    //         width: double.infinity,
    //         child: DropdownButton<String>(
    //           isExpanded: true,
    //           underline: Divider(
    //             color: Colors.transparent,
    //           ),
    //           hint: Row(
    //             children: <Widget>[
    //               Padding(
    //                 padding: const EdgeInsets.only(left: 8.0),
    //                 child: Icon(
    //                   Icons.supervised_user_circle,
    //                   color: Colors.grey[600],
    //                 ),
    //               ),
    //               Padding(
    //                 padding: const EdgeInsets.only(left: 16.0),
    //                 child: Text("Profile Type"),
    //               ),
    //             ],
    //           ),
    //           value: selectedType,
    //           onChanged: (value) {
    //             setState(() {
    //               selectedType = value;
    //               type.forEach((element) {
    //                 if (element["name"] == selectedType) {
    //                   price = element["price"];
    //                 }
    //               });
    //             });
    //           },
    //           items: type.map((type) {
    //             return DropdownMenuItem<String>(
    //               value: type["name"],
    //               child: Padding(
    //                 padding: const EdgeInsets.fromLTRB(8.0, 0, 0, 0),
    //                 child: Text(
    //                   type["name"],
    //                   style: TextStyle(color: Colors.black),
    //                 ),
    //               ),
    //             );
    //           }).toList(),
    //         ),
    //       ),
    //     ),
    //   ],
    // );
    return CustomizedDropDownField(
      title: "Account type",
      child: DropdownButton<String>(
        isExpanded: true,
        underline: Divider(
          color: Colors.transparent,
        ),
        hint: Row(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Icon(
                Icons.supervised_user_circle,
                color: Colors.grey[600],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 16.0),
              child: Text("Profile Type"),
            ),
          ],
        ),
        value: selectedType,
        onChanged: (value) {
          setState(() {
            selectedType = value;
            type.forEach((element) {
              if (element["name"] == selectedType) {
                price = element["price"];
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
                style: TextStyle(color: Colors.black),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget getBusinessName() {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text("Business Name"),
          SizedBox(
            height: 4,
          ),
          TextFormField(
            autofocus: false,
            obscureText: false,
            keyboardType: TextInputType.text,
            decoration: InputDecoration(
                prefixIcon: Icon(Icons.person),
                fillColor: Colors.white,
                filled: true,
                hintText: "Enter Your Business name",
                labelStyle: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                ),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(4)),
                    borderSide: BorderSide(
                        width: 1,
                        color: Colors.green,
                        style: BorderStyle.solid))),
            validator: (val) => val.length < 5
                ? AppLocalization.of(context).validationTextMessage
                : null,
            onChanged: (val) {
              if (mounted) {
                setState(() {
                  businessName = val;
                });
              }
            },
          ),
        ]);
  }

  Widget getCategoryField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text("Default Payment Type "),
        SizedBox(
          height: 4,
        ),
        Card(
          margin: EdgeInsets.all(0),
          child: Container(
            padding: EdgeInsets.all(8),
            width: double.infinity,
            child: DropdownButton<String>(
              isExpanded: true,
              underline: Divider(
                color: Colors.transparent,
              ),
              hint: Row(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Icon(
                      Icons.category,
                      color: Colors.grey[600],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 16.0),
                    child: Text(AppLocalization.of(context).category),
                  ),
                ],
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
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget submitButton() {
    return MaterialButton(
      minWidth: double.infinity,
      height: 42,
      child: Text(
        "Submit",
        style: TextStyle(color: Colors.white, fontSize: 16),
      ),
      color: darkBlue(),
      onPressed: () {
        var data = {
          "account_type": selectedType.toString().trim(),
          "business_name": businessName.toString().trim(),
          "default_payment_type": selectedCategory.toString().trim(),
        };
        _auth.upgradeUserProfile(data).then((result) {
          if (result) {
            Toast.show(
                "Request sent !! Your Profile Will Be Updated Soon !!", context,
                textColor: Colors.white, backgroundColor: darkBlue());

            _auth
                .authenticate(userBloc.user.phoneNumber, userBloc.user.password)
                .then((newUser) {
              print(newUser.type);
              if (mounted) {
                setState(() {
                  userBloc.user = newUser;
                });
              }

              _auth.fetchCustomerProfile(userBloc.user.userName).then((user) {
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
    );
  }

  Widget getAmount() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text("Amount To Be Paid"),
        SizedBox(
          height: 4,
        ),
        Card(
          margin: EdgeInsets.symmetric(horizontal: 0),
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  "Price:",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: darkBlue(),
                  ),
                ),
                Row(
                  children: <Widget>[
                    Text(
                      worldCurrencies[userBloc.user.currency] + " ",
                      style: TextStyle(
                        fontFamily: "Roboto",
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: darkBlue(),
                      ),
                    ),
                    Text(
                      price,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: darkBlue(),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
