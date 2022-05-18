class ProviderModel {
  String name;
  String avatar;
  String providerId;

  ProviderModel({
    required this.name,
    required this.avatar,
    required this.providerId,
  });

  factory ProviderModel.fromJson(Map<String, dynamic> json) {
    return ProviderModel(
      name: json['name'],
      providerId: json['id'],
      avatar: json['avatar'] ??
          "https://www.nicepng.com/png/full/413-4139394_other-internet-providers-in-czech-republic-internet-service.png",
    );
  }
}
