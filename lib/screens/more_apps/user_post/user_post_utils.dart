import 'dart:convert';

import 'package:Slydo/screens/more_apps/user_post/user_post_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../../../data/state_notifier.dart';
import '../../../utils/util.dart';
import '../../../widget/loading_indicator.dart';
import '../messaging/chat/models/chat_conversation.dart';
import '../messaging/chat/share_in_chat/ShareInChat.dart';
import 'models/user_post.dart';

class UserPostUtils {
  static void deleteBlogPost(
      {required String blogId,
      required BuildContext context,
      required Function onDeleteBlog}) {
    showDialog(
        context: context,
        builder: (dialogLoadingContext) => LoadingIndicator());

    UserPostAuth().deleteBlog(blogId: blogId).then(
      (deleted) {
        Navigator.pop(context); // Dismiss loading indicator

        if (deleted) {
          onDeleteBlog();
          showToast(message: 'Post Deleted');
        } else {
          showToast(message: 'Something went wrong, please try again');
        }
      },
    ).catchError((e) {
      Navigator.pop(context);

      if (e.toString().toLowerCase().contains('server error')) {
        showToast(message: 'Server error, please try again.');
      } else {
        showToast(message: e.toString());
      }
    });
  }

  static void sendPostToUserInChat(
      {required BuildContext context, required UserPost userPost}) async {
    final List<ChatConversation?> listOfRecipient =
        await ShareInChat().selectShareCustomer(context);
    debugPrint("Selected users = ${listOfRecipient.length}");

    for (var recipient in listOfRecipient) {
      addUserPostToChat(
          context: context, recipientUser: recipient!, userPost: userPost);
    }
  }

  static void addUserPostToChat({
    required UserPost userPost,
    required BuildContext context,
    required ChatConversation recipientUser,
    String? url,
  }) async {
    final UserBloc userBloc = Provider.of<UserBloc>(context, listen: false);

    final Map<String, dynamic> data = {
      "meta_data": jsonEncode({
        "id": userPost.id,
        "title": userPost.title,
        "image": userPost.image,
        "video": userPost.video,
        "author_avatar": userPost.authorAvatar,
        "author_username": userPost.authorUsername,
      }),
      "check_id": const Uuid().v4(),
      "conversation_id": recipientUser.conversationId,
      "author": userBloc.user.userName,
      "message": 'blog_post',
      "kind": "blog_post",
      "created_at": DateTime.now().toUtc().toString(),
      "type": "chatroom_message",
    };
    await sendDataToSocket(data);
    showToast(message: 'Post Shared');
  }
}
