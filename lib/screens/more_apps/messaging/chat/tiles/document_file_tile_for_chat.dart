import 'dart:io';
import 'dart:isolate';
import 'dart:ui';

import 'package:Slydo/data/database_helper.dart';
import 'package:Slydo/screens/more_apps/messaging/chat/models/document_file_in_chat_download_model.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/LoadingIndicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import '../../../../../data/state_notifier.dart';
import '../../../../../utils/enums.dart';
import '../models/ChatConversation.dart';
import 'package:external_path/external_path.dart';

class DocumentFileTileForChat extends StatefulWidget {
  final Map<String, dynamic>? message;
  final ChatConversation? chatConversation;

  DocumentFileTileForChat({required this.message, this.chatConversation});

  @override
  State<DocumentFileTileForChat> createState() =>
      _DocumentFileTileForChatState();
}

class _DocumentFileTileForChatState extends State<DocumentFileTileForChat> {
  @override
  Widget build(BuildContext context) {
    UserBloc userBloc = Provider.of<UserBloc>(context);

    bool isSend = widget.message!["author"] == userBloc.user.userName;
    String? messageText = widget.message!['text'] ?? "";
    bool isMessageEmpty = messageText == "";
    messageText = messageDecoderWithEmoji(messageText);

    return FileTileForChat(
        message: widget.message,
        downloadUrl: widget.message!['media'],
        fileName: widget.message!['media'].toString().split('/').last,
        documentFileTypeForChat: getDocumentFileTypeForChat(
            widget.message!['media'].toString().split('.').last));
  }
}

class FileTileForChat extends StatefulWidget {
  final String fileName;
  final String downloadUrl;
  final Map<String, dynamic>? message;
  final DocumentFileTypeForChat documentFileTypeForChat;

  const FileTileForChat(
      {Key? key,
      required this.message,
      required this.fileName,
      required this.downloadUrl,
      required this.documentFileTypeForChat})
      : super(key: key);

  @override
  State<FileTileForChat> createState() => _FileTileForChatState();
}

class _FileTileForChatState extends State<FileTileForChat> {
  late String checkID;
  late String conversationID;
  bool isDownloading = false;
  bool canDownloadFile = true;
  bool isDownloadComplete = false;

  static void downloadCallback(
      String id, DownloadTaskStatus status, int progress) {
    final SendPort send =
        IsolateNameServer.lookupPortByName('downloader_send_port')!;
    send.send(progress);
  }

  ReceivePort receivePort = ReceivePort();
  @override
  void initState() {
    super.initState();

    checkID = widget.message!['check_id'];
    conversationID = widget.message!['conversation_id'];

    getIfFileIsDownloadable();
    IsolateNameServer.registerPortWithName(
        receivePort.sendPort, 'downloader_send_port');

    receivePort.listen((message) {
      debugPrint('DOWNLOAD MESSAGE ::: $message');
    });
    FlutterDownloader.registerCallback(downloadCallback);
    super.initState();
  }

  getIfFileIsDownloadable() async {
    DocumentFileInChatDownloadModel model = DocumentFileInChatDownloadModel(
      checkID: checkID,
      conversationID: conversationID,
    );
    String? filePathInOs =
        await DatabaseHelper().checkIfFileExistsInDB(model: model);

    debugPrint('file path ::: $filePathInOs');

    if (filePathInOs != null) {
      bool fileExistsOnFileSystemOS = await doesFileExist(filePathInOs);

      debugPrint('file path exists in os :: $fileExistsOnFileSystemOS');

      if (fileExistsOnFileSystemOS) {
        canDownloadFile = false;
      } else {
        debugPrint('DELETING FILE ::: ${model.checkID}');
        DatabaseHelper().deleteDocumentFileInChatFromDb(model: model);
      }
    }

    debugPrint('CAN DOWNLOAD FILE ::: $canDownloadFile');

    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width / 1.8,
          minWidth: MediaQuery.of(context).size.width / 1.8,
        ),
        margin: EdgeInsets.only(right: 20),
        padding: EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: navyBlue,
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(10),
            topLeft: Radius.circular(10),
            topRight: Radius.circular(10),
          ),
        ),
        child: ListTile(
          leading: CircleAvatar(
            radius: 18,
            backgroundColor: Colors.white,
            child: SvgPicture.asset(
              getDocumentFileIcon(widget.documentFileTypeForChat),
              fit: BoxFit.cover,
            ),
          ),
          title: Text(
            truncateFileName(widget.fileName),
            style: TextStyle(color: Colors.white, fontSize: 14),
          ),
          trailing: InkWell(
            onTap: canDownloadFile
                ? () async {
                    _downloadAndSaveFileNameToDb();

                    // downloadFileFromServer(
                    //   uniqueFileName: widget.fileName,
                    //   downloadUrl: widget.downloadUrl,
                    //   onDownloadStart: () {
                    //     if (mounted) {
                    //       setState(() {
                    //         isDownloading = true;
                    //       });
                    //     }
                    //   },
                    //   onDownloadComplete: () {
                    //     if (mounted) {
                    //       setState(() {
                    //         isDownloading = false;
                    //         isDownloadComplete = true;
                    //       });
                    //     }
                    //   },
                    //   catchErrorOccurred: (error) {
                    //     if (mounted) {
                    //       setState(() {
                    //         isDownloading = false;
                    //       });
                    //     }
                    //   },
                    // );
                  }
                : null,
            child: getTrailingIcon(),
          ),
        ),
      ),
    );
  }

  _downloadAndSaveFileNameToDb() async {
    PermissionStatus status = await Permission.storage.request();

    var downloadsDirectoryPath =
        await ExternalPath.getExternalStoragePublicDirectory(
            ExternalPath.DIRECTORY_DOWNLOADS);

    debugPrint('FILE DOWNLOADS PATH ::: $downloadsDirectoryPath');

    if (status.isGranted) {
      setState(() {
        isDownloading = true;
      });

      String formattedFileName =
          await makeFileName(downloadsDirectoryPath, widget.fileName);

      debugPrint('FORMATTED FILE NAME ::: $formattedFileName');

      String? download = await FlutterDownloader.enqueue(
          url: widget.downloadUrl,
          savedDir: downloadsDirectoryPath,
          fileName: formattedFileName);

      debugPrint('DOWNLOAD : $download');
      setState(() {
        isDownloading = false;
        isDownloadComplete = true;
      });

      DocumentFileInChatDownloadModel model = DocumentFileInChatDownloadModel(
        checkID: checkID,
        conversationID: conversationID,
        filePathInOs: '$downloadsDirectoryPath/${widget.fileName}',
      );

      DatabaseHelper().saveDocumentFileInChatFromDb(model);
    } else {
      Permission.storage.request();
    }
  }

  Future<String> makeFileName(String path, String fileName) async {
    bool fileExists = await File('$path/$fileName').exists();

    /// "/download/contract_52.pdf"
    if (fileExists) {
      int counter = 1;
      List newFileExt = fileName.split('.');
      String ext = newFileExt[1];

      /// "pdf"
      String fName = newFileExt[0];

      /// "contract_52"
      String newFileName = '$fName($counter).$ext';

      /// "contract_52(1).pdf"

      bool newFileExists = await File('$path/$newFileName').exists();

      /// "contract_52(1).pdf"
      while (newFileExists) {
        debugPrint('NEW FILE EXISTS ::: $newFileExists');
        List newFileExt = fileName.split('.');

        /// "pdf"
        String ext = newFileExt[1];

        /// "contract_52(1)"
        String fName = newFileExt[0];

        if (fName.contains("($counter)")) {
          fName = fName.replaceAll("($counter)", "(${counter + 1})");
        } else {
          fName = "$fName($counter)";
        }

        debugPrint('fName ::: $fName');

        // TODO: Replace this line with Regex. Find last occurrence of open and close bracket, replace it with the new $counter with ().
        /// contract(1)_52(1)
        /// contract(2)_52(2)

        newFileName = '$fName.$ext';

        /// Invoice_36(1).pdf.pdf

        debugPrint('FINAL NEWFILEANME ::: $newFileName');
        newFileExists = await File('$path/$newFileName').exists();
        counter += 1;
      }

      return newFileName;
    }

    return fileName;
  }

  getTrailingIcon() {
    if (isDownloading) {
      return SizedBox(
          width: 25,
          height: 25,
          child: CircularLoadingIndicator(color: Colors.white));
    } else if (isDownloadComplete) {
      return Icon(Icons.check, color: Colors.white);
    } else if (!canDownloadFile) {
      return Icon(Icons.check, color: Colors.white);
    }
    return SvgPicture.asset('assets/images/file_in_chat_download_icon.svg');
  }

  truncateFileName(String fileName) {
    String actualFileName = fileName.split('.').first;
    if (actualFileName.length >= 13) {
      return '...${fileName.substring(fileName.length - 13)}';
    }
    return fileName;
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
