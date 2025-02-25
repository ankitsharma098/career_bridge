// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'candidate_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Candidate _$CandidateFromJson(Map<String, dynamic> json) => Candidate(
      id: json['_id'] as String? ?? '',
      personalInfo: json['personalInfo'] == null
          ? const PersonalInfo()
          : PersonalInfo.fromJson(json['personalInfo'] as Map<String, dynamic>),
      disabilityDetails: json['disabilityDetails'] == null
          ? const DisabilityDetails()
          : DisabilityDetails.fromJson(
              json['disabilityDetails'] as Map<String, dynamic>),
      profileSummary: json['profileSummary'] as String? ?? '',
      about: json['about'] as String? ?? '',
      education: (json['education'] as List<dynamic>?)
              ?.map((e) => Education.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      skills: (json['skills'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      resume: json['resume'] as String? ?? '',
      jobPreferences: json['jobPreferences'] == null
          ? const JobPreferences()
          : JobPreferences.fromJson(
              json['jobPreferences'] as Map<String, dynamic>),
      jobs: json['jobs'] == null
          ? const CandidateJobs()
          : CandidateJobs.fromJson(json['jobs'] as Map<String, dynamic>),
      stories: json['stories'] == null
          ? const UserStories()
          : UserStories.fromJson(json['stories'] as Map<String, dynamic>),
      events: json['events'] == null
          ? const UserEvents()
          : UserEvents.fromJson(json['events'] as Map<String, dynamic>),
      auth: json['auth'] == null
          ? const Auth()
          : Auth.fromJson(json['auth'] as Map<String, dynamic>),
      projects: (json['projects'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      internships: (json['internships'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      workExperience: (json['workExperience'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      certifications: (json['certifications'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      createdAt: json['createdAt'] as String? ?? '',
      updatedAt: json['updatedAt'] as String? ?? '',
      fcmToken: json['fcmToken'] as String? ?? '',
    );

Map<String, dynamic> _$CandidateToJson(Candidate instance) => <String, dynamic>{
      '_id': instance.id,
      'personalInfo': instance.personalInfo,
      'disabilityDetails': instance.disabilityDetails,
      'profileSummary': instance.profileSummary,
      'about': instance.about,
      'education': instance.education,
      'skills': instance.skills,
      'resume': instance.resume,
      'jobPreferences': instance.jobPreferences,
      'jobs': instance.jobs,
      'stories': instance.stories,
      'events': instance.events,
      'auth': instance.auth,
      'projects': instance.projects,
      'internships': instance.internships,
      'workExperience': instance.workExperience,
      'certifications': instance.certifications,
      'createdAt': instance.createdAt,
      'updatedAt': instance.updatedAt,
      'fcmToken': instance.fcmToken,
    };

DisabilityDetails _$DisabilityDetailsFromJson(Map<String, dynamic> json) =>
    DisabilityDetails(
      type: json['type'] as String? ?? '',
      percentage: (json['percentage'] as num?)?.toInt() ?? 0,
      certificateNumber: json['certificateNumber'] as String? ?? '',
      certificateDoc: json['certificateDoc'] as String? ?? '',
      accommodationsNeeded: (json['accommodationsNeeded'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      assistiveTechnology: (json['assistiveTechnology'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
    );

Map<String, dynamic> _$DisabilityDetailsToJson(DisabilityDetails instance) =>
    <String, dynamic>{
      'type': instance.type,
      'percentage': instance.percentage,
      'certificateNumber': instance.certificateNumber,
      'certificateDoc': instance.certificateDoc,
      'accommodationsNeeded': instance.accommodationsNeeded,
      'assistiveTechnology': instance.assistiveTechnology,
    };

Education _$EducationFromJson(Map<String, dynamic> json) => Education(
      degree: json['degree'] as String? ?? '',
      course: json['course'] as String? ?? '',
      courseType: json['courseType'] as String? ?? '',
      specialization: json['specialization'] as String? ?? '',
      institution: json['institution'] as String? ?? '',
      startingYear: json['startingYear'] as String? ?? '',
      passingYear: (json['passingYear'] as num?)?.toInt() ?? 0,
      cgpa: json['cgpa'] as String? ?? '',
      id: json['_id'] as String? ?? '',
    );

Map<String, dynamic> _$EducationToJson(Education instance) => <String, dynamic>{
      'degree': instance.degree,
      'course': instance.course,
      'courseType': instance.courseType,
      'specialization': instance.specialization,
      'institution': instance.institution,
      'startingYear': instance.startingYear,
      'passingYear': instance.passingYear,
      'cgpa': instance.cgpa,
      '_id': instance.id,
    };

JobPreferences _$JobPreferencesFromJson(Map<String, dynamic> json) =>
    JobPreferences(
      industries: (json['industries'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      roles:
          (json['roles'] as List<dynamic>?)?.map((e) => e as String).toList() ??
              [],
      preferredSalary: (json['preferredSalary'] as num?)?.toInt() ?? 0,
      location: (json['location'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      workMode: json['workMode'] as String? ?? '',
      employmentType: (json['employmentType'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      experienceLevel: json['experienceLevel'] as String? ?? '',
    );

Map<String, dynamic> _$JobPreferencesToJson(JobPreferences instance) =>
    <String, dynamic>{
      'industries': instance.industries,
      'roles': instance.roles,
      'preferredSalary': instance.preferredSalary,
      'location': instance.location,
      'workMode': instance.workMode,
      'employmentType': instance.employmentType,
      'experienceLevel': instance.experienceLevel,
    };

CandidateJobs _$CandidateJobsFromJson(Map<String, dynamic> json) =>
    CandidateJobs(
      enrolledJobs: (json['enrolledJobs'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      savedJobs: (json['savedJobs'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
    );

Map<String, dynamic> _$CandidateJobsToJson(CandidateJobs instance) =>
    <String, dynamic>{
      'enrolledJobs': instance.enrolledJobs,
      'savedJobs': instance.savedJobs,
    };
