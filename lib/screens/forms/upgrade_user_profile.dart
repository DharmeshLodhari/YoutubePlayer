import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/services/auth.dart';
import 'package:flutter/material.dart';

import '../colors.dart';

class UpgradeUserProfile extends StatefulWidget {
  @override
  _UpgradeUserProfileState createState() => _UpgradeUserProfileState();
}

class _UpgradeUserProfileState extends State<UpgradeUserProfile> {
  final _formKey = GlobalKey<FormState>();

  var type = ["Business", "Developer"];
  var selectedType = "Business";
  List<String> paymentCategories = List();
  var selectedCategory;

  String businessName;

  final _auth = AuthService();

  @override
  Widget build(BuildContext context) {
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
        body: SingleChildScrollView(
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
                    height: 10,
                  ),
                  getUpgradeProfileType(),
                  SizedBox(
                    height: 10,
                  ),
                  getBusinessName(),
                  SizedBox(
                    height: 10,
                  ),
                  getCategoryField(),
                  SizedBox(
                    height: 10,
                  ),
                  Text("Price xyz"),
                  SizedBox(
                    height: 10,
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
    return DropdownButtonFormField(
      isExpanded: true,
      decoration: InputDecoration(
        isDense: true,
        fillColor: Colors.white,
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(4)),
          borderSide: BorderSide(
              width: 1, color: Colors.white, style: BorderStyle.solid),
        ),
      ),
      value: selectedType,
      icon: Flexible(
        child: Icon(
          Icons.keyboard_arrow_down,
        ),
        fit: FlexFit.loose,
      ),
      iconSize: 24,
      elevation: 16,
      style: TextStyle(color: Colors.black),
      items: type.map((type) {
        return DropdownMenuItem(
          value: type,
          child: Text(
            type,
            style: TextStyle(color: darkBlue(), fontSize: 18),
          ),
        );
      }).toList(),
    );
  }

  getBusinessName() {
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
      child: Text(
        "Submit",
        style: TextStyle(color: Colors.white),
      ),
      color: darkBlue(),
      onPressed: () {
        var data = {
          "type": selectedType,
          "business_name": businessName,
          "default_category": selectedCategory
        };

        _auth.upgradeUserProfile(data).then((result) {
          if (result) {}
        });
      },
    );
  }
}
