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
    final Map<String, dynamic> data = Map<String, dynamic>();

    data['check_id'] = this.checkID;
    data['file_path_in_os'] = this.filePathInOs;
    data['conversation_id'] = this.conversationID;

    return data;
  }
}
