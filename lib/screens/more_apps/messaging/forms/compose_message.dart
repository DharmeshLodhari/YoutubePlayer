import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/screens/more_apps/messaging/message_auth.dart';
import 'package:Slydo/screens/more_apps/user_profile/models/user.dart';
import 'package:Slydo/screens/more_apps/user_profile/user_auth.dart';
import 'package:Slydo/utils/colors.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/LoadingIndicator.dart';
import 'package:Slydo/widget/curved_btn.dart';
import 'package:Slydo/widget/customized_textform_field.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:toast/toast.dart';

// ignore: must_be_immutable
class ComposeMessage extends StatefulWidget {
  var arguments;

  ComposeMessage({this.arguments});

  @override
  _ComposeMessageState createState() =>
      _ComposeMessageState(arguments: arguments);
}

class _ComposeMessageState extends State<ComposeMessage> {
  var arguments;

  DashboardBloc _dashboardBloc;

  _ComposeMessageState({this.arguments});

  TextEditingController _recipientController = TextEditingController();
  TextEditingController _subjectController = TextEditingController();
  FocusNode _recipientFocus = FocusNode();

  bool isValidRecipient = false;
  bool isReplyMessage = false;
  bool isSubjectIsPresent = false;
  final _messageAuth = MessageAuth();
  final _formKey = GlobalKey<FormState>();
  CustomerProfile messageReceiver;
  UserBloc userBloc;
  String subject = "";
  String message = "";
  String errorMessage = "";
  String recipient;

  @override
  void initState() {
    // to adding listener on recipient field when user leave that textField it will convert that
    // recipient text lowercase
    makeUsernameLowercase();

    // checking if the message is replay message then we fetch recipient and subject Details
    // and set into recipient field and subject field and also display the recipent data tile

    if (arguments != null) {
      setState(() {
        isReplyMessage = arguments['isReply'] == 1 ? true : false ?? false;
      });
      recipient = arguments['recipient'];
      _recipientController.text = recipient;
      subject = arguments['subject'];
      if (subject != "") {
        setState(() {
          isSubjectIsPresent = true;
        });
      }
      _subjectController.text = subject;
      fetchCustomer();
    }

    super.initState();
  }

  void fetchCustomer() async {
    var customerProfile = await UserAuth().fetchCustomerProfile(recipient);

    messageReceiver = customerProfile;
    isValidRecipient = messageReceiver.userName != userBloc.user.userName;

    if (mounted) {
      setState(() {});
    }
  }

  void makeUsernameLowercase() {
    /* adding listener on recipientFocus when user unFocus
    From Recipient Field then value of that field should be in lowerCase */
    _recipientFocus
      ..addListener(() {
        if (!_recipientFocus.hasFocus) {
          setState(() {
            _recipientController.text = _recipientController.text.toLowerCase();
          });
        }
      });
  }

  @override
  Widget build(BuildContext context) {
    userBloc = Provider.of<UserBloc>(context);
    _dashboardBloc = Provider.of<DashboardBloc>(context);

    return WillPopScope(
      onWillPop: () async {
        messageReceiver = null;
        return true;
      },
      child: Scaffold(
          backgroundColor: Colors.white,
          resizeToAvoidBottomInset: true,
          appBar: appBar(),
          body: scaffoldBody()),
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
          messageReceiver = null;
          Navigator.pop(context);
        },
      ),
      title: Text(
        AppLocalization.of(context).composeMessage,
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
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Column(
          children: [
            Expanded(
              flex: 8,
              child: Card(
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
                    child: Column(
                      children: <Widget>[
                        getDisplayCard(),
                        Expanded(
                            child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          child: Column(
                            children: [
                              flexibleSpace(),
                              getRecipientField(),
                              flexibleSpace(),
                              getSubjectField(),
                              flexibleSpace(),
                              getContentField(),
                              flexibleSpace(),
                              Text(
                                errorMessage,
                                style: TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16),
                              ),
                              flexibleSpace(),
                            ],
                          ),
                        )),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
                flex: 3,
                child: Container(
                  child: Column(
                    children: [
                      flexibleSpace(),
                      getSubmitButton(),
                      flexibleSpace(flex: 2),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Widget getSubmitButton() {
    return CurvedButton(
      onPressed: onSubmit,
      backgroundColor: navyBlue,
      textColor: Colors.white,
      text: "Send message",
    );
  }

  void onSubmit() {
    if (!isValidRecipient) {
      setState(() {
        errorMessage = AppLocalization.of(context).invalidRecipient;
        return;
      });
    } else if (recipient == userBloc.user.userName) {
      setState(() {
        errorMessage = AppLocalization.of(context).invalidRecipient;
        return;
      });
    } else if (recipient == messageReceiver.userName) {
      if (!isValidRecipient) {
        setState(() {
          errorMessage = AppLocalization.of(context).invalidRecipient;
          return;
        });
      }
      if (_formKey.currentState.validate()) {
        if (userBloc.user.userName != recipient) {
          showDialog(
              context: context,
              builder: (context) => Center(child: CircularLoadingIndicator()));
          try {
            var data = {
              "sender": userBloc.user.userName,
              "recipient": recipient.trim(),
              "body": message.trim(),
              "subject": subject.trim(),
            };
            _messageAuth.sendMessage(data).then((value) {
              if (value) {
                Navigator.popUntil(context, ModalRoute.withName("/dashboard"));
                _dashboardBloc.index = 0;
                Navigator.of(context).pushNamed('/message-list');
                // Navigator.of(context).pushNamedAndRemoveUntil(
                //   "/dashboard",
                //   (Route<dynamic> route) => false,
                //   arguments: {"dashboardIndex": 4},
                // );
              } else {
                Navigator.pop(context);
                var msg = AppLocalization.of(context).error;
                Toast.show(msg, context,
                    gravity: Toast.CENTER,
                    backgroundColor: darkBlue(),
                    textColor: Colors.white);
              }
            });
          } catch (e) {
            Navigator.pop(context);
            Toast.show(e, context,
                gravity: Toast.BOTTOM, backgroundColor: darkBlue());
          }
        } else {
          var msg = AppLocalization.of(context).invalidRecipient;
          Toast.show(msg, context,
              gravity: Toast.CENTER,
              backgroundColor: darkBlue(),
              textColor: Colors.white);
        }
      }
    } else {
      var msg = AppLocalization.of(context).invalidRecipient;
      Toast.show(msg, context,
          gravity: Toast.CENTER,
          backgroundColor: darkBlue(),
          textColor: Colors.white);
    }
  }

  Widget sendMessage() {
    return IconButton(
        icon: Icon(Icons.send),
        onPressed: () {
          if (!isValidRecipient) {
            setState(() {
              errorMessage = AppLocalization.of(context).invalidRecipient;
              return;
            });
          } else if (recipient == userBloc.user.userName) {
            setState(() {
              errorMessage = AppLocalization.of(context).invalidRecipient;
              return;
            });
          } else if (recipient == messageReceiver.userName) {
            if (!isValidRecipient) {
              setState(() {
                errorMessage = AppLocalization.of(context).invalidRecipient;
                return;
              });
            }
            if (_formKey.currentState.validate()) {
              if (userBloc.user.userName != recipient) {
                showDialog(
                    context: context,
                    builder: (context) => Center(
                            child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor: AlwaysStoppedAnimation(Colors.white),
                          backgroundColor: lightBlue(),
                        )));
                try {
                  var data = {
                    "sender": userBloc.user.userName,
                    "recipient": recipient.trim(),
                    "body": message.trim(),
                    "subject": subject.trim(),
                  };
                  _messageAuth.sendMessage(data).then((value) {
                    if (value) {
                      Navigator.of(context).pushNamedAndRemoveUntil(
                        "/dashboard",
                        (Route<dynamic> route) => false,
                        arguments: {"dashboardIndex": 4},
                      );
                    } else {
                      Navigator.pop(context);
                      var msg = AppLocalization.of(context).error;
                      Toast.show(msg, context,
                          gravity: Toast.CENTER,
                          backgroundColor: darkBlue(),
                          textColor: Colors.white);
                    }
                  });
                } catch (e) {
                  Navigator.pop(context);
                  Toast.show(e, context,
                      gravity: Toast.BOTTOM, backgroundColor: darkBlue());
                }
              } else {
                var msg = AppLocalization.of(context).invalidRecipient;
                Toast.show(msg, context,
                    gravity: Toast.CENTER,
                    backgroundColor: darkBlue(),
                    textColor: Colors.white);
              }
            }
          } else {
            var msg = AppLocalization.of(context).invalidRecipient;
            Toast.show(msg, context,
                gravity: Toast.CENTER,
                backgroundColor: darkBlue(),
                textColor: Colors.white);
          }
        });
  }

  Widget showBackArrow() {
    return IconButton(
      icon: Icon(Icons.arrow_back_ios),
      onPressed: () {
        Navigator.pop(context);
      },
    );
  }

  Widget getDisplayCard() {
    var avatarImage;
    var qrCodeImage;
    if (messageReceiver != null) {
      Color borderColor = getUserTypeColor(user: messageReceiver);

      avatarImage = Container(
        height: 48,
        width: 48,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(
              25,
            ),
            border: Border.all(color: borderColor, width: 2)),
        child: ClipOval(
          child: CachedNetworkImage(
            imageUrl: messageReceiver.avatar,
            colorBlendMode: BlendMode.darken,
            fit: BoxFit.fill,
            filterQuality: FilterQuality.high,
          ),
        ),
      );
      qrCodeImage = CachedNetworkImage(
        height: 48,
        width: 48,
        imageUrl: messageReceiver.qrCode,
        colorBlendMode: BlendMode.darken,
        fit: BoxFit.fitWidth,
        filterQuality: FilterQuality.high,
      );
    }

    return messageReceiver == null
        ? Container()
        : Column(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    messageReceiver.fullName,
                    style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 16),
                  ),
                  subtitle: Text(
                    messageReceiver.userName,
                    style: TextStyle(fontSize: 14, color: darkGrey),
                  ),
                  leading: avatarImage,
                  trailing: qrCodeImage,
                  onTap: () {
                    Navigator.pushNamed(context, '/profile',
                        arguments: {"searchedUser": messageReceiver});
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

  Widget getRecipientField() {
    return CustomizedTextFormField(
        labelText: AppLocalization.of(context).recipient,
        controller: _recipientController,
        focusNode: _recipientFocus,
        enabled: !isReplyMessage && !isSubjectIsPresent,
        validator: (value) {
          if (value != messageReceiver.userName) {
            return AppLocalization.of(context).invalidRecipient;
          }
          return null;
        },
        onChanged: (val) {
          setState(() {
            if (isReplyMessage && messageReceiver != null) {
              recipient = messageReceiver.userName;
            } else {
              recipient = val.toLowerCase();
            }
          });
        });
  }

  Widget getSubjectField() {
    return CustomizedTextFormField(
      labelText: AppLocalization.of(context).subject,
      controller: _subjectController,
      enabled: !isReplyMessage && !isSubjectIsPresent,
      validator: (val) {
        if (val.length == 0) {
          return "Subject Should Not Be Empty ";
        }
        return null;
      },
      onChanged: (val) {
        setState(() {
          subject = val;
        });
      },
      onTap: () async {
        if (recipient != null) {
          recipient = recipient.trim();
          if (mounted) {
            setState(() {
              _recipientController.text = recipient;
            });
          }
          var customerProfile =
              await UserAuth().fetchCustomerProfile(recipient);
          setState(() {
            messageReceiver = customerProfile;
            isValidRecipient =
                messageReceiver.userName != userBloc.user.userName;
          });
        }
      },
    );
  }

  Widget getContentField() {
    return CustomizedTextFormField(
      labelText: AppLocalization.of(context).message,
      maxLines: 5,
      validator: (val) {
        if (val.length == 0) {
          return "Message Should Not Be Empty ";
        }
        return null;
      },
      onChanged: (val) {
        setState(() {
          message = val;
        });
      },
    );
  }

  @override
  void dispose() {
    _recipientController.dispose();
    _recipientFocus.dispose();
    _subjectController.dispose();
    super.dispose();
  }
}
