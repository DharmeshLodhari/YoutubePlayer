class StatesModel {
  int? id;
  String? name;
  Country? country;
  String? isoCode;

  StatesModel(
      {this.id, required this.name, required this.country, this.isoCode});

  factory StatesModel.fromJson(Map<String, dynamic> json) {
    return StatesModel(
      id: json['id'],
      name: json['name'],
      isoCode: json['iso_code'],
      country:
          json['country'] != null ? Country.fromJson(json['country']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    if (this.country != null) {
      data['country'] = this.country!.toJson();
    }
    return data;
  }
}

class Country {
  int? id;
  String? name;
  String? isoCode;

  Country({required this.id, required this.name, required this.isoCode});

  factory Country.fromJson(Map<String, dynamic> json) {
    return Country(
      id: json['id'],
      name: json['name'],
      isoCode: json['iso_code'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['iso_code'] = this.isoCode;
    return data;
  }
}

class Cities {
  String? name;
  String? stateCode;

  Cities({required this.name, required this.stateCode});

  factory Cities.fromJson(Map<String, dynamic> json) {
    return Cities(
      name: json['name'],
      stateCode: json['state_code'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['name'] = this.name;
    data['state_code'] = this.stateCode;
    return data;
  }
}
