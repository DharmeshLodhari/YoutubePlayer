class Photo {
  int? height;
  List<String>? htmlAttributions;
  String? photoReference;
  int? width;

  Photo({this.height, this.htmlAttributions, this.photoReference, this.width});

  factory Photo.fromJson(Map<String, dynamic> json) {
    return Photo(
      height: json['height'],
      htmlAttributions: json['html_attributions'] != null
          ? List<String>.from(json['html_attributions'])
          : null,
      photoReference: json['photo_reference'],
      width: json['width'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['height'] = this.height;
    data['photo_reference'] = this.photoReference;
    data['width'] = this.width;
    if (this.htmlAttributions != null) {
      data['html_attributions'] = this.htmlAttributions;
    }
    return data;
  }
}
