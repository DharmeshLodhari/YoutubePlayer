import 'dart:ui';

class AskCategories {
  String? id;
  String? name;
  String? color;
  String? image;

  AskCategories({this.id, this.name, this.color, this.image});

  AskCategories.fromJson(object) {
    this.id = object['id'];
    this.name = object['name'];
    this.color = object['color'];
    this.image = object['image'];
  }

  Map toJson() => {
        "id": id,
        "name": name,
        "color": color,
        "image": image,
      };
}

class UsersCategories {
  String? id;
  String? owner;
  List<AskCategories>? categories;

  UsersCategories({this.id, this.owner, this.categories});

  UsersCategories.fromJson(object) {
    this.id = object["id"];
    this.owner = object["owner"];
    if (object["categories"] != null) {
      categories = [];
      object["categories"].forEach((v) {
        categories!.add(AskCategories.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "owner": owner,
        "categories": categories!.map((v) => v.toJson()).toList(),
      };
}

class UserCategoriesStructure {
  String? userId;
  String? userSelectedCategory;

  UserCategoriesStructure({this.userId, this.userSelectedCategory});

  UserCategoriesStructure.fromJson(object) {
    this.userId = object['user_id'];
    this.userSelectedCategory = object['categories'];
  }

  Map<String, dynamic> toJson() => {
        "user_id": userId,
        "categories": userSelectedCategory,
      };
}
