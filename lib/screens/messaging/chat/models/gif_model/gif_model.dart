import 'package:Slydo/screens/messaging/chat/models/gif_model/analytics_model.dart';
import 'package:Slydo/screens/messaging/chat/models/gif_model/images_model.dart';

class GIFModel {
  Analytics? analytics;
  String? analyticsResponsePayload;
  String? bitlyGifUrl;
  String? bitlyUrl;
  String? contentUrl;
  String? embedUrl;
  String? id;
  Images? images;
  String? importDatetime;
  int? isSticker;
  String? rating;
  String? slug;
  String? source;
  String? sourcePostUrl;
  String? sourceTld;
  String? title;
  String? trendingDatetime;
  String? type;
  String? url;
  String? username;

  GIFModel(
      {this.analytics,
      this.analyticsResponsePayload,
      this.bitlyGifUrl,
      this.bitlyUrl,
      this.contentUrl,
      this.embedUrl,
      this.id,
      this.images,
      this.importDatetime,
      this.isSticker,
      this.rating,
      this.slug,
      this.source,
      this.sourcePostUrl,
      this.sourceTld,
      this.title,
      this.trendingDatetime,
      this.type,
      this.url,
      this.username});

  factory GIFModel.fromJson(Map<String, dynamic> json) {
    return GIFModel(
      analytics: json['analytics'] != null
          ? Analytics.fromJson(json['analytics'])
          : null,
      analyticsResponsePayload: json['analytics_response_payload'],
      bitlyGifUrl: json['bitly_gif_url'],
      bitlyUrl: json['bitly_url'],
      contentUrl: json['content_url'],
      embedUrl: json['embed_url'],
      id: json['id'],
      images: json['images'] != null ? Images.fromJson(json['images']) : null,
      importDatetime: json['import_datetime'],
      isSticker: json['is_sticker'],
      rating: json['rating'],
      slug: json['slug'],
      source: json['source'],
      sourcePostUrl: json['source_post_url'],
      sourceTld: json['source_tld'],
      title: json['title'],
      trendingDatetime: json['trending_datetime'],
      type: json['type'],
      url: json['url'],
      username: json['username'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['analytics_response_payload'] = analyticsResponsePayload;
    data['bitly_gif_url'] = bitlyGifUrl;
    data['bitly_url'] = bitlyUrl;
    data['content_url'] = contentUrl;
    data['embed_url'] = embedUrl;
    data['id'] = id;
    data['import_datetime'] = importDatetime;
    data['is_sticker'] = isSticker;
    data['rating'] = rating;
    data['slug'] = slug;
    data['source'] = source;
    data['source_post_url'] = sourcePostUrl;
    data['source_tld'] = sourceTld;
    data['title'] = title;
    data['trending_datetime'] = trendingDatetime;
    data['type'] = type;
    data['url'] = url;
    data['username'] = username;
    if (analytics != null) {
      data['analytics'] = analytics!.toJson();
    }
    if (images != null) {
      data['images'] = images!.toJson();
    }
    return data;
  }
}
