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
          ? const EmployerCompanyInfo()
          : EmployerCompanyInfo.fromJson(
              json['companyDetails'] as Map<String, dynamic>),
      postedJobs: (json['postedJobs'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      stories: json['stories'] == null
          ? const UserStories()
          : UserStories.fromJson(json['stories'] as Map<String, dynamic>),
      events: json['events'] == null
          ? const UserEvents()
          : UserEvents.fromJson(json['events'] as Map<String, dynamic>),
      about: json['about'] as String? ?? '',
    );

Map<String, dynamic> _$EmployerToJson(Employer instance) => <String, dynamic>{
      '_id': instance.id,
      'personalInfo': instance.personalInfo,
      'companyDetails': instance.companyDetails,
      'postedJobs': instance.postedJobs,
      'stories': instance.stories,
      'events': instance.events,
      'about': instance.about,
    };

PersonalInfo _$PersonalInfoFromJson(Map<String, dynamic> json) => PersonalInfo(
      address: json['address'] as String? ?? '',
      DOB: json['DOB'] == null ? null : DateTime.parse(json['DOB'] as String),
      gender: json['gender'] as String? ?? '',
      fullName: json['fullName'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phoneNumber: json['phoneNumber'] as String? ?? '',
      profilePic: json['profilePic'] as String?,
    );

Map<String, dynamic> _$PersonalInfoToJson(PersonalInfo instance) =>
    <String, dynamic>{
      'fullName': instance.fullName,
      'email': instance.email,
      'profilePic': instance.profilePic,
      'phoneNumber': instance.phoneNumber,
      'address': instance.address,
      'DOB': instance.DOB?.toIso8601String(),
      'gender': instance.gender,
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

UserEvents _$UserEventsFromJson(Map<String, dynamic> json) => UserEvents(
      myEventIds: (json['myEvents'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      savedEventIds: (json['savedEvents'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
    );

Map<String, dynamic> _$UserEventsToJson(UserEvents instance) =>
    <String, dynamic>{
      'myEvents': instance.myEventIds,
      'savedEvents': instance.savedEventIds,
    };

EmployerCompanyInfo _$EmployerCompanyInfoFromJson(Map<String, dynamic> json) =>
    EmployerCompanyInfo(
      companyId: json['companyId'] as String? ?? '',
      designation: json['designation'] as String? ?? '',
    );

Map<String, dynamic> _$EmployerCompanyInfoToJson(
        EmployerCompanyInfo instance) =>
    <String, dynamic>{
      'companyId': instance.companyId,
      'designation': instance.designation,
    };
