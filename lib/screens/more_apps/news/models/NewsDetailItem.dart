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
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['author'] = this.author;
    data['author_avatar'] = this.authorAvatar;
    data['description'] = this.description;
    data['poster'] = this.poster;
    data['read'] = this.readTime;
    data['short_description'] = this.shortDescription;
    data['sub_header'] = this.subHeader;
    data['title'] = this.title;
    data['upload_time'] = this.uploadTime;
    data['video'] = this.video;
    if (this.newsListItems != null) {
      data['news_list_items'] =
          this.newsListItems!.map((v) => v.toJson()).toList();
    }
    if (this.tags != null) {
      data['tags'] = this.tags;
    }
    return data;
  }
}
