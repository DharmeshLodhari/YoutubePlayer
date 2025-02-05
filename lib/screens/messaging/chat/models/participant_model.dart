class Participant {
  String? avatar;
  String? fullName;
  String? type;
  String? userName;
  bool? isVerified;
  String? nickName;

  Participant(
      {this.avatar,
      this.fullName,
      this.type,
      this.userName,
      this.isVerified = false,
      this.nickName});

  factory Participant.fromJson(Map<String, dynamic> json) {
    return Participant(
      avatar: json['avatar'],
      isVerified: json['is_verified'],
      fullName: json['full_name'],
      type: json['type'],
      userName: json['username'],
      nickName: json['nickname'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['avatar'] = avatar;
    data['full_name'] = fullName;
    data['type'] = type;
    data['username'] = userName;
    data['is_verified'] = isVerified;
    data['nickname'] = nickName;
    return data;
  }
}
