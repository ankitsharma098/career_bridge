// import 'package:json_annotation/json_annotation.dart';
//
// import '../company/common_model.dart';
//
// part 'story_model.g.dart';
//
// @JsonSerializable()
// class Story {
//   @JsonKey(name: '_id')
//   final String id;
//   final String title;
//   final String userType;
//   final String content;
//   final List<String> mediaUrls;
//   final List<String> tags;
//   final String category;
//   final int views;
//   // final List<Like> likes;
//   final HostDetails hostDetails;
//   final DateTime createdAt;
//   final bool isLiked;
//   final int likesCount;
//   final int commentsCount;
//   final int sharesCount;
//
//   Story(this.userType, this.hostDetails, {
//     required this.id,
//     required this.title,
//     required this.content,
//     required this.mediaUrls,
//     required this.tags,
//     required this.category,
//     required this.views,
//     // required this.likes,
//     required this.createdAt,
//     required this.isLiked,
//     required this.likesCount,
//     required this.commentsCount,
//     required this.sharesCount,
//   });
//
//   factory Story.fromJson(Map<String, dynamic> json) => _$StoryFromJson(json);
//
//   Map<String, dynamic> toJson() => _$StoryToJson(this);
// }
//
//
