/// id : "7f075b56-c5b3-477f-85bc-ece0c5ed7903"
/// author_avatar : "https://slydo-assets.s3.amazonaws.com/media/customer/avatar/4f4470b6dbf44b62859ddf2b945d7472.jpg"
/// title : "Starting An E-Commerce Business 101"
/// tag_line : "Test title1"
/// text : "Morbi in sem quis dui placerat ornare. Pellentesque odio nisi, euismod in, pharetra a, ultricies in, diam. Sed arcu. Cras consequat.\nPraesent dapibus, neque id cursus faucibus, tortor neque egestas augue, eu vulputate magna eros eu erat. Aliquam erat volutpat. Nam dui mi, tincidunt quis, accumsan porttitor, facilisis luctus, metus.\nPhasellus ultrices nulla quis nibh. Quisque a lectus. Donec consectetuer ligula vulputate sem tristique cursus. Nam nulla quam, gravida non, commodo a, sodales sit amet, nisi.\nPellentesque fermentum dolor. Aliquam quam lectus, facilisis auctor, ultrices ut, elementum vulputate, nunc.\nPellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas. Vestibulum tortor quam, feugiat vitae, ultricies eget, tempor sit amet, ante. Donec eu libero sit amet quam egestas semper. Aenean ultricies mi vitae est. Mauris placerat eleifend leo. Quisque sit amet est et sapien ullamcorper pharetra. Vestibulum erat wisi, condimentum sed, commodo vitae, ornare sit amet, wisi. Aenean fermentum, elit eget tincidunt condimentum, eros ipsum rutrum orci, sagittis tempus lacus enim ac dui. Donec non enim in turpis pulvinar facilisis. Ut felis. Praesent dapibus, neque id cursus faucibus, tortor neque egestas augue, eu vulputate magna eros eu erat. Aliquam erat volutpat. Nam dui mi, tincidunt quis, accumsan porttitor, facilisis luctus, metus\n\nDefinition list\nConsectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.\nLorem ipsum dolor sit amet\nConsectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat."
/// image : "https://slydo-assets.s3.amazonaws.com/media/post_image/13184203-business-news-newspaper-with-white-background.jpg"
/// video : null
/// is_published : true
/// enable_commenting : false
/// enable_like : true
/// author_username : "black"
/// viewers : null
/// created_at : "2022-01-03T16:21:22.899308+01:00"
/// modified_at : "2022-01-06T22:37:28.732270+01:00"
/// published_date : "2022-01-03T16:21:22.744653+01:00"
/// likes : 0
/// dislikes : 0

class UserPost {
  UserPost({
    this.id,
    this.tags,
    this.text,
    this.image,
    this.video,
    this.title,
    this.likes,
    this.views,
    this.userLiked,
    this.userDisLiked,
    this.viewers,
    this.tagLine,
    this.dislikes,
    this.readTime,
    this.createdAt,
    this.enableLike,
    this.authorName,
    this.publicRead,
    this.modifiedAt,
    this.isPublished,
    this.authorAvatar,
    this.publishedDate,
    this.authorUsername,
    this.enableCommenting,
  });

  UserPost.fromJson(dynamic json) {
    id = json['id'];
    tags = json['tags'];
    text = json['text'];
    title = json['title'];
    image = json['image'];
    video = json['video'];
    likes = json['likes'];
    views = json['views'];
    userLiked = json['user_liked'];
    userDisLiked = json['user_disliked'];
    viewers = json['viewers'];
    tagLine = json['tag_line'];
    dislikes = json['dislikes'];
    readTime = json['read_time'];
    publicRead = json['public_read'];
    enableLike = json['enable_like'];
    authorName = json['author_name'];
    isPublished = json['is_published'];
    authorAvatar = json['author_avatar'];
    authorUsername = json['author_username'];
    enableCommenting = json['enable_commenting'];
    modifiedAt = json['modified_at'] != null
        ? DateTime.parse(json['modified_at'])
        : null;
    publishedDate = json['published_date'] != null
        ? DateTime.parse(json['published_date'])
        : null;
    createdAt =
        json['created_at'] != null ? DateTime.parse(json['created_at']) : null;
  }

  String? id;
  int? likes;
  int? views;
  String? text;
  String? title;
  int? dislikes;
  String? image;
  String? video;
  bool? userLiked;
  bool? userDisLiked;
  dynamic viewers;
  String? tagLine;
  bool? enableLike;
  bool? publicRead;
  int? readTime;
  bool? isPublished;
  String? authorName;
  List<dynamic>? tags;
  DateTime? createdAt;
  DateTime? modifiedAt;
  String? authorAvatar;
  bool? enableCommenting;
  String? authorUsername;
  DateTime? publishedDate;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['text'] = text;
    map['title'] = title;
    map['video'] = video;
    map['image'] = image;
    map['likes'] = likes;
    map['viewers'] = viewers;
    map['tag_line'] = tagLine;
    map['dislikes'] = dislikes;
    map['created_at'] = createdAt?.toIso8601String();

    map['modified_at'] = modifiedAt?.toIso8601String();

    map['enable_like'] = enableLike;
    map['is_published'] = isPublished;
    map['author_avatar'] = authorAvatar;
    map['published_date'] = publishedDate?.toIso8601String();
    map['author_username'] = authorUsername;
    map['enable_commenting'] = enableCommenting;
    return map;
  }
}
