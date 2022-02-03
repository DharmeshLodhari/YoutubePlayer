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
  WStill? wStill;
  Downsized? downsized;
  DownsizedLarge? downsizedLarge;
  DownsizedMedium? downsizedMedium;
  DownsizedSmall? downsizedSmall;
  DownsizedStill? downsizedStill;
  FixedHeight? fixedHeight;
  FixedHeightDownSampled? fixedHeightDownSampled;
  FixedHeightSmall? fixedHeightSmall;
  FixedHeightSmallStill? fixedHeightSmallStill;
  FixedHeightStill? fixedHeightStill;
  FixedWidth? fixedWidth;
  FixedWidthDownSampled? fixedWidthDownSampled;
  FixedWidthSmall? fixedWidthSmall;
  FixedWidthSmallStill? fixedWidthSmallStill;
  FixedWidthStill? fixedWidthStill;
  Looping? looping;
  Original? original;
  OriginalMp4? originalMp4;
  OriginalStill? originalStill;
  Preview? preview;
  PreviewGif? previewGif;
  PreviewWebp? previewWebp;

  Images(
      {this.wStill,
      this.downsized,
      this.downsizedLarge,
      this.downsizedMedium,
      this.downsizedSmall,
      this.downsizedStill,
      this.fixedHeight,
      this.fixedHeightDownSampled,
      this.fixedHeightSmall,
      this.fixedHeightSmallStill,
      this.fixedHeightStill,
      this.fixedWidth,
      this.fixedWidthDownSampled,
      this.fixedWidthSmall,
      this.fixedWidthSmallStill,
      this.fixedWidthStill,
      this.looping,
      this.original,
      this.originalMp4,
      this.originalStill,
      this.preview,
      this.previewGif,
      this.previewWebp});

  factory Images.fromJson(Map<String, dynamic> json) {
    return Images(
      wStill: json['480w_still'] != null
          ? WStill.fromJson(json['480w_still'])
          : null,
      downsized: json['downsized'] != null
          ? Downsized.fromJson(json['downsized'])
          : null,
      downsizedLarge: json['downsized_large'] != null
          ? DownsizedLarge.fromJson(json['downsized_large'])
          : null,
      downsizedMedium: json['downsized_medium'] != null
          ? DownsizedMedium.fromJson(json['downsized_medium'])
          : null,
      downsizedSmall: json['downsized_small'] != null
          ? DownsizedSmall.fromJson(json['downsized_small'])
          : null,
      downsizedStill: json['downsized_still'] != null
          ? DownsizedStill.fromJson(json['downsized_still'])
          : null,
      fixedHeight: json['fixed_height'] != null
          ? FixedHeight.fromJson(json['fixed_height'])
          : null,
      fixedHeightDownSampled: json['fixed_height_downsampled'] != null
          ? FixedHeightDownSampled.fromJson(json['fixed_height_downsampled'])
          : null,
      fixedHeightSmall: json['fixed_height_small'] != null
          ? FixedHeightSmall.fromJson(json['fixed_height_small'])
          : null,
      fixedHeightSmallStill: json['fixed_height_small_still'] != null
          ? FixedHeightSmallStill.fromJson(json['fixed_height_small_still'])
          : null,
      fixedHeightStill: json['fixed_height_still'] != null
          ? FixedHeightStill.fromJson(json['fixed_height_still'])
          : null,
      fixedWidth: json['fixed_width'] != null
          ? FixedWidth.fromJson(json['fixed_width'])
          : null,
      fixedWidthDownSampled: json['fixed_width_downsampled'] != null
          ? FixedWidthDownSampled.fromJson(json['fixed_width_downsampled'])
          : null,
      fixedWidthSmall: json['fixed_width_small'] != null
          ? FixedWidthSmall.fromJson(json['fixed_width_small'])
          : null,
      fixedWidthSmallStill: json['fixed_width_small_still'] != null
          ? FixedWidthSmallStill.fromJson(json['fixed_width_small_still'])
          : null,
      fixedWidthStill: json['fixed_width_still'] != null
          ? FixedWidthStill.fromJson(json['fixed_width_still'])
          : null,
      looping:
          json['looping'] != null ? Looping.fromJson(json['looping']) : null,
      original:
          json['original'] != null ? Original.fromJson(json['original']) : null,
      originalMp4: json['original_mp4'] != null
          ? OriginalMp4.fromJson(json['original_mp4'])
          : null,
      originalStill: json['original_still'] != null
          ? OriginalStill.fromJson(json['original_still'])
          : null,
      preview:
          json['preview'] != null ? Preview.fromJson(json['preview']) : null,
      previewGif: json['preview_gif'] != null
          ? PreviewGif.fromJson(json['preview_gif'])
          : null,
      previewWebp: json['preview_webp'] != null
          ? PreviewWebp.fromJson(json['preview_webp'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.wStill != null) {
      data['480w_still'] = this.wStill!.toJson();
    }
    if (this.downsized != null) {
      data['downsized'] = this.downsized!.toJson();
    }
    if (this.downsizedLarge != null) {
      data['downsized_large'] = this.downsizedLarge!.toJson();
    }
    if (this.downsizedMedium != null) {
      data['downsized_medium'] = this.downsizedMedium!.toJson();
    }
    if (this.downsizedSmall != null) {
      data['downsized_small'] = this.downsizedSmall!.toJson();
    }
    if (this.downsizedStill != null) {
      data['downsized_still'] = this.downsizedStill!.toJson();
    }
    if (this.fixedHeight != null) {
      data['fixed_height'] = this.fixedHeight!.toJson();
    }
    if (this.fixedHeightDownSampled != null) {
      data['fixed_height_downsampled'] = this.fixedHeightDownSampled!.toJson();
    }
    if (this.fixedHeightSmall != null) {
      data['fixed_height_small'] = this.fixedHeightSmall!.toJson();
    }
    if (this.fixedHeightSmallStill != null) {
      data['fixed_height_small_still'] = this.fixedHeightSmallStill!.toJson();
    }
    if (this.fixedHeightStill != null) {
      data['fixed_height_still'] = this.fixedHeightStill!.toJson();
    }
    if (this.fixedWidth != null) {
      data['fixed_width'] = this.fixedWidth!.toJson();
    }
    if (this.fixedWidthDownSampled != null) {
      data['fixed_width_downsampled'] = this.fixedWidthDownSampled!.toJson();
    }
    if (this.fixedWidthSmall != null) {
      data['fixed_width_small'] = this.fixedWidthSmall!.toJson();
    }
    if (this.fixedWidthSmallStill != null) {
      data['fixed_width_small_still'] = this.fixedWidthSmallStill!.toJson();
    }
    if (this.fixedWidthStill != null) {
      data['fixed_width_still'] = this.fixedWidthStill!.toJson();
    }
    if (this.looping != null) {
      data['looping'] = this.looping!.toJson();
    }
    if (this.original != null) {
      data['original'] = this.original!.toJson();
    }
    if (this.originalMp4 != null) {
      data['original_mp4'] = this.originalMp4!.toJson();
    }
    if (this.originalStill != null) {
      data['original_still'] = this.originalStill!.toJson();
    }
    if (this.preview != null) {
      data['preview'] = this.preview!.toJson();
    }
    if (this.previewGif != null) {
      data['preview_gif'] = this.previewGif!.toJson();
    }
    if (this.previewWebp != null) {
      data['preview_webp'] = this.previewWebp!.toJson();
    }
    return data;
  }
}
