class OpeningHourForDay {
  String? day;
  String? time;

  OpeningHourForDay({this.day, this.time});

  factory OpeningHourForDay.fromJson(Map<String, dynamic> json) {
    return OpeningHourForDay(
      day: json['day'],
      time: json['time'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['day'] = this.day;
    data['time'] = this.time;
    return data;
  }
}
