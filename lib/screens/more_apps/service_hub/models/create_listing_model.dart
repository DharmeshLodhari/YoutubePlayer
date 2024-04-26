class CreateListingModel {
  String? id;
  String? type;
  bool? isActive;
  String? createdAt;
  String? expirationDate;
  String? job;

  CreateListingModel(
      {this.id,
      this.type,
      this.isActive,
      this.createdAt,
      this.expirationDate,
      this.job});

  CreateListingModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    type = json['type'];
    isActive = json['is_active'];
    createdAt = json['created_at'];
    expirationDate = json['expiration_date'];
    job = json['job'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['type'] = type;
    data['is_active'] = isActive;
    data['created_at'] = createdAt;
    data['expiration_date'] = expirationDate;
    data['job'] = job;
    return data;
  }
}
