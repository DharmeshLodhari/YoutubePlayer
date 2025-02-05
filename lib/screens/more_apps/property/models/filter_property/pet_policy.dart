class PetPolicy {
  bool? catAllowed;
  bool? dogAllowed;

  PetPolicy({this.catAllowed, this.dogAllowed});

  factory PetPolicy.fromJson(Map<String, dynamic> json) {
    return PetPolicy(
      catAllowed: json['cat_allowed'],
      dogAllowed: json['dog_allowed'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['cat_allowed'] = catAllowed;
    data['dog_allowed'] = dogAllowed;
    return data;
  }
}
