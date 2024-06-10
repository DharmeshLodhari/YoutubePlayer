import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/curved_btn.dart';
import 'package:Slydo/widget/customized_textform_field.dart';
import 'package:Slydo/widget/loading_indicator.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../payment_and_banking_auth.dart';

class AlreadyHaveReferenceScreen extends StatefulWidget {
  const AlreadyHaveReferenceScreen({super.key});

  @override
  State<AlreadyHaveReferenceScreen> createState() =>
      _AlreadyHaveReferenceScreenState();
}

class _AlreadyHaveReferenceScreenState
    extends State<AlreadyHaveReferenceScreen> {
  final _formKeyTwo = GlobalKey<FormState>();

  UserBloc? userBloc;
  late BankAccountBloc bankAccountBloc;

  String errorMessage = "";

  String referenceNumber = "";

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    userBloc = Provider.of<UserBloc>(context);
    bankAccountBloc = Provider.of<BankAccountBloc>(context);

    return PopScope(
      onPopInvoked: (didPop) async {
        if (didPop) {
          return;
        }
      },
      child: Scaffold(
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
        "Topup",
        style: TextStyle(
            color: blackFont, fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget scaffoldBody() {
    return SingleChildScrollView(
      child: Container(
        height: MediaQuery.of(context).size.height -
            (AppBar().preferredSize.height +
                MediaQuery.of(context).padding.top),
        width: MediaQuery.of(context).size.width,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Form(
          key: _formKeyTwo,
          child: Column(
            children: <Widget>[
              displayReferenceField(),
              const SizedBox(
                height: 40,
              ),
              submitBtn(),
            ],
          ),
        ),
      ),
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
        child: ListTile(
          dense: true,
          title: Text(
            bankAccountBloc.bankAccount!.bankName!,
            style: TextStyle(
                color: blackFont, fontWeight: FontWeight.w600, fontSize: 14),
          ),
          subtitle: Text(
            '******${bankAccountBloc.bankAccount!.accountNumber.toString().substring(5, 9)}',
            style: TextStyle(color: darkGrey, fontSize: 12),
          ),
          leading: CachedNetworkImage(
            imageUrl: bankAccountBloc.bankAccount!.bankAvatar!,
            height: 48,
            width: 48,
            colorBlendMode: BlendMode.darken,
            fit: BoxFit.cover,
            filterQuality: FilterQuality.high,
            placeholder: (context, url) =>
                bankAccountBloc.bankAccount!.bankAvatar == ""
                    ? const Icon(Icons.account_balance)
                    : CircularLoadingIndicator(),
            errorWidget: imageErrorWidget,
          ),
        ),
      ),
    );
  }

  Widget displayReferenceField() {
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
        decoration: decorateBox(),
        child: CustomizedTextFormField(
          labelText: "Reference",
          keyboardType: TextInputType.text,
          onChanged: (val) {
            referenceNumber = val.toString();
            setState(() {});
          },
          validator: (val) {
            if (val.isNotEmpty) {
              if (val.toString().length == 20) {
                return null;
              }
            }
            return "Invalid reference";
          },
        ),
      ),
    );
  }

  Widget submitBtn() {
    return CurvedButton(
      onPressed: onSubmit,
      backgroundColor: navyBlue,
      textColor: Colors.white,
      text: "Next",
    );
  }

  void onSubmit() async {
    //for closing the keypad if it is open
    FocusScope.of(context).unfocus();

    final data = {"amount": "100", "currency": "NGN"};
    // var data = {"reference": referenceNumber.toString()};

    showDialog(
        context: context,
        builder: (context) => Center(child: CircularLoadingIndicator()));

    if (_formKeyTwo.currentState!.validate()) {
      PaymentAndBankingAuth().verifyReferenceNumber(data).then((value) {
        if (value != null) {
          Navigator.pop(context);
          final result = value;
          Navigator.popAndPushNamed(context, "/add-money-to-slydo-two",
              arguments: result);
        }
      }).catchError((e) {
        Navigator.pop(context);
        debugPrint(e);
        showToast(message: e);
      });
    } else {
      Navigator.pop(context);
    }
  }
}
