import 'package:Slydo/screens/more_apps/payment_and_banking/payment_and_banking_auth.dart';
import 'package:Slydo/utils/colors.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/LoadingIndicator.dart';
import 'package:Slydo/widget/curved_btn.dart';
import 'package:Slydo/widget/customized_textform_field.dart';
import 'package:flutter/material.dart';
import 'package:toast/toast.dart';

// ignore: must_be_immutable
class AddBvnNumber extends StatefulWidget {
  @override
  _AddBvnNumberState createState() => _AddBvnNumberState();
}

class _AddBvnNumberState extends State<AddBvnNumber> {
  final _formKeyTwo = GlobalKey<FormState>();

  TextEditingController bvnNumberController;

  @override
  void initState() {
    bvnNumberController = TextEditingController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
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
      centerTitle: false,
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
        "Add BVN number",
        style: TextStyle(
            color: blackFont, fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget scaffoldBody() {
    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.only(left: 16, right: 16, top: 16),
        child: Form(
          key: _formKeyTwo,
          child: Column(
            children: <Widget>[
              addBvnNumberTextField(),
              SizedBox(
                height: 28,
              ),
            ],
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

  Widget getSubmitButton() {
    return CurvedButton(
      onPressed: onSubmit,
      backgroundColor: navyBlue,
      textColor: Colors.white,
      text: "Topup",
    );
  }

  void onSubmit() async {
    //for closing the keypad if it is open
    FocusScope.of(context).unfocus();

    showDialog(
        context: context,
        builder: (context) => Center(child: CircularLoadingIndicator()));

    if (_formKeyTwo.currentState.validate()) {
      var data = {"bvn_number": bvnNumberController.text};
      PaymentAndBankingAuth()
          .confirmTopUpWithReferenceNumber(data)
          .then((value) {
        if (value) {
          Navigator.pop(context);
          Navigator.popUntil(context, ModalRoute.withName("/dashboard"));
        }
      }).catchError((e) {
        Navigator.pop(context);
        debugPrint(e.toString());
        Toast.show(e, context, gravity: Toast.BOTTOM, textColor: Colors.white);
      });
    } else {
      Navigator.pop(context);
    }
  }

  Widget addBvnNumberTextField() {
    return CustomizedTextFormField(controller: bvnNumberController);
  }

  Widget userTopUpNote() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        "Please tick the box below after you have transferred payment.",
        style: TextStyle(
            fontSize: 12, color: mateRed, fontWeight: FontWeight.w600),
      ),
    );
  }
}
