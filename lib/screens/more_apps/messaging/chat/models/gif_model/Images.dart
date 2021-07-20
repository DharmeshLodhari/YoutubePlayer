import 'Downsized.dart';
import 'DownsizedLarge.dart';
import 'DownsizedMedium.dart';
import 'DownsizedSmall.dart';
import 'DownsizedStill.dart';
import 'FixedHeight.dart';
import 'FixedHeightDownsampled.dart';
import 'FixedHeightSmall.dart';
import 'FixedHeightSmallStill.dart';
import 'FixedHeightStill.dart';
import 'FixedWidth.dart';
import 'FixedWidthDownsampled.dart';
import 'FixedWidthSmall.dart';
import 'FixedWidthSmallStill.dart';
import 'FixedWidthStill.dart';
import 'Looping.dart';
import 'Original.dart';
import 'OriginalMp4.dart';
import 'OriginalStill.dart';
import 'Preview.dart';
import 'PreviewGif.dart';
import 'PreviewWebp.dart';
import 'WStill.dart';

class Images {
  WStill w_still;
  Downsized downsized;
  DownsizedLarge downsized_large;
  DownsizedMedium downsized_medium;
  DownsizedSmall downsized_small;
  DownsizedStill downsized_still;
  FixedHeight fixed_height;
  FixedHeightDownsampled fixed_height_downsampled;
  FixedHeightSmall fixed_height_small;
  FixedHeightSmallStill fixed_height_small_still;
  FixedHeightStill fixed_height_still;
  FixedWidth fixed_width;
  FixedWidthDownsampled fixed_width_downsampled;
  FixedWidthSmall fixed_width_small;
  FixedWidthSmallStill fixed_width_small_still;
  FixedWidthStill fixed_width_still;
  Looping looping;
  Original original;
  OriginalMp4 original_mp4;
  OriginalStill original_still;
  Preview preview;
  PreviewGif preview_gif;
  PreviewWebp preview_webp;

  Images(
      {this.w_still,
      this.downsized,
      this.downsized_large,
      this.downsized_medium,
      this.downsized_small,
      this.downsized_still,
      this.fixed_height,
      this.fixed_height_downsampled,
      this.fixed_height_small,
      this.fixed_height_small_still,
      this.fixed_height_still,
      this.fixed_width,
      this.fixed_width_downsampled,
      this.fixed_width_small,
      this.fixed_width_small_still,
      this.fixed_width_still,
      this.looping,
      this.original,
      this.original_mp4,
      this.original_still,
      this.preview,
      this.preview_gif,
      this.preview_webp});

  factory Images.fromJson(Map<String, dynamic> json) {
    return Images(
      w_still: json['480w_still'] != null
          ? WStill.fromJson(json['480w_still'])
          : null,
      downsized: json['downsized'] != null
          ? Downsized.fromJson(json['downsized'])
          : null,
      downsized_large: json['downsized_large'] != null
          ? DownsizedLarge.fromJson(json['downsized_large'])
          : null,
      downsized_medium: json['downsized_medium'] != null
          ? DownsizedMedium.fromJson(json['downsized_medium'])
          : null,
      downsized_small: json['downsized_small'] != null
          ? DownsizedSmall.fromJson(json['downsized_small'])
          : null,
      downsized_still: json['downsized_still'] != null
          ? DownsizedStill.fromJson(json['downsized_still'])
          : null,
      fixed_height: json['fixed_height'] != null
          ? FixedHeight.fromJson(json['fixed_height'])
          : null,
      fixed_height_downsampled: json['fixed_height_downsampled'] != null
          ? FixedHeightDownsampled.fromJson(json['fixed_height_downsampled'])
          : null,
      fixed_height_small: json['fixed_height_small'] != null
          ? FixedHeightSmall.fromJson(json['fixed_height_small'])
          : null,
      fixed_height_small_still: json['fixed_height_small_still'] != null
          ? FixedHeightSmallStill.fromJson(json['fixed_height_small_still'])
          : null,
      fixed_height_still: json['fixed_height_still'] != null
          ? FixedHeightStill.fromJson(json['fixed_height_still'])
          : null,
      fixed_width: json['fixed_width'] != null
          ? FixedWidth.fromJson(json['fixed_width'])
          : null,
      fixed_width_downsampled: json['fixed_width_downsampled'] != null
          ? FixedWidthDownsampled.fromJson(json['fixed_width_downsampled'])
          : null,
      fixed_width_small: json['fixed_width_small'] != null
          ? FixedWidthSmall.fromJson(json['fixed_width_small'])
          : null,
      fixed_width_small_still: json['fixed_width_small_still'] != null
          ? FixedWidthSmallStill.fromJson(json['fixed_width_small_still'])
          : null,
      fixed_width_still: json['fixed_width_still'] != null
          ? FixedWidthStill.fromJson(json['fixed_width_still'])
          : null,
      looping:
          json['looping'] != null ? Looping.fromJson(json['looping']) : null,
      original:
          json['original'] != null ? Original.fromJson(json['original']) : null,
      original_mp4: json['original_mp4'] != null
          ? OriginalMp4.fromJson(json['original_mp4'])
          : null,
      original_still: json['original_still'] != null
          ? OriginalStill.fromJson(json['original_still'])
          : null,
      preview:
          json['preview'] != null ? Preview.fromJson(json['preview']) : null,
      preview_gif: json['preview_gif'] != null
          ? PreviewGif.fromJson(json['preview_gif'])
          : null,
      preview_webp: json['preview_webp'] != null
          ? PreviewWebp.fromJson(json['preview_webp'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.w_still != null) {
      data['480w_still'] = this.w_still.toJson();
    }
    if (this.downsized != null) {
      data['downsized'] = this.downsized.toJson();
    }
    if (this.downsized_large != null) {
      data['downsized_large'] = this.downsized_large.toJson();
    }
    if (this.downsized_medium != null) {
      data['downsized_medium'] = this.downsized_medium.toJson();
    }
    if (this.downsized_small != null) {
      data['downsized_small'] = this.downsized_small.toJson();
    }
    if (this.downsized_still != null) {
      data['downsized_still'] = this.downsized_still.toJson();
    }
    if (this.fixed_height != null) {
      data['fixed_height'] = this.fixed_height.toJson();
    }
    if (this.fixed_height_downsampled != null) {
      data['fixed_height_downsampled'] = this.fixed_height_downsampled.toJson();
    }
    if (this.fixed_height_small != null) {
      data['fixed_height_small'] = this.fixed_height_small.toJson();
    }
    if (this.fixed_height_small_still != null) {
      data['fixed_height_small_still'] = this.fixed_height_small_still.toJson();
    }
    if (this.fixed_height_still != null) {
      data['fixed_height_still'] = this.fixed_height_still.toJson();
    }
    if (this.fixed_width != null) {
      data['fixed_width'] = this.fixed_width.toJson();
    }
    if (this.fixed_width_downsampled != null) {
      data['fixed_width_downsampled'] = this.fixed_width_downsampled.toJson();
    }
    if (this.fixed_width_small != null) {
      data['fixed_width_small'] = this.fixed_width_small.toJson();
    }
    if (this.fixed_width_small_still != null) {
      data['fixed_width_small_still'] = this.fixed_width_small_still.toJson();
    }
    if (this.fixed_width_still != null) {
      data['fixed_width_still'] = this.fixed_width_still.toJson();
    }
    if (this.looping != null) {
      data['looping'] = this.looping.toJson();
    }
    if (this.original != null) {
      data['original'] = this.original.toJson();
    }
    if (this.original_mp4 != null) {
      data['original_mp4'] = this.original_mp4.toJson();
    }
    if (this.original_still != null) {
      data['original_still'] = this.original_still.toJson();
    }
    if (this.preview != null) {
      data['preview'] = this.preview.toJson();
    }
    if (this.preview_gif != null) {
      data['preview_gif'] = this.preview_gif.toJson();
    }
    if (this.preview_webp != null) {
      data['preview_webp'] = this.preview_webp.toJson();
    }
    return data;
  }
}
