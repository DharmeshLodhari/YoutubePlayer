import 'dart:developer';
import 'dart:io';
import 'dart:isolate';
import 'dart:ui';

import 'package:Slydo/data/database_helper.dart';
import 'package:Slydo/data/state_notifiers/user_bloc.dart';
import 'package:Slydo/screens/messaging/chat/models/chat_conversation.dart';
import 'package:Slydo/screens/messaging/chat/models/document_file_in_chat_download_model.dart';
import 'package:Slydo/screens/messaging/chat/utils.dart';
import 'package:Slydo/utils/enums.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/loading_indicator.dart';
import 'package:external_path/external_path.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

class DocumentFileTileForChat extends StatefulWidget {
  final Map<String, dynamic> message;
  final ChatConversation? chatConversation;

  const DocumentFileTileForChat(
      {super.key, required this.message, this.chatConversation});

  @override
  State<DocumentFileTileForChat> createState() =>
      _DocumentFileTileForChatState();
}

class _DocumentFileTileForChatState extends State<DocumentFileTileForChat> {
  @override
  Widget build(BuildContext context) {
    final UserBloc userBloc = Provider.of<UserBloc>(context);

    final bool isSend = widget.message["author"] == userBloc.user.userName;
    String? messageText = widget.message['text'] ?? "";
    messageText = messageDecoderWithEmoji(messageText);

    return Row(
      mainAxisAlignment:
          isSend ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment:
              isSend ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isSend) Container() else Container(width: 20),
                FileTileForChat(
                  message: widget.message,
                  chatConversation: widget.chatConversation!,
                ),
                if (isSend)
                  SizedBox(
                      width: 20, child: getMessageTick(message: widget.message))
                else
                  Container(),
              ],
            ),
            const SizedBox(height: 1),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (isSend)
                  Container()
                else
                  const SizedBox(
                    width: 20,
                  ),
                Text(
                  formatTime(widget.message["created_at"]),
                  style: TextStyle(
                      color: darkGrey,
                      fontSize: 10,
                      fontWeight: FontWeight.w500),
                ),
                if (isSend)
                  const SizedBox(
                    width: 20,
                  )
                else
                  Container(),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

Widget getMessageTick({required Map<String, dynamic> message}) {
  return Icon(
    message['delivered']
        ? Icons.check_circle_rounded
        : Icons.check_circle_outline_outlined,
    size: 12,
    color: getMessageTickColor(message: message),
  );
}

Color getMessageTickColor({required Map<String, dynamic> message}) {
  return message['delivered']
      ? message['read_by_recipient'] ?? false
          ? navyBlue
          : darkGrey
      : darkGrey;
}

class FileTileForChat extends StatefulWidget {
  final Map<String, dynamic> message;
  final ChatConversation chatConversation;

  const FileTileForChat(
      {super.key, required this.message, required this.chatConversation});

  @override
  State<FileTileForChat> createState() => _FileTileForChatState();
}

class _FileTileForChatState extends State<FileTileForChat> {
  late String media;
  late String checkID;
  late String fileName;
  late String? messageText;
  bool isDownloading = false;
  bool downloadFailed = false;
  bool canDownloadFile = true;
  late String? conversationID;
  bool isDownloadCompleted = false;

  int downloadProgress = 0;
  ReceivePort receivePort = ReceivePort();
  @override
  void initState() {
    super.initState();

    media = widget.message['media'];
    checkID = widget.message['check_id'];
    messageText = widget.message['text'] ?? "";
    conversationID = widget.message['conversation_id'];
    fileName = widget.message['media'].toString().split('/').last;

    IsolateNameServer.registerPortWithName(
        receivePort.sendPort, 'downloader_send_port');

    receivePort.listen((message) {
      downloadProgress = message[2];
      if (downloadProgress != 0) {
        isDownloading = true;
        if (mounted) setState(() {});

        if (downloadProgress == 100) {
          isDownloading = false;
          isDownloadCompleted = true;
          if (mounted) setState(() {});
          showToast(message: 'Downloaded');
        } else if (downloadProgress == -1) {
          downloadFailed = true;
          isDownloading = false;
          if (mounted) setState(() {});
          showToast(message: 'File cannot be downloaded at the moment');
        }
      }

      // debugPrint('DOWNLOAD MESSAGE ::: $message');
    });

    FlutterDownloader.registerCallback(downloadCallback);
    getIfFileIsDownloadable();
  }

  @pragma(
      'vm:entry-point') // To avoid tree shaking in release mode for Android.
  static void downloadCallback(String id, int status, int progress) {
    final SendPort send =
        IsolateNameServer.lookupPortByName('downloader_send_port')!;
    send.send([id, status, progress]);
  }

  void getIfFileIsDownloadable() async {
    final DocumentFileInChatDownloadModel model =
        DocumentFileInChatDownloadModel(
      checkID: checkID,
      conversationID: conversationID!,
    );
    final String? filePathInOs =
        await DatabaseHelper().checkIfFileExistsInDB(model: model);

    // debugPrint('file path ::: $filePathInOs');

    if (filePathInOs != null) {
      final bool fileExistsOnFileSystemOS = await doesFileExist(filePathInOs);

      // debugPrint('file path exists in os :: $fileExistsOnFileSystemOS');

      if (fileExistsOnFileSystemOS) {
        canDownloadFile = false;
      } else {
        // debugPrint('DELETING FILE ::: ${model.checkID}');
        DatabaseHelper().deleteDocumentFileInChatFromDb(model: model);
      }
    }

    // debugPrint('CAN DOWNLOAD FILE ::: $canDownloadFile');

    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    IsolateNameServer.removePortNameMapping('downloader_send_port');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final UserBloc userBloc = Provider.of<UserBloc>(context);
    final bool isSend = widget.message["author"] == userBloc.user.userName;

    return Align(
      alignment: isSend ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width / 1.8,
          minWidth: MediaQuery.of(context).size.width / 1.8,
        ),
        padding: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: isSend ? navyBlue : Colors.white,
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(10),
            topLeft: Radius.circular(10),
            topRight: Radius.circular(10),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.chatConversation.isGroupConversation!)
              Padding(
                padding: const EdgeInsets.only(left: 16),
                child: Text(
                  getAuthorName(
                      message: widget.message, currentUser: userBloc.user)!,
                  style: TextStyle(
                      color: isSend ? Colors.white : navyBlue,
                      fontSize: 12,
                      fontWeight: FontWeight.w700),
                ),
              )
            else
              const SizedBox.shrink(),
            ListTile(
              leading: CircleAvatar(
                radius: 18,
                backgroundColor: isSend ? Colors.white : blackFont,
                child: SvgPicture.asset(
                  getDocumentFileIcon(
                    getDocumentFileTypeForChat(media.split('.').last),
                  ),
                  fit: BoxFit.cover,
                ),
              ),
              title: Text(
                truncateFileName(fileName),
                style: TextStyle(
                    color: isSend ? Colors.white : blackFont, fontSize: 14),
              ),
              trailing: InkWell(
                onTap: canDownloadFile
                    ? () async {
                        _downloadAndSaveFileNameToDb();
                      }
                    : null,
                child: getTrailingIcon(isSend),
              ),
              onTap: openFile,
            ),
            if (messageText != null && messageText!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  messageText ?? '',
                  style: TextStyle(
                      color: isSend ? Colors.white : blackFont,
                      fontSize: 14,
                      fontWeight: FontWeight.w400),
                ),
              )
            else
              const SizedBox.shrink(),
          ],
        ),
      ),
    );
  }

  void openFile() async {
    if (isDownloading) return;

    final DocumentFileInChatDownloadModel model =
        DocumentFileInChatDownloadModel(
      checkID: checkID,
      conversationID: conversationID!,
    );
    final String? filePathInOs =
        await DatabaseHelper().checkIfFileExistsInDB(model: model);

    if (filePathInOs != null && filePathInOs != "") {
      log("FILE PATH:- $filePathInOs");
      try {
        final OpenResult openResult = await OpenFilex.open(filePathInOs);
      } catch (error) {
        log("ERROR WHILE OPENING FILE:- $filePathInOs");
      }
    }
  }

  void _downloadAndSaveFileNameToDb() async {
    final PermissionStatus status = await Permission.storage.request();

    var downloadsDirectoryPath;

    if (Platform.isIOS) {
      final Directory directory = await getApplicationDocumentsDirectory();
      downloadsDirectoryPath = directory.path;
    } else {
      downloadsDirectoryPath =
          await ExternalPath.getExternalStoragePublicDirectory(
        ExternalPath.DIRECTORY_DOWNLOADS,
      );
    }

    if (status.isGranted) {
      setState(() {
        isDownloading = true;
      });
      final String formattedFileName =
          await makeFileName(downloadsDirectoryPath, fileName);

      await FlutterDownloader.enqueue(
        url: media,
        fileName: formattedFileName,
        savedDir: downloadsDirectoryPath,
      );

      final DocumentFileInChatDownloadModel model =
          DocumentFileInChatDownloadModel(
        checkID: checkID,
        conversationID: conversationID!,
        filePathInOs: '$downloadsDirectoryPath/$formattedFileName',
      );

      DatabaseHelper().saveDocumentFileInChatFromDb(model);
    } else {
      Permission.storage.request();
    }
  }

  Widget getTrailingIcon(bool isSend) {
    if (isDownloading) {
      return SizedBox(
        width: 25,
        height: 25,
        child: CircularLoadingIndicator(
          color: isSend ? Colors.white : blackFont,
        ),
      );
    } else if (isDownloadCompleted) {
      return Icon(Icons.check, color: isSend ? Colors.white : blackFont);
    } else if (!canDownloadFile) {
      return Icon(Icons.check, color: isSend ? Colors.white : blackFont);
    } else if (downloadFailed) {
      return SvgPicture.asset('assets/images/file_in_chat_download_icon.svg',
          color: isSend ? Colors.white : blackFont);
    }
    return SvgPicture.asset('assets/images/file_in_chat_download_icon.svg',
        color: isSend ? Colors.white : blackFont);
  }

  String truncateFileName(String fileName) {
    final String actualFileName = fileName.split('.').first;
    if (actualFileName.length >= 13) {
      return '...${fileName.substring(fileName.length - 13)}';
    }
    return fileName;
  }
}

String getDocumentFileIcon(DocumentFileTypeForChat docsType) {
  switch (docsType) {
    case DocumentFileTypeForChat.apk:
      return 'assets/images/apk_icon.svg';
    case DocumentFileTypeForChat.pdf:
      return 'assets/images/pdf_icon.svg';
    case DocumentFileTypeForChat.txt:
      return 'assets/images/txt_icon.svg';
    case DocumentFileTypeForChat.xls:
      return 'assets/images/xls_icon.svg';
    case DocumentFileTypeForChat.zip:
      return 'assets/images/zip_icon.svg';
    default:
      return 'assets/images/zip_icon.svg';
  }
}

getDocumentFileTypeForChat(String extension) {
  switch (extension) {
    case 'pdf':
      return DocumentFileTypeForChat.pdf;
    case 'apk':
      return DocumentFileTypeForChat.apk;
    case 'xls':
      return DocumentFileTypeForChat.xls;
    case 'zip':
      return DocumentFileTypeForChat.zip;
    case 'txt':
      return DocumentFileTypeForChat.txt;
  }
}
