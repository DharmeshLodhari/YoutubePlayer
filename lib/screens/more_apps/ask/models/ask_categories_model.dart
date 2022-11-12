import 'dart:ui';

class AskCategories {
  String? id;
  String? name;
  Color? color;

  AskCategories({this.id, this.name, this.color});

  AskCategories.fromJson(object) {
    this.id = object['id'];
    this.name = object['name'];
  }

  Map toJson() => {
    "id": id,
    "name": name,
  };
}