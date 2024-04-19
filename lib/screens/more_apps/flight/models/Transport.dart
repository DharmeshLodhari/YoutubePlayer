class Transport {
  String? currency;
  String? date;
  String? from;
  String? logo;
  String? name;
  String? price;
  String? time;
  String? to;
  String? travelTime;

  Transport(
      {this.currency,
      this.date,
      this.from,
      this.logo,
      this.name,
      this.price,
      this.time,
      this.to,
      this.travelTime});

  factory Transport.fromJson(Map<String, dynamic> json) {
    return Transport(
      currency: json['currency'],
      date: json['date'],
      from: json['from'],
      logo: json['logo'],
      name: json['name'],
      price: json['price'],
      time: json['time'],
      to: json['to'],
      travelTime: json['travel_time'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['currency'] = this.currency;
    data['date'] = this.date;
    data['from'] = this.from;
    data['logo'] = this.logo;
    data['name'] = this.name;
    data['price'] = this.price;
    data['time'] = this.time;
    data['to'] = this.to;
    data['travel_time'] = this.travelTime;
    return data;
  }
}
