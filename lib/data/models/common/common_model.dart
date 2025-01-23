
import 'package:json_annotation/json_annotation.dart';

part 'common_model.g.dart';

@JsonSerializable()
class Like {
  final String userType;
  final HostDetails user;
  @JsonKey(name: '_id')
  final String id;

  Like({
    required this.userType,
    required this.user,
    required this.id,
  });

  factory Like.fromJson(Map<String, dynamic> json) => _$LikeFromJson(json);
}


@JsonSerializable()
class HostDetails{

  @JsonKey(name: "_id")
  final String id;
  final String name;
  final String? profilePic;

  HostDetails({required this.id, required this.name, this.profilePic});

  factory HostDetails.fromJson(Map<String,dynamic> json)=>_$HostDetailsFromJson(json);


}

@JsonSerializable()
class Comment {
  @JsonKey(name: "_id")
  final String id;
  final String text;
  final DateTime timeStamp;
  final String userType;
  final HostDetails user;

  Comment({required this.id, required this.text, required this.user,required this.timeStamp, required this.userType});

  factory Comment.fromJson(Map<String,dynamic> json)=>_$CommentFromJson(json);

}