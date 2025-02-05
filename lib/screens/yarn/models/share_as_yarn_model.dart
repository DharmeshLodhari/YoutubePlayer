class ShareAsYarnModel {
  int? id;
  String? name;

  ShareAsYarnModel({this.id, this.name});

  ShareAsYarnModel.fromJson(object) {
    id = object['id'];
    name = object['name'];
  }

  Map toJson() => {"id": id, "name": name};

  static List<ShareAsYarnModel> get shareAsYarnModel => [
        ShareAsYarnModel(id: 13, name: 'Rating • 13'),
        ShareAsYarnModel(id: 15, name: 'Rating • 15'),
        ShareAsYarnModel(id: 18, name: 'Rating • 18'),
        ShareAsYarnModel(id: 21, name: 'Rating • 21')
      ];
}
