import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/utils/extensions.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/curved_btn.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../../../../routes/route_constants.dart';

// ignore: must_be_immutable
class AccountType extends StatefulWidget {
  var arguments;

  AccountType({required this.arguments});

  @override
  _AccountTypeState createState() => _AccountTypeState(arguments: arguments);
}

class _AccountTypeState extends State<AccountType> {
  var arguments;
  String? accountType;

  _AccountTypeState({required this.arguments});

  final _personalDetailFormKey = GlobalKey<FormState>();

  String? phoneNumber = '';
  String password = '';
  String otpCode = '';

  UserBloc? userBloc;

  bool isPersonalAccount = false;
  bool accountTypeChosen = false;
  bool showButton = false;

  @override
  void initState() {
    phoneNumber = arguments['phoneNumber'];
    otpCode = arguments['otpCode'];

    debugPrint('Phone number -> $phoneNumber');
    showButton = true;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    userBloc = Provider.of<UserBloc>(context);
    return WillPopScope(
      onWillPop: () {
        if (FocusScope.of(context).hasFocus) {
          FocusScope.of(context).unfocus();
        }

        Navigator.pop(context);

        return Future.value(false);
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: Icon(
              Icons.keyboard_arrow_left,
              color: navyBlue,
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        body: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  appIcon(),
                  SizedBox(
                    height: 10,
                  ),
                  registerTitle(),
                  SizedBox(height: 40),
                  Form(
                    key: _personalDetailFormKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Account type',
                          style: TextStyle(color: darkGrey, fontSize: 14),
                        ),
                        SizedBox(height: 6),
                        Container(
                          height: 50,
                          padding: const EdgeInsets.symmetric(horizontal: 14.0),
                          decoration: BoxDecoration(
                            border: Border.all(color: dividerColor),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: DropdownButton2(
                            isExpanded: true,
                            value: accountType,
                            dropdownDecoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            hint: Text('Select an account type'),
                            underline: SizedBox.shrink(),
                            items: ['Personal', 'Business'].map((String item) {
                              return DropdownMenuItem(
                                value: item,
                                child: Text(item),
                              );
                            }).toList(),
                            onChanged: (String? value) {
                              setState(() {
                                accountType = value;
                                accountTypeChosen = true;
                                isPersonalAccount = accountType == 'Personal';
                              });
                            },
                          ),
                        ),
                        Visibility(
                          visible: accountTypeChosen,
                          child: accountType == 'Personal'
                              ? personalAccountFields()
                              : businessAccountFields(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget personalAccountFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 20),
        Text(
          'You will have access to :',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        SizedBox(height: 20),
        setTextInfo('Chat'),
        SizedBox(height: 20),
        setTextInfo('Yarn'),
        SizedBox(height: 20),
        setTextInfo('Blog'),
        SizedBox(height: 20),
        setTextInfo('Moment'),
        SizedBox(height: 20),
        setTextInfo('Contactless Payment'),
        SizedBox(height: 20),
        Text(
          'and every other purchasing features.',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        SizedBox(
          height: 40,
        ),
        proceedBtn(),
        SizedBox(height: 40),
      ],
    );
  }

  Widget businessAccountFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 20),
        Text(
          'You will have access to :',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        SizedBox(height: 20),
        setTextInfo('Web Dashboard'),
        SizedBox(height: 20),
        setTextInfo('Store Listing'),
        SizedBox(height: 20),
        setTextInfo('Invoicing'),
        SizedBox(height: 20),
        setTextInfo('Digital Contract'),
        SizedBox(height: 20),
        setTextInfo('Seamless Payment'),
        SizedBox(height: 20),
        setTextInfo('Business Visibility'),
        SizedBox(height: 20),
        Text(
          'and every other purchasing features.',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        SizedBox(
          height: 40,
        ),
        proceedBtn(),
        SizedBox(
          height: 40,
        ),
      ],
    );
  }

  Widget appIcon() {
    return Container(
      child: Image.asset(
        "assets/images/app_logo_navyBlue.png",
        height: MediaQuery.of(context).size.height / 16,
        frameBuilder: imageFrameBuilder,
      ),
    );
  }

  Widget registerTitle() {
    return Container(
      child: Row(
        children: <Widget>[
          Text(
            "Slydo ",
            style: TextStyle(
                fontSize: 22, fontWeight: FontWeight.w700, color: navyBlue),
          ),
          Text(
            "Registration",
            style: TextStyle(
                fontSize: 22, fontWeight: FontWeight.w700, color: blackFont),
          ),
        ],
      ),
    );
  }

  Widget proceedBtn() {
    return accountTypeChosen == true
        ? CurvedButton(
            onPressed: selectedProceedUser,
            text: "Proceed",
            textColor: Colors.white,
            backgroundColor: navyBlue,
          )
        : SizedBox();
  }

  // validate the all field in the form then authenticate user and navigate him to dashboard screen
  void selectedProceedUser() async {
    if (FocusScope.of(context).hasFocus) {
      FocusScope.of(context).unfocus();
    }

    Navigator.of(context).popAndPushNamed(Routes.SIGN_UP, arguments: {
      'phoneNumber': phoneNumber,
      'otpCode': otpCode,
      'accountType': accountType
    });
  }

  Widget setTextInfo(String text) {
    return Row(
      children: [
        SizedBox(
          height: 20,
          width: 20,
          child: SvgPicture.asset(
            "checkbox_active".toSVG(),
          ),
        ),
        SizedBox(
          width: 12,
        ),
        Text(
          text,
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
        ),
        Container(),
      ],
    );
  }
}
