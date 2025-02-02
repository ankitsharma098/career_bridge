// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'application_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

JobApplicationResponse _$JobApplicationResponseFromJson(
        Map<String, dynamic> json) =>
    JobApplicationResponse(
      totalApplications: (json['totalApplications'] as num?)?.toInt() ?? 0,
      applications: (json['applications'] as List<dynamic>?)
              ?.map((e) => Application.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$JobApplicationResponseToJson(
        JobApplicationResponse instance) =>
    <String, dynamic>{
      'totalApplications': instance.totalApplications,
      'applications': instance.applications,
    };

Application _$ApplicationFromJson(Map<String, dynamic> json) => Application(
      id: json['_id'] as String,
      status: json['status'] as String? ?? 'pending',
      appliedDate: DateTime.parse(json['appliedDate'] as String),
      resume: json['resume'] as String? ?? '',
      contactInfo:
          ContactInfo.fromJson(json['contactInfo'] as Map<String, dynamic>),
      isFresher: json['isFresher'] as bool? ?? true,
      experience: (json['experience'] as List<dynamic>)
          .map((e) => Experience.fromJson(e as Map<String, dynamic>))
          .toList(),
      candidateInfo:
          CandidateInfo.fromJson(json['candidateInfo'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ApplicationToJson(Application instance) =>
    <String, dynamic>{
      '_id': instance.id,
      'status': instance.status,
      'appliedDate': instance.appliedDate.toIso8601String(),
      'resume': instance.resume,
      'contactInfo': instance.contactInfo,
      'isFresher': instance.isFresher,
      'experience': instance.experience,
      'candidateInfo': instance.candidateInfo,
    };

ContactInfo _$ContactInfoFromJson(Map<String, dynamic> json) => ContactInfo(
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
    );

Map<String, dynamic> _$ContactInfoToJson(ContactInfo instance) =>
    <String, dynamic>{
      'email': instance.email,
      'phone': instance.phone,
    };

Experience _$ExperienceFromJson(Map<String, dynamic> json) => Experience(
      id: json['_id'] as String,
      designation: json['designation'] as String? ?? '',
      company: json['company'] as String? ?? '',
      duration: json['duration'] as String? ?? '',
      description: json['description'] as String? ?? '',
    );

Map<String, dynamic> _$ExperienceToJson(Experience instance) =>
    <String, dynamic>{
      '_id': instance.id,
      'designation': instance.designation,
      'company': instance.company,
      'duration': instance.duration,
      'description': instance.description,
    };

CandidateInfo _$CandidateInfoFromJson(Map<String, dynamic> json) =>
    CandidateInfo(
      id: json['_id'] as String,
      fullName: json['fullName'] as String? ?? '',
      email: json['email'] as String? ?? '',
      profilePic: json['profilePic'] as String?,
      skills: (json['skills'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
    );

Map<String, dynamic> _$CandidateInfoToJson(CandidateInfo instance) =>
    <String, dynamic>{
      '_id': instance.id,
      'fullName': instance.fullName,
      'email': instance.email,
      'profilePic': instance.profilePic,
      'skills': instance.skills,
    };
