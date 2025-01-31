// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'job_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

JobModel _$JobModelFromJson(Map<String, dynamic> json) => JobModel(
      id: json['_id'] as String? ?? '',
      companyId: json['companyId'] as String? ?? '',
      employerId: json['employerId'] as String? ?? '',
      employerEmail: json['employerEmail'] as String? ?? '',
      title: json['title'] as String? ?? '',
      overview: json['overview'] as String? ?? '',
      employmentType: json['employmentType'] == null
          ? ''
          : JobModel._employmentTypeFromJson(json['employmentType'] as String?),
      experienceLevel: json['experienceLevel'] == null
          ? ''
          : JobModel._experienceLevelFromJson(
              json['experienceLevel'] as String?),
      responsibilities: (json['responsibilities'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      qualifications: (json['qualifications'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      benefits: (json['benefits'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      workspaceAccommodations: json['workspaceAccommodations'] as String? ?? '',
      interviewAccommodations: json['interviewAccommodations'] as String? ?? '',
      skills: (json['skills'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      location: json['location'] == null
          ? const LocationDetails()
          : LocationDetails.fromJson(json['location'] as Map<String, dynamic>),
      salary: json['salary'] == null
          ? const SalaryDetails()
          : SalaryDetails.fromJson(json['salary'] as Map<String, dynamic>),
      disabilityTypes: json['disabilityTypes'] == null
          ? const DisabilityTypes()
          : DisabilityTypes.fromJson(
              json['disabilityTypes'] as Map<String, dynamic>),
      deadline: json['deadline'] as String? ?? '',
      status: json['status'] == null
          ? ''
          : JobModel._statusFromJson(json['status'] as String?),
      applicants: (json['applicants'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      views: (json['views'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$JobModelToJson(JobModel instance) => <String, dynamic>{
      '_id': instance.id,
      'companyId': instance.companyId,
      'employerId': instance.employerId,
      'employerEmail': instance.employerEmail,
      'title': instance.title,
      'overview': instance.overview,
      'employmentType': JobModel._employmentTypeToJson(instance.employmentType),
      'experienceLevel':
          JobModel._experienceLevelToJson(instance.experienceLevel),
      'responsibilities': instance.responsibilities,
      'qualifications': instance.qualifications,
      'benefits': instance.benefits,
      'workspaceAccommodations': instance.workspaceAccommodations,
      'interviewAccommodations': instance.interviewAccommodations,
      'skills': instance.skills,
      'location': instance.location,
      'salary': instance.salary,
      'disabilityTypes': instance.disabilityTypes,
      'deadline': instance.deadline,
      'status': JobModel._statusToJson(instance.status),
      'applicants': instance.applicants,
      'views': instance.views,
    };

LocationDetails _$LocationDetailsFromJson(Map<String, dynamic> json) =>
    LocationDetails(
      type: json['type'] as String? ?? '',
      address: json['address'] as String? ?? '',
      city: json['city'] as String? ?? '',
      state: json['state'] as String? ?? '',
      country: json['country'] as String? ?? '',
      facilityAccessibility: (json['facilityAccessibility'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
    );

Map<String, dynamic> _$LocationDetailsToJson(LocationDetails instance) =>
    <String, dynamic>{
      'type': instance.type,
      'address': instance.address,
      'city': instance.city,
      'state': instance.state,
      'country': instance.country,
      'facilityAccessibility': instance.facilityAccessibility,
    };

SalaryDetails _$SalaryDetailsFromJson(Map<String, dynamic> json) =>
    SalaryDetails(
      currency: json['currency'] as String? ?? 'Rupees',
      min: (json['min'] as num?)?.toInt() ?? 0,
      max: (json['max'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$SalaryDetailsToJson(SalaryDetails instance) =>
    <String, dynamic>{
      'currency': instance.currency,
      'min': instance.min,
      'max': instance.max,
    };

DisabilityTypes _$DisabilityTypesFromJson(Map<String, dynamic> json) =>
    DisabilityTypes(
      supportedDisabilities: (json['supportedDisabilities'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
    );

Map<String, dynamic> _$DisabilityTypesToJson(DisabilityTypes instance) =>
    <String, dynamic>{
      'supportedDisabilities': instance.supportedDisabilities,
    };
