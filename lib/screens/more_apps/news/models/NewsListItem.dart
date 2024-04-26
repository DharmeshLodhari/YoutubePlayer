class NewsListItem {
  String? description;
  String? image;
  String? title;

  NewsListItem({this.description, this.image, this.title});

  factory NewsListItem.fromJson(Map<String, dynamic> json) {
    return NewsListItem(
      description: json['description'] ?? "",
      image: json['image'] ?? "",
      title: json['title'] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['description'] = description;
    data['image'] = image;
    data['title'] = title;
    return data;
  }
}
