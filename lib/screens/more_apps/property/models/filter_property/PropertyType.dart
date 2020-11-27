class PropertyType {
  bool any;
  bool apartment;
  bool condo;
  bool house;
  bool townHouse;

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
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['any'] = this.any;
    data['apartment'] = this.apartment;
    data['condo'] = this.condo;
    data['house'] = this.house;
    data['town_house'] = this.townHouse;
    return data;
  }
}
