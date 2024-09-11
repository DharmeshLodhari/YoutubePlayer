// To parse this JSON data, do
//
//     final listOfCategories = listOfCategoriesFromJson(jsonString);

import 'dart:convert';

ListOfCategories listOfCategoriesFromJson(String str) =>
    ListOfCategories.fromJson(json.decode(str));

String listOfCategoriesToJson(ListOfCategories data) =>
    json.encode(data.toJson());

class ListOfCategories {
  ListOfCategories({
    this.count,
    this.next,
    this.previous,
    this.results,
  });

  int? count;
  String? next;
  dynamic previous;
  List<CategoryListData>? results;

  factory ListOfCategories.fromJson(Map<String, dynamic> json) =>
      ListOfCategories(
        count: json["count"],
        next: json["next"],
        previous: json["previous"],
        results:
            List<CategoryListData>.from(json["results"]!.map((x) => CategoryListData.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "count": count,
        "next": next,
        "previous": previous,
        "results": List<dynamic>.from(results!.map((x) => x.toJson())),
      };
}

class CategoryListData {
  CategoryListData({
    this.slug,
    this.image,
    this.name,
  });

  String? slug;
  String? image;
  String? name;

  factory CategoryListData.fromJson(Map<String, dynamic> json) => CategoryListData(
        slug: json["slug"],
        image: json["image"],
        name: json["name"],
      );

  Map<String, dynamic> toJson() => {
        "slug": slug,
        "image": image,
        "name": name,
      };
}
