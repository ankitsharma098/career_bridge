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

  final Resume resume;

  final JobPreferences jobPreferences;

  final CandidateJobs jobs;

  final UserStories stories;


  final Auth auth;

  @JsonKey(defaultValue: [])
  final List<Project> projects;

  @JsonKey(defaultValue: [])
  final List<Internship> internships;

  @JsonKey(defaultValue: [])
  final List<WorkExperience> workExperience;

  @JsonKey(defaultValue: [])
  final List<Certification> certifications;

  @JsonKey(defaultValue: '')
  final String createdAt;

  @JsonKey(defaultValue: '')
  final String updatedAt;


  Candidate({
    this.id = '',
    this.personalInfo = const PersonalInfo(),
    this.disabilityDetails = const DisabilityDetails(),
    this.profileSummary = '',
    this.about = '',
    this.education = const [],
    this.skills = const [],
    this.resume = const Resume(),
    this.jobPreferences = const JobPreferences(),
    this.jobs = const CandidateJobs(),
    this.stories = const UserStories(),
    this.auth = const Auth(),
    this.projects = const [],
    this.internships = const [],
    this.workExperience = const [],
    this.certifications = const [],
    this.createdAt = '',
    this.updatedAt = '',
  });

  factory Candidate.fromJson(Map<String, dynamic> json) => _$CandidateFromJson(json);
  Map<String, dynamic> toJson() => _$CandidateToJson(this);
}
@JsonSerializable()
class Resume {
  @JsonKey(defaultValue: '')
  final String url;


  @JsonKey(defaultValue: '')
  final String publicId;

  const Resume({
    this.url = '',
    this.publicId = '',
  });

  factory Resume.fromJson(Map<String, dynamic> json) => _$ResumeFromJson(json);
  Map<String, dynamic> toJson() => _$ResumeToJson(this);
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

  @JsonKey(defaultValue: '')
  final String publicId;

  @JsonKey(defaultValue: [])
  final List<String> accommodationsNeeded;

  @JsonKey(defaultValue: '')
  final String preferredCommunicationMethod;


  @JsonKey(defaultValue: [])
  final List<String> assistiveTechnology;

  const DisabilityDetails({
    this.type = '',
    this.percentage = 0,
    this.certificateNumber = '',
    this.certificateDoc = '',
    this.preferredCommunicationMethod = '',
    this.publicId = '',
    this.accommodationsNeeded = const [],
    this.assistiveTechnology = const [],
  });

  factory DisabilityDetails.fromJson(Map<String, dynamic> json) => _$DisabilityDetailsFromJson(json);
  Map<String, dynamic> toJson() => _$DisabilityDetailsToJson(this);
}

@JsonSerializable()
class Education {
  @JsonKey(defaultValue: '')
  final String course;

  @JsonKey(defaultValue: '')
  final String specialization;

  @JsonKey(defaultValue: '')
  final String institution;

  @JsonKey(defaultValue: null)
  final DateTime? startingYear;

  @JsonKey(defaultValue: null)
  final DateTime? passingYear;

  @JsonKey(defaultValue: '')
  final String CGPA;

  @JsonKey(name: '_id', defaultValue: '')
  final String id;

  const Education({
    this.course = '',
    this.specialization = '',
    this.institution = '',
    this.startingYear ,
    this.passingYear,
    this.CGPA = '',
    this.id = '',
  });

  String get startYear => startingYear?.year.toString() ?? '';
  int get endYear => passingYear?.year ?? 0;

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
class Project {
  @JsonKey(defaultValue: '')
  final String projectName;

  @JsonKey(defaultValue: null)
  final DateTime? startDate;

  @JsonKey(defaultValue: null)
  final DateTime? endDate;

  @JsonKey(defaultValue: '')
  final String descriptions;

  @JsonKey(defaultValue: [])
  final List<String> skills;

  @JsonKey(defaultValue: '')
  final String projectUrl;

  @JsonKey(name: '_id', defaultValue: '')
  final String id;

  const Project({
    this.projectName = '',
    this.startDate,
    this.endDate,
    this.descriptions = '',
    this.skills = const [],
    this.projectUrl = '',
    this.id = '',
  });

  factory Project.fromJson(Map<String, dynamic> json) => _$ProjectFromJson(json);
  Map<String, dynamic> toJson() => _$ProjectToJson(this);
}

@JsonSerializable()
class Internship {
  @JsonKey(defaultValue: '')
  final String company;

  @JsonKey(defaultValue: '')
  final String role;

  @JsonKey(defaultValue: null)
  final DateTime? startDate;

  @JsonKey(defaultValue: null)
  final DateTime? endDate;

  @JsonKey(defaultValue: '')
  final String projectName;

  @JsonKey(defaultValue: '')
  final String descriptions;

  @JsonKey(defaultValue: [])
  final List<String> skills;

  @JsonKey(defaultValue: '')
  final String projectUrl;

  @JsonKey(name: '_id', defaultValue: '')
  final String id;

  const Internship({
    this.company = '',
    this.role = '',
    this.startDate,
    this.endDate,
    this.projectName = '',
    this.descriptions = '',
    this.skills = const [],
    this.projectUrl = '',
    this.id = '',
  });

  factory Internship.fromJson(Map<String, dynamic> json) => _$InternshipFromJson(json);
  Map<String, dynamic> toJson() => _$InternshipToJson(this);
}

@JsonSerializable()
class WorkExperience {
  @JsonKey(defaultValue: '')
  final String company;

  @JsonKey(defaultValue: '')
  final String position;

  @JsonKey(defaultValue: null)
  final DateTime? startDate;

  @JsonKey(defaultValue: null)
  final DateTime? endDate;


  @JsonKey(defaultValue: '')
  final String descriptions;

  @JsonKey(name: '_id', defaultValue: '')
  final String id;

  const WorkExperience({
    this.company = '',
    this.position = '',
    this.startDate,
    this.endDate ,
    this.descriptions = '',
    this.id = '',
  });

  factory WorkExperience.fromJson(Map<String, dynamic> json) => _$WorkExperienceFromJson(json);
  Map<String, dynamic> toJson() => _$WorkExperienceToJson(this);
}

@JsonSerializable()
class Certification {
  @JsonKey(defaultValue: '')
  final String name;

  @JsonKey(defaultValue: '')
  final String issuingOrganization;

  @JsonKey(defaultValue: null)
  final DateTime? issueDate;

  @JsonKey(defaultValue: '')
  final String credentialID;

  @JsonKey(defaultValue: '')
  final String url;

  @JsonKey(name: '_id', defaultValue: '')
  final String id;

  const Certification({
    this.name = '',
    this.issuingOrganization = '',
    this.issueDate ,
    this.credentialID = '',
    this.url = '',
    this.id = '',
  });

  factory Certification.fromJson(Map<String, dynamic> json) => _$CertificationFromJson(json);
  Map<String, dynamic> toJson() => _$CertificationToJson(this);
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