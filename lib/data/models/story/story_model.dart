import 'package:json_annotation/json_annotation.dart';

part 'story_model.g.dart';

@JsonSerializable(explicitToJson: true)
class StoryModel {
  @JsonKey(name: '_id', defaultValue: '')
  final String id;

  @JsonKey(name: 'userType', defaultValue: '')
  final String userType;

  @JsonKey(defaultValue: '')
  final String title;

  @JsonKey(defaultValue: '')
  final String content;

  @JsonKey(name: 'mediaUrls', defaultValue: [])
  final List<MediaUrl> mediaUrls;

  @JsonKey(defaultValue: [])
  final List<String> tags;

  @JsonKey(defaultValue: '')
  final String category;

  @JsonKey(defaultValue: 0)
  final int views;

  @JsonKey(name: 'createdAt')
  final String createdAt;

  @JsonKey(name: 'hostDetails')
  final HostDetails hostDetails;

  @JsonKey(name: 'isLiked', defaultValue: false)
  final bool isLiked;

  @JsonKey(name: 'likesCount', defaultValue: 0)
  final int likesCount;

  @JsonKey(name: 'commentsCount', defaultValue: 0)
  final int commentsCount;

  @JsonKey(name: 'sharesCount', defaultValue: 0)
  final int sharesCount;

  StoryModel({
    this.id = '',
    this.userType = '',
    this.title = '',
    this.content = '',
    this.mediaUrls = const [],
    this.tags = const [],
    this.category = '',
    this.views = 0,
    this.createdAt = '',
    this.hostDetails = const HostDetails(),
    this.isLiked = false,
    this.likesCount = 0,
    this.commentsCount = 0,
    this.sharesCount = 0,
  });

  StoryModel copyWith({
    String? id,
    String? userType,
    String? title,
    String? content,
    List<MediaUrl>? mediaUrls,
    List<String>? tags,
    String? category,
    int? views,
    String? createdAt,
    HostDetails? hostDetails,
    bool? isLiked,
    int? likesCount,
    int? commentsCount,
    int? sharesCount,
  }) {
    return StoryModel(
      id: id ?? this.id,
      userType: userType ?? this.userType,
      title: title ?? this.title,
      content: content ?? this.content,
      mediaUrls: mediaUrls ?? this.mediaUrls,
      tags: tags ?? this.tags,
      category: category ?? this.category,
      views: views ?? this.views,
      createdAt: createdAt ?? this.createdAt,
      hostDetails: hostDetails ?? this.hostDetails,
      isLiked: isLiked ?? this.isLiked,
      likesCount: likesCount ?? this.likesCount,
      commentsCount: commentsCount ?? this.commentsCount,
      sharesCount: sharesCount ?? this.sharesCount,
    );
  }

  factory StoryModel.fromJson(Map<String, dynamic> json) =>
      _$StoryModelFromJson(json);

  Map<String, dynamic> toJson() => _$StoryModelToJson(this);
}

@JsonSerializable(explicitToJson: true)
class MediaUrl {
  @JsonKey(defaultValue: '')
  final String url;

  @JsonKey(defaultValue: '')
  final String publicId;

  @JsonKey(name: '_id', defaultValue: '')
  final String id;

  MediaUrl({
    this.url = '',
    this.publicId = '',
    this.id = '',
  });

  MediaUrl copyWith({
    String? url,
    String? publicId,
    String? id,
  }) {
    return MediaUrl(
      url: url ?? this.url,
      publicId: publicId ?? this.publicId,
      id: id ?? this.id,
    );
  }

  factory MediaUrl.fromJson(Map<String, dynamic> json) =>
      _$MediaUrlFromJson(json);

  Map<String, dynamic> toJson() => _$MediaUrlToJson(this);
}

@JsonSerializable(explicitToJson: true)
class HostDetails {
  @JsonKey(name: '_id', defaultValue: '')
  final String id;

  @JsonKey(defaultValue: '')
  final String name;

  @JsonKey(name: 'profilePic', defaultValue: '')
  final String profilePic;

  const HostDetails({
    this.id = '',
    this.name = '',
    this.profilePic = '',
  });

  HostDetails copyWith({
    String? id,
    String? name,
    String? profilePic,
  }) {
    return HostDetails(
      id: id ?? this.id,
      name: name ?? this.name,
      profilePic: profilePic ?? this.profilePic,
    );
  }

  factory HostDetails.fromJson(Map<String, dynamic> json) =>
      _$HostDetailsFromJson(json);

  Map<String, dynamic> toJson() => _$HostDetailsToJson(this);
}