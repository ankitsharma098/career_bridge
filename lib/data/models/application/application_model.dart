import 'package:json_annotation/json_annotation.dart';

part 'application_model.g.dart';

@JsonSerializable()
class JobApplicationResponse {
  @JsonKey(defaultValue: 0)
  final int totalApplications;

  @JsonKey(name: 'applications')
  final List<Application> applications;

  JobApplicationResponse({
    this.totalApplications = 0,
    this.applications = const []
  });

  factory JobApplicationResponse.fromJson(Map<String, dynamic> json) =>
      _$JobApplicationResponseFromJson(json);

  Map<String, dynamic> toJson() => _$JobApplicationResponseToJson(this);
}

@JsonSerializable()
class Application {
  @JsonKey(name: '_id',defaultValue: '')
  final String id;

  @JsonKey(defaultValue: 'pending')
  final String status;

  @JsonKey(defaultValue: '')
  final String appliedDate;

  @JsonKey(defaultValue: '')
  final String resume;

  final ContactInfo contactInfo;

  @JsonKey(defaultValue: true)
  final bool isFresher;

  final List<Experience> experience;

  final CandidateInfo candidateInfo;

  Application({
     this.appliedDate='',
     this.id='',
    this.status = 'pending',
    this.resume = '',
     this.contactInfo=const ContactInfo(),
    this.isFresher = true,
     this.experience= const [],
     this.candidateInfo=const CandidateInfo(),
  });

  factory Application.fromJson(Map<String, dynamic> json) =>
      _$ApplicationFromJson(json);

  Map<String, dynamic> toJson() => _$ApplicationToJson(this);
}

@JsonSerializable()
class ContactInfo {
  @JsonKey(defaultValue: '')
  final String email;

  @JsonKey(defaultValue: '')
  final String phone;

  const ContactInfo({
    this.email = '',
    this.phone = '',
  });

  factory ContactInfo.fromJson(Map<String, dynamic> json) =>
      _$ContactInfoFromJson(json);

  Map<String, dynamic> toJson() => _$ContactInfoToJson(this);
}

@JsonSerializable()
class Experience {
  @JsonKey(name: '_id')
  final String id;

  @JsonKey(defaultValue: '')
  final String designation;

  @JsonKey(defaultValue: '')
  final String company;

  @JsonKey(defaultValue: '')
  final String duration;

  @JsonKey(defaultValue: '')
  final String description;

  const Experience({
     this.id='',
    this.designation = '',
    this.company = '',
    this.duration = '',
    this.description = '',
  });

  factory Experience.fromJson(Map<String, dynamic> json) =>
      _$ExperienceFromJson(json);

  Map<String, dynamic> toJson() => _$ExperienceToJson(this);
}

@JsonSerializable()
class CandidateInfo {
  @JsonKey(name: '_id',defaultValue: '')
  final String id;

  @JsonKey(defaultValue: '')
  final String fullName;

  @JsonKey(defaultValue: '')
  final String email;

  final String? profilePic;

  @JsonKey(defaultValue: [])
  final List<String> skills;

  const CandidateInfo({
     this.id='',
    this.fullName = '',
    this.email = '',
    this.profilePic,
    this.skills =  const [],
  });

  factory CandidateInfo.fromJson(Map<String, dynamic> json) =>
      _$CandidateInfoFromJson(json);

  Map<String, dynamic> toJson() => _$CandidateInfoToJson(this);
}