class Looping {
    String mp4;
    String mp4_size;

    Looping({this.mp4, this.mp4_size});

    factory Looping.fromJson(Map<String, dynamic> json) {
        return Looping(
            mp4: json['mp4'], 
            mp4_size: json['mp4_size'], 
        );
    }

    Map<String, dynamic> toJson() {
        final Map<String, dynamic> data = new Map<String, dynamic>();
        data['mp4'] = this.mp4;
        data['mp4_size'] = this.mp4_size;
        return data;
    }
}