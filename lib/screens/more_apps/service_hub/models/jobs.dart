import 'package:flutter/material.dart';

class JobModel {
  String? id;
  List<String>? tags;
  List<Pictures>? pictures;
  Video? video;
  Category? category;
  String? ownerAvatar;
  String? ownerName;
  int? applicantsCount;
  String? activeListing;
  String? title;
  int? pay;
  String? status;
  String? owner;
  bool? isListed;
  bool? isOnline;
  List<dynamic>? applicants;
  String? assignee;
  String? description;
  String? dueDate;
  String? creationDate;
  String? location;
  bool? isNegotiable;
  bool? isVerified;
  String? currency;

  JobModel(
      {this.id,
      this.tags,
      this.pictures,
      this.video,
      this.category,
      this.ownerAvatar,
      this.ownerName,
      this.applicantsCount,
      this.activeListing,
      this.title,
      this.pay,
      this.status,
      this.owner,
      this.isListed,
      this.isOnline,
      this.applicants,
      this.assignee,
      this.description,
      this.dueDate,
      this.creationDate,
      this.location,
      this.isVerified,
      this.isNegotiable,
      this.currency});

  JobModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    tags = json['tags'].cast<String>();
    if (json['pictures'] != null) {
      pictures = <Pictures>[];
      json['pictures'].forEach((v) {
        pictures!.add(new Pictures.fromJson(v));
      });
    }
    video = json['video'] != null ? new Video.fromJson(json['video']) : null;
    category = json['category'] != null
        ? new Category.fromJson(json['category'])
        : null;
    ownerAvatar = json['owner_avatar'];
    ownerName = json['owner_name'];
    applicantsCount = json['applicants_count'];
    activeListing = json['active_listing'];
    title = json['title'];
    pay = json['pay'];
    status = json['status'];
    owner = json['owner'];
    isListed = json['is_listed'];
    isOnline = json['is_online'];
    isVerified = json['is_verified'];
    applicants = json['applicants'] == null ? [] : json['applicants'];
    assignee = json['assignee'];
    description = json['description'];
    dueDate = json['due_date'];
    creationDate = json['creation_date'];
    location = json['location'];
    isNegotiable =
        json.containsKey('is_negotiable') ? json['is_negotiable'] : false;
    currency = json.containsKey('currency') ? json['currency'] : 'NGN';
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['tags'] = this.tags;
    if (this.pictures != null) {
      data['pictures'] = this.pictures!.map((v) => v.toJson()).toList();
    }
    if (this.video != null) {
      data['video'] = this.video!.toJson();
    }
    if (this.category != null) {
      data['category'] = this.category!.toJson();
    }
    data['owner_avatar'] = this.ownerAvatar;
    data['owner_name'] = this.ownerName;
    data['applicants_count'] = this.applicantsCount;
    data['active_listing'] = this.activeListing;
    data['title'] = this.title;
    data['pay'] = this.pay;
    data['status'] = this.status;
    data['owner'] = this.owner;
    data['is_listed'] = this.isListed;
    data['is_online'] = this.isOnline;
    data['applicants'] = this.applicants;
    data['assignee'] = this.assignee;
    data['description'] = this.description;
    data['due_date'] = this.dueDate;
    data['creation_date'] = this.creationDate;
    data['location'] = this.location;
    data['is_verified'] = this.isVerified;
    return data;
  }

  // ignore: missing_return
  String getImageId(String? imageUrl) {
    // debugPrint("${this.serverImages}");
    for (var data in this.pictures!) {
      if (data.image == imageUrl) {
        return data.id.toString();
      }
    }
    return "";
  }
}

class Pictures {
  String? id;
  String? image;
  String? caption;

  Pictures({this.id, this.image, this.caption});

  Pictures.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    image = json['image'];
    caption = json['caption'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
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
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['slug'] = this.slug;
    data['image'] = this.image;
    data['name'] = this.name;
    return data;
  }
}

class Video {
  String? id;
  String? file;
  Null? imagePoster;
  Null? caption;

  Video({this.id, this.file, this.imagePoster, this.caption});

  Video.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    file = json['file'];
    imagePoster = json['image_poster'];
    caption = json['caption'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['file'] = this.file;
    data['image_poster'] = this.imagePoster;
    data['caption'] = this.caption;
    return data;
  }
}
