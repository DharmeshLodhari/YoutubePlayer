class CustomProfileModel {
  String? id;
  bool? product;
  bool? service;
  bool? blog;
  bool? yarn;
  bool? moment;
  bool? channels;
  bool? reviews;
  bool? openingHours;
  List<String>? ordering;
  String? productLabel;
  String? serviceLabel;
  String? createdAt;
  String? updatedAt;

  CustomProfileModel(
      {this.id,
        this.product,
        this.service,
        this.blog,
        this.yarn,
        this.moment,
        this.channels,
        this.reviews,
        this.openingHours,
        this.ordering,
        this.productLabel,
        this.serviceLabel,
        this.createdAt,
        this.updatedAt});

  CustomProfileModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    product = json['product'];
    service = json['service'];
    blog = json['blog'];
    yarn = json['yarn'];
    moment = json['moment'];
    channels = json['channels'];
    reviews = json['reviews'];
    openingHours = json['opening_hours'];
    ordering = json['ordering'].cast<String>();
    productLabel = json['product_label'];
    serviceLabel = json['service_label'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['product'] = product;
    data['service'] = service;
    data['blog'] = blog;
    data['yarn'] = yarn;
    data['moment'] = moment;
    data['channels'] = channels;
    data['reviews'] = reviews;
    data['opening_hours'] = openingHours;
    data['ordering'] = ordering;
    data['product_label'] = productLabel;
    data['service_label'] = serviceLabel;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    return data;
  }
}