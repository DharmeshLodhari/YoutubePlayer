import 'dart:io';

import 'package:Slydo/data/database_helper.dart';
import 'package:Slydo/screens/more_apps/messaging/chat/helpers/chat_message_handler.dart';
import 'package:Slydo/screens/more_apps/messaging/chat/helpers/chat_user_manager.dart';
import 'package:Slydo/screens/more_apps/messaging/chat/helpers/connection_list_manager.dart';
import 'package:Slydo/screens/more_apps/messaging/chat/helpers/db_socket_message_handler.dart';
import 'package:Slydo/services/auth.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class CacheManager {
  void deleteCache({bool clearAll = false}) async {
    final Directory tempDir = await getTemporaryDirectory();
    final List<FileSystemEntity> list =
        tempDir.listSync(followLinks: false, recursive: clearAll);
    final List<FileSystemEntity> temp = [];
    list.forEach((element) {
      if (element is File) {
        temp.add(element);
      }
    });
    temp.forEach((element) {
      element.deleteSync(recursive: true);
    });

    /*try {
      MyGlobals.notificationStream?.cancel();
    } catch (error) {
      debugPrint("Subscription Removing :- $error");
    }
*/
    if (clearAll) {
      await ChatMessageHandler().deleteChatMessages();
      await ChatUserManager().clearChatUsers();
      await ConnectionListManager().clearConnections();
      await DBSocketMessageHandler().clearSocketQueueChatMessage();
      await DatabaseHelper().deleteVirtualAccount();
      await DatabaseHelper().deleteGeneralSettings();
      await AuthService().deleteUsers();
      await AuthService().deleteDevice();

      await DatabaseHelper().deleteUsers();

      debugPrint("Cache cleared");
    }
  }
}
