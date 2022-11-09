class AskCategories {
  String? id;
  String? name;

  AskCategories({this.id, this.name});

  AskCategories.fromJson(object) {
    this.id = object['id'];
    this.name = object['name'];
  }

  Map toJson() => {
    "id": id,
    "name": name,
  };
}