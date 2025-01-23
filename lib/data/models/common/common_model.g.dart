// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'common_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Like _$LikeFromJson(Map<String, dynamic> json) => Like(
      userType: json['userType'] as String,
      user: HostDetails.fromJson(json['user'] as Map<String, dynamic>),
      id: json['_id'] as String,
    );

Map<String, dynamic> _$LikeToJson(Like instance) => <String, dynamic>{
      'userType': instance.userType,
      'user': instance.user,
      '_id': instance.id,
    };

HostDetails _$HostDetailsFromJson(Map<String, dynamic> json) => HostDetails(
      id: json['_id'] as String,
      name: json['name'] as String,
      profilePic: json['profilePic'] as String?,
    );

Map<String, dynamic> _$HostDetailsToJson(HostDetails instance) =>
    <String, dynamic>{
      '_id': instance.id,
      'name': instance.name,
      'profilePic': instance.profilePic,
    };

Comment _$CommentFromJson(Map<String, dynamic> json) => Comment(
      id: json['_id'] as String,
      text: json['text'] as String,
      user: HostDetails.fromJson(json['user'] as Map<String, dynamic>),
      timeStamp: DateTime.parse(json['timeStamp'] as String),
      userType: json['userType'] as String,
    );

Map<String, dynamic> _$CommentToJson(Comment instance) => <String, dynamic>{
      '_id': instance.id,
      'text': instance.text,
      'timeStamp': instance.timeStamp.toIso8601String(),
      'userType': instance.userType,
      'user': instance.user,
    };
