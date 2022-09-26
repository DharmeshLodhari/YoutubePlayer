import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/screens/more_apps/messaging/chat/models/ChatConversation.dart';
import 'package:Slydo/utils/colors.dart';
import 'package:Slydo/utils/slydo_app_icon_icons.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'get_connection_list_for_sharing.dart';

/// For sharing items in the chat
class ShareInChat {
  Future<String?> selectUsersToShare(BuildContext context) async {
    return shareSheet(context);
  }

  Future<String?> shareSheet(BuildContext context) async {
    return await showModalBottomSheet<String>(
        backgroundColor: Colors.transparent,
        context: context,
        builder: (BuildContext context) {
          ShareMessageToChatBloc shareMessageToChatBloc =
              Provider.of<ShareMessageToChatBloc>(context);

          return Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20)),
              ),
              color: Colors.white,
              margin: EdgeInsets.zero,
              child: Container(
                padding: EdgeInsets.only(bottom: 18),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      height: 8,
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: Center(
                            child: Text(
                              "Share in Chat",
                              style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: blackFont,
                                  fontSize: 18),
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            SlydoAppIcon.send_message_2,
                            color: shareMessageToChatBloc.recipientsLength() > 0
                                ? navyBlue
                                : dividerColor,
                            size: 24,
                          ),
                          onPressed:
                              shareMessageToChatBloc.recipientsLength() > 0
                                  ? () {
                                      Navigator.pop(context, "Send");
                                    }
                                  : null,
                        ),
                        // MaterialButton(
                        //   padding: EdgeInsets.zero,
                        //   disabledColor: dividerColor,
                        //   disabledTextColor: blackFont,
                        //   shape: RoundedRectangleBorder(
                        //       borderRadius: BorderRadius.circular(50)),
                        //   onPressed:
                        //       shareMessageToChatBloc.recipientsLength() > 0
                        //           ? () {
                        //               Navigator.pop(context, "Send");
                        //             }
                        //           : null,
                        //   child: Text(
                        //     "Send",
                        //     style: TextStyle(
                        //         color: Colors.white,
                        //         fontWeight: FontWeight.w600),
                        //   ),
                        //   color: navyBlue,
                        // ),
                        SizedBox(
                          width: 20,
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    Expanded(child: GetUserConnectionList())
                  ],
                ),
              ));
        });
  }

  Future<List<ChatConversation?>> selectShareCustomer(
      BuildContext context) async {
    var result = await selectUsersToShare(context);

    ShareMessageToChatBloc shareMessageToChatBloc =
        Provider.of<ShareMessageToChatBloc>(context, listen: false);

    debugPrint("Result = $result");
    if (result == null) {
      shareMessageToChatBloc.clearRecipient();
      return [];
    } else {
      List<ChatConversation?> tempList = shareMessageToChatBloc.getRecipients();

      List<ChatConversation?> recipientList = [];

      if (tempList != null && tempList.isNotEmpty) {
        for (ChatConversation? conversation in tempList) {
          if (conversation != null) {
            recipientList.add(conversation);
          }
        }
      }

      shareMessageToChatBloc.clearRecipient();

      return recipientList;
    }
  }
}
