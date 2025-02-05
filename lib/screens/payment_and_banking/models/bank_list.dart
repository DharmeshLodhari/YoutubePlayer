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
        results!.add(BankModel.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['count'] = count;
    data['next'] = next;
    data['previous'] = previous;
    if (results != null) {
      data['results'] = results!.map((v) => v.toJson()).toList();
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
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['short_name'] = shortName;
    data['provider_code'] = providerCode;
    data['logo_url'] = logoUrl;
    data['country'] = country;
    data['slug'] = slug;
    data['id'] = id;
    return data;
  }
}
