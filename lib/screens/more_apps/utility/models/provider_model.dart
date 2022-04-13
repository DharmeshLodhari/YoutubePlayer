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
          "https://upload.wikimedia.org/wikipedia/commons/9/93/New-mtn-logo.jpg",
    );
  }
}
