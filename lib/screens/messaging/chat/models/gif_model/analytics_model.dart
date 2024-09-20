import 'package:Slydo/screens/messaging/chat/models/gif_model/on_click.dart';
import 'package:Slydo/screens/messaging/chat/models/gif_model/on_load.dart';
import 'package:Slydo/screens/messaging/chat/models/gif_model/on_sent.dart';

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
    final Map<String, dynamic> data = <String, dynamic>{};
    if (onclick != null) {
      data['onclick'] = onclick!.toJson();
    }
    if (onload != null) {
      data['onload'] = onload!.toJson();
    }
    if (onsent != null) {
      data['onsent'] = onsent!.toJson();
    }
    return data;
  }
}
