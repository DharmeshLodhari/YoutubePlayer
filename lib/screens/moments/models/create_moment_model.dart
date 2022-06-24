class CreateMomentModel {
  String filePath;
  bool isPublic;
  String text;
  String? mediaPoster;
  List<String>? userTags;

  CreateMomentModel({
    this.mediaPoster,
    this.userTags,
    required this.filePath,
    required this.isPublic,
    required this.text,
  });
}
