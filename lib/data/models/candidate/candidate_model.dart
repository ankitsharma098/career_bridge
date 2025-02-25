import 'package:json_annotation/json_annotation.dart';
import '../employer/employer_model.dart';

part 'candidate_model.g.dart';

@JsonSerializable()
class Candidate {
  @JsonKey(name: '_id', defaultValue: '')
  final String id;

  final PersonalInfo personalInfo;

  final DisabilityDetails disabilityDetails;

  @JsonKey(defaultValue: '')
  final String profileSummary;

  @JsonKey(defaultValue: '')
  final String about;

  @JsonKey(defaultValue: [])
  final List<Education> education;

  @JsonKey(defaultValue: [])
  final List<String> skills;

  @JsonKey(defaultValue: '')
  final String resume;

  final JobPreferences jobPreferences;

  final CandidateJobs jobs;

  final UserStories stories;

  final UserEvents events;

  final Auth auth;

  @JsonKey(defaultValue: [])
  final List<String> projects;

  @JsonKey(defaultValue: [])
  final List<String> internships;

  @JsonKey(defaultValue: [])
  final List<String> workExperience;

  @JsonKey(defaultValue: [])
  final List<String> certifications;

  @JsonKey(defaultValue: '')
  final String createdAt;

  @JsonKey(defaultValue: '')
  final String updatedAt;

  @JsonKey(defaultValue: '')
  final String fcmToken; // Added for consistency with Employer login response

  Candidate({
    this.id = '',
    this.personalInfo = const PersonalInfo(),
    this.disabilityDetails = const DisabilityDetails(),
    this.profileSummary = '',
    this.about = '',
    this.education = const [],
    this.skills = const [],
    this.resume = '',
    this.jobPreferences = const JobPreferences(),
    this.jobs = const CandidateJobs(),
    this.stories = const UserStories(),
    this.events = const UserEvents(),
    this.auth = const Auth(),
    this.projects = const [],
    this.internships = const [],
    this.workExperience = const [],
    this.certifications = const [],
    this.createdAt = '',
    this.updatedAt = '',
    this.fcmToken = '',
  });

  factory Candidate.fromJson(Map<String, dynamic> json) => _$CandidateFromJson(json);
  Map<String, dynamic> toJson() => _$CandidateToJson(this);
}

@JsonSerializable()
class DisabilityDetails {
  @JsonKey(defaultValue: '')
  final String type;

  @JsonKey(defaultValue: 0)
  final int percentage;

  @JsonKey(defaultValue: '')
  final String certificateNumber;

  @JsonKey(defaultValue: '')
  final String certificateDoc;

  @JsonKey(defaultValue: [])
  final List<String> accommodationsNeeded;

  @JsonKey(defaultValue: [])
  final List<String> assistiveTechnology;

  const DisabilityDetails({
    this.type = '',
    this.percentage = 0,
    this.certificateNumber = '',
    this.certificateDoc = '',
    this.accommodationsNeeded = const [],
    this.assistiveTechnology = const [],
  });

  factory DisabilityDetails.fromJson(Map<String, dynamic> json) => _$DisabilityDetailsFromJson(json);
  Map<String, dynamic> toJson() => _$DisabilityDetailsToJson(this);
}

@JsonSerializable()
class Education {
  @JsonKey(defaultValue: '')
  final String degree;

  @JsonKey(defaultValue: '')
  final String course;

  @JsonKey(defaultValue: '')
  final String courseType;

  @JsonKey(defaultValue: '')
  final String specialization;

  @JsonKey(defaultValue: '')
  final String institution;

  @JsonKey(defaultValue: '')
  final String startingYear;

  @JsonKey(defaultValue: 0)
  final int passingYear;

  @JsonKey(defaultValue: '')
  final String cgpa;

  @JsonKey(name: '_id', defaultValue: '')
  final String id;

  const Education({
    this.degree = '',
    this.course = '',
    this.courseType = '',
    this.specialization = '',
    this.institution = '',
    this.startingYear = '',
    this.passingYear = 0,
    this.cgpa = '',
    this.id = '',
  });

  factory Education.fromJson(Map<String, dynamic> json) => _$EducationFromJson(json);
  Map<String, dynamic> toJson() => _$EducationToJson(this);
}

@JsonSerializable()
class JobPreferences {
  @JsonKey(defaultValue: [])
  final List<String> industries;

  @JsonKey(defaultValue: [])
  final List<String> roles;

  @JsonKey(defaultValue: 0)
  final int preferredSalary;

  @JsonKey(defaultValue: [])
  final List<String> location;

  @JsonKey(defaultValue: '')
  final String workMode;

  @JsonKey(defaultValue: [])
  final List<String> employmentType;

  @JsonKey(defaultValue: '')
  final String experienceLevel;

  const JobPreferences({
    this.industries = const [],
    this.roles = const [],
    this.preferredSalary = 0,
    this.location = const [],
    this.workMode = '',
    this.employmentType = const [],
    this.experienceLevel = '',
  });

  factory JobPreferences.fromJson(Map<String, dynamic> json) => _$JobPreferencesFromJson(json);
  Map<String, dynamic> toJson() => _$JobPreferencesToJson(this);
}

@JsonSerializable()
class CandidateJobs {
  @JsonKey(defaultValue: [])
  final List<String> enrolledJobs;

  @JsonKey(defaultValue: [])
  final List<String> savedJobs;

  const CandidateJobs({
    this.enrolledJobs = const [],
    this.savedJobs = const [],
  });

  factory CandidateJobs.fromJson(Map<String, dynamic> json) => _$CandidateJobsFromJson(json);
  Map<String, dynamic> toJson() => _$CandidateJobsToJson(this);
}