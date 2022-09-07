class Participant {
  String? avatar;
  String? fullName;
  String? type;
  String? userName;
  bool? isVerified;

  Participant({this.avatar, this.fullName, this.type, this.userName, this.isVerified = false});

  factory Participant.fromJson(Map<String, dynamic> json) {
    return Participant(
      avatar: json['avatar'],
      isVerified: json['is_verified'],
      fullName: json['full_name'],
      type: json['type'],
      userName: json['username'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['avatar'] = this.avatar;
    data['full_name'] = this.fullName;
    data['type'] = this.type;
    data['username'] = this.userName;
    data['is_verified'] = this.isVerified;
    return data;
  }
}
