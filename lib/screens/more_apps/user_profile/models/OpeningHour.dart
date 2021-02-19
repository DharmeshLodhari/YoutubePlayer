class OpeningHour {
  String day;
  String time;

  OpeningHour({this.day, this.time});

  factory OpeningHour.fromJson(Map<String, dynamic> json) {
    return OpeningHour(
      day: json['day'],
      time: json['time'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['day'] = this.day;
    data['time'] = this.time;
    return data;
  }
}
