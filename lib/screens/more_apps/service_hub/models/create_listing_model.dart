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
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['id'] = this.id;
    data['type'] = this.type;
    data['is_active'] = this.isActive;
    data['created_at'] = this.createdAt;
    data['expiration_date'] = this.expirationDate;
    data['job'] = this.job;
    return data;
  }
}
