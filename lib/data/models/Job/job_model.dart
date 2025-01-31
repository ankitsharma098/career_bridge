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

  @JsonKey(defaultValue: '')
  final String overview;

  @JsonKey(defaultValue: '',
      fromJson: _employmentTypeFromJson,
      toJson: _employmentTypeToJson)
  final String employmentType;

  @JsonKey(defaultValue: '',
      fromJson: _experienceLevelFromJson,
      toJson: _experienceLevelToJson)
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

  @JsonKey(defaultValue: [])
  final List<String> skills;

  final LocationDetails location;
  final SalaryDetails salary;
  final DisabilityTypes disabilityTypes;

  @JsonKey(defaultValue: '')
  final String deadline;

  @JsonKey(defaultValue: '',
      fromJson: _statusFromJson,
      toJson: _statusToJson)
  final String status;

  @JsonKey(defaultValue: [])
  final List<String> applicants;

  @JsonKey(defaultValue: 0)
  final int views;

  JobModel({
    this.id = '',
    this.companyId = '',
    this.employerId = '',
    this.employerEmail = '',
    this.title = '',
    this.overview = '',
    this.employmentType = '',
    this.experienceLevel = '',
    this.responsibilities = const [],
    this.qualifications = const [],
    this.benefits = const [],
    this.workspaceAccommodations = '',
    this.interviewAccommodations = '',
    this.skills = const [],
    this.location = const LocationDetails(),
    this.salary = const SalaryDetails(),
    this.disabilityTypes = const DisabilityTypes(),
    this.deadline = '',
    this.status = '',
    this.applicants = const [],
    this.views = 0,
  });

  factory JobModel.fromJson(Map<String, dynamic> json) => _$JobModelFromJson(json);
  Map<String, dynamic> toJson() => _$JobModelToJson(this);

  // Enum conversion methods
  static String _employmentTypeFromJson(String? type) {
    return type ?? '';
  }

  static String _employmentTypeToJson(String type) {
    const validTypes = [
      'Full-time', 'Part-time', 'Internship',
      'Contract', 'Permanent', 'Temporary', 'Freelance'
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

  static String _statusFromJson(String? status) {
    return status ?? '';
  }

  static String _statusToJson(String status) {
    const validStatuses = ['Open', 'Closed', 'Cancelled'];
    return validStatuses.contains(status) ? status : '';
  }
}

@JsonSerializable()
class LocationDetails {
  @JsonKey(defaultValue: '')
  final String type;

  @JsonKey(defaultValue: '')
  final String address;

  @JsonKey(defaultValue: '')
  final String city;

  @JsonKey(defaultValue: '')
  final String state;

  @JsonKey(defaultValue: '')
  final String country;

  @JsonKey(defaultValue: [])
  final List<String> facilityAccessibility;

  const LocationDetails({
    this.type = '',
    this.address = '',
    this.city = '',
    this.state = '',
    this.country = '',
    this.facilityAccessibility = const [],
  });

  factory LocationDetails.fromJson(Map<String, dynamic> json) => _$LocationDetailsFromJson(json);
  Map<String, dynamic> toJson() => _$LocationDetailsToJson(this);
}

@JsonSerializable()
class SalaryDetails {
  @JsonKey(defaultValue: 'Rupees')
  final String currency;

  @JsonKey(defaultValue: 0)
  final int min;

  @JsonKey(defaultValue: 0)
  final int max;

  const SalaryDetails({
    this.currency = 'Rupees',
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