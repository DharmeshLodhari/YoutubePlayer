/// id : 1
/// title : "Twice As Tall Album"
/// image : "https://trendybeatz.com/images/Burna-Boy-Twice-As-Tall-Album-Cover.jpg"
/// audio : [{"src":"https://rawcdn.githack.com/BlackStriker99/slydo-mock-data/f133a23f344e2e96b275800d505011f54a4dc20f/Burna-Boy-Monsters-You-Made-ft-Chris-Martin.mp3","metas":{"id":"1","title":"Monsters You Made","artist":"Burna Boy","album":"Twice As Tall Album","image":"https://trendybeatz.com/images/Burna-Boy-Twice-As-Tall-Album-Cover.jpg"}},{"src":"https://rawcdn.githack.com/BlackStriker99/slydo-mock-data/673e733fe5e055fb5d3d1e35500e0f4991d4faad/Martin Garrix - Animals (Original Mix).mp3","metas":{"id":"2","title":"Animals (Original Mix)","artist":"Martin Garrix","album":"Animals","image":"https://i.pinimg.com/originals/ce/de/a5/cedea5f757301128e39ebf13a36d3596.jpg"}},{"src":"https://rawcdn.githack.com/BlackStriker99/slydo-mock-data/ab04b116c1c257db491490aa8159fff960edeb55/Olamide-Wizkid-Kana.mp3","metas":{"id":"3","title":"Kana","artist":"Olamide & Wizkid","album":"Olamide & Wizkid","image":"https://www.naijavibes.com/wp-content/uploads/2018/05/Olamide-Kana-Artwork.jpg"}},{"src":"https://rawcdn.githack.com/BlackStriker99/slydo-mock-data/7454987a918388eec9174581ef08c52fb18eb412/Tekno-Sudden.mp3","metas":{"id":"4","title":"Sudden","artist":"Tekno","album":"Singles","image":"https://trendybeatz.com/images/tekno-sudden-artwork.jpg"}},{"src":"https://rawcdn.githack.com/BlackStriker99/slydo-mock-data/7454987a918388eec9174581ef08c52fb18eb412/Davido_ChrisBrown.mp3","metas":{"id":"5","title":"Blow My Mind","artist":"Davido","album":"Blow My Mind ft Chris Brown","image":"https://trendybeatz.com/images/Davido_ChrisBrown.jpg"}}]

class MusicAlbum {
  int _id;
  String _title;
  String _image;
  List<Audio> _audio;

  int get id => _id;
  String get title => _title;
  String get image => _image;
  List<Audio> get audio => _audio;

  MusicAlbum({int id, String title, String image, List<Audio> audio}) {
    _id = id;
    _title = title;
    _image = image;
    _audio = audio;
  }

  MusicAlbum.fromJson(dynamic json) {
    _id = json["id"];
    _title = json["title"];
    _image = json["image"];
    if (json["audio"] != null) {
      _audio = [];
      json["audio"].forEach((v) {
        _audio.add(Audio.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    var map = <String, dynamic>{};
    map["id"] = _id;
    map["title"] = _title;
    map["image"] = _image;
    if (_audio != null) {
      map["audio"] = _audio.map((v) => v.toJson()).toList();
    }
    return map;
  }
}

/// src : "https://rawcdn.githack.com/BlackStriker99/slydo-mock-data/f133a23f344e2e96b275800d505011f54a4dc20f/Burna-Boy-Monsters-You-Made-ft-Chris-Martin.mp3"
/// metas : {"id":"1","title":"Monsters You Made","artist":"Burna Boy","album":"Twice As Tall Album","image":"https://trendybeatz.com/images/Burna-Boy-Twice-As-Tall-Album-Cover.jpg"}

class Audio {
  String _src;
  Metas _metas;

  String get src => _src;
  Metas get metas => _metas;

  Audio({String src, Metas metas}) {
    _src = src;
    _metas = metas;
  }

  Audio.fromJson(dynamic json) {
    _src = json["src"];
    _metas = json["metas"] != null ? Metas.fromJson(json["metas"]) : null;
  }

  Map<String, dynamic> toJson() {
    var map = <String, dynamic>{};
    map["src"] = _src;
    if (_metas != null) {
      map["metas"] = _metas.toJson();
    }
    return map;
  }
}

/// id : "1"
/// title : "Monsters You Made"
/// artist : "Burna Boy"
/// album : "Twice As Tall Album"
/// image : "https://trendybeatz.com/images/Burna-Boy-Twice-As-Tall-Album-Cover.jpg"

class Metas {
  String _id;
  String _title;
  String _artist;
  String _album;
  String _image;

  String get id => _id;
  String get title => _title;
  String get artist => _artist;
  String get album => _album;
  String get image => _image;

  Metas({String id, String title, String artist, String album, String image}) {
    _id = id;
    _title = title;
    _artist = artist;
    _album = album;
    _image = image;
  }

  Metas.fromJson(dynamic json) {
    _id = json["id"];
    _title = json["title"];
    _artist = json["artist"];
    _album = json["album"];
    _image = json["image"];
  }

  Map<String, dynamic> toJson() {
    var map = <String, dynamic>{};
    map["id"] = _id;
    map["title"] = _title;
    map["artist"] = _artist;
    map["album"] = _album;
    map["image"] = _image;
    return map;
  }
}
