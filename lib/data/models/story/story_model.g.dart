// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'story_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StoryModel _$StoryModelFromJson(Map<String, dynamic> json) => StoryModel(
      id: json['_id'] as String? ?? '',
      userType: json['userType'] as String? ?? '',
      title: json['title'] as String? ?? '',
      content: json['content'] as String? ?? '',
      mediaUrls: (json['mediaUrls'] as List<dynamic>?)
              ?.map((e) => MediaUrl.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      tags:
          (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
              [],
      category: json['category'] as String? ?? '',
      views: (json['views'] as num?)?.toInt() ?? 0,
      createdAt: json['createdAt'] as String? ?? '',
      hostDetails: json['hostDetails'] == null
          ? const HostDetails()
          : HostDetails.fromJson(json['hostDetails'] as Map<String, dynamic>),
      isLiked: json['isLiked'] as bool? ?? false,
      isSaved: json['isSaved'] as bool? ?? false,
      likesCount: (json['likesCount'] as num?)?.toInt() ?? 0,
      commentsCount: (json['commentsCount'] as num?)?.toInt() ?? 0,
      sharesCount: (json['sharesCount'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$StoryModelToJson(StoryModel instance) =>
    <String, dynamic>{
      '_id': instance.id,
      'userType': instance.userType,
      'title': instance.title,
      'content': instance.content,
      'mediaUrls': instance.mediaUrls.map((e) => e.toJson()).toList(),
      'tags': instance.tags,
      'category': instance.category,
      'views': instance.views,
      'createdAt': instance.createdAt,
      'hostDetails': instance.hostDetails.toJson(),
      'isLiked': instance.isLiked,
      'isSaved': instance.isSaved,
      'likesCount': instance.likesCount,
      'commentsCount': instance.commentsCount,
      'sharesCount': instance.sharesCount,
    };

MediaUrl _$MediaUrlFromJson(Map<String, dynamic> json) => MediaUrl(
      url: json['url'] as String? ?? '',
      publicId: json['publicId'] as String? ?? '',
      id: json['_id'] as String? ?? '',
    );

Map<String, dynamic> _$MediaUrlToJson(MediaUrl instance) => <String, dynamic>{
      'url': instance.url,
      'publicId': instance.publicId,
      '_id': instance.id,
    };

HostDetails _$HostDetailsFromJson(Map<String, dynamic> json) => HostDetails(
      id: json['_id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      profilePic: json['profilePic'] as String? ?? '',
    );

Map<String, dynamic> _$HostDetailsToJson(HostDetails instance) =>
    <String, dynamic>{
      '_id': instance.id,
      'name': instance.name,
      'profilePic': instance.profilePic,
    };
