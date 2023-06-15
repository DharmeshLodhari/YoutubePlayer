class CreateMomentModel {
  String filePath;
  bool isPublic;
  String? text;
  String? url;
  bool enablePayMe;
  bool enableLike;
  bool enableCommenting;
  bool isPermanent;
  String? mediaPoster;
  List<String>? userTags;
  String? payMeLabel;
  String? payMeButtonColor;
  Map<String, String>? attachmentMap;
  int? duration;

  CreateMomentModel({
    this.url,
    this.attachmentMap,
    this.payMeButtonColor,
    this.payMeLabel = 'Pay Me',
    this.enableLike = false,
    this.enableCommenting = false,
    this.isPermanent = false,
    this.enablePayMe = false,
    this.mediaPoster,
    this.userTags,
    this.duration,
    required this.filePath,
    required this.isPublic,
    required this.text,
  });
}
