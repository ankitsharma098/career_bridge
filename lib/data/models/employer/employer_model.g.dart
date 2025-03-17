// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'employer_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Employer _$EmployerFromJson(Map<String, dynamic> json) => Employer(
      id: json['_id'] as String? ?? '',
      personalInfo: json['personalInfo'] == null
          ? const PersonalInfo()
          : PersonalInfo.fromJson(json['personalInfo'] as Map<String, dynamic>),
      companyDetails: json['companyDetails'] == null
          ? const MinimalCompanyDetails()
          : MinimalCompanyDetails.fromJson(
              json['companyDetails'] as Map<String, dynamic>),
      postedJobs: (json['postedJobs'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      stories: json['stories'] == null
          ? const UserStories()
          : UserStories.fromJson(json['stories'] as Map<String, dynamic>),
      auth: json['auth'] == null
          ? const Auth()
          : Auth.fromJson(json['auth'] as Map<String, dynamic>),
      role: json['role'] as String? ?? '',
      about: json['about'] as String? ?? '',
      createdAt: json['createdAt'] as String? ?? '',
      updatedAt: json['updatedAt'] as String? ?? '',
    );

Map<String, dynamic> _$EmployerToJson(Employer instance) => <String, dynamic>{
      '_id': instance.id,
      'personalInfo': instance.personalInfo,
      'companyDetails': instance.companyDetails,
      'postedJobs': instance.postedJobs,
      'stories': instance.stories,
      'auth': instance.auth,
      'role': instance.role,
      'about': instance.about,
      'createdAt': instance.createdAt,
      'updatedAt': instance.updatedAt,
    };

PersonalInfo _$PersonalInfoFromJson(Map<String, dynamic> json) => PersonalInfo(
      fullName: json['fullName'] as String? ?? '',
      email: json['email'] as String? ?? '',
      profilePic: json['profilePic'] as String? ?? '',
      publicId: json['publicId'] as String? ?? '',
      phoneNumber: json['phoneNumber'] as String? ?? '',
      address: json['address'] as String? ?? '',
      dob:json['DOB'] == null ? null : DateTime.parse(json['DOB']),
      gender: json['gender'] as String? ?? 'Male',
    );

Map<String, dynamic> _$PersonalInfoToJson(PersonalInfo instance) =>
    <String, dynamic>{
      'fullName': instance.fullName,
      'email': instance.email,
      'profilePic': instance.profilePic,
      'publicId': instance.publicId,
      'phoneNumber': instance.phoneNumber,
      'address': instance.address,
      'dob': instance.dob?.toIso8601String(),
      'gender': instance.gender,
    };

MinimalCompanyDetails _$MinimalCompanyDetailsFromJson(
        Map<String, dynamic> json) =>
    MinimalCompanyDetails(
      companyId: json['companyId'] as String? ?? '',
      designation: json['designation'] as String? ?? '',
    );

Map<String, dynamic> _$MinimalCompanyDetailsToJson(
        MinimalCompanyDetails instance) =>
    <String, dynamic>{
      'companyId': instance.companyId,
      'designation': instance.designation,
    };

UserStories _$UserStoriesFromJson(Map<String, dynamic> json) => UserStories(
      myStoryIds: (json['myStories'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      savedStoryIds: (json['savedStories'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
    );

Map<String, dynamic> _$UserStoriesToJson(UserStories instance) =>
    <String, dynamic>{
      'myStories': instance.myStoryIds,
      'savedStories': instance.savedStoryIds,
    };

Auth _$AuthFromJson(Map<String, dynamic> json) => Auth(
      verified: json['verified'] as bool? ?? false,
      status: json['status'] as String? ?? '',
    );

Map<String, dynamic> _$AuthToJson(Auth instance) => <String, dynamic>{
      'verified': instance.verified,
      'status': instance.status,
    };
