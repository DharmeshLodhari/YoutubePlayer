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
    final Map<String, dynamic> data = <String, dynamic>{};
    data['currency'] = currency;
    data['date'] = date;
    data['from'] = from;
    data['logo'] = logo;
    data['name'] = name;
    data['price'] = price;
    data['time'] = time;
    data['to'] = to;
    data['travel_time'] = travelTime;
    return data;
  }
}
