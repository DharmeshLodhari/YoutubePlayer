import 'package:Slydo/data/currency.dart';
import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/services/auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:toast/toast.dart';

import '../colors.dart';

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
        backgroundColor: lightBlue(),
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          backgroundColor: darkBlue(),
          title: Text("Upgrade Profile"),
          elevation: 0.0,
        ),
        body: isLoading
            ? Center(
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation(Colors.white),
                  backgroundColor: lightBlue(),
                ),
              )
            : SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Form(
                  key: _formKey,
                  child: Container(
                    color: lightBlue(),
                    padding: EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      children: <Widget>[
                        SizedBox(
                          height: 40,
                        ),
                        getUpgradeProfileType(),
                        SizedBox(
                          height: 15,
                        ),
                        getBusinessName(),
                        SizedBox(
                          height: 15,
                        ),
                        getCategoryField(),
                        SizedBox(
                          height: 15,
                        ),
                        getAmount(),
                        SizedBox(
                          height: 15,
                        ),
                        submitButton()
                      ],
                    ),
                  ),
                ),
              ),
      ),
    );
  }

  Widget getUpgradeProfileType() {
    return Card(
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
      ),
    );
  }

  Widget getBusinessName() {
    return TextFormField(
      autofocus: false,
      obscureText: false,
      keyboardType: TextInputType.text,
      decoration: InputDecoration(
          prefixIcon: Icon(Icons.person),
          fillColor: Colors.white,
          filled: true,
          hintText: "Business name",
          labelStyle: TextStyle(
            color: Colors.black,
            fontSize: 16,
          ),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(4)),
              borderSide: BorderSide(
                  width: 1, color: Colors.green, style: BorderStyle.solid))),
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
    );
  }

  Widget getCategoryField() {
    return Card(
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
    );
  }

  Widget submitButton() {
    return MaterialButton(
      minWidth: double.infinity,
      height: 40,
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
            Navigator.pop(context);
            Toast.show(
                "Request sent !! Your Profile Will Be Updated Soon !!", context,
                textColor: Colors.white, backgroundColor: darkBlue());
          } else {
            Toast.show("Request Fail Try After Some Time", context,
                textColor: Colors.white, backgroundColor: darkBlue());
          }
        });
      },
    );
  }

  Widget getAmount() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: Text(
            "Price:",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
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
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Text(
                price,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
