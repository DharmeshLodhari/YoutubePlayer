class Participant {
  String? avatar;
  String? fullName;
  String? type;
  String? userName;

  Participant({this.avatar, this.fullName, this.type, this.userName});

  factory Participant.fromJson(Map<String, dynamic> json) {
    return Participant(
      avatar: json['avatar'],
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
    return data;
  }
}
