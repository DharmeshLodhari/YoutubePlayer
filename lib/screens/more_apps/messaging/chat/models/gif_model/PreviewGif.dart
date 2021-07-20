class PreviewGif {
  String height;
  String size;
  String url;
  String width;

  PreviewGif({this.height, this.size, this.url, this.width});

  factory PreviewGif.fromJson(Map<String, dynamic> json) {
    return PreviewGif(
      height: json['height'],
      size: json['size'],
      url: json['url'],
      width: json['width'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['height'] = this.height;
    data['size'] = this.size;
    data['url'] = this.url;
    data['width'] = this.width;
    return data;
  }
}
