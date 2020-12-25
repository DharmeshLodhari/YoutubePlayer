class Media {
    String `file`;
    String type;

    Media({this.`file`, this.type});

    factory Media.fromJson(Map<String, dynamic> json) {
        return Media(
            `file`: json['`file`'], 
            type: json['type'], 
        );
    }

    Map<String, dynamic> toJson() {
        final Map<String, dynamic> data = new Map<String, dynamic>();
        data['`file`'] = this.`file`;
        data['type'] = this.type;
        return data;
    }
}