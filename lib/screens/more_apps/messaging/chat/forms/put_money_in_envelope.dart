import 'dart:io';

import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/screens/more_apps/messaging/chat/models/ChatConversation.dart';
import 'package:Slydo/screens/more_apps/messaging/message_auth.dart';
import 'package:Slydo/screens/more_apps/payment_and_banking/models/Envelope.dart';
import 'package:Slydo/screens/more_apps/user_profile/models/user.dart';
import 'package:Slydo/screens/more_apps/user_profile/user_auth.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/curved_btn.dart';
import 'package:Slydo/widget/customized_passcode_sheet/bottomsheet_passcode.dart';
import 'package:Slydo/widget/customized_textform_field.dart';
import 'package:Slydo/widget/loading_indicator.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// ignore: must_be_immutable
class PutMoneyInEnvelope extends StatefulWidget {
  final arguments;

  PutMoneyInEnvelope({this.arguments});

  @override
  _PutMoneyInEnvelopeState createState() => _PutMoneyInEnvelopeState();
}

class _PutMoneyInEnvelopeState extends State<PutMoneyInEnvelope> {
  TextEditingController _amountController = TextEditingController();
  TextEditingController _messageController = TextEditingController();
  TextEditingController _titleController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  final _putMoneyInEnvelopeScaffold = GlobalKey<ScaffoldState>();
  final _putMoneyInEnvelopeScaffoldMessenger =
      GlobalKey<ScaffoldMessengerState>();
  late UserBloc userBloc;

  double? amount;
  String errorMessage = "";

  Map<String, dynamic>? message;

  Envelope? envelope;

  ChatConversation? chatConversation;

  bool isLoading = false;
  CustomerProfile? customerProfile;

  /// {"id": "f608d81c-6a49-4679-b6fa-f064d3d5fb20",
  /// "check_id": "b46c11fb-1c21-4fda-b797-a0e5b040c563",
  /// "conversation": "f1da3859-3206-4669-acce-78db308899ac",
  /// "author": "black", "text": "", "read_by_author": true,
  /// "read_by_recipient": false, "was_edited": false,
  /// "media": null, "poster": null,
  /// "updated_at": "2021-06-21T13:20:46.458541+01:00",
  /// "created_at": "2021-06-21T13:20:46.458572+01:00",
  /// "kind": "envelope", "deleted_for_recipient":
  /// false, "deleted_for_author": false, "delivered": true,
  /// "meta_data":
  /// {"id": 11, "type": "empty-envelop",
  /// "magic_envelop": null, "from_customer": "black",
  /// "to_customer": "brijesh.sakariya",
  /// "message": "Test", "title": "Hello",
  /// "created_at": "2021-06-21T13:20:46.333352+01:00"},
  /// "replied_to": null, "type": "chatroom_message"}

  @override
  void initState() {
    message = widget.arguments["message"];
    envelope = widget.arguments["envelope"];
    chatConversation = widget.arguments["chatConversation"];
    fetchSenderDetail();

    super.initState();
  }

  void fetchSenderDetail() async {
    isLoading = true;
    if (mounted) setState(() {});

    customerProfile =
        await UserAuth().fetchCustomerProfile(envelope!.fromCustomer);
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
        key: _putMoneyInEnvelopeScaffoldMessenger,
        child: Scaffold(
          backgroundColor: Colors.white,
          key: _putMoneyInEnvelopeScaffold,
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
        "Send money in envelope",
        style: TextStyle(
            color: blackFont, fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget getDisplayCard() {
    var avatarImage;
    var qrCodeImage;
    if (customerProfile != null) {
      avatarImage = Container(
        height: 48,
        width: 48,
        child: ClipOval(
          child: CachedNetworkImage(
            imageUrl: customerProfile!.avatar!,
            colorBlendMode: BlendMode.darken,
            fit: BoxFit.fill,
            filterQuality: FilterQuality.high,
            errorWidget: imageErrorWidget,
          ),
        ),
      );

      qrCodeImage = CachedNetworkImage(
        height: 48,
        width: 48,
        imageUrl: customerProfile!.qrCode ?? "",
        colorBlendMode: BlendMode.darken,
        fit: BoxFit.fill,
        filterQuality: FilterQuality.high,
        errorWidget: imageErrorWidget,
      );
    }

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(
              customerProfile!.displayName()!,
              style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 16),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
            subtitle: Text(
              customerProfile!.userName!,
              style: TextStyle(fontSize: 14, color: darkGrey),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
            leading: avatarImage,
            trailing: qrCodeImage,
            onTap: () {
              Navigator.pushNamed(context, '/profile',
                  arguments: {"searchedUserName": customerProfile!.userName});
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
    bool isScreenIsSmall = MediaQuery.of(context).size.height < 600;

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
                                    const SizedBox(
                                      height: 20,
                                    ),
                                    getEnvelopeTitleAndMessage(),
                                    const SizedBox(
                                      height: 20,
                                    ),
                                    displayAmountField(),
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
                                        : const SizedBox(
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

  Widget getEnvelopeTitleAndMessage() {
    return Container(
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Expanded(
                  flex: 1,
                  child: Text(
                    "Title",
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  )),
              Expanded(flex: 4, child: Text("${envelope!.title}")),
            ],
          ),
          const SizedBox(
            height: 8,
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Expanded(
                  child: Text(
                "Message",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              )),
              Expanded(flex: 4, child: Text("${envelope!.message}")),
            ],
          ),
        ],
      ),
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
            double amount = double.parse(val.replaceAll(',', ''));
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
        Text("₦ 4",
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
            Map<String, dynamic> data = {
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
            data["currency"] = userBloc.user.currency;
            data["amount"] = moneyInputNormalizer(amount.toString());
            data["category"] = "General";

            data['check_id'] = message!['check_id'];

            await MessageAuth()
                .putMoneyInEnvelope(data: data, envelope: envelope!)
                .catchError((error) {
              showToast(message: "ERROR:- $error");
            });

            Navigator.popUntil(context, ModalRoute.withName("/chat-screen"));
          },
          cancelCallBack: () {
            _putMoneyInEnvelopeScaffoldMessenger.currentState
                ?.showSnackBar(SnackBar(
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
