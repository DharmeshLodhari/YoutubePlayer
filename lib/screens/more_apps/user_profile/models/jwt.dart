/// access : ""
/// refresh : ""
/// expiration : ""

class Jwt {
  Jwt({
    this.access,
    this.refresh,
    this.expiration,
  });

  Jwt.fromJson(Map<String, dynamic> json) {
    access = json['access']
        .toString(); // Get `access` and `refresh` Tokens from response
    refresh = json['refresh'].toString();
    expiration =
        json['expiration'].toString(); // Convert expirationTime int to string .
  }

  Jwt.fromDBJson(Map<String, dynamic> json) {
    access = json['access'];
    refresh = json['refresh'];
    expiration = json['expiration'];
  }

  String? access;
  String? refresh;
  String? expiration;

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> map = <String, dynamic>{};
    map['access'] = access!;
    map['refresh'] = refresh!;
    map['expiration'] = expiration!;
    return map;
  }

  Map<String, String> toDBJson() {
    final Map<String, String> map = <String, String>{};
    map['access'] = access!;
    map['refresh'] = refresh!;
    map['expiration'] = expiration!;
    return map;
  }
}
