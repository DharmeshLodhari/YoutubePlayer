class ProductIndustryModel {
  List<ProductIndustryResults>? results;

  ProductIndustryModel({this.results});

  ProductIndustryModel.fromJson(Map<String, dynamic> json) {
    results = json["results"] == null
        ? null
        : (json["results"] as List)
            .map((e) => ProductIndustryResults.fromJson(e))
            .toList();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (results != null) {
      data["results"] = results?.map((e) => e.toJson()).toList();
    }
    return data;
  }
}

class ProductIndustryResults {
  String? id;
  String? name;
  dynamic alias;

  ProductIndustryResults({this.id, this.name, this.alias});

  ProductIndustryResults.fromJson(Map<String, dynamic> json) {
    id = json["id"];
    name = json["name"];
    alias = json["alias"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data["id"] = id;
    data["name"] = name;
    data["alias"] = alias;
    return data;
  }
}
