class Bedroom {
  bool? fourPlus;
  bool? one;
  bool? studio;
  bool? three;
  bool? two;

  Bedroom({this.fourPlus, this.one, this.studio, this.three, this.two});

  factory Bedroom.fromJson(Map<String, dynamic> json) {
    return Bedroom(
      fourPlus: json['four_plus'],
      one: json['one'],
      studio: json['studio'],
      three: json['three'],
      two: json['two'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['four_plus'] = this.fourPlus;
    data['one'] = this.one;
    data['studio'] = this.studio;
    data['three'] = this.three;
    data['two'] = this.two;
    return data;
  }
}
