import 'package:Slydo/screens/more_apps/messaging/chat/models/gif_model/Analytics.dart';
import 'package:Slydo/screens/more_apps/messaging/chat/models/gif_model/Images.dart';

class GIFModel {
  Analytics analytics;
  String analyticsResponsePayload;
  String bitlyGifUrl;
  String bitlyUrl;
  String contentUrl;
  String embedUrl;
  String id;
  Images images;
  String importDatetime;
  int isSticker;
  String rating;
  String slug;
  String source;
  String sourcePostUrl;
  String sourceTld;
  String title;
  String trendingDatetime;
  String type;
  String url;
  String username;

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
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['analytics_response_payload'] = this.analyticsResponsePayload;
    data['bitly_gif_url'] = this.bitlyGifUrl;
    data['bitly_url'] = this.bitlyUrl;
    data['content_url'] = this.contentUrl;
    data['embed_url'] = this.embedUrl;
    data['id'] = this.id;
    data['import_datetime'] = this.importDatetime;
    data['is_sticker'] = this.isSticker;
    data['rating'] = this.rating;
    data['slug'] = this.slug;
    data['source'] = this.source;
    data['source_post_url'] = this.sourcePostUrl;
    data['source_tld'] = this.sourceTld;
    data['title'] = this.title;
    data['trending_datetime'] = this.trendingDatetime;
    data['type'] = this.type;
    data['url'] = this.url;
    data['username'] = this.username;
    if (this.analytics != null) {
      data['analytics'] = this.analytics.toJson();
    }
    if (this.images != null) {
      data['images'] = this.images.toJson();
    }
    return data;
  }
}
