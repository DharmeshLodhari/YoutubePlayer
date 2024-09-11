import 'FixedWidth.dart';
import 'FixedWidthDownsampled.dart';
import 'FixedWidthSmall.dart';
import 'FixedWidthSmallStill.dart';
import 'downsized.dart';
import 'downsized_large.dart';
import 'downsized_medium.dart';
import 'downsized_small.dart';
import 'downsized_still.dart';
import 'fixed_height.dart';
import 'fixed_height_downsampled.dart';
import 'fixed_height_small.dart';
import 'fixed_height_small_still.dart';
import 'fixed_height_still.dart';
import 'fixed_width_still.dart';
import 'looping.dart';
import 'original.dart';
import 'original_mp4.dart';
import 'original_still.dart';
import 'preview.dart';
import 'preview_gif.dart';
import 'preview_webp.dart';
import 'w_still.dart';

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
    final Map<String, dynamic> data = <String, dynamic>{};
    if (wStill != null) {
      data['480w_still'] = wStill!.toJson();
    }
    if (downsized != null) {
      data['downsized'] = downsized!.toJson();
    }
    if (downsizedLarge != null) {
      data['downsized_large'] = downsizedLarge!.toJson();
    }
    if (downsizedMedium != null) {
      data['downsized_medium'] = downsizedMedium!.toJson();
    }
    if (downsizedSmall != null) {
      data['downsized_small'] = downsizedSmall!.toJson();
    }
    if (downsizedStill != null) {
      data['downsized_still'] = downsizedStill!.toJson();
    }
    if (fixedHeight != null) {
      data['fixed_height'] = fixedHeight!.toJson();
    }
    if (fixedHeightDownSampled != null) {
      data['fixed_height_downsampled'] = fixedHeightDownSampled!.toJson();
    }
    if (fixedHeightSmall != null) {
      data['fixed_height_small'] = fixedHeightSmall!.toJson();
    }
    if (fixedHeightSmallStill != null) {
      data['fixed_height_small_still'] = fixedHeightSmallStill!.toJson();
    }
    if (fixedHeightStill != null) {
      data['fixed_height_still'] = fixedHeightStill!.toJson();
    }
    if (fixedWidth != null) {
      data['fixed_width'] = fixedWidth!.toJson();
    }
    if (fixedWidthDownSampled != null) {
      data['fixed_width_downsampled'] = fixedWidthDownSampled!.toJson();
    }
    if (fixedWidthSmall != null) {
      data['fixed_width_small'] = fixedWidthSmall!.toJson();
    }
    if (fixedWidthSmallStill != null) {
      data['fixed_width_small_still'] = fixedWidthSmallStill!.toJson();
    }
    if (fixedWidthStill != null) {
      data['fixed_width_still'] = fixedWidthStill!.toJson();
    }
    if (looping != null) {
      data['looping'] = looping!.toJson();
    }
    if (original != null) {
      data['original'] = original!.toJson();
    }
    if (originalMp4 != null) {
      data['original_mp4'] = originalMp4!.toJson();
    }
    if (originalStill != null) {
      data['original_still'] = originalStill!.toJson();
    }
    if (preview != null) {
      data['preview'] = preview!.toJson();
    }
    if (previewGif != null) {
      data['preview_gif'] = previewGif!.toJson();
    }
    if (previewWebp != null) {
      data['preview_webp'] = previewWebp!.toJson();
    }
    return data;
  }
}
