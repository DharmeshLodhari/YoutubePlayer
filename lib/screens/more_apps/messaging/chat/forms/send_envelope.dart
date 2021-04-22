import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/utils/colors.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/curved_btn.dart';
import 'package:Slydo/widget/customized_passcode_sheet/bottomsheet_passcode.dart';
import 'package:Slydo/widget/customized_textform_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

// ignore: must_be_immutable
class SendEnvelope extends StatefulWidget {
  final arguments;

  SendEnvelope({this.arguments});

  @override
  _SendEnvelopeState createState() => _SendEnvelopeState();
}

class _SendEnvelopeState extends State<SendEnvelope> {
  TextEditingController _amountController = TextEditingController();
  TextEditingController _messageController = TextEditingController();
  TextEditingController _titleController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  final _sendEnvelopeScaffold = GlobalKey<ScaffoldState>();
  UserBloc userBloc;

  double amount;
  String errorMessage = "";

  bool isEmptyEnvelope;

  @override
  void initState() {
    isEmptyEnvelope =
        widget.arguments != null ? widget.arguments["isEmptyEnvelope"] : false;

    super.initState();
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
        key: _sendEnvelopeScaffold,
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
        onPressed: () async {
          Navigator.pop(context);
        },
      ),
      title: Text(
        "Send envelope",
        style: TextStyle(
            color: blackFont, fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget scaffoldBody() {
    bool isScreenIsSmall = MediaQuery.of(context).size.height < 600;

    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.symmetric(
            horizontal: 16, vertical: isScreenIsSmall ? 8 : 16),
        child: Column(
          children: [
            Card(
              elevation: 2,
              margin: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              shadowColor: iconBtnGrey,
              child: Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: iconBtnGrey, width: 1)),
                child: Form(
                  key: _formKey,
                  child: Container(
                    child: Column(
                      children: <Widget>[
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          child: Column(
                            children: [
                              isEmptyEnvelope
                                  ? Container()
                                  : Column(
                                      children: [
                                        SizedBox(
                                          height: 20,
                                        ),
                                        displayAmountField(),
                                      ],
                                    ),
                              SizedBox(
                                height: 20,
                              ),
                              getTitleField(),
                              SizedBox(
                                height: 20,
                              ),
                              getMessageField(),
                              SizedBox(
                                height: 20,
                              ),
                              errorMessage == ""
                                  ? Container()
                                  : Text(
                                      errorMessage,
                                      style: TextStyle(
                                          color: mateRed,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16),
                                    ),
                              errorMessage == ""
                                  ? Container()
                                  : SizedBox(
                                      height: 20,
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
            Container(
              child: Column(
                children: [
                  SizedBox(
                    height: 20,
                  ),
                  getSubmitButton(),
                  SizedBox(
                    height: 20,
                  ),
                ],
              ),
            ),
          ],
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

  Widget displayAmountField() {
    return CustomizedTextFormField(
      labelText: "Amount",
      isAmount: true,
      keyboardType: TextInputType.number,
      // inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      controller: _amountController,
      onChanged: (val) {
        if (mounted) {
          setState(() {
            amount = double.parse(val);
          });
        }
      },
      validator: (val) {
        if (val.isNotEmpty) {
          try {
            double amount = double.parse(val);
            if (amount > 0.0) {
              return null;
            } else {
              throw Exception("Invalid amount");
            }
          } catch (e) {
            return AppLocalization.of(context).invalidAmount;
          }
        }
        return AppLocalization.of(context).invalidAmount;
      },
    );
  }

  Widget getMessageField() {
    return CustomizedTextFormField(
      maxLines: 4,
      labelText: "Message",
      textCapitalization: TextCapitalization.sentences,
      controller: _messageController,
    );
  }

  Widget getTitleField() {
    return CustomizedTextFormField(
      labelText: "Title",
      textCapitalization: TextCapitalization.sentences,
      controller: _titleController,
    );
  }

  Widget getSubmitButton() {
    return CurvedButton(
      onPressed: onSubmit,
      backgroundColor: navyBlue,
      textColor: Colors.white,
      text: "Send",
    );
  }

  void onSubmit() async {
    if (FocusScope.of(context).hasFocus) {
      FocusScope.of(context).unfocus();
    }

    if (_formKey.currentState.validate()) {
      await Future.delayed(Duration(milliseconds: 300));
      BottomSheetPassCode(
          context: context,
          isValidCallback: () async {
            Navigator.pop(context, {
              "amount": moneyInputNormalizer(amount.toString()),
              "message": _messageController.text.trim(),
              "title": _titleController.text.trim()
            });
          },
          cancelCallBack: () {
            _sendEnvelopeScaffold.currentState.showSnackBar(SnackBar(
              content: Text(AppLocalization.of(context).invalidPassword),
            ));
          });
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _messageController.dispose();

    super.dispose();
  }
}
