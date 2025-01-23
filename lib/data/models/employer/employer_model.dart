
import 'package:json_annotation/json_annotation.dart';

part 'employer_model.g.dart';

@JsonSerializable()
class Employer {
  @JsonKey(name: '_id')
  final String id;
  final PersonalInfo personalInfo;
  final EmployerCompanyInfo companyDetails;
  final List<String> postedJobs;
  final UserStories stories;
  final UserEvents events;
  final String about;

  Employer(
      {required this.id,
      required this.personalInfo,
      required this.companyDetails,
      required this.postedJobs,
      required this.stories,
      required this.events,
      required this.about});

  factory Employer.fromJson(Map<String, dynamic> json) =>
      _$EmployerFromJson(json);

  Map<String, dynamic> toJson() => _$EmployerToJson(this);

}

@JsonSerializable()
class PersonalInfo {
  final String fullName;
  final String email;
  final String phoneNumber;
  final String? profilePic;

  PersonalInfo(
      {required this.fullName,
      required this.email,
      required this.phoneNumber,
      this.profilePic});

  factory PersonalInfo.fromJson(Map<String, dynamic> json) =>
      _$PersonalInfoFromJson(json);

  Map<String, dynamic> toJson() => _$PersonalInfoToJson(this);
}

@JsonSerializable()
class UserStories {
  @JsonKey(name: 'myStories', defaultValue: [])
  final List<String> myStoryIds;
  @JsonKey(name: 'savedStories', defaultValue: [])
  final List<String> savedStoryIds;

  UserStories({required this.myStoryIds, required this.savedStoryIds});

  factory UserStories.fromJson(Map<String, dynamic> json) =>
      _$UserStoriesFromJson(json);

  Map<String, dynamic> toJson() => _$UserStoriesToJson(this);
}

@JsonSerializable()
class UserEvents {
  @JsonKey(name: 'myEvents', defaultValue: [])
  final List<String> myEventIds;
  @JsonKey(name: 'savedEvents', defaultValue: [])
  final List<String> savedEventIds;

  UserEvents({required this.myEventIds, required this.savedEventIds});

  factory UserEvents.fromJson(Map<String,dynamic> json)=>_$UserEventsFromJson(json);

  Map<String,dynamic> toJson()=>_$UserEventsToJson(this);
}

@JsonSerializable()
class EmployerCompanyInfo {
  final String companyId;
  final String designation;

  EmployerCompanyInfo({
    required this.companyId,
    required this.designation,
  });

  factory EmployerCompanyInfo.fromJson(Map<String, dynamic> json) =>
      _$EmployerCompanyInfoFromJson(json);

  Map<String, dynamic> toJson() => _$EmployerCompanyInfoToJson(this);
}
