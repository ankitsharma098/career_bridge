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
      resume: json['resume'] == null
          ? const Resume()
          : Resume.fromJson(json['resume'] as Map<String, dynamic>),
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
      auth: json['auth'] == null
          ? const Auth()
          : Auth.fromJson(json['auth'] as Map<String, dynamic>),
      projects: (json['projects'] as List<dynamic>?)
              ?.map((e) => Project.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      internships: (json['internships'] as List<dynamic>?)
              ?.map((e) => Internship.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      workExperience: (json['workExperience'] as List<dynamic>?)
              ?.map((e) => WorkExperience.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      certifications: (json['certifications'] as List<dynamic>?)
              ?.map((e) => Certification.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      createdAt: json['createdAt'] as String? ?? '',
      updatedAt: json['updatedAt'] as String? ?? '',
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
      'auth': instance.auth,
      'projects': instance.projects,
      'internships': instance.internships,
      'workExperience': instance.workExperience,
      'certifications': instance.certifications,
      'createdAt': instance.createdAt,
      'updatedAt': instance.updatedAt,
    };

Resume _$ResumeFromJson(Map<String, dynamic> json) => Resume(
      url: json['url'] as String? ?? '',
      publicId: json['publicId'] as String? ?? '',
    );

Map<String, dynamic> _$ResumeToJson(Resume instance) => <String, dynamic>{
      'url': instance.url,
      'publicId': instance.publicId,
    };

DisabilityDetails _$DisabilityDetailsFromJson(Map<String, dynamic> json) =>
    DisabilityDetails(
      type: json['type'] as String? ?? '',
      percentage: (json['percentage'] as num?)?.toInt() ?? 0,
      certificateNumber: json['certificateNumber'] as String? ?? '',
      certificateDoc: json['certificateDoc'] as String? ?? '',
      preferredCommunicationMethod:
          json['preferredCommunicationMethod'] as String? ?? '',
      publicId: json['publicId'] as String? ?? '',
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
      'publicId': instance.publicId,
      'accommodationsNeeded': instance.accommodationsNeeded,
      'preferredCommunicationMethod': instance.preferredCommunicationMethod,
      'assistiveTechnology': instance.assistiveTechnology,
    };

Education _$EducationFromJson(Map<String, dynamic> json) => Education(
      course: json['course'] as String? ?? '',
      specialization: json['specialization'] as String? ?? '',
      institution: json['institution'] as String? ?? '',
      startingYear: json['startingYear'] == null
          ? null
          : DateTime.parse(json['startingYear'] as String),
      passingYear: json['passingYear'] == null
          ? null
          : DateTime.parse(json['passingYear'] as String),
      CGPA: json['CGPA'] as String? ?? '',
      id: json['_id'] as String? ?? '',
    );

Map<String, dynamic> _$EducationToJson(Education instance) => <String, dynamic>{
      'course': instance.course,
      'specialization': instance.specialization,
      'institution': instance.institution,
      'startingYear': instance.startingYear?.toIso8601String(),
      'passingYear': instance.passingYear?.toIso8601String(),
      'CGPA': instance.CGPA,
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

Project _$ProjectFromJson(Map<String, dynamic> json) => Project(
      projectName: json['projectName'] as String? ?? '',
      startDate: json['startDate'] == null
          ? null
          : DateTime.parse(json['startDate'] as String),
      endDate: json['endDate'] == null
          ? null
          : DateTime.parse(json['endDate'] as String),
      descriptions: json['descriptions'] as String? ?? '',
      skills: (json['skills'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      projectUrl: json['projectUrl'] as String? ?? '',
      id: json['_id'] as String? ?? '',
    );

Map<String, dynamic> _$ProjectToJson(Project instance) => <String, dynamic>{
      'projectName': instance.projectName,
      'startDate': instance.startDate?.toIso8601String(),
      'endDate': instance.endDate?.toIso8601String(),
      'descriptions': instance.descriptions,
      'skills': instance.skills,
      'projectUrl': instance.projectUrl,
      '_id': instance.id,
    };

Internship _$InternshipFromJson(Map<String, dynamic> json) => Internship(
      company: json['company'] as String? ?? '',
      role: json['role'] as String? ?? '',
      startDate: json['startDate'] == null
          ? null
          : DateTime.parse(json['startDate'] as String),
      endDate: json['endDate'] == null
          ? null
          : DateTime.parse(json['endDate'] as String),
      projectName: json['projectName'] as String? ?? '',
      descriptions: json['descriptions'] as String? ?? '',
      skills: (json['skills'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      projectUrl: json['projectUrl'] as String? ?? '',
      id: json['_id'] as String? ?? '',
    );

Map<String, dynamic> _$InternshipToJson(Internship instance) =>
    <String, dynamic>{
      'company': instance.company,
      'role': instance.role,
      'startDate': instance.startDate?.toIso8601String(),
      'endDate': instance.endDate?.toIso8601String(),
      'projectName': instance.projectName,
      'descriptions': instance.descriptions,
      'skills': instance.skills,
      'projectUrl': instance.projectUrl,
      '_id': instance.id,
    };

WorkExperience _$WorkExperienceFromJson(Map<String, dynamic> json) =>
    WorkExperience(
      company: json['company'] as String? ?? '',
      position: json['position'] as String? ?? '',
      startDate: json['startDate'] == null
          ? null
          : DateTime.parse(json['startDate'] as String),
      endDate: json['endDate'] == null
          ? null
          : DateTime.parse(json['endDate'] as String),
      descriptions: json['descriptions'] as String? ?? '',
      id: json['_id'] as String? ?? '',
    );

Map<String, dynamic> _$WorkExperienceToJson(WorkExperience instance) =>
    <String, dynamic>{
      'company': instance.company,
      'position': instance.position,
      'startDate': instance.startDate?.toIso8601String(),
      'endDate': instance.endDate?.toIso8601String(),
      'descriptions': instance.descriptions,
      '_id': instance.id,
    };

Certification _$CertificationFromJson(Map<String, dynamic> json) =>
    Certification(
      name: json['name'] as String? ?? '',
      issuingOrganization: json['issuingOrganization'] as String? ?? '',
      issueDate: json['issueDate'] == null
          ? null
          : DateTime.parse(json['issueDate'] as String),
      credentialID: json['credentialID'] as String? ?? '',
      url: json['url'] as String? ?? '',
      id: json['_id'] as String? ?? '',
    );

Map<String, dynamic> _$CertificationToJson(Certification instance) =>
    <String, dynamic>{
      'name': instance.name,
      'issuingOrganization': instance.issuingOrganization,
      'issueDate': instance.issueDate?.toIso8601String(),
      'credentialID': instance.credentialID,
      'url': instance.url,
      '_id': instance.id,
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
