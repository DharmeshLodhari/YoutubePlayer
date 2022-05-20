class DocumentFileInChatDownloadModel {
  String fileName;
  bool downloaded;

  DocumentFileInChatDownloadModel({
    required this.fileName,
    required this.downloaded,
  });

  Map<String, dynamic> toJson() {
    return {
      "file_name": fileName,
      "downloaded": downloaded,
    };
  }
}
