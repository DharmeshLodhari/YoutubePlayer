class CreateMomentModel {
  String filePath;
  bool isPublic;
  String text;
  String? url;
  String? mediaPoster;
  List<String>? userTags;

  CreateMomentModel({
    this.url,
    this.mediaPoster,
    this.userTags,
    required this.filePath,
    required this.isPublic,
    required this.text,
  });
}
