import 'dart:async';
import 'dart:io';

import 'package:Slydo/data/database_helper.dart';
import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/routes/route_constants.dart';
import 'package:Slydo/screens/more_apps/messaging/chat/models/ChatConversation.dart';
import 'package:Slydo/screens/more_apps/messaging/message_auth.dart';
import 'package:Slydo/screens/more_apps/payment_and_banking/models/fee_structure.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/curved_btn.dart';
import 'package:Slydo/widget/customized_passcode_sheet/bottomsheet_passcode.dart';
import 'package:Slydo/widget/customized_textform_field.dart';
import 'package:Slydo/widget/loading_indicator.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../payment_loading_screen.dart';

// ignore: must_be_immutable
class SendEnvelope extends StatefulWidget {
  final arguments;

  SendEnvelope({this.arguments});

  @override
  _SendEnvelopeState createState() => _SendEnvelopeState();
}

class _SendEnvelopeState extends State<SendEnvelope> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  final _sendEnvelopeScaffold = GlobalKey<ScaffoldState>();
  final _sendEnvelopeScaffoldMessenger = GlobalKey<ScaffoldMessengerState>();
  late UserBloc userBloc;

  double? amount;
  String errorMessage = "";

  bool? isEmptyEnvelope;

  ChatConversation? chatConversation;

  String costOfEnvelope = "";
  bool isLoading = false;

  @override
  void initState() {
    isEmptyEnvelope =
        widget.arguments != null ? widget.arguments["isEmptyEnvelope"] : false;
    chatConversation = widget.arguments["chatConversation"];

    getTransactionFees();
    super.initState();
  }

  void getTransactionFees() async {
    isLoading = true;
    if (mounted) setState(() {});

    final FeeStructure? feeStructure = await DatabaseHelper().getFeeStructure();

    if (feeStructure == null) {
      isLoading = false;
      if (mounted) setState(() {});
      return null;
    }

    costOfEnvelope = feeStructure.getFeeWithTax(
        type: isEmptyEnvelope!
            ? FeesType.EMPTY_ENVELOPE_FEE
            : FeesType.MAGIC_ENVELOPE_FEE);

    isLoading = false;
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    userBloc = Provider.of<UserBloc>(context);

    return WillPopScope(
      onWillPop: () async {
        return true;
      },
      child: ScaffoldMessenger(
        key: _sendEnvelopeScaffoldMessenger,
        child: Scaffold(
          backgroundColor: Colors.white,
          key: _sendEnvelopeScaffold,
          resizeToAvoidBottomInset: true,
          appBar: appBar() as PreferredSizeWidget?,
          body: scaffoldBody(),
        ),
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
        isEmptyEnvelope! ? "Send empty envelope" : "Send magic envelope",
        style: TextStyle(
            color: blackFont, fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget getDisplayCard() {
    var avatarImage;
    if (chatConversation != null) {
      avatarImage = Container(
        height: 48,
        width: 48,
        child: ClipOval(
          child: CachedNetworkImage(
            imageUrl: chatConversation!.avatar!,
            colorBlendMode: BlendMode.darken,
            fit: BoxFit.fill,
            filterQuality: FilterQuality.high,
            errorWidget: imageErrorWidget,
          ),
        ),
      );
    }

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(
              chatConversation!.fullName!,
              style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 16),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
            subtitle: Text(
              chatConversation!.userName!,
              style: TextStyle(fontSize: 14, color: darkGrey),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
            leading: avatarImage,
            // trailing: qrCodeImage,
            onTap: () {
              Navigator.pushNamed(context, Routes.USER_PROFILE,
                  arguments: {"searchedUserName": chatConversation!.userName});
            },
          ),
        ),
        Divider(
          color: dividerColor,
          height: 1,
          thickness: 1,
        ),
      ],
    );
  }

  Widget scaffoldBody() {
    final bool isScreenIsSmall = MediaQuery.of(context).size.height < 600;

    return isLoading
        ? Center(
            child: CircularLoadingIndicator(),
          )
        : SingleChildScrollView(
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
                              getDisplayCard(),
                              Container(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 20),
                                child: Column(
                                  children: [
                                    if (isEmptyEnvelope!)
                                      Container()
                                    else
                                      Column(
                                        children: [
                                          const SizedBox(
                                            height: 20,
                                          ),
                                          displayAmountField(),
                                        ],
                                      ),
                                    const SizedBox(
                                      height: 20,
                                    ),
                                    getTitleField(),
                                    const SizedBox(
                                      height: 20,
                                    ),
                                    getMessageField(),
                                    const SizedBox(
                                      height: 20,
                                    ),
                                    if (errorMessage == "")
                                      Container()
                                    else
                                      Text(
                                        errorMessage,
                                        style: TextStyle(
                                            color: mateRed,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16),
                                      ),
                                    if (errorMessage == "")
                                      Container()
                                    else
                                      const SizedBox(
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
                        const SizedBox(
                          height: 20,
                        ),
                        getSubmitButton(),
                        const SizedBox(
                          height: 20,
                        ),
                        getConditionText(),
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
      icon: const Icon(Icons.arrow_back_ios),
      onPressed: () {
        Navigator.pop(context);
      },
    );
  }

  Widget displayAmountField() {
    return CustomizedTextFormField(
      labelText: "Amount",
      isAmountField: true,
      keyboardType: Platform.isIOS
          ? const TextInputType.numberWithOptions(decimal: true)
          : TextInputType.number,
      controller: _amountController,
      onChanged: (val) {
        if (mounted) {
          setState(() {
            amount = double.parse(val.replaceAll(',', ''));
          });
        }
      },
      validator: (val) {
        if (val.isNotEmpty) {
          try {
            final double amount = double.parse(val.replaceAll(',', ''));
            if (amount > 0.0) {
              return null;
            } else {
              throw Exception("Invalid amount");
            }
          } catch (e) {
            return AppLocalization.of(context)!.invalidAmount;
          }
        }
        return AppLocalization.of(context)!.invalidAmount;
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

  Widget getConditionText() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text("This service will cost you ",
            style: TextStyle(
                fontSize: 14, fontWeight: FontWeight.w400, color: darkGrey)),
        Text("₦ $costOfEnvelope",
            style: TextStyle(
                fontFamily: "Inter",
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: darkGrey)),
      ],
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

    if (_formKey.currentState!.validate()) {
      await Future.delayed(const Duration(milliseconds: 300));
      BottomSheetPassCode(
          context: context,
          isValidCallback: () async {
            showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) =>
                    Center(child: CircularLoadingIndicator()));

            String? envelope = 'Empty Envelope';

            final Map<String, dynamic> data = {
              "from_customer": userBloc.user.userName,
              "to_customer": chatConversation!.userName,
              "notes": "",
              "description": "",
              "is_anonymous": false,
              "made_from_chat": true,
              "message": _messageController.text.trim(),
              "title": _titleController.text.trim(),
              "conversation_id": chatConversation!.conversationId
            };
            if (!isEmptyEnvelope!) {
              data["currency"] = userBloc.user.currency;
              data["amount"] = moneyInputNormalizer(amount.toString());
              data["category"] = "General";
              envelope = 'Magic Envelope';
            }

            //show loading screen
            // Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => PaymentLoadingScreen(
                        text: 'Sending $envelope...',
                        imagePath: 'assets/images/app_logo.png',
                      )),
            );

            await MessageAuth()
                .sendEnvelope(isEmpty: isEmptyEnvelope!, data: data)
                .catchError((error) {
              showToast(message: "ERROR:- $error");
            });

            Navigator.popUntil(
                context, ModalRoute.withName(Routes.CHAT_SCREEN));
          },
          cancelCallBack: () {
            _sendEnvelopeScaffoldMessenger.currentState?.showSnackBar(SnackBar(
              content: Text(AppLocalization.of(context)!.invalidPassword),
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
