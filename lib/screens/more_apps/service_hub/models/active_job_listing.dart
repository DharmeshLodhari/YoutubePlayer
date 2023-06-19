import 'package:Slydo/screens/more_apps/service_hub/models/jobs.dart';

class ActiveJobListing {
  int? count;
  dynamic next;
  dynamic previous;
  List<ActiveListingData>? results;

  ActiveJobListing({this.count, this.next, this.previous, this.results});

  ActiveJobListing.fromJson(Map<String, dynamic> json) {
    count = json['count'];
    next = json['next'];
    previous = json['previous'];
    if (json['results'] != null) {
      results = <ActiveListingData>[];
      json['results'].forEach((v) {
        results!.add(new ActiveListingData.fromJson(v));
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

class ActiveListingData {
  String? id;
  JobModel? job;
  String? type;
  bool? isActive;
  String? createdAt;
  String? expirationDate;

  ActiveListingData(
      {this.id,
      this.job,
      this.type,
      this.isActive,
      this.createdAt,
      this.expirationDate});

  ActiveListingData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    job = json['job'] != null ? new JobModel.fromJson(json['job']) : null;
    type = json['type'];
    isActive = json['is_active'];
    createdAt = json['created_at'];
    expirationDate = json['expiration_date'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    if (this.job != null) {
      data['job'] = this.job!.toJson();
    }
    data['type'] = this.type;
    data['is_active'] = this.isActive;
    data['created_at'] = this.createdAt;
    data['expiration_date'] = this.expirationDate;
    return data;
  }
}

// class Job {
//   String? id;
//   List<String>? tags;
//   List<Pictures>? pictures;
//   Video? video;
//   Category? category;
//   String? ownerAvatar;
//   String? ownerName;
//   String? title;
//   int? pay;
//   String? status;
//   String? owner;
//   bool? isListed;
//   dynamic applicants;
//   dynamic assignee;
//   String? description;
//   String? dueDate;
//   String? creationDate;
//   String? location;

//   Job(
//       {this.id,
//       this.tags,
//       this.pictures,
//       this.video,
//       this.category,
//       this.ownerAvatar,
//       this.ownerName,
//       this.title,
//       this.pay,
//       this.status,
//       this.owner,
//       this.isListed,
//       this.applicants,
//       this.assignee,
//       this.description,
//       this.dueDate,
//       this.creationDate,
//       this.location});

//   Job.fromJson(Map<String, dynamic> json) {
//     id = json['id'];
//     tags = json['tags'].cast<String>();
//     if (json['pictures'] != null) {
//       pictures = <Pictures>[];
//       json['pictures'].forEach((v) {
//         pictures!.add(new Pictures.fromJson(v));
//       });
//     }
//     video = json['video'] != null ? new Video.fromJson(json['video']) : null;
//     category = json['category'] != null
//         ? new Category.fromJson(json['category'])
//         : null;
//     ownerAvatar = json['owner_avatar'];
//     ownerName = json['owner_name'];
//     title = json['title'];
//     pay = json['pay'];
//     status = json['status'];
//     owner = json['owner'];
//     isListed = json['is_listed'];
//     applicants = json['applicants'];
//     assignee = json['assignee'];
//     description = json['description'];
//     dueDate = json['due_date'];
//     creationDate = json['creation_date'];
//     location = json['location'];
//   }

//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['id'] = this.id;
//     data['tags'] = this.tags;
//     if (this.pictures != null) {
//       data['pictures'] = this.pictures!.map((v) => v.toJson()).toList();
//     }
//     if (this.video != null) {
//       data['video'] = this.video!.toJson();
//     }
//     if (this.category != null) {
//       data['category'] = this.category!.toJson();
//     }
//     data['owner_avatar'] = this.ownerAvatar;
//     data['owner_name'] = this.ownerName;
//     data['title'] = this.title;
//     data['pay'] = this.pay;
//     data['status'] = this.status;
//     data['owner'] = this.owner;
//     data['is_listed'] = this.isListed;
//     data['applicants'] = this.applicants;
//     data['assignee'] = this.assignee;
//     data['description'] = this.description;
//     data['due_date'] = this.dueDate;
//     data['creation_date'] = this.creationDate;
//     data['location'] = this.location;
//     return data;
//   }
// }

// class Pictures {
//   String? id;
//   String? image;
//   String? caption;

//   Pictures({this.id, this.image, this.caption});

//   Pictures.fromJson(Map<String, dynamic> json) {
//     id = json['id'];
//     image = json['image'];
//     caption = json['caption'];
//   }

//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['id'] = this.id;
//     data['image'] = this.image;
//     data['caption'] = this.caption;
//     return data;
//   }
// }

// class Video {
//   String? id;
//   String? file;
//   Null? imagePoster;
//   Null? caption;

//   Video({this.id, this.file, this.imagePoster, this.caption});

//   Video.fromJson(Map<String, dynamic> json) {
//     id = json['id'];
//     file = json['file'];
//     imagePoster = json['image_poster'];
//     caption = json['caption'];
//   }

//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['id'] = this.id;
//     data['file'] = this.file;
//     data['image_poster'] = this.imagePoster;
//     data['caption'] = this.caption;
//     return data;
//   }
// }

// class Category {
//   String? slug;
//   String? image;
//   String? name;

//   Category({this.slug, this.image, this.name});

//   Category.fromJson(Map<String, dynamic> json) {
//     slug = json['slug'];
//     image = json['image'];
//     name = json['name'];
//   }

//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['slug'] = this.slug;
//     data['image'] = this.image;
//     data['name'] = this.name;
//     return data;
//   }
// }
