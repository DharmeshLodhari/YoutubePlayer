class FinancialInstitution {
  String? country;
  String? logo;
  String? name;

  FinancialInstitution({this.country, this.logo, this.name});

  factory FinancialInstitution.fromJson(Map<String, dynamic> json) {
    return FinancialInstitution(
      country: json['country'],
      logo: json['logo'],
      name: json['name'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['country'] = this.country;
    data['logo'] = this.logo;
    data['name'] = this.name;
    return data;
  }
}
