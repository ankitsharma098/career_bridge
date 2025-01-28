
import 'package:json_annotation/json_annotation.dart';

part 'employer_model.g.dart';

@JsonSerializable()
class Employer {
  @JsonKey(name: '_id', defaultValue: '')
  final String id;

  final PersonalInfo personalInfo;


  final EmployerCompanyInfo companyDetails;

  @JsonKey(defaultValue: [])
  final List<String> postedJobs;


  final UserStories stories;


  final UserEvents events;

  @JsonKey(defaultValue: '')
  final String about;

  Employer({
    this.id = '',
    this.personalInfo = const PersonalInfo(),
    this.companyDetails = const EmployerCompanyInfo(),
    this.postedJobs = const [],
    this.stories = const UserStories(),
    this.events = const UserEvents(),
    this.about = '',
  });

  factory Employer.fromJson(Map<String, dynamic> json) =>
      _$EmployerFromJson(json);

  Map<String, dynamic> toJson() => _$EmployerToJson(this);

}

@JsonSerializable()
class PersonalInfo {
  @JsonKey(defaultValue: '')
  final String fullName;

  @JsonKey(defaultValue: '')
  final String email;

  @JsonKey(defaultValue: null)
  final String? profilePic;

  @JsonKey(defaultValue: '')
  final String phoneNumber;

  @JsonKey(defaultValue: '')
  final String address;

  @JsonKey(defaultValue: null)
  final DateTime? DOB;

  @JsonKey(defaultValue: '')
  final String gender;

  const PersonalInfo( {
    this.address='',
    this.DOB=null,
    this.gender='Male',
    this.fullName = 'fullName',
    this.email = 'email',
    this.phoneNumber = '+91 730XXX',
     this.profilePic,
  });

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

  const UserStories({
    this.myStoryIds = const [],
    this.savedStoryIds = const [],
  });

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

  const UserEvents({
    this.myEventIds = const [],
    this.savedEventIds = const [],
  });



  factory UserEvents.fromJson(Map<String,dynamic> json)=>_$UserEventsFromJson(json);

  Map<String,dynamic> toJson()=>_$UserEventsToJson(this);
}

@JsonSerializable()
class EmployerCompanyInfo {

  @JsonKey(defaultValue: '')
  final String companyId;

  @JsonKey(defaultValue: '')
  final String designation;

  const EmployerCompanyInfo({
    this.companyId='companyId',
    this.designation='designation',
  });

  factory EmployerCompanyInfo.fromJson(Map<String, dynamic> json) =>
      _$EmployerCompanyInfoFromJson(json);

  Map<String, dynamic> toJson() => _$EmployerCompanyInfoToJson(this);
}
