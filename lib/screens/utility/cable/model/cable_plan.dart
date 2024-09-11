import 'package:Slydo/screens/utility/cable/model/Pack.dart';

class CablePlan {
  List<String>? features;
  String? name;
  List<Pack>? packs;
  String? price;

  CablePlan({this.features, this.name, this.packs, this.price});

  factory CablePlan.fromJson(Map<String, dynamic> json) {
    return CablePlan(
      features:
          json['features'] != null ? List<String>.from(json['features']) : null,
      name: json['name'],
      packs: json['packs'] != null
          ? (json['packs'] as List).map((i) => Pack.fromJson(i)).toList()
          : null,
      price: json['price'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['price'] = price;
    if (features != null) {
      data['features'] = features;
    }
    if (packs != null) {
      data['packs'] = packs!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}
