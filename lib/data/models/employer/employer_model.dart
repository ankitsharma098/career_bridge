import 'package:json_annotation/json_annotation.dart';


part 'employer_model.g.dart';

@JsonSerializable()
class Employer {
  @JsonKey(name: '_id', defaultValue: '')
  final String id;

  final PersonalInfo personalInfo;

  final MinimalCompanyDetails companyDetails; // Embedded minimal company info

  @JsonKey(defaultValue: [])
  final List<String> postedJobs;

  final UserStories stories;

  final UserEvents events;

  final Auth auth;

  @JsonKey(defaultValue: '')
  final String role;

  @JsonKey(defaultValue: '')
  final String about;

  @JsonKey(defaultValue: '')
  final String createdAt;

  @JsonKey(defaultValue: '')
  final String updatedAt;

  @JsonKey(defaultValue: '')
  final String fcmToken; // Added from login response

  Employer({
    this.id = '',
    this.personalInfo = const PersonalInfo(),
    this.companyDetails = const MinimalCompanyDetails(),
    this.postedJobs = const [],
    this.stories = const UserStories(),
    this.events = const UserEvents(),
    this.auth = const Auth(),
    this.role = '',
    this.about = '',
    this.createdAt = '',
    this.updatedAt = '',
    this.fcmToken = '',
  });

  factory Employer.fromJson(Map<String, dynamic> json) => _$EmployerFromJson(json);
  Map<String, dynamic> toJson() => _$EmployerToJson(this);
}

@JsonSerializable()
class PersonalInfo {
  @JsonKey(defaultValue: '')
  final String fullName;

  @JsonKey(defaultValue: '')
  final String email;

  @JsonKey(defaultValue: '')
  final String? profilePic;

  @JsonKey(defaultValue: '')
  final String phoneNumber;

  @JsonKey(defaultValue: '')
  final String address;

  @JsonKey(defaultValue: '')
  final String? dob;

  @JsonKey(defaultValue: 'Male')
  final String gender;

  const PersonalInfo({
    this.fullName = '',
    this.email = '',
    this.profilePic,
    this.phoneNumber = '',
    this.address = '',
    this.dob = '',
    this.gender = 'Male',
  });

  factory PersonalInfo.fromJson(Map<String, dynamic> json) => _$PersonalInfoFromJson(json);
  Map<String, dynamic> toJson() => _$PersonalInfoToJson(this);
}

@JsonSerializable()
class MinimalCompanyDetails {
  @JsonKey(defaultValue: '')
  final String companyId;

  @JsonKey(defaultValue: '')
  final String designation;

  const MinimalCompanyDetails({
    this.companyId = '',
    this.designation = '',
  });

  factory MinimalCompanyDetails.fromJson(Map<String, dynamic> json) => _$MinimalCompanyDetailsFromJson(json);
  Map<String, dynamic> toJson() => _$MinimalCompanyDetailsToJson(this);
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

  factory UserStories.fromJson(Map<String, dynamic> json) => _$UserStoriesFromJson(json);
  Map<String, dynamic> toJson() => _$UserStoriesToJson(this);
}

@JsonSerializable()
class UserEvents {
  @JsonKey(defaultValue: [])
  final List<String> myEvents;

  @JsonKey(defaultValue: [])
  final List<String> savedEvents;

  @JsonKey(defaultValue: [])
  final List<String> registeredEvents;

  const UserEvents({
    this.myEvents = const [],
    this.savedEvents = const [],
    this.registeredEvents = const [],
  });

  factory UserEvents.fromJson(Map<String, dynamic> json) => _$UserEventsFromJson(json);
  Map<String, dynamic> toJson() => _$UserEventsToJson(this);
}

@JsonSerializable()
class Auth {
  @JsonKey(defaultValue: false)
  final bool verified;

  @JsonKey(defaultValue: '')
  final String status;

  const Auth({
    this.verified = false,
    this.status = '',
  });

  factory Auth.fromJson(Map<String, dynamic> json) => _$AuthFromJson(json);
  Map<String, dynamic> toJson() => _$AuthToJson(this);
}