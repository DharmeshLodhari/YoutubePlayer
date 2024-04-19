import 'package:Slydo/screens/more_apps/messaging/chat/models/gif_model/Onclick.dart';
import 'package:Slydo/screens/more_apps/messaging/chat/models/gif_model/Onload.dart';
import 'package:Slydo/screens/more_apps/messaging/chat/models/gif_model/Onsent.dart';

class Analytics {
  Onclick? onclick;
  Onload? onload;
  Onsent? onsent;

  Analytics({this.onclick, this.onload, this.onsent});

  factory Analytics.fromJson(Map<String, dynamic> json) {
    return Analytics(
      onclick:
          json['onclick'] != null ? Onclick.fromJson(json['onclick']) : null,
      onload: json['onload'] != null ? Onload.fromJson(json['onload']) : null,
      onsent: json['onsent'] != null ? Onsent.fromJson(json['onsent']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    if (this.onclick != null) {
      data['onclick'] = this.onclick!.toJson();
    }
    if (this.onload != null) {
      data['onload'] = this.onload!.toJson();
    }
    if (this.onsent != null) {
      data['onsent'] = this.onsent!.toJson();
    }
    return data;
  }
}
