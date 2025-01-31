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

  // JobModel({
  //   this.id='',
  //   this.companyId='',
  //   required this.employerId,
  //   required this.employerEmail,
  //   required this.title,
  //   required this.description,
  //   required this.requirements,
  //   required this.jobType,
  //   required this.jobLocation,
  //   required this.jobLocationDetails,
  //   required this.employmentType,
  //   required this.experienceLevel,
  //   required this.applicationProcess,
  //   required this.deadline,
  //   required this.status,
  //   required this.applicants,
  //   required this.views,
  //   required this.accessibilityFeatures,
  //   required this.inclusivityStatement,
  //   required this.specialNeeds,
  //   required this.disabilityTypes,
  //   required this.inclusiveHiringPractices,
  // });
  JobModel({
    this.id = '',
    this.companyId='',
    this.employerId='',
    this.employerEmail='',
    this.title='',
    this.description=const JobDescription(),
    this.requirements=const [],
    this.jobType='',
    this.jobLocation='',
    this.jobLocationDetails=const JobLocationDetails(),
    this.employmentType='',
    this.experienceLevel='',
    this.applicationProcess=const ApplicationProcess(),
    this.deadline='',
    this.status='',
    this.applicants=const [],
    this.views=0,
    this.accessibilityFeatures=const AccessibilityFeatures(),
    this.inclusivityStatement='',
    this.specialNeeds=const SpecialNeeds(),
    this.disabilityTypes=const DisabilityTypes(),
    this.inclusiveHiringPractices=const InclusiveHiringPractices()
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

  const JobDescription({
     this.roleOverview='',
     this.responsibilities=const [],
     this.qualifications=const Qualifications(),
     this.benefits=const [],
     this.workEnvironment=const WorkEnvironment(),
     this.companyOverview='',
     this.growthOpportunities='',
     this.salary=const Salary(),
     this.applicationInstructions='',
     this.content='',
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

  const Qualifications({
     this.education='',
     this.experience='',
     this.skills=const [],
     this.certifications=const [],
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

  const WorkEnvironment({
     this.location='',
     this.schedule='',
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

  const Salary({
     this.currency='USD',
     this.min=0,
     this.max=0,
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

  const JobLocationDetails({
     this.address='',
     this.city='',
     this.state='',
     this.country='',
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

  const ApplicationProcess({
     this.steps=const [],
     this.contactEmail='',
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

  const AccessibilityFeatures({
     this.workplaceAccommodations=const [],
     this.communicationSupport='',
     this.disabilityFriendliness='',
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

  const SpecialNeeds({
     this.personalAssistanceAvailable=false,
     this.specialEquipmentProvided=false,
     this.additionalSupportDetails='',
  });

  factory SpecialNeeds.fromJson(Map<String, dynamic> json) => _$SpecialNeedsFromJson(json);
  Map<String, dynamic> toJson() => _$SpecialNeedsToJson(this);
}

@JsonSerializable()
class DisabilityTypes {
  @JsonKey(defaultValue: [])
  final List<String> supportedDisabilities;

  const DisabilityTypes({
     this.supportedDisabilities=const[],
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

  const InclusiveHiringPractices({
     this.blindRecruitment=false,
     this.alternativeInterviewFormats=const[],
  });

  factory InclusiveHiringPractices.fromJson(Map<String, dynamic> json) => _$InclusiveHiringPracticesFromJson(json);
  Map<String, dynamic> toJson() => _$InclusiveHiringPracticesToJson(this);
}