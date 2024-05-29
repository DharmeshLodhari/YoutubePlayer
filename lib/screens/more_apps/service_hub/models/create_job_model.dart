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
    data['id'] = id;
    data['tags'] = tags;
    if (pictures != null) {
      data['pictures'] = pictures!.map((v) => v.toJson()).toList();
    }
    data['video'] = video;
    if (category != null) {
      data['category'] = category!.toJson();
    }
    data['owner_avatar'] = ownerAvatar;
    data['owner_name'] = ownerName;
    data['applicants_count'] = applicantsCount;
    data['title'] = title;
    data['pay'] = pay;
    data['status'] = status;
    data['owner'] = owner;
    data['is_listed'] = isListed;
    data['applicants'] = applicants;
    data['assignee'] = assignee;
    data['description'] = description;
    data['due_date'] = dueDate;
    data['creation_date'] = creationDate;
    data['city'] = city;
    data['state'] = state;
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
    data['id'] = id;
    data['image'] = image;
    data['caption'] = caption;
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
    data['slug'] = slug;
    data['image'] = image;
    data['name'] = name;
    return data;
  }
}
