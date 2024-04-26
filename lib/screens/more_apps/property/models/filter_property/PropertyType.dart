class PropertyType {
  bool? any;
  bool? apartment;
  bool? condo;
  bool? house;
  bool? townHouse;

  PropertyType(
      {this.any, this.apartment, this.condo, this.house, this.townHouse});

  factory PropertyType.fromJson(Map<String, dynamic> json) {
    return PropertyType(
      any: json['any'],
      apartment: json['apartment'],
      condo: json['condo'],
      house: json['house'],
      townHouse: json['town_house'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['any'] = any;
    data['apartment'] = apartment;
    data['condo'] = condo;
    data['house'] = house;
    data['town_house'] = townHouse;
    return data;
  }
}
