class DocumentFileInChatDownloadModel {
  String checkID;
  String conversationID;
  String? filePathInOs;

  DocumentFileInChatDownloadModel({
    this.filePathInOs,
    required this.checkID,
    required this.conversationID,
  });

  Map<String, dynamic> toDBJson() {
    final Map<String, dynamic> data = <String, dynamic>{};

    data['check_id'] = checkID;
    data['file_path_in_os'] = filePathInOs;
    data['conversation_id'] = conversationID;

    return data;
  }
}
