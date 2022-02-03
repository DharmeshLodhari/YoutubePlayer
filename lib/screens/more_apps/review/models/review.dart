/// id : "ae9127f1-566c-4634-86c5-d4c17ea6c02f"
/// rating : 3
/// author_avatar : "https://slydo-assets.s3.amazonaws.com/media/customer/avatar/4059d32af9974a66b898964736173075.jpg"
/// text : "Very nice business."
/// author_username : "abiola.rasheed.19"
/// likes : 0
/// dislikes : 0
/// created_at : "2022-01-04T16:17:12.540540+01:00"
/// model_object : "496c7f0e-1593-4970-a620-add66f0eaf40"

class Review {
  Review({
    this.id,
    this.rating,
    this.authorAvatar,
    this.text,
    this.authorUsername,
    this.likes,
    this.dislikes,
    this.createdAt,
    this.modelObject,
  });

  Review.fromJson(dynamic json) {
    id = json['id'];
    rating = json['rating'];
    authorAvatar = json['author_avatar'];
    text = json['text'];
    authorUsername = json['author_username'];
    likes = json['likes'];
    dislikes = json['dislikes'];
    createdAt = json['created_at'];
    modelObject = json['model_object'];
  }
  String? id;
  int? rating;
  String? authorAvatar;
  String? text;
  String? authorUsername;
  int? likes;
  int? dislikes;
  String? createdAt;
  String? modelObject;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['rating'] = rating;
    map['author_avatar'] = authorAvatar;
    map['text'] = text;
    map['author_username'] = authorUsername;
    map['likes'] = likes;
    map['dislikes'] = dislikes;
    map['created_at'] = createdAt;
    map['model_object'] = modelObject;
    return map;
  }
}
