import 'package:Slydo/screens/more_apps/news/models/NewsListItem.dart';

class NewsDetailItem {
  String? image;
  String? author;
  String? authorAvatar;
  String? description;
  List<NewsListItem>? newsListItems;
  String? poster;
  int? readTime;
  String? shortDescription;
  String? subHeader;
  List<String>? tags;
  String? title;
  String? uploadTime;
  String? video;

  NewsDetailItem(
      {this.image,
      this.author = "",
      this.authorAvatar = "",
      this.description = "",
      this.newsListItems = const [],
      this.poster = "",
      this.readTime,
      this.shortDescription = "",
      this.subHeader = "",
      this.tags = const [],
      this.title = "",
      this.uploadTime = "",
      this.video = ""});

  factory NewsDetailItem.fromJson(Map<String, dynamic> json) {
    return NewsDetailItem(
      author: json['author'],
      image: json['image'],
      authorAvatar: json['author_avatar'],
      description: json['description'],
      newsListItems: json['news_list_items'] != null
          ? (json['news_list_items'] as List)
              .map((i) => NewsListItem.fromJson(i))
              .toList()
          : null,
      poster: json['poster'],
      readTime: json['read'],
      shortDescription: json['short_description'],
      subHeader: json['sub_header'],
      tags: json['tags'] != null ? List<String>.from(json['tags']) : null,
      title: json['title'],
      uploadTime: json['upload_time'],
      video: json['video'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['author'] = author;
    data['author_avatar'] = authorAvatar;
    data['description'] = description;
    data['poster'] = poster;
    data['read'] = readTime;
    data['short_description'] = shortDescription;
    data['sub_header'] = subHeader;
    data['title'] = title;
    data['upload_time'] = uploadTime;
    data['video'] = video;
    if (newsListItems != null) {
      data['news_list_items'] = newsListItems!.map((v) => v.toJson()).toList();
    }
    if (tags != null) {
      data['tags'] = tags;
    }
    return data;
  }
}
