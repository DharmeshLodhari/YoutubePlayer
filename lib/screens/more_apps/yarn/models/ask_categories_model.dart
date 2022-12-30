class YarnCategories {
  String? id;
  String? name;
  String? color;
  String? image;

  YarnCategories({this.id, this.name, this.color, this.image});

  YarnCategories.fromJson(object) {
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
  List<YarnCategories>? categories;

  UsersCategories({this.id, this.owner, this.categories});

  UsersCategories.fromJson(object) {
    this.id = object["id"];
    this.owner = object["owner"];
    if (object["categories"] != null) {
      categories = [];
      object["categories"].forEach((v) {
        categories!.add(YarnCategories.fromJson(v));
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

class UserYarnSettings {
  String? id;
  String? owner;
  bool allowAdultContent = false;
  bool allowSensitiveContent = false;
  bool allowNotification = false;
  UsersCategories? categories;

  UserYarnSettings(
      {this.id,
      this.owner,
      this.allowAdultContent = false,
      this.allowSensitiveContent = false,
      this.allowNotification = false,
      this.categories});

  UserYarnSettings.fromJson(object) {
    this.id = object["id"];
    this.allowAdultContent = object['allow_adult_content'] ?? false;
    this.allowSensitiveContent = object['allow_sensitive_content'] ?? false;
    this.allowNotification = object['allow_notification'] ?? false;
    this.owner = object["owner"];
    this.categories = UsersCategories.fromJson(object);
  }
}
