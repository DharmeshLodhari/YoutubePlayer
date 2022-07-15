class CreateMomentModel {
  String filePath;
  bool isPublic;
  String? text;
  String? url;
  bool enablePayMe;
  bool enableLike;
  bool enableCommenting;
  String? mediaPoster;
  List<String>? userTags;
  String payMeLabel;
  String? payMeButtonColor;

  CreateMomentModel({

    this.url,
    this.payMeButtonColor,
    this.payMeLabel = 'Pay Me',
    this.enableLike = false,
    this.enableCommenting = false,
    this.enablePayMe = false,
    this.mediaPoster,
    this.userTags,
    required this.filePath,
    required this.isPublic,
    required this.text,
  });
}
