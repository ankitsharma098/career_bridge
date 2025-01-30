// job_model.dart
import 'package:json_annotation/json_annotation.dart';

part 'job_model.g.dart';

@JsonSerializable()
class JobModel {
  @JsonKey(name: '_id', defaultValue: '')
  final String id;

  @JsonKey(defaultValue: '')
  final String companyId;

  @JsonKey(defaultValue: '')
  final String employerId;

  @JsonKey(defaultValue: '')
  final String employerEmail;

  @JsonKey(defaultValue: '')
  final String title;

  final JobDescription description;

  @JsonKey(defaultValue: [])
  final List<String> requirements;

  @JsonKey(defaultValue: '')
  final String jobType;

  @JsonKey(defaultValue: '')
  final String jobLocation;

  final JobLocationDetails jobLocationDetails;

  @JsonKey(defaultValue: '')
  final String employmentType;

  @JsonKey(defaultValue: '')
  final String experienceLevel;

  final ApplicationProcess applicationProcess;

  @JsonKey(defaultValue: '')
  final String deadline;

  @JsonKey(defaultValue: '')
  final String status;

  @JsonKey(defaultValue: [])
  final List<String> applicants;

  @JsonKey(defaultValue: 0)
  final int views;

  final AccessibilityFeatures accessibilityFeatures;

  @JsonKey(defaultValue: '')
  final String inclusivityStatement;

  final SpecialNeeds specialNeeds;

  final DisabilityTypes disabilityTypes;

  final InclusiveHiringPractices inclusiveHiringPractices;

  JobModel({
    required this.id,
    required this.companyId,
    required this.employerId,
    required this.employerEmail,
    required this.title,
    required this.description,
    required this.requirements,
    required this.jobType,
    required this.jobLocation,
    required this.jobLocationDetails,
    required this.employmentType,
    required this.experienceLevel,
    required this.applicationProcess,
    required this.deadline,
    required this.status,
    required this.applicants,
    required this.views,
    required this.accessibilityFeatures,
    required this.inclusivityStatement,
    required this.specialNeeds,
    required this.disabilityTypes,
    required this.inclusiveHiringPractices,
  });

  factory JobModel.fromJson(Map<String, dynamic> json) => _$JobModelFromJson(json);
  Map<String, dynamic> toJson() => _$JobModelToJson(this);
}

@JsonSerializable()
class JobDescription {
  @JsonKey(defaultValue: '')
  final String roleOverview;

  @JsonKey(defaultValue: [])
  final List<String> responsibilities;

  final Qualifications qualifications;

  @JsonKey(defaultValue: [])
  final List<String> benefits;

  final WorkEnvironment workEnvironment;

  @JsonKey(defaultValue: '')
  final String companyOverview;

  @JsonKey(defaultValue: '')
  final String growthOpportunities;

  final Salary salary;

  @JsonKey(defaultValue: '')
  final String applicationInstructions;

  @JsonKey(defaultValue: '')
  final String content;

  JobDescription({
    required this.roleOverview,
    required this.responsibilities,
    required this.qualifications,
    required this.benefits,
    required this.workEnvironment,
    required this.companyOverview,
    required this.growthOpportunities,
    required this.salary,
    required this.applicationInstructions,
    required this.content,
  });

  factory JobDescription.fromJson(Map<String, dynamic> json) => _$JobDescriptionFromJson(json);
  Map<String, dynamic> toJson() => _$JobDescriptionToJson(this);
}

@JsonSerializable()
class Qualifications {
  @JsonKey(defaultValue: '')
  final String education;

  @JsonKey(defaultValue: '')
  final String experience;

  @JsonKey(defaultValue: [])
  final List<String> skills;

  @JsonKey(defaultValue: [])
  final List<String> certifications;

  Qualifications({
    required this.education,
    required this.experience,
    required this.skills,
    required this.certifications,
  });

  factory Qualifications.fromJson(Map<String, dynamic> json) => _$QualificationsFromJson(json);
  Map<String, dynamic> toJson() => _$QualificationsToJson(this);
}

@JsonSerializable()
class WorkEnvironment {
  @JsonKey(defaultValue: '')
  final String location;

  @JsonKey(defaultValue: '')
  final String schedule;

  WorkEnvironment({
    required this.location,
    required this.schedule,
  });

  factory WorkEnvironment.fromJson(Map<String, dynamic> json) => _$WorkEnvironmentFromJson(json);
  Map<String, dynamic> toJson() => _$WorkEnvironmentToJson(this);
}

@JsonSerializable()
class Salary {
  @JsonKey(defaultValue: 'USD')
  final String currency;

  @JsonKey(defaultValue: 0)
  final int min;

  @JsonKey(defaultValue: 0)
  final int max;

  Salary({
    required this.currency,
    required this.min,
    required this.max,
  });

  factory Salary.fromJson(Map<String, dynamic> json) => _$SalaryFromJson(json);
  Map<String, dynamic> toJson() => _$SalaryToJson(this);
}

@JsonSerializable()
class JobLocationDetails {
  @JsonKey(defaultValue: '')
  final String address;

  @JsonKey(defaultValue: '')
  final String city;

  @JsonKey(defaultValue: '')
  final String state;

  @JsonKey(defaultValue: '')
  final String country;

  JobLocationDetails({
    required this.address,
    required this.city,
    required this.state,
    required this.country,
  });

  factory JobLocationDetails.fromJson(Map<String, dynamic> json) => _$JobLocationDetailsFromJson(json);
  Map<String, dynamic> toJson() => _$JobLocationDetailsToJson(this);
}

@JsonSerializable()
class ApplicationProcess {
  @JsonKey(defaultValue: [])
  final List<String> steps;

  @JsonKey(defaultValue: '')
  final String contactEmail;

  ApplicationProcess({
    required this.steps,
    required this.contactEmail,
  });

  factory ApplicationProcess.fromJson(Map<String, dynamic> json) => _$ApplicationProcessFromJson(json);
  Map<String, dynamic> toJson() => _$ApplicationProcessToJson(this);
}

@JsonSerializable()
class AccessibilityFeatures {
  @JsonKey(defaultValue: [])
  final List<String> workplaceAccommodations;

  @JsonKey(defaultValue: '')
  final String communicationSupport;

  @JsonKey(defaultValue: '')
  final String disabilityFriendliness;

  AccessibilityFeatures({
    required this.workplaceAccommodations,
    required this.communicationSupport,
    required this.disabilityFriendliness,
  });

  factory AccessibilityFeatures.fromJson(Map<String, dynamic> json) => _$AccessibilityFeaturesFromJson(json);
  Map<String, dynamic> toJson() => _$AccessibilityFeaturesToJson(this);
}

@JsonSerializable()
class SpecialNeeds {
  @JsonKey(defaultValue: false)
  final bool personalAssistanceAvailable;

  @JsonKey(defaultValue: false)
  final bool specialEquipmentProvided;

  @JsonKey(defaultValue: '')
  final String additionalSupportDetails;

  SpecialNeeds({
    required this.personalAssistanceAvailable,
    required this.specialEquipmentProvided,
    required this.additionalSupportDetails,
  });

  factory SpecialNeeds.fromJson(Map<String, dynamic> json) => _$SpecialNeedsFromJson(json);
  Map<String, dynamic> toJson() => _$SpecialNeedsToJson(this);
}

@JsonSerializable()
class DisabilityTypes {
  @JsonKey(defaultValue: [])
  final List<String> supportedDisabilities;

  DisabilityTypes({
    required this.supportedDisabilities,
  });

  factory DisabilityTypes.fromJson(Map<String, dynamic> json) => _$DisabilityTypesFromJson(json);
  Map<String, dynamic> toJson() => _$DisabilityTypesToJson(this);
}

@JsonSerializable()
class InclusiveHiringPractices {
  @JsonKey(defaultValue: false)
  final bool blindRecruitment;

  @JsonKey(defaultValue: [])
  final List<String> alternativeInterviewFormats;

  InclusiveHiringPractices({
    required this.blindRecruitment,
    required this.alternativeInterviewFormats,
  });

  factory InclusiveHiringPractices.fromJson(Map<String, dynamic> json) => _$InclusiveHiringPracticesFromJson(json);
  Map<String, dynamic> toJson() => _$InclusiveHiringPracticesToJson(this);
}