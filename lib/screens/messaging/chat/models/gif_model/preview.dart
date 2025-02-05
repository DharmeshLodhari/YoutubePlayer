class Preview {
  String? height;
  String? mp4;
  String? mp4Size;
  String? width;

  Preview({this.height, this.mp4, this.mp4Size, this.width});

  factory Preview.fromJson(Map<String, dynamic> json) {
    return Preview(
      height: json['height'],
      mp4: json['mp4'],
      mp4Size: json['mp4_size'],
      width: json['width'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['height'] = height;
    data['mp4'] = mp4;
    data['mp4_size'] = mp4Size;
    data['width'] = width;
    return data;
  }
}
