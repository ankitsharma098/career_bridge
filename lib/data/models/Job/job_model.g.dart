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
      description:
          JobDescription.fromJson(json['description'] as Map<String, dynamic>),
      requirements: (json['requirements'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      jobType: json['jobType'] as String? ?? '',
      jobLocation: json['jobLocation'] as String? ?? '',
      jobLocationDetails: JobLocationDetails.fromJson(
          json['jobLocationDetails'] as Map<String, dynamic>),
      employmentType: json['employmentType'] as String? ?? '',
      experienceLevel: json['experienceLevel'] as String? ?? '',
      applicationProcess: ApplicationProcess.fromJson(
          json['applicationProcess'] as Map<String, dynamic>),
      deadline: json['deadline'] as String? ?? '',
      status: json['status'] as String? ?? '',
      applicants: (json['applicants'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      views: (json['views'] as num?)?.toInt() ?? 0,
      accessibilityFeatures: AccessibilityFeatures.fromJson(
          json['accessibilityFeatures'] as Map<String, dynamic>),
      inclusivityStatement: json['inclusivityStatement'] as String? ?? '',
      specialNeeds:
          SpecialNeeds.fromJson(json['specialNeeds'] as Map<String, dynamic>),
      disabilityTypes: DisabilityTypes.fromJson(
          json['disabilityTypes'] as Map<String, dynamic>),
      inclusiveHiringPractices: InclusiveHiringPractices.fromJson(
          json['inclusiveHiringPractices'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$JobModelToJson(JobModel instance) => <String, dynamic>{
      '_id': instance.id,
      'companyId': instance.companyId,
      'employerId': instance.employerId,
      'employerEmail': instance.employerEmail,
      'title': instance.title,
      'description': instance.description,
      'requirements': instance.requirements,
      'jobType': instance.jobType,
      'jobLocation': instance.jobLocation,
      'jobLocationDetails': instance.jobLocationDetails,
      'employmentType': instance.employmentType,
      'experienceLevel': instance.experienceLevel,
      'applicationProcess': instance.applicationProcess,
      'deadline': instance.deadline,
      'status': instance.status,
      'applicants': instance.applicants,
      'views': instance.views,
      'accessibilityFeatures': instance.accessibilityFeatures,
      'inclusivityStatement': instance.inclusivityStatement,
      'specialNeeds': instance.specialNeeds,
      'disabilityTypes': instance.disabilityTypes,
      'inclusiveHiringPractices': instance.inclusiveHiringPractices,
    };

JobDescription _$JobDescriptionFromJson(Map<String, dynamic> json) =>
    JobDescription(
      roleOverview: json['roleOverview'] as String? ?? '',
      responsibilities: (json['responsibilities'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      qualifications: Qualifications.fromJson(
          json['qualifications'] as Map<String, dynamic>),
      benefits: (json['benefits'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      workEnvironment: WorkEnvironment.fromJson(
          json['workEnvironment'] as Map<String, dynamic>),
      companyOverview: json['companyOverview'] as String? ?? '',
      growthOpportunities: json['growthOpportunities'] as String? ?? '',
      salary: Salary.fromJson(json['salary'] as Map<String, dynamic>),
      applicationInstructions: json['applicationInstructions'] as String? ?? '',
      content: json['content'] as String? ?? '',
    );

Map<String, dynamic> _$JobDescriptionToJson(JobDescription instance) =>
    <String, dynamic>{
      'roleOverview': instance.roleOverview,
      'responsibilities': instance.responsibilities,
      'qualifications': instance.qualifications,
      'benefits': instance.benefits,
      'workEnvironment': instance.workEnvironment,
      'companyOverview': instance.companyOverview,
      'growthOpportunities': instance.growthOpportunities,
      'salary': instance.salary,
      'applicationInstructions': instance.applicationInstructions,
      'content': instance.content,
    };

Qualifications _$QualificationsFromJson(Map<String, dynamic> json) =>
    Qualifications(
      education: json['education'] as String? ?? '',
      experience: json['experience'] as String? ?? '',
      skills: (json['skills'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      certifications: (json['certifications'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
    );

Map<String, dynamic> _$QualificationsToJson(Qualifications instance) =>
    <String, dynamic>{
      'education': instance.education,
      'experience': instance.experience,
      'skills': instance.skills,
      'certifications': instance.certifications,
    };

WorkEnvironment _$WorkEnvironmentFromJson(Map<String, dynamic> json) =>
    WorkEnvironment(
      location: json['location'] as String? ?? '',
      schedule: json['schedule'] as String? ?? '',
    );

Map<String, dynamic> _$WorkEnvironmentToJson(WorkEnvironment instance) =>
    <String, dynamic>{
      'location': instance.location,
      'schedule': instance.schedule,
    };

Salary _$SalaryFromJson(Map<String, dynamic> json) => Salary(
      currency: json['currency'] as String? ?? 'USD',
      min: (json['min'] as num?)?.toInt() ?? 0,
      max: (json['max'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$SalaryToJson(Salary instance) => <String, dynamic>{
      'currency': instance.currency,
      'min': instance.min,
      'max': instance.max,
    };

JobLocationDetails _$JobLocationDetailsFromJson(Map<String, dynamic> json) =>
    JobLocationDetails(
      address: json['address'] as String? ?? '',
      city: json['city'] as String? ?? '',
      state: json['state'] as String? ?? '',
      country: json['country'] as String? ?? '',
    );

Map<String, dynamic> _$JobLocationDetailsToJson(JobLocationDetails instance) =>
    <String, dynamic>{
      'address': instance.address,
      'city': instance.city,
      'state': instance.state,
      'country': instance.country,
    };

ApplicationProcess _$ApplicationProcessFromJson(Map<String, dynamic> json) =>
    ApplicationProcess(
      steps:
          (json['steps'] as List<dynamic>?)?.map((e) => e as String).toList() ??
              [],
      contactEmail: json['contactEmail'] as String? ?? '',
    );

Map<String, dynamic> _$ApplicationProcessToJson(ApplicationProcess instance) =>
    <String, dynamic>{
      'steps': instance.steps,
      'contactEmail': instance.contactEmail,
    };

AccessibilityFeatures _$AccessibilityFeaturesFromJson(
        Map<String, dynamic> json) =>
    AccessibilityFeatures(
      workplaceAccommodations:
          (json['workplaceAccommodations'] as List<dynamic>?)
                  ?.map((e) => e as String)
                  .toList() ??
              [],
      communicationSupport: json['communicationSupport'] as String? ?? '',
      disabilityFriendliness: json['disabilityFriendliness'] as String? ?? '',
    );

Map<String, dynamic> _$AccessibilityFeaturesToJson(
        AccessibilityFeatures instance) =>
    <String, dynamic>{
      'workplaceAccommodations': instance.workplaceAccommodations,
      'communicationSupport': instance.communicationSupport,
      'disabilityFriendliness': instance.disabilityFriendliness,
    };

SpecialNeeds _$SpecialNeedsFromJson(Map<String, dynamic> json) => SpecialNeeds(
      personalAssistanceAvailable:
          json['personalAssistanceAvailable'] as bool? ?? false,
      specialEquipmentProvided:
          json['specialEquipmentProvided'] as bool? ?? false,
      additionalSupportDetails:
          json['additionalSupportDetails'] as String? ?? '',
    );

Map<String, dynamic> _$SpecialNeedsToJson(SpecialNeeds instance) =>
    <String, dynamic>{
      'personalAssistanceAvailable': instance.personalAssistanceAvailable,
      'specialEquipmentProvided': instance.specialEquipmentProvided,
      'additionalSupportDetails': instance.additionalSupportDetails,
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

InclusiveHiringPractices _$InclusiveHiringPracticesFromJson(
        Map<String, dynamic> json) =>
    InclusiveHiringPractices(
      blindRecruitment: json['blindRecruitment'] as bool? ?? false,
      alternativeInterviewFormats:
          (json['alternativeInterviewFormats'] as List<dynamic>?)
                  ?.map((e) => e as String)
                  .toList() ??
              [],
    );

Map<String, dynamic> _$InclusiveHiringPracticesToJson(
        InclusiveHiringPractices instance) =>
    <String, dynamic>{
      'blindRecruitment': instance.blindRecruitment,
      'alternativeInterviewFormats': instance.alternativeInterviewFormats,
    };
