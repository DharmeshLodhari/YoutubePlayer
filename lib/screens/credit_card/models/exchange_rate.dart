

class ExchangeRate {
  String? id;
  String? provider;
  String? currency;
  double? providerRateToNgn;
  double? providerNgnToRate;
  double? slydoRateToNgn;
  double? slydoNgnToRate;
  String? createdAt;
  String? updatedAt;
  String? time;

  ExchangeRate(
      {this.id,
        this.provider,
        this.currency,
        this.providerRateToNgn,
        this.providerNgnToRate,
        this.slydoRateToNgn,
        this.slydoNgnToRate,
        this.createdAt,
        this.updatedAt,
        this.time});

  ExchangeRate.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    provider = json['provider'];
    currency = json['currency'];
    providerRateToNgn = double.parse(json['provider_rate_to_ngn'].toString());
    providerNgnToRate = double.parse(json['provider_ngn_to_rate'].toString());
    slydoRateToNgn = double.parse(json['slydo_rate_to_ngn'].toString());
    slydoNgnToRate = double.parse(json['slydo_ngn_to_rate'].toString());
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    time = json['time'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['provider'] = provider;
    data['currency'] = currency;
    data['provider_rate_to_ngn'] = providerRateToNgn;
    data['provider_ngn_to_rate'] = providerNgnToRate;
    data['slydo_rate_to_ngn'] = slydoRateToNgn;
    data['slydo_ngn_to_rate'] = slydoNgnToRate;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['time'] = time;
    return data;
  }
}