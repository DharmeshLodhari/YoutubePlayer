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
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['avatar'] = this.avatar;
    data['full_name'] = this.fullName;
    data['type'] = this.type;
    data['username'] = this.userName;
    data['is_verified'] = this.isVerified;
    data['nickname'] = this.nickName;
    return data;
  }
}
