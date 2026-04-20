// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';

part 'app_banner.freezed.dart';
part 'app_banner.g.dart';

@freezed
class AppBanner with _$AppBanner {
  const factory AppBanner({
    required String id,
    required String title,
    required String subtitle,
    @JsonKey(name: 'image_url') required String imageUrl,
    @JsonKey(name: 'action_url') String? actionUrl,
    @JsonKey(name: 'action_title') String? actionTitle,
    @JsonKey(name: 'sort_order') @Default(0) int sortOrder,
  }) = _AppBanner;

  factory AppBanner.fromJson(Map<String, dynamic> json) =>
      _$AppBannerFromJson(json);
}
