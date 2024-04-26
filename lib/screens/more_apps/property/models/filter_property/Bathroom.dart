class Bathroom {
  bool? fivePlus;
  bool? four;
  bool? one;
  bool? three;
  bool? two;

  Bathroom({this.fivePlus, this.four, this.one, this.three, this.two});

  factory Bathroom.fromJson(Map<String, dynamic> json) {
    return Bathroom(
      fivePlus: json['five_plus'],
      four: json['four'],
      one: json['one'],
      three: json['three'],
      two: json['two'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['five_plus'] = fivePlus;
    data['four'] = four;
    data['one'] = one;
    data['three'] = three;
    data['two'] = two;
    return data;
  }
}
