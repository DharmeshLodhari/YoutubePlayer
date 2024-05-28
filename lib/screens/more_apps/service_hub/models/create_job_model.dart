import 'dart:io';

class CreateJobModel {
  String? id;
  List<String>? tags;
  List<Pictures>? pictures;
  dynamic video;
  Category? category;
  String? ownerAvatar;
  String? ownerName;
  int? applicantsCount;
  String? title;
  int? pay;
  String? status;
  String? owner;
  bool? isListed;
  dynamic applicants;
  dynamic assignee;
  String? description;
  String? dueDate;
  String? creationDate;
  // String? location;

  String? state;
  String? city;

  CreateJobModel({
    this.id,
    this.tags,
    this.pictures,
    this.video,
    this.category,
    this.ownerAvatar,
    this.ownerName,
    this.applicantsCount,
    this.title,
    this.pay,
    this.status,
    this.owner,
    this.isListed,
    this.applicants,
    this.assignee,
    this.description,
    this.dueDate,
    this.creationDate,
    this.city,
    this.state,
    // this.location,
  });

  CreateJobModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    tags = json['tags'].cast<String>();
    if (json['pictures'] != null) {
      pictures = <Pictures>[];
      json['pictures'].forEach((v) {
        pictures!.add(Pictures.fromJson(v));
      });
    }
    video = json['video'];
    category =
        json['category'] != null ? Category.fromJson(json['category']) : null;
    ownerAvatar = json['owner_avatar'];
    ownerName = json['owner_name'];
    applicantsCount = json['applicants_count'];
    title = json['title'];
    pay = json['pay'];
    status = json['status'];
    owner = json['owner'];
    isListed = json['is_listed'];
    applicants = json['applicants'];
    assignee = json['assignee'];
    description = json['description'];
    dueDate = json['due_date'];
    creationDate = json['creation_date'];
    city = json["city"];
    state = json["state"];
    // location = json['location'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['id'] = this.id;
    data['tags'] = this.tags;
    if (this.pictures != null) {
      data['pictures'] = this.pictures!.map((v) => v.toJson()).toList();
    }
    data['video'] = this.video;
    if (this.category != null) {
      data['category'] = this.category!.toJson();
    }
    data['owner_avatar'] = this.ownerAvatar;
    data['owner_name'] = this.ownerName;
    data['applicants_count'] = this.applicantsCount;
    data['title'] = this.title;
    data['pay'] = this.pay;
    data['status'] = this.status;
    data['owner'] = this.owner;
    data['is_listed'] = this.isListed;
    data['applicants'] = this.applicants;
    data['assignee'] = this.assignee;
    data['description'] = this.description;
    data['due_date'] = this.dueDate;
    data['creation_date'] = this.creationDate;
    data['city'] = this.city;
    data['state'] = this.state;
    // data['location'] = this.location;
    return data;
  }
}

class Pictures {
  String? id;
  File? image;
  String? caption;

  Pictures({this.id, this.image, this.caption});

  Pictures.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    image = json['image'];
    caption = json['caption'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['id'] = this.id;
    data['image'] = this.image;
    data['caption'] = this.caption;
    return data;
  }
}

class Category {
  String? slug;
  String? image;
  String? name;

  Category({this.slug, this.image, this.name});

  Category.fromJson(Map<String, dynamic> json) {
    slug = json['slug'];
    image = json['image'];
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['slug'] = this.slug;
    data['image'] = this.image;
    data['name'] = this.name;
    return data;
  }
}
