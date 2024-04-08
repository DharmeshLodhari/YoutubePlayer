import 'package:Slydo/screens/more_apps/utility/cable/model/Pack.dart';

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
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['name'] = this.name;
    data['price'] = this.price;
    if (this.features != null) {
      data['features'] = this.features;
    }
    if (this.packs != null) {
      data['packs'] = this.packs!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}
