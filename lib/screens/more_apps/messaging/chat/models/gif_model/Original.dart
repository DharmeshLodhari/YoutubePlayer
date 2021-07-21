class Original {
  String frames;
  String hash;
  String height;
  String mp4;
  String mp4_size;
  String size;
  String url;
  String webp;
  String webp_size;
  String width;

  Original(
      {this.frames,
      this.hash,
      this.height,
      this.mp4,
      this.mp4_size,
      this.size,
      this.url,
      this.webp,
      this.webp_size,
      this.width});

  factory Original.fromJson(Map<String, dynamic> json) {
    return Original(
      frames: json['frames'],
      hash: json['hash'],
      height: json['height'],
      mp4: json['mp4'],
      mp4_size: json['mp4_size'],
      size: json['size'],
      url: json['url'],
      webp: json['webp'],
      webp_size: json['webp_size'],
      width: json['width'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['frames'] = this.frames;
    data['hash'] = this.hash;
    data['height'] = this.height;
    data['mp4'] = this.mp4;
    data['mp4_size'] = this.mp4_size;
    data['size'] = this.size;
    data['url'] = this.url;
    data['webp'] = this.webp;
    data['webp_size'] = this.webp_size;
    data['width'] = this.width;
    return data;
  }
}
