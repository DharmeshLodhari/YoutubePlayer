import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/screens/more_apps/shopping/shopping_auth.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/curved_btn.dart';
import 'package:Slydo/widget/customized_textform_field.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../utils/colors.dart';

class AddOrEditUserBioScreen extends StatefulWidget {
  @override
  _AddOrEditUserBioScreenState createState() => _AddOrEditUserBioScreenState();
}

class _AddOrEditUserBioScreenState extends State<AddOrEditUserBioScreen> {
  final _auth = ShoppingAuthService();
  final _formKey = GlobalKey<FormState>();

  UserBloc userBloc;

  var productName;

  var productDescription;

  var productManufacturer;

  @override
  void deactivate() {
    super.deactivate();
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
        "Edit Bio",
        style: TextStyle(
            color: blackFont, fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget scaffoldBody() {
    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Center(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                SizedBox(height: 10),
                addBioField(),
                SizedBox(
                  height: 10,
                ),
                addAddressField(),
                SizedBox(
                  height: 10,
                ),
                addContactNumberField(),
                SizedBox(
                  height: 10,
                ),
                SizedBox(height: 40),
                getSubmitButton(),
                SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget showBackArrow() {
    return IconButton(
      icon: Icon(Icons.arrow_back_ios),
      onPressed: () {
        Navigator.pop(context);
      },
    );
  }

  Widget addAddressField() {
    return CustomizedTextFormField(
      labelText: "Address",
      maxLines: 3,
      validator: (val) {
        if (val.isNotEmpty) {
          return null;
        }
        return AppLocalization.of(context).pleaseEnterProductName;
      },
      onChanged: (val) {
        productName = val;
      },
    );
  }

  Widget addBioField() {
    return CustomizedTextFormField(
      maxLines: 5,
      textCapitalization: TextCapitalization.sentences,
      labelText: "Bio",
      onChanged: (val) {
        productDescription = val;
      },
    );
  }

  Widget addContactNumberField() {
    return CustomizedTextFormField(
      labelText: "Contact number",
      keyboardType: TextInputType.number,
      validator: (val) {
        if (val.isNotEmpty) {
          return null;
        }
        return AppLocalization.of(context).pleaseEnterManufacturerName;
      },
      onChanged: (val) {
        productManufacturer = val;
      },
    );
  }

  Widget getSubmitButton() {
    return CurvedButton(
      onPressed: () async {
        FocusScope.of(context).unfocus();
        updateBio();
      },
      backgroundColor: navyBlue,
      textColor: Colors.white,
      text: "Update Bio",
    );
  }

  void updateBio() {
    if (_formKey.currentState.validate()) {
      // _auth.addProduct(product).then((value) {
      //   Navigator.pop(context);
      //   Toast.show(
      //     AppLocalization.of(context).productAddedSuccessfully,
      //     context,
      //     textColor: Colors.white,
      //     backgroundColor: darkBlue(),
      //     duration: 3,
      //   );
      // }).catchError((error) {
      //   debugPrint(error.toString());
      //   Toast.show(error.toString(), context,
      //       textColor: Colors.white, backgroundColor: darkBlue());
      // });

    }
  }

  @override
  void dispose() {
    super.dispose();
  }
}
