// To parse this JSON data, do
//
//     final myJobList = myJobListFromJson(jsonString);

import 'dart:convert';

import 'package:Slydo/screens/more_apps/service_hub/models/active_job_listing.dart';
import 'package:Slydo/screens/more_apps/service_hub/models/jobs.dart';

MyJobList myJobListFromJson(String str) => MyJobList.fromJson(json.decode(str));

String myJobListToJson(MyJobList data) => json.encode(data.toJson());

class MyJobList {
  MyJobList({
    this.count,
    this.next,
    this.previous,
    this.results,
  });

  int? count;
  dynamic next;
  dynamic previous;
  List<JobModel>? results;

  factory MyJobList.fromJson(Map<String, dynamic> json) => MyJobList(
        count: json["count"],
        next: json["next"],
        previous: json["previous"],
        results: List<JobModel>.from(json["results"].map((x) => JobModel.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "count": count,
        "next": next,
        "previous": previous,
        "results": List<dynamic>.from(results!.map((x) => x.toJson())),
      };
}

// class MyJobListData {
//   MyJobListData({
//     this.id,
//     this.tags,
//     this.pictures,
//     this.video,
//     this.category,
//     this.ownerAvatar,
//     this.ownerName,
//     this.title,
//     this.pay,
//     this.status,
//     this.owner,
//     this.isListed,
//     this.applicants,
//     this.assignee,
//     this.description,
//     this.dueDate,
//     this.creationDate,
//     this.location,
//   });

//   String? id;
//   List<dynamic>? tags;
//   List<Picture>? pictures;
//   dynamic video;
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
//   DateTime? dueDate;
//   DateTime? creationDate;
//   String? location;

//   factory MyJobListData.fromJson(Map<String, dynamic> json) => MyJobListData(
//         id: json["id"],
//         tags: List<dynamic>.from(json["tags"].map((x) => x)),
//         pictures: List<Picture>.from(
//             json["pictures"].map((x) => Picture.fromJson(x))),
//         video: json["video"],
//         category: Category.fromJson(json["category"]),
//         ownerAvatar: json["owner_avatar"],
//         ownerName: json["owner_name"],
//         title: json["title"],
//         pay: json["pay"],
//         status: json["status"],
//         owner: json["owner"],
//         isListed: json["is_listed"],
//         applicants: json["applicants"],
//         assignee: json["assignee"],
//         description: json["description"],
//         dueDate: DateTime.parse(json["due_date"]),
//         creationDate: DateTime.parse(json["creation_date"]),
//         location: json["location"],
//       );

//   Map<String, dynamic> toJson() => {
//         "id": id,
//         "tags": List<dynamic>.from(tags!.map((x) => x)),
//         "pictures": List<dynamic>.from(pictures!.map((x) => x.toJson())),
//         "video": video,
//         "category": category!.toJson(),
//         "owner_avatar": ownerAvatar,
//         "owner_name": ownerName,
//         "title": title,
//         "pay": pay,
//         "status": status,
//         "owner": owner,
//         "is_listed": isListed,
//         "applicants": applicants,
//         "assignee": assignee,
//         "description": description,
//         "due_date":
//             "${dueDate!.year.toString().padLeft(4, '0')}-${dueDate!.month.toString().padLeft(2, '0')}-${dueDate!.day.toString().padLeft(2, '0')}",
//         "creation_date": creationDate!.toIso8601String(),
//         "location": location,
//       };
// }

// class Category {
//   Category({
//     this.slug,
//     this.image,
//     this.name,
//   });

//   String? slug;
//   String? image;
//   String? name;

//   factory Category.fromJson(Map<String, dynamic> json) => Category(
//         slug: json["slug"],
//         image: json["image"],
//         name: json["name"],
//       );

//   Map<String, dynamic> toJson() => {
//         "slug": slug,
//         "image": image,
//         "name": name,
//       };
// }

// class Picture {
//   Picture({
//     this.id,
//     this.image,
//     this.caption,
//   });

//   String? id;
//   String? image;
//   String? caption;

//   factory Picture.fromJson(Map<String, dynamic> json) => Picture(
//         id: json["id"],
//         image: json["image"],
//         caption: json["caption"],
//       );

//   Map<String, dynamic> toJson() => {
//         "id": id,
//         "image": image,
//         "caption": caption,
//       };
// }
