// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'candidate_job_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CandidateJobModel _$CandidateJobModelFromJson(Map<String, dynamic> json) =>
    CandidateJobModel(
      id: json['_id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      overview: json['overview'] as String? ?? '',
      employmentType: json['employmentType'] == null
          ? ''
          : CandidateJobModel._employmentTypeFromJson(
              json['employmentType'] as String?),
      experienceLevel: json['experienceLevel'] == null
          ? ''
          : CandidateJobModel._experienceLevelFromJson(
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
      status: json['status'] as String? ?? '',
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
      views: (json['views'] as num?)?.toInt() ?? 0,
      companyDetails: json['companyDetails'] == null
          ? const CompanyDetails()
          : CompanyDetails.fromJson(
              json['companyDetails'] as Map<String, dynamic>),
      isSaved: json['isSaved'] as bool? ?? false,
    );

Map<String, dynamic> _$CandidateJobModelToJson(CandidateJobModel instance) =>
    <String, dynamic>{
      '_id': instance.id,
      'title': instance.title,
      'overview': instance.overview,
      'employmentType':
          CandidateJobModel._employmentTypeToJson(instance.employmentType),
      'experienceLevel':
          CandidateJobModel._experienceLevelToJson(instance.experienceLevel),
      'responsibilities': instance.responsibilities,
      'qualifications': instance.qualifications,
      'benefits': instance.benefits,
      'workspaceAccommodations': instance.workspaceAccommodations,
      'interviewAccommodations': instance.interviewAccommodations,
      'status': instance.status,
      'skills': instance.skills,
      'location': instance.location,
      'salary': instance.salary,
      'disabilityTypes': instance.disabilityTypes,
      'deadline': instance.deadline,
      'views': instance.views,
      'companyDetails': instance.companyDetails,
      'isSaved': instance.isSaved,
    };

LocationDetails _$LocationDetailsFromJson(Map<String, dynamic> json) =>
    LocationDetails(
      type: json['type'] as String? ?? '',
      city: json['city'] as String? ?? '',
      address: json['address'] as String? ?? '',
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
      'city': instance.city,
      'address': instance.address,
      'state': instance.state,
      'country': instance.country,
      'facilityAccessibility': instance.facilityAccessibility,
    };

SalaryDetails _$SalaryDetailsFromJson(Map<String, dynamic> json) =>
    SalaryDetails(
      currency: json['currency'] as String? ?? 'USD',
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

CompanyDetails _$CompanyDetailsFromJson(Map<String, dynamic> json) =>
    CompanyDetails(
      companyName: json['companyName'] as String? ?? '',
      website: json['website'] as String? ?? '',
      logo: json['companyLogo'] == null
          ? const CompanyLogo()
          : CompanyLogo.fromJson(json['companyLogo'] as Map<String, dynamic>),
      industryType: json['industryType'] as String? ?? '',
      location: json['location'] == null
          ? const CompanyLocation()
          : CompanyLocation.fromJson(json['location'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$CompanyDetailsToJson(CompanyDetails instance) =>
    <String, dynamic>{
      'companyName': instance.companyName,
      'website': instance.website,
      'companyLogo': instance.logo,
      'industryType': instance.industryType,
      'location': instance.location,
    };

CompanyLogo _$CompanyLogoFromJson(Map<String, dynamic> json) => CompanyLogo(
      url: json['url'] as String? ?? '',
    );

Map<String, dynamic> _$CompanyLogoToJson(CompanyLogo instance) =>
    <String, dynamic>{
      'url': instance.url,
    };

CompanyLocation _$CompanyLocationFromJson(Map<String, dynamic> json) =>
    CompanyLocation(
      country: json['country'] as String? ?? '',
      state: json['state'] as String? ?? '',
      city: json['city'] as String? ?? '',
    );

Map<String, dynamic> _$CompanyLocationToJson(CompanyLocation instance) =>
    <String, dynamic>{
      'country': instance.country,
      'state': instance.state,
      'city': instance.city,
    };
