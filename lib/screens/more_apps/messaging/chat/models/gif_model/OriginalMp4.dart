class OriginalMp4 {
  String height;
  String mp4;
  String mp4Size;
  String width;

  OriginalMp4({this.height, this.mp4, this.mp4Size, this.width});

  factory OriginalMp4.fromJson(Map<String, dynamic> json) {
    return OriginalMp4(
      height: json['height'],
      mp4: json['mp4'],
      mp4Size: json['mp4_size'],
      width: json['width'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['height'] = this.height;
    data['mp4'] = this.mp4;
    data['mp4_size'] = this.mp4Size;
    data['width'] = this.width;
    return data;
  }
}
