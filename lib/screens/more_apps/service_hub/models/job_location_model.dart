class JobLocationModel {
  int? count;
  String? next;
  dynamic previous;
  List<LocationData>? results;

  JobLocationModel({this.count, this.next, this.previous, this.results});

  JobLocationModel.fromJson(Map<String, dynamic> json) {
    count = json['count'];
    next = json['next'];
    previous = json['previous'];
    if (json['results'] != null) {
      results = <LocationData>[];
      json['results'].forEach((v) {
        results!.add(new LocationData.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['count'] = this.count;
    data['next'] = this.next;
    data['previous'] = this.previous;
    if (this.results != null) {
      data['results'] = this.results!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class LocationData {
  String? slug;
  String? name;

  LocationData({this.slug, this.name});

  LocationData.fromJson(Map<String, dynamic> json) {
    slug = json['slug'];
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['slug'] = this.slug;
    data['name'] = this.name;
    return data;
  }
}
