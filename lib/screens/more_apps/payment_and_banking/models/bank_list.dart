class BankList {
  int? count;
  String? next;
  String? previous;
  List<BankModel>? results;

  BankList({this.count, this.next, this.previous, this.results});

  BankList.fromJson(Map<String, dynamic> json) {
    count = json['count'];
    next = json['next'];
    previous = json['previous'];
    if (json['results'] != null) {
      results = <BankModel>[];
      json['results'].forEach((v) {
        results!.add(new BankModel.fromJson(v));
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

class BankModel {
  String? name;
  String? shortName;
  String? providerCode;
  String? logoUrl;
  String? country;
  String? slug;
  int? id;

  BankModel(
      {this.name,
      this.shortName,
      this.providerCode,
      this.logoUrl,
      this.country,
      this.slug,
      this.id});

  BankModel.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    shortName = json['short_name'];
    providerCode = json['provider_code'];
    if (json['logo_url'].isNotEmpty) {
      final String url = json['logo_url'];
      logoUrl = url.replaceAll('https//', 'https://');
    } else {
      logoUrl = json['logo_url'];
    }
    country = json['country'];
    slug = json['slug'];
    id = json['id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['short_name'] = this.shortName;
    data['provider_code'] = this.providerCode;
    data['logo_url'] = this.logoUrl;
    data['country'] = this.country;
    data['slug'] = this.slug;
    data['id'] = this.id;
    return data;
  }
}
