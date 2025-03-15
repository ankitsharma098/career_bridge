import 'package:json_annotation/json_annotation.dart';

part 'candidate_job_model.g.dart';

@JsonSerializable()
class CandidateJobModel {
  @JsonKey(name: '_id', defaultValue: '')
  final String id;

  @JsonKey(defaultValue: '')
  final String title;

  @JsonKey(defaultValue: '')
  final String overview;

  @JsonKey(defaultValue: '', fromJson: _employmentTypeFromJson, toJson: _employmentTypeToJson)
  final String employmentType;

  @JsonKey(defaultValue: '', fromJson: _experienceLevelFromJson, toJson: _experienceLevelToJson)
  final String experienceLevel;

  @JsonKey(defaultValue: [])
  final List<String> responsibilities;

  @JsonKey(defaultValue: [])
  final List<String> qualifications;

  @JsonKey(defaultValue: [])
  final List<String> benefits;

  @JsonKey(defaultValue: '')
  final String workspaceAccommodations;

  @JsonKey(defaultValue: '')
  final String interviewAccommodations;

  @JsonKey(defaultValue: '')
  final String status;

  @JsonKey(defaultValue: [])
  final List<String> skills;

  final LocationDetails location;

  final SalaryDetails salary;

  final DisabilityTypes disabilityTypes;

  @JsonKey(defaultValue: '')
  final String deadline;

  @JsonKey(defaultValue: 0)
  final int views;

  final CompanyDetails companyDetails;

  CandidateJobModel({
    this.id = '',
    this.title = '',
    this.overview = '',
    this.employmentType = '',
    this.experienceLevel = '',
    this.responsibilities = const [],
    this.qualifications = const [],
    this.benefits = const [],
    this.workspaceAccommodations = '',
    this.interviewAccommodations = '',
    this.status = '',
    this.skills = const [],
    this.location = const LocationDetails(),
    this.salary = const SalaryDetails(),
    this.disabilityTypes = const DisabilityTypes(),
    this.deadline = '',
    this.views = 0,
    this.companyDetails = const CompanyDetails(),
  });

  factory CandidateJobModel.fromJson(Map<String, dynamic> json) => _$CandidateJobModelFromJson(json);
  Map<String, dynamic> toJson() => _$CandidateJobModelToJson(this);

  // Enum conversion methods
  static String _employmentTypeFromJson(String? type) {
    return type ?? '';
  }

  static String _employmentTypeToJson(String type) {
    const validTypes = [
      'Full-time',
      'Part-time',
      'Internship',
      'Contract',
      'Permanent',
      'Temporary',
      'Freelance'
    ];
    return validTypes.contains(type) ? type : '';
  }

  static String _experienceLevelFromJson(String? level) {
    return level ?? '';
  }

  static String _experienceLevelToJson(String level) {
    const validLevels = ['Freshers', 'Intermediate', 'Professional'];
    return validLevels.contains(level) ? level : '';
  }
}

@JsonSerializable()
class LocationDetails {
  @JsonKey(defaultValue: '')
  final String type;

  @JsonKey(defaultValue: '')
  final String city;


  @JsonKey(defaultValue: '')
  final String address;

  @JsonKey(defaultValue: '')
  final String state;

  @JsonKey(defaultValue: '')
  final String country;

  @JsonKey(defaultValue: [])
  final List<String> facilityAccessibility;

  const LocationDetails({
    this.type = '',
    this.city = '',
    this.address = '',
    this.state = '',
    this.country = '',
    this.facilityAccessibility = const [],
  });

  factory LocationDetails.fromJson(Map<String, dynamic> json) => _$LocationDetailsFromJson(json);
  Map<String, dynamic> toJson() => _$LocationDetailsToJson(this);
}

@JsonSerializable()
class SalaryDetails {
  @JsonKey(defaultValue: 'USD')
  final String currency;

  @JsonKey(defaultValue: 0)
  final int min;

  @JsonKey(defaultValue: 0)
  final int max;

  const SalaryDetails({
    this.currency = 'USD',
    this.min = 0,
    this.max = 0,
  });

  factory SalaryDetails.fromJson(Map<String, dynamic> json) => _$SalaryDetailsFromJson(json);
  Map<String, dynamic> toJson() => _$SalaryDetailsToJson(this);
}

@JsonSerializable()
class DisabilityTypes {
  @JsonKey(defaultValue: [])
  final List<String> supportedDisabilities;

  const DisabilityTypes({
    this.supportedDisabilities = const [],
  });

  factory DisabilityTypes.fromJson(Map<String, dynamic> json) => _$DisabilityTypesFromJson(json);
  Map<String, dynamic> toJson() => _$DisabilityTypesToJson(this);
}

@JsonSerializable()
class CompanyDetails {
  @JsonKey(defaultValue: '')
  final String companyName;

  @JsonKey(defaultValue: '')
  final String website;

  @JsonKey(name: 'companyLogo')
  final CompanyLogo logo;

  @JsonKey(defaultValue: '')
  final String industryType;

  final CompanyLocation location;

  const CompanyDetails({
    this.companyName = '',
    this.website = '',
    this.logo = const CompanyLogo(),
    this.industryType = '',
    this.location = const CompanyLocation(),
  });

  factory CompanyDetails.fromJson(Map<String, dynamic> json) => _$CompanyDetailsFromJson(json);
  Map<String, dynamic> toJson() => _$CompanyDetailsToJson(this);
}

@JsonSerializable()
class CompanyLogo {
  @JsonKey(defaultValue: '')
  final String url;

  const CompanyLogo({
    this.url = '',
  });

  factory CompanyLogo.fromJson(Map<String, dynamic> json) => _$CompanyLogoFromJson(json);
  Map<String, dynamic> toJson() => _$CompanyLogoToJson(this);
}

@JsonSerializable()
class CompanyLocation {
  @JsonKey(defaultValue: '')
  final String country;

  @JsonKey(defaultValue: '')
  final String state;

  @JsonKey(defaultValue: '')
  final String city;

  const CompanyLocation({
    this.country = '',
    this.state = '',
    this.city = '',
  });

  factory CompanyLocation.fromJson(Map<String, dynamic> json) => _$CompanyLocationFromJson(json);
  Map<String, dynamic> toJson() => _$CompanyLocationToJson(this);
}