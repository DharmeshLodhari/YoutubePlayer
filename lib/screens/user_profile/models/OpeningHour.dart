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
    final Map<String, dynamic> data = <String, dynamic>{};
    data['day'] = day;
    data['time'] = time;
    return data;
  }
}
