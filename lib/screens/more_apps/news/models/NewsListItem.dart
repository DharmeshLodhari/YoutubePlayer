class NewsListItem {
  String description;
  String image;
  String title;

  NewsListItem({this.description, this.image, this.title});

  factory NewsListItem.fromJson(Map<String, dynamic> json) {
    return NewsListItem(
      description: json['description'] ?? "",
      image: json['image'] ?? "",
      title: json['title'] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['description'] = this.description;
    data['image'] = this.image;
    data['title'] = this.title;
    return data;
  }
}
